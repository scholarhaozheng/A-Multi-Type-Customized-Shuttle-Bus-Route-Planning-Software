# Routing model and objective

The solver optimizes a supplied set of shuttle routes using ALNS and Tabu Search. Each request represents one passenger, with one pickup and one delivery. Vehicles have individual capacities, cost coefficients, departure times and return deadlines.

## Routes and constraints

Each vehicle starts empty and returns to its assigned depot. The search preserves the initial set of served requests; other request IDs are returned in `unservedRequests`. Depot visits are implicit in the route vectors.

| Constraint | Definition |
| --- | --- |
| Request coverage | Exactly one pickup and one delivery for each served request |
| Order | Pickup precedes delivery on a direct route |
| Capacity | Passenger load stays between zero and the vehicle capacity |
| Customer windows | Service starts within the pickup or delivery window |
| Return windows | Depot return meets the vehicle deadline and any supplied depot closing time |
| Driving time | Travel between stops plus both depot legs is at most `TravelTimeMax` |

`ValidateSolution` checks coverage and route constraints. The default search uses direct-service routes (`EnableTransfers=false`). Input fields, node IDs and output components are defined in [DATA.md](DATA.md).

## Time convention

`RouteSchedule` computes the earliest service-start time at each customer as the maximum of physical arrival and the lower window bound. Service duration is added before travel to the next node. Return time includes service at the last stop and the final depot leg.

`TravelTimeMax` bounds driving time. Waiting and service contribute to elapsed route time and the objective. Intercustomer travel may be directed; the depot-time interface uses equal outbound and return travel for each depot–node pair.

## Objective

`calculatetotalcost_test` returns a weighted score:

```text
C = 0.15 * fixed_cost
  + 0.25 * vehicle_duration_cost
  + 0.30 * passenger_onboard_waiting_cost
  + 0.30 * vehicle_waiting_cost

Q = 0.40 * (10 * pickup_deviation)
  + 0.40 * ( 8 * delivery_deviation)
  + 0.20 * ( 2 * journey_time_deviation)

score = (C + Q) / 1000
```

The components are summed over active vehicles and their served requests:

- **Fixed cost:** the vehicle's `fixedcost`.
- **Vehicle duration cost:** `ctk` multiplied by elapsed time from departure to depot return, including driving, service and early-arrival waiting.
- **Passenger onboard waiting cost:** three times the sum of early-arrival waiting minutes multiplied by the load already onboard.
- **Vehicle waiting cost:** `cwk` multiplied by early-arrival waiting minutes.
- **Pickup deviation:** absolute difference between service start and the midpoint of the pickup window.
- **Delivery deviation:** absolute difference between service start and the lower bound of the delivery window.
- **Journey-time deviation:** absolute difference between pickup-to-delivery service-start duration and direct travel time, for requests whose endpoints are on the same route.

The weighted score and its components are returned in `result.objective`; their order is documented in [DATA.md](DATA.md#solver-output).

## Transfer-candidate interface

`EnableTransfers=true` enables research routines that construct meeting candidates and request exchanges between two routes. Each route uses an independent clock. Candidate evaluation covers request continuity, local loads, node order, service windows and return constraints.

The fields in `result.validation` separate local checks from a complete feasibility result:

| Field | Meaning |
| --- | --- |
| `routeConstraintsSatisfied` | Coverage, load, order and individual-route time checks pass |
| `hasTransfers` | At least one route visits a transfer node |
| `transferSynchronizationChecked` | False for solutions containing transfer visits |
| `feasible` | True only when all checks pass and the solution uses direct-service routes |

The [algorithm guide](ALGORITHM.md) describes candidate construction and the search flow.
