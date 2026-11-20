# Data and route conventions

Start with `make_demo_instance`, adapt its fields, and pass the resulting structure to `MDVRPTW`. This guide defines the options, input schema and saved files.

## Calling the solver

```matlab
data = make_demo_instance();
result = MDVRPTW(data,struct('MaxIterations',5,'Seed',7));
```

`MDVRPTW` returns results in memory. Its options are:

| Option | Default | Meaning |
| --- | --- | --- |
| `MaxIterations` | `10` | Nonnegative integer; `0` evaluates the initial routes without searching |
| `Neighbors` | `3` | Positive integer number of candidates per iteration |
| `Seed` | `7` | Integer from 0 to `2^32-1`; initializes the random generator for this call |
| `EnableTransfers` | `false` | Enables the [transfer-candidate research interface](MODEL.md#transfer-candidate-interface) |
| `Verbose` | `false` | Prints search progress when true |
| `OutputDir` | `''` | Empty for memory-only results; otherwise saves files in this directory |

`run_demo` uses the same options with defaults of five iterations and an output
directory at `results/demo` inside the repository. Each call restores the caller's
random-generator state. A fixed seed repeats the search on the same runtime;
different MATLAB and Octave versions can produce different random sequences.

From another working folder, add the repository root with `addpath`. Supplied
relative MAT-file paths and relative output directories resolve from the current
working folder. The default research MAT file and `run_demo`'s default output
directory resolve from the repository location.

### Saving and reloading

To save an instance and run it again:

```matlab
data = make_demo_instance();
save('my-instance.mat','data','-v7');
result = MDVRPTW('my-instance.mat',struct('MaxIterations',5));
```

For a flat MAT workspace, use `save('my-instance.mat','-struct','data','-v7')`.
The input structure's initial routes determine the served request set.

## MATLAB input structure

The runner accepts a scalar instance structure or a MAT-file path. A MAT file can
store the input fields as top-level variables, or contain one scalar structure
named `data`, as exported by `run_demo`. Each request represents one passenger.
Times are minutes; the supplied matrix uses `timematrix = 2 * distancematrix`,
corresponding to 0.5 km/min when distance is kilometres.

| Field | Shape / interpretation |
| --- | --- |
| `demand`, `vhcnum` | Positive integer request and vehicle counts |
| `tsNum`, `depotNum` | Optional counts; inferred from the node IDs when omitted |
| `demandstarttime`, `demandendtime` | `demand × 2`; earliest and latest service-start time |
| `vhcstarttime`, `vhcendtime` | `vhcnum × 2`; existing code uses departure column 1 and return deadline column 2 |
| `timematrix` | `N × N`, row = origin and column = destination |
| `vhcdemandtimematrix` | `vhcnum × N`, travel from each vehicle's starting depot to every node; also used for return travel |
| `vhcdepot` | `vhcnum × 1`; starting-depot node IDs |
| `vhccapacity` | `vhcnum × 1`; positive integer passenger capacities |
| `fixedcost`, `cwk`, `ctk` | `vhcnum × 1`; fixed, waiting-per-minute and operating-per-minute coefficients |
| `TS` | Row vector of transfer-station node IDs |
| `depotendtime` | Optional rows `[depotID closingTime]`; when supplied, include every vehicle depot exactly once |
| `op`, `tsop` | Nonnegative customer and transfer-station service durations |
| `TravelTimeMax` | Positive driving-time bound, including outbound and return depot legs |
| `inisolution1` | `vhcnum × 1` cell array; each cell is a row vector of route node IDs |
| `inireject1` | Request IDs omitted from the initial solution |
| `tabulength`, `lambda` | Maximum tabu-memory entries and operator adaptation segment length |
| `alpha1`, `alpha2`, `alpha3`, `r` | Nonnegative operator rewards and adaptation coefficient `0 ≤ r ≤ 1` |
| `SetTsMax`, `EachOptionMax` | Transfer candidate-search limits |

The saved `maxiteration = 100` and `neignum = 10` describe the historical workspace.
The runner uses its explicit `MaxIterations` and `Neighbors` options (defaults 10
and 3). The snapshot also includes locations, distance matrices, historical loop
variables and history cells. The runner uses its own search state.

The required fields are `demand`, `vhcnum`, `inisolution1`, the four time-window
arrays, both travel-time matrices, `vhccapacity`, `fixedcost`, `cwk`, `ctk` and
`vhcdepot`. Omitted controls receive the following defaults; values present in
the supplied structure or MAT file take precedence.

| Optional instance fields | Defaults |
| --- | --- |
| `op`, `tsop` | 2 and 3 minutes |
| `TravelTimeMax` | 480 minutes |
| `tabulength`, `lambda` | 30 entries and 100 iterations |
| `alpha1`, `alpha2`, `alpha3`, `r` | 33, 9, 13 and 0.1 |
| `SetTsMax`, `EachOptionMax` | 16 and 8 |
| `TS`, `depotendtime` | Empty arrays |
| `inireject1`, `tsNum`, `depotNum` | Derived from route coverage and node IDs |

For `D = demand`, the supplied case uses:

- `1:D`: pickups.
- `D+1:2*D`: deliveries; delivery `D+r` belongs to request `r`.
- `2*D+1:2*D+tsNum`: transfer stations.
- Remaining IDs: depots.

Custom instances specify transfer IDs in `TS`; all other IDs above `2*D` are
depots. Pickup, delivery, transfer and depot ID sets are disjoint. Depot visits
are implicit in route vectors. A return must meet both the vehicle deadline and
the depot closing time when a closing time is supplied.

Route vectors contain customer and transfer visits.
A transfer route can hand off a request whose pickup appears without its delivery,
or receive a request whose delivery appears without its pickup. The transfer search
uses one transfer visit per route and paired vehicles. `ValidateSolution` checks
request coverage, handoff station identity and pickup-before-handoff-before-delivery
order. Transfer arrival times use independent vehicle clocks; synchronized handoffs
and their waiting costs are outside this evaluator.

The supplied matrices are symmetric. Intercustomer travel may be directed. Depot
travel must agree in both directions with `vhcdemandtimematrix`; the loader checks
this condition. Separate outbound and inbound depot matrices are outside this interface.

## Synthetic example

[`make_demo_instance.m`](../make_demo_instance.m) constructs six requests, three
vehicles with capacities 2/3/4, two transfer stations and two depots. Coordinates,
time windows and an initially feasible set of three direct routes are explicit in
that file. It needs no spreadsheet, MAT-file or toolbox. `run_demo` runs the search
with transfers disabled by default.

## Solver output

`MDVRPTW` returns the initial and best scores, best and final routes, request coverage,
feasibility details, operator weights and the objective history. With `OutputDir`
set, the files are:

| File | Contents |
| --- | --- |
| `result.mat` | One structure named `result` |
| `history.csv` | Numeric rows `[iteration, currentScore, bestScore]`; no header; starts at iteration zero |
| `routes.csv` | Header `vehicle,position,node`, followed by the best solution's visits; implicit depot legs are omitted |
| `instance.mat` | Added by `run_demo`; one reusable structure named `data` |

Each iteration contributes one history row even if no move is accepted. The
current score can increase; the best score never increases. Files with these names
are replaced when the same output directory is reused.

From the repository root, reload a saved result or rerun its input with:

```matlab
saved = load(fullfile('results','demo','result.mat'));
saved.result.bestSolution
result = MDVRPTW(fullfile('results','demo','instance.mat'), ...
    struct('MaxIterations',5,'OutputDir',''));
```

`result.objective` contains the best solution's components in the order below.
`result.initialObjective` uses the same order for the starting routes. The definitions of
`C`, `Q` and the deviations are given in the [model reference](MODEL.md#objective).

| Position | Component |
| ---: | --- |
| 1 | Score: `(C + Q) / 1000` |
| 2 | Weighted total: `C + Q` |
| 3 | Weighted cost: `C` |
| 4 | Fixed cost |
| 5 | Vehicle duration cost |
| 6 | Passenger onboard waiting cost |
| 7 | Vehicle waiting cost |
| 8 | Weighted service quality: `Q` |
| 9 | `10 * pickup_deviation` |
| 10 | `8 * delivery_deviation` |
| 11 | `2 * journey_time_deviation` |

## Supplied snapshot

`initial0805_concentrate.mat` is a MATLAB v5 workspace whose header records
5 August 2021. Its SHA-256 is
`1ef298609504341dcd2097f8c0b05985f7d87c413a19d55f805b8b2c991cfff4`.
The [machine-readable inventory](../data/data_inventory.json) lists every variable
including dimensions and MATLAB types.

| Item | Value |
| --- | ---: |
| Requests | 500 |
| Vehicles | 170 |
| Transfer stations | 3 |
| Depots | 5 |
| Node count | 1,008 |
| Vehicle capacities and counts | 4 seats × 35; 8 × 45; 12 × 45; 16 × 45 |
| Initial active / empty routes | 153 / 17 |
| Initial served / rejected requests | 396 / 104 |

The 104 request IDs absent from the routes match `inireject1`. The initial routes
have one pickup and one delivery for each served request, valid pickup-before-delivery
order and unit-passenger loads within capacity. They contain no transfer visits.

The stored routes are an evaluation input. Use
`MDVRPTW([],struct('MaxIterations',0))` to obtain their score and constraint report
in `result.validation`. Optimization requires a feasible initial solution;
[`make_demo_instance`](../make_demo_instance.m) supplies the runnable synthetic case.

## Historical spreadsheet dependencies

The main snapshot path does not need Excel. Historical preprocessing and reporting
scripts reference workbooks and result workspaces that are absent from this repository,
including `result0731_right.xlsx`, `vechleinfomation0730_1000.xlsx`,
`passengerdemand_result1.xlsx`, `vehcleinfomation.xlsx`, `gams0805.xlsx`,
`longtitude_and_latitude0415.xlsx`, `use.xlsx`, `x0802_7.xlsx`, `gams10.mat`,
`solution.mat` and dated `solution*.mat` files. Their column ranges remain visible
in `legacy/unused/`.

## Data inventory

With Python, NumPy and SciPy installed:

```sh
python scripts/inspect_snapshot.py --metadata-only --output data/data_inventory.json
```

This command writes variable dimensions, parameters, vehicle types and route counts.
Omit `--metadata-only` to inspect route coverage, capacity and time constraints.
