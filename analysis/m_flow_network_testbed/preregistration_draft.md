# M Flow Network Testbed Preregistration Draft

Status: draft; not frozen.

Date: 2026-04-29

## 1. Study Question

Does M-component allocation predict persistence and intervention ranking beyond
total maintenance budget in a controlled flow-network structure?

Primary frozen claim:

> Under the same total energy budget and damage process, M-profile allocation
> improves held-out intervention-ranking prediction over a total-resource
> baseline.

This is controlled mechanistic support. It is not real-world empirical support
for software, SaaS, batteries, organizations, or hospitals.


## 2. Maintained Function

Each instance is a directed capacitated network with source \(s\), sink \(t\),
and required flow \(Q\).

The maintained function is:

\[
  \operatorname{maxflow}_{s\to t}(G_n,c_n)\ge Q_n.
\]

Collapse occurs when this inequality fails.


## 3. Calibration and Primary Split

Calibration may tune:

- graph sizes;
- nontrivial \(Q\) ranges;
- damage intensities;
- energy grids;
- degeneracy thresholds;
- support thresholds.

Primary evaluation freezes:

- graph generator families;
- held-out graph family;
- damage families;
- held-out damage family;
- allocation grid;
- held-out allocation mix or held-out simplex region;
- energy grid;
- policies;
- baseline features;
- M-profile features;
- metrics;
- support / no-support rules.

No primary result may be used to change these choices.


## 4. Graph Families

Calibration families:

- layered DAG;
- grid;
- series-parallel.

Held-out family:

- random geometric, unless calibration reveals it is structurally degenerate.

If the held-out family changes, the reason must be recorded before primary
evaluation.


## 5. Damage Families

Primary damage families:

- random attrition;
- bottleneck attack;
- clustered failure;
- demand shock;
- repairable wear;
- scalar-only control.

At least one family is held out from rule selection and used only in primary
evaluation.


## 6. Allocation Grid and Policies

Policies receive the same total energy \(E\). The primary object is not a
four-class policy label, but an allocation vector:

\[
  (E_{\mathrm{buffer}},E_{\mathrm{recovery}},E_{\mathrm{reconfiguration}}),
  \qquad
  E_{\mathrm{buffer}}+E_{\mathrm{recovery}}+E_{\mathrm{reconfiguration}}=E.
\]

Named policies are anchor points:

- buffer-heavy;
- recovery-heavy;
- reconfiguration-heavy;
- balanced.

The frozen allocation grid must include mixed allocations as well as extremes.
At least one allocation mix or simplex region is held out from calibration and
used only in primary evaluation.

Optional oracle policy is reported only as an upper bound.


## 7. Baselines

Total-resource baseline:

- graph family;
- graph size;
- edge count;
- initial max-flow;
- initial margin;
- total energy \(E\);
- damage intensity;
- horizon \(T\).

M-profile model:

- all total-resource baseline features;
- \(E_{\mathrm{buffer}}/E\);
- \(E_{\mathrm{recovery}}/E\);
- \(E_{\mathrm{reconfiguration}}/E\);
- pre-frozen interactions, if any.

Calibration-best-policy baseline:

- calibration-estimated best policy or allocation region from observable graph
  and damage summaries;
- no access to the held-out allocation mix outcomes;
- included as a strong policy-prior baseline.

The M-profile model must not receive damage-family oracle labels unless the
total-resource baseline also receives them and the label is declared observable.


## 8. Outcomes

Primary outcome:

- intervention-ranking agreement on held-out instances.

Primary ranking metrics:

- top-1 agreement;
- top-2 agreement;
- Kendall \(\tau\);
- regret relative to best observed policy.

Secondary outcomes:

- collapse time;
- maintained-flow ratio;
- minimum margin;
- recovery time after damage.


## 9. Support Rules

M-primary support requires all of the following:

1. M-profile improves the primary ranking metric over the total-resource baseline
   on held-out graph seeds.
2. Improvement holds on the held-out graph family.
3. Improvement holds on at least one held-out damage family.
4. Improvement holds on the held-out allocation mix or held-out simplex region.
5. M-profile beats the calibration-best-policy baseline.
6. Scalar-only control does not show a spurious large M advantage.
7. Degenerate cells remain below the pre-frozen maximum fraction.

M-preparatory support requires:

- M-profile improves at least one secondary outcome prediction over the
  total-resource baseline out-of-sample.

No-support is recorded if:

- total-resource baseline matches or beats M-profile on the primary metric;
- calibration-best-policy baseline matches or beats M-profile on the primary metric;
- M-profile only wins after excluding unfavorable frozen regimes;
- M-profile only memorizes named policy labels and fails on held-out allocation mixes;
- held-out topology or held-out damage reverses the effect;
- most primary cells are degenerate;
- the M model is given generator-rule information not available to the baseline.


## 10. Reporting

Report:

- all configs;
- seeds;
- graph and damage family counts;
- degenerate-cell table;
- primary ranking metrics;
- secondary metrics;
- baseline-vs-M comparison;
- no-support or support decision;
- exact code commit hash.

All failed or degenerate attempts remain in the record.


## 11. Non-Claims

This preregistration does not claim:

- real-world software / SaaS support;
- causal validity in observational domains;
- universal \(M\)-law;
- that M-profile must win in every damage regime;
- that artificial testbed support transfers to any target domain.
