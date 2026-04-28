# Phase 6.2 Repair-Maintenance template

Status: Phase 6.2 v0 template note after the Phase 5 ladder and Phase 6.1
Foster-Lyapunov / queueing wrappers. A thin Lean wrapper now exists in
`Survival.RepairMaintenanceTemplate`.

This note asks how the Bernoulli-CSP `Sigma` template and the
Foster-Lyapunov / queueing template transfer to a third limited class:
repair-maintenance systems with explicit damage and repair flows.

It is not a stochastic reliability theorem, an optimal maintenance theorem, a
repair-policy theorem, or an unconditional repair-side second law. It is a
template map: which finite-prefix identities already exist, which `Sigma` /
resource-cost facts already exist, and which high-probability certificates are
available only after a concrete stochastic step model satisfies explicit
resource-bounded assumptions.

## 1. Why Repair-Maintenance is the third class

Bernoulli-CSP gives a specification-fixed one-sided exposure class. Its
high-probability certificates use Chernoff/KL.

Foster-Lyapunov / queueing gives a drift class. Its high-probability
certificates use conditional-Azuma / bounded-increment assumptions.

Repair-Maintenance is different again. Its natural primitives are:

- damage amount \(d_t\);
- repair or maintenance amount \(r_t\);
- net consumption \(b_t=d_t-r_t\);
- accumulated damage \(D_n=D_0+\sum_{t<n}(d_t-r_t)\);
- remaining margin \(B-D_n\);
- resource cost / repair slack when repair is not free.

This class is important because it is the most direct finite-prefix model of
open-system structural persistence: repair can reduce net consumption, but
repair itself must be paid for in the `Sigma` / total-production layer.

## 2. Existing Lean anchors

| Role | Lean anchor | Current status |
|---|---|---|
| damage / repair net action | `RepairMaintenanceBalance.netAction` | defined as `damage - repair` |
| cumulative net consumption | `RepairMaintenanceBalance.cumulativeNetAction` | finite-prefix successor proven |
| accumulated damage | `RepairMaintenanceBalance.damageLevel` | \(D_n=D_0+\sum(d_t-r_t)\) proven |
| remaining margin | `RepairMaintenanceBalance.margin` | \((B-D_0)-\sum(d_t-r_t)\) proven |
| threshold crossing | `RepairMaintenanceBalance.ThresholdCrossed` | equivalent to nonpositive margin |
| exponential maintenance coordinate | `RepairMaintenanceBalance.relativeMaintenance` | local signed-action update proven |
| repair improves damage-only margin | `damageOnlyMargin_le_margin_of_repair_nonneg` | proven under nonnegative repair |
| `Sigma` / total production | `SecondLawTotalProduction.*` | reader-facing `Σ=B+C=L+slack` core proven |
| resource-bounded stochastic route | `ResourceBoundedStochasticCollapse.*` | stopped-collapse / hitting-time certificates under supplied assumptions |
| coarse stochastic transfer | `ResourceBoundedStochasticCollapse.*` | conditional transfer under explicit stochastic compatibility |

The new wrapper `Survival.RepairMaintenanceTemplate` gives these anchors stable
Phase-6.2 names. It adds naming and class-template staging, not a new universal
repair law.

## 3. Bernoulli / Foster-Lyapunov / Repair-Maintenance comparison

| Template role | Bernoulli-CSP | Foster-Lyapunov / queueing | Repair-Maintenance |
|---|---|---|---|
| primitive increment | one-sided bad event | Lyapunov / load increment | \(d_t-r_t\) |
| cumulative quantity | `Sigma` from bad-event emissions | cumulative action / expected `Sigma` | damage level / net consumption / `Sigma` |
| concentration engine | Chernoff / KL | conditional-Azuma | resource-bounded Azuma when a stochastic step model is supplied |
| pathwise nondecrease | yes, for nonnegative emissions | not generally claimed | not generally claimed |
| repair cost | absent or simple | supplied by resource budget | central: repair is beneficial but not free |
| coarse transfer | endpoint-defect / stochastic compatibility | stochastic compatibility | stochastic compatibility, not unconditional DPI |

The important distinction is that repair-maintenance has two visible flows.
Reducing \(B_n\) by increasing repair is not free evidence of a law-side
decrease; it moves cost into the `Sigma` / total-production account.

## 4. Lean wrapper names

The Phase 6.2 v0 wrapper now exposes:

- `RepairMaintenanceTemplate.netConsumption_eq_damage_sub_repair`
- `RepairMaintenanceTemplate.cumulativeNetConsumption_succ`
- `RepairMaintenanceTemplate.damageLevel_eq_initial_plus_cumulativeNetConsumption`
- `RepairMaintenanceTemplate.margin_eq_initial_margin_sub_cumulativeNetConsumption`
- `RepairMaintenanceTemplate.thresholdCrossed_iff_margin_nonpos`
- `RepairMaintenanceTemplate.thresholdCrossed_of_initial_margin_le_cumulativeNetConsumption`
- `RepairMaintenanceTemplate.relativeMaintenance_succ_eq_mul_exp_neg_netConsumption`
- `RepairMaintenanceTemplate.netConsumption_le_damage_of_repair_nonneg`
- `RepairMaintenanceTemplate.netConsumption_nonpos_of_damage_le_repair`
- `RepairMaintenanceTemplate.damageLevel_le_damageOnlyLevel_of_repair_nonneg`
- `RepairMaintenanceTemplate.damageOnlyMargin_le_margin_of_repair_nonneg`
- `RepairMaintenanceTemplate.sigma_equals_B_plus_C`
- `RepairMaintenanceTemplate.sigma_equals_L_plus_repair_slack`
- `RepairMaintenanceTemplate.sigma_at_least_L`
- `RepairMaintenanceTemplate.sigma_equals_L_under_exact_payment`
- `RepairMaintenanceTemplate.repairMaintenance_resourceBoundedExpectedSigma_monotone`
- `RepairMaintenanceTemplate.repairMaintenance_stoppedCollapseWithFailureBound_of_expectedMargin`
- `RepairMaintenanceTemplate.repairMaintenance_stoppedCollapseWithFailureBound_of_initialExpectedMargin`
- `RepairMaintenanceTemplate.repairMaintenance_hittingTimeBeforeHorizonWithFailureBound_of_expectedMargin`
- `RepairMaintenanceTemplate.repairMaintenance_hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin`
- `RepairMaintenanceTemplate.coarseRepairMaintenance_stoppedCollapseWithFailureBound_of_microExpectedMargin`
- `RepairMaintenanceTemplate.coarseRepairMaintenance_stoppedCollapseWithFailureBound_of_microInitialMargin`
- `RepairMaintenanceTemplate.coarseRepairMaintenance_hittingTimeBeforeHorizonWithFailureBound_of_microExpectedMargin`
- `RepairMaintenanceTemplate.coarseRepairMaintenance_hittingTimeBeforeHorizonWithFailureBound_of_microInitialMargin`

These names are intentionally verbose. They make the assumptions visible:
resource-boundedness, expected margin, hitting/stopped event, and explicit
coarse compatibility.

## 5. What counts as Phase 6.2 v0 closed

Phase 6.2 v0 is closed when the repo has:

1. a template note for repair-maintenance as the third limited class;
2. reader-facing Lean wrappers for finite-prefix damage/repair algebra;
3. reader-facing Lean wrappers for the `Sigma` / repair-cost grammar;
4. resource-bounded stopped-collapse / hitting-time certificate wrappers for
   supplied stochastic repair-maintenance step models;
5. coarse stopped-collapse / hitting-time transfer wrappers under explicit
   stochastic compatibility;
6. explicit non-claims separating this v0 template from stochastic reliability,
   optimal policy, and unconditional repair-law statements.

The current wrapper satisfies these items at the alias / reader-facing layer.

## 6. What remains open

Phase 6.2 v0 does not close:

- a stochastic reliability theorem for arbitrary repair processes;
- an optimal maintenance or repair-policy theorem;
- Bernoulli-style pathwise nondecrease;
- an unconditional repair-maintenance second law;
- a set-level admissible coarse map for repair-maintenance systems;
- a necessary/sufficient admissible-map characterization;
- a cross-class unification theorem.

The correct reading is:

```text
Repair-Maintenance is now staged as the third limited class. It shares the
Sigma / net-consumption / resource-cost / concentration / coarse-transfer
grammar, but only under supplied finite-prefix and stochastic compatibility
assumptions.
```

## 7. Recommended next move

After this v0 wrapper, the natural next choices are:

1. record the three-class comparison explicitly in the second-law-level
   roadmap;
2. decide whether Phase 6.2 needs a v1 stochastic repair model with concrete
   bounded-difference assumptions, or whether v0 is enough to move to Phase 7
   v0;
3. only later return to set-level repair-maintenance admissible maps or
   necessary-side Phase-5 pruning.

The key discipline is the same as in Phase 5 and Phase 6.1: close the
assumption-visible wrapper first, and do not rename it as a universal law.
