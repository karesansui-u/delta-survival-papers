# M Flow Network Testbed Design Note

Status: design note, not a completed experiment.

Date: 2026-04-29

## 1. Purpose

The M flow-network testbed is a controlled mechanistic validation target for the
resource side of structural persistence theory.

The testbed asks whether \(M\)-component allocation carries information beyond
total resource:

\[
  E = E_{\mathrm{buffer}} + E_{\mathrm{recovery}} + E_{\mathrm{reconfiguration}}.
\]

The intended claim is deliberately narrow:

> under the same damage process and the same total maintenance budget,
> \(M\)-component allocation predicts persistence and intervention ranking better
> than a total-resource baseline.

This is controlled mechanistic support, not real-world empirical support.


## 2. Structural Object

Use a directed capacitated network \(G=(N,E)\) with source \(s\), sink \(t\),
and edge capacities \(c_e\).

The maintained function is:

\[
  F(G,c)=1 \quad \Longleftrightarrow \quad \operatorname{maxflow}_{s\to t}(G,c)\ge Q.
\]

Collapse occurs when:

\[
  \operatorname{maxflow}_{s\to t}(G_n,c_n)<Q.
\]

Primary readouts:

- collapse time;
- maintained-flow ratio;
- minimum flow margin;
- recovery time after damage;
- intervention-ranking accuracy.


## 3. M Components

| Component | Operational meaning | Allowed action |
|---|---|---|
| \(M_{\mathrm{buffer}}\) | spare capacity and redundant margin | increase selected capacities before damage |
| \(M_{\mathrm{recovery}}\) | ability to restore damaged capacity | repair damaged edges after damage |
| \(M_{\mathrm{reconfiguration}}\) | ability to preserve \(F\) through topology change | activate bypass edges or rewire around bottlenecks |

External supply is represented as energy entering one of these components, not as
a fourth component.


## 4. Why This Testbed Is Needed

Software / SaaS and OSS data are closer to real systems, but they introduce
confounding, hidden interventions, missing logs, and ambiguous outcomes.

The artificial testbed is less realistic but cleaner:

- \(F\) is explicit;
- the collapse boundary is exact;
- total resource \(E\) is fixed;
- allocation can be varied independently;
- damage processes can be held out;
- intervention ranking has a ground-truth evaluation.

This testbed is therefore the first place to ask whether M is more than a
labeling scheme.


## 5. Anti-Overfitting Guardrails

The main risk is building a simulator where M wins by construction. The design
must therefore include these guardrails.

1. Strong total-resource baseline.

   The baseline receives graph family, graph size, initial max-flow margin, total
   budget \(E\), damage intensity, and other pre-frozen non-M covariates. M must
   beat this baseline, not a weak toy baseline.

2. Held-out graph topology.

   Calibration chooses generator families and parameter ranges. Primary
   evaluation uses held-out graph seeds and at least one held-out topology family.

3. Held-out damage regime.

   Primary evaluation includes damage families not used for selecting the M-rule.
   This prevents the M-profile rule from memorizing the simulator's damage logic.

4. Include regimes where M should not help.

   Some cells must be scalar-only regimes where total energy and initial margin
   are expected to explain most outcomes. Positive support requires improvement
   without failing these no-gain regimes.

5. Do not give the predictor the generator rule.

   Predictors receive observable summaries and M allocation, not labels such as
   "bottleneck attack" unless that label is declared observable in the test.

6. Frozen no-support rules.

   If policies tie, collapse never occurs, every policy collapses immediately, or
   the M model only wins after post-hoc regime filtering, record no-support or
   degeneracy rather than support.


## 6. Damage Families

Use multiple families so that no component is globally optimal.

| Family | Mechanism | Expected useful component |
|---|---|---|
| random attrition | independent capacity loss | buffer / recovery |
| bottleneck attack | loss concentrated near min-cut | reconfiguration / buffer |
| clustered failure | correlated loss in a subnetwork | reconfiguration |
| demand shock | temporary increase in \(Q\) | buffer |
| repairable wear | repeated small capacity loss | recovery |
| scalar-only control | uniform mild damage | total resource may be sufficient |

The "expected useful component" column is a preregistration hypothesis, not a
support claim.


## 7. Policy Families

All policies receive the same total budget \(E\).

| Policy | Allocation |
|---|---|
| buffer-heavy | large \(E_{\mathrm{buffer}}\) |
| recovery-heavy | large \(E_{\mathrm{recovery}}\) |
| reconfiguration-heavy | large \(E_{\mathrm{reconfiguration}}\) |
| balanced | near-equal allocation |
| scalar baseline | sees only total \(E\), not allocation |

Optional oracle policies can be reported as an upper bound but cannot be used as
support baselines.


## 8. Support Levels

Preparatory support:

- M allocation improves held-out prediction of collapse time, maintained-flow
  ratio, or minimum margin over the total-resource baseline.

M-primary support:

- pre-frozen M allocation predicts the observed intervention-policy ranking
  above the frozen threshold and above the total-resource baseline.

M-strong support:

- M-primary support is stable across graph families, damage families, energy
  levels, normalization choices, and aggregation choices.

Non-support:

- total-resource baseline matches or beats M-profile;
- M-profile only wins in one hand-picked regime;
- the predictor effectively receives the true generator rule;
- most primary cells are degenerate;
- held-out topology or held-out damage destroys the effect.


## 9. Relation to Real Domains

A positive result in this testbed would not validate software, SaaS, batteries,
or organizations. It would show the narrower mechanistic point:

> in a controlled functional structure, the same total resource can have
> different persistence value depending on whether it is allocated to buffer,
> recovery, or reconfiguration.

Real-domain support still requires separate frozen validation in the target
domain.
