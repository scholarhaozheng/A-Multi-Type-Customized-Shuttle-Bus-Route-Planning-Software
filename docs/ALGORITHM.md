# ALNS and Tabu Search

ALNS improves a starting plan by repeatedly removing and reinserting passenger requests. A **destroy operator** chooses what to remove; a **repair operator** puts those requests back into feasible route positions. Each resulting plan is a **neighbor**, or candidate solution. Tabu Search guides which candidate to accept. The [model reference](MODEL.md) defines the constraints and objective.

## Representation

For `demand = n`, pickup IDs are `1:n`, delivery IDs are `n+1:2*n`, and transfer nodes are listed in `TS`. Starting routes are row vectors in `inisolution1{vehicle}`. Depot nodes are implicit: travel to/from the assigned depot comes from `vhcdemandtimematrix`. Empty cells represent unused vehicles.

In the six-request example, `[1 2 7 8]` means `P1 → P2 → D1 → D2`: pick up requests 1 and 2, then drop them off. Delivery node `r+6` belongs to request `r`. The assigned depot is added implicitly at both ends.

Each request represents one passenger. A transfer exchanges request identities between a pair of routes at a common node while retaining one pickup and one delivery per served request.

## Search procedure

The caller supplies a feasible initial solution without transfers. The run stops after `MaxIterations` iterations and returns the best plan visited.

```text
Load and validate the input instance and starting routes.
Evaluate the starting score.
Set current solution and best solution to those starting routes.
Initialize operator weights and an empty tabu memory.

For iteration = 1 to MaxIterations:
    For each requested neighbor:
        Choose one of five destroy operators using its weight.
        Choose an implemented repair operator using its weight.
        Select two nonempty routes.
        Restore linked routes to a no-transfer form when required.
        Remove selected requests and reinsert them across the two routes.
        Construct the candidate without transfers.
        If transfers are enabled:
            Enumerate/sample compatible transfer locations and request exchanges.
            Reinsert affected delivery nodes and evaluate transfer candidates.
        Validate each candidate and keep the lower-cost available alternative.
        Build its request-to-vehicle assignment transition key.

    Select the best admissible move.
    Allow a tabu move if it improves the best score (aspiration).
    If no admissible candidate exists, keep the current solution.
    Otherwise update current solution and best solution, and store the inverse key.
    Credit the selected operators and update segment scores/usage counts.
    At each segment boundary, update operator weights.
Return routes, objective trace and run metadata.
```

## Operator details

The five destroy operators select random requests, low-cost removal candidates, related requests, a random pickup suffix, or a cost-selected pickup subsequence. Removing a request removes both endpoints. Relatedness uses travel time plus the absolute difference between earliest pickup times.

Random-start repair chooses a starting pickup position, scans pickup positions cyclically, and accepts the first feasible paired insertion. Greedy repair scores the first feasible delivery insertion at each pickup position and keeps the lowest-cost candidate. Both process requests in the supplied removal order.

## Tabu memory and adaptation

Tabu memory temporarily blocks reversing recent request assignments. A candidate that improves the best score can override that rule; this is the aspiration criterion. Adaptive weights favor operators that have earned higher rewards per use.

For every request whose assignment changes, the tabu key contains its ID and old/new pickup and delivery vehicles. The key is ordered by request ID. Its inverse exchanges the old and new assignments. Route positions and transfer-station choices are outside these attributes; a move with no assignment change has an empty key.

The memory stores up to `tabulength` nonempty inverse assignment keys in first-in, first-out order. An exact key match is tabu unless its score improves the global best. If no admissible candidate exists, the current solution is kept and the oldest memory entry expires.

Every `lambda` iterations, an operator with score `s`, usage count `u`, weight `w` and reaction factor `r` receives `w = (1-r)*w + r*s/u` when `u > 0`; otherwise its weight becomes `(1-r)*w`. This follows Eq. (47). Rewards distinguish a new global best, a current-solution improvement, and an accepted worsening move. Equal-cost moves receive no reward. If every weight in an operator group reaches zero, equal weights of 0.1 are restored for sampling.

## Transfer candidates and outputs

`Ts` in function names denotes transfer stations. `SetTsMax` limits sampled meeting candidates and `EachOptionMax` limits selected exchange-cardinality groups. Enumeration raises `Shuttle:TransferEnumerationLimit` before allocating more than 10,000 nonempty subset pairs for a meeting candidate. These alternatives use independent route schedules; see the [transfer-candidate interface](MODEL.md#transfer-candidate-interface) for the returned feasibility fields.

`result` contains the best and current routes, cost history, objective components, selected operators and weights, request coverage, constraint reports, seed/options, runtime version and elapsed time. The [example](../examples/README.md) illustrates these outputs.

## Function index

| Role | Source |
| --- | --- |
| Main search | [MDVRPTW](../MDVRPTW.m) |
| Weighted operator selection | [Operator selector](../GeneratingOperatorsChoice.m) |
| Tabu attributes and candidate choice | [Assignment key](../AssignmentMoveKey.m), [candidate selector](../SelectALNSNeighbor.m) |
| Removal and reinsertion across two routes | [Neighborhood coordinator](../DestroyandRepair_swap_2opt_func0803_edit_rep_1.m) |
| Request removal | [Random](../DestroyOperator1.m), [cost-based](../DestroyOperator2.m), [related](../DestroyOperator3.m), [random segment](../DestroyOperator4.m), [best segment](../DestroyOperator5.m) |
| Request reinsertion | [Random-start](../RepairOperator1_0803.m), [greedy](../RepairOperator2_0426.m) |
| Transfer construction | [Meeting candidates](../TransitOrNotAndWhere0421.m), [request exchanges](../TsBestSolutionALNS0711.m), [delivery insertion](../InsertdeliverypointALNS0711.m) |
| Restoration of direct routes | [Route restoration](../BackToNoTs.m) |
| Constraint checks | [Schedule](../RouteSchedule.m), [capacity](../CapacityCheck.m), [solution validation](../ValidateSolution.m), [driving time](../CalculatingTotalTime.m) |
| Objective | [Cost evaluator](../calculatetotalcost_test.m) |

Source: Zheng, H.; Zhang, X.; Chen, J. (2021), [Sections 3-5](https://doi.org/10.3390/info12100429).
