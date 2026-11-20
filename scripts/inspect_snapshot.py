"""Inspect the supplied MAT snapshot with NumPy/SciPy, independently of MATLAB.

Usage: python scripts/inspect_snapshot.py --output data/data_inventory.json
The schedule check assumes one passenger per request and return to the vehicle's
starting depot. All quantities are read from the input MAT file.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
from scipy.io import loadmat, whosmat

ROOT = Path(__file__).resolve().parents[1]


def scalar(data, key):
    return float(data[key].item())


def inspect(path):
    data = loadmat(path)
    demand = int(scalar(data, "demand"))
    vehicles = int(scalar(data, "vhcnum"))
    transfers = int(scalar(data, "tsNum"))
    depots = int(scalar(data, "depotNum"))
    nodes = 2*demand + transfers + depots
    expected_shapes = {
        "timematrix": (nodes, nodes), "distancematrix": (nodes, nodes),
        "allLocation": (nodes, 2), "demandstarttime": (demand, 2),
        "demandendtime": (demand, 2), "vhcdemandtimematrix": (vehicles, nodes),
        "inisolution1": (vehicles, 1), "vhccapacity": (vehicles, 1),
    }
    for key, expected in expected_shapes.items():
        if data[key].shape != expected:
            raise ValueError(f"{key}: expected {expected}, got {data[key].shape}")
    routes = [value.reshape(-1).astype(int) for value in data["inisolution1"].reshape(-1)]
    route_nodes = np.concatenate(routes)
    if np.any((route_nodes < 1) | (route_nodes > 2*demand)):
        raise ValueError("This snapshot inspector expects direct initial routes without transfer nodes.")
    pickups = route_nodes[route_nodes <= demand]
    deliveries = route_nodes[route_nodes > demand] - demand
    missing = sorted(set(range(1, demand+1)) - set(pickups))
    rejected = data["inireject1"].reshape(-1).astype(int)
    capacity_errors, precedence_errors, window_errors, return_errors, driving_errors = [], [], [], [], []
    for vehicle, route in enumerate(routes):
        if not route.size:
            continue
        loads = np.cumsum(np.where(route <= demand, 1, -1))
        if np.any(loads < 0) or np.max(loads) > data["vhccapacity"][vehicle, 0] or loads[-1] != 0:
            capacity_errors.append(vehicle+1)
        for position, node in enumerate(route):
            if node > demand and node-demand not in route[:position]:
                precedence_errors.append({"vehicle": vehicle+1, "node": int(node)})
        clock = data["vhcstarttime"][vehicle, 0] + data["vhcdemandtimematrix"][vehicle, route[0]-1]
        for position, node in enumerate(route):
            if position:
                clock += data["timematrix"][route[position-1]-1, node-1]
            lower, upper = data["demandtime"][node-1]
            clock = max(clock, lower)
            if clock > upper + 1e-9:
                window_errors.append({"vehicle": vehicle+1, "node": int(node),
                                      "service_start": float(clock), "latest": float(upper)})
            clock += scalar(data, "op")
        clock += data["vhcdemandtimematrix"][vehicle, route[-1]-1]
        latest = data["vhcendtime"][vehicle, 1]
        if clock > latest + 1e-9:
            return_errors.append({"vehicle": vehicle+1, "return_time": float(clock),
                                  "latest": float(latest), "excess_minutes": float(clock-latest)})
        driving = (data["vhcdemandtimematrix"][vehicle, route[0]-1]
                   + sum(data["timematrix"][u-1, v-1] for u, v in zip(route, route[1:]))
                   + data["vhcdemandtimematrix"][vehicle, route[-1]-1])
        if driving > scalar(data, "TravelTimeMax") + 1e-9:
            driving_errors.append({"vehicle": vehicle+1, "driving_minutes": float(driving),
                                   "maximum": scalar(data, "TravelTimeMax")})
    scalars = {key: float(value.item()) for key, value in data.items()
               if isinstance(value, np.ndarray) and value.shape == (1, 1)
               and np.issubdtype(value.dtype, np.number)}
    return {
        "source": {"file": path.name, "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                   "mat_header": data["__header__"].decode("gb18030"),
                   "bytes": path.stat().st_size},
        "variables": [{"name": name, "shape": list(shape), "matlab_class": cls}
                      for name, shape, cls in whosmat(path)],
        "scalar_parameters": scalars,
        "dimensions": {"requests": demand, "vehicles": vehicles, "transfer_stations": transfers,
                       "depots": depots, "nodes": nodes},
        "vehicle_types": [{"type": int(kind), "count": int(np.sum(data["vhctype"] == kind)),
                           "capacity": int(data["vhccapacity"][np.flatnonzero(data["vhctype"] == kind)[0], 0])}
                          for kind in np.unique(data["vhctype"])],
        "initial_routes": {"active_vehicles": sum(bool(route.size) for route in routes),
                           "empty_vehicles": sum(not route.size for route in routes),
                           "pickup_count": int(pickups.size), "unique_pickups": int(np.unique(pickups).size),
                           "delivery_count": int(deliveries.size), "unique_deliveries": int(np.unique(deliveries).size),
                           "pickup_delivery_sets_equal": set(pickups) == set(deliveries),
                           "missing_request_count": len(missing), "rejected_request_count": int(rejected.size),
                           "missing_matches_rejected": set(missing) == set(rejected),
                           "capacity_error_vehicles": capacity_errors, "precedence_errors": precedence_errors,
                           "customer_window_errors": window_errors, "depot_return_errors": return_errors,
                           "driving_time_errors": driving_errors},
        "matrix_checks": {
            "maximum_asymmetry": float(np.max(abs(data["timematrix"]-data["timematrix"].T))),
            "maximum_diagonal": float(np.max(abs(np.diag(data["timematrix"])))),
            "time_equals_twice_distance_maximum_error": float(np.max(abs(data["timematrix"]-2*data["distancematrix"]))),
            "vehicle_matrix_matches_depot_rows_maximum_error": float(np.max(abs(
                data["vhcdemandtimematrix"]-data["timematrix"][data["vhcdepot"].reshape(-1).astype(int)-1, :]))),
        },
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path, default=ROOT / "initial0805_concentrate.mat")
    parser.add_argument("--output", type=Path)
    parser.add_argument("--metadata-only", action="store_true",
                        help="Export the input schema and route counts without diagnostic findings.")
    args = parser.parse_args()
    report = inspect(args.input.resolve())
    if args.metadata_only:
        report = {key: report[key] for key in (
            "source", "variables", "scalar_parameters", "dimensions", "vehicle_types", "initial_routes")}
        count_keys = ("active_vehicles", "empty_vehicles", "pickup_count", "unique_pickups",
                      "delivery_count", "unique_deliveries", "missing_request_count", "rejected_request_count")
        report["initial_routes"] = {key: report["initial_routes"][key] for key in count_keys}
    text = json.dumps(report, indent=2, ensure_ascii=False) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(text, encoding="utf-8")
        initial = report["initial_routes"]
        print(f"Wrote {args.output}: {initial['unique_pickups']} served requests, "
              f"{initial['missing_request_count']} rejected.")
        if not args.metadata_only:
            print(f"{len(initial['depot_return_errors'])} depot-return violations, "
                  f"{len(initial['driving_time_errors'])} driving-time violations.")
    else:
        print(text, end="")


if __name__ == "__main__":
    main()
