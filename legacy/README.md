# Additional MATLAB routines

This directory contains an earlier entry script, alternate operators, data preparation and reporting utilities. Add only the repository root to the MATLAB path; recursive path expansion would expose these variants alongside the solver functions.

| Directory | Contents |
| --- | --- |
| `entry/` | Workspace-based entry script with spreadsheet preparation and CSV export |
| `unused/` | Alternate operators, initial-solution routines, coordinate conversion and reporting |

## Operator alternatives

The executable solver calls the following versions from the repository root:

| Alternate file in `unused/` | Solver function |
| --- | --- |
| `DestroyandRepair_swap_2opt_func.m` | `DestroyandRepair_swap_2opt_func0803_edit_rep_1.m` |
| `InsertdeliverypointALNS.m` | `InsertdeliverypointALNS0711.m` |
| `RepairOperator1.m` | `RepairOperator1_0803.m` |
| `RepairOperator2.m` | `RepairOperator2_0426.m` |
| `TransitOrNotAndWhere.m` | `TransitOrNotAndWhere0421.m` |
| `TsBestSolutionALNS.m` | `TsBestSolutionALNS0711.m` |

## External inputs

Preparation and reporting routines refer to spreadsheets such as `result0731_right.xlsx`, `vechleinfomation0730_1000.xlsx`, `passengerdemand_result1.xlsx`, `vehcleinfomation.xlsx`, `gams0805.xlsx`, `use.xlsx`, `x0802_7.xlsx`, `longtitude_and_latitude0415.xlsx` and `stop_shortestdistance`. These inputs are not included; paths must be configured for the intended data source.

Initial-solution routines require external helpers named `calculatetotalcost_test_right`, `GenerateinisolutionRight0406` or `GenerateinisolutionRight0410`. The main solver accepts explicit starting routes, and `make_demo_instance` supplies a small feasible example.

Coordinate utilities use Mapping Toolbox functions including `makerefmat`, `latlon2pix`, `axesm`, `utmzone` and `mfwdtran`. `Generate_Costs.m` also uses `roundn` and Image Processing Toolbox's `std2`. These dependencies are separate from the base-MATLAB example.

Use the repository-root evaluator and the [documented objective](../docs/MODEL.md#objective) for consistent scores.
