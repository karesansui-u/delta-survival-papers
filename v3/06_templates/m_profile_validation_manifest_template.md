Optional M-Component Diagnostic Manifest Template
================================================

manifest_id:

domain_id:

date_frozen:

frozen_by:


1. Validation Role
------------------

- target support level: optional M-component diagnostic / exploratory resource-side evidence
- validation type: risk prediction / diagnosis / persistence readout
- observability layer:
- claim boundary:

Use this manifest only when an optional test decomposes the scalar resource-side
term \(M\) into \(M_{\mathrm{buffer}}\), \(M_{\mathrm{recovery}}\),
\(M_{\mathrm{reconfiguration}}\), or external supply channels. The core theory
does not require this decomposition. A successful result may be recorded as an
exploratory M-component diagnostic signal, not as law-side support.
\(M\) itself is treated as the familiar effective maintenance surplus available
for the pre-fixed maintenance problem. It is not assumed to directly choose an
intervention.


2. Maintenance Target
---------------------

- target function \(F\):
- maintained structure \(\Sigma\):
- unit of analysis:
- observation unit:
- time horizon:
- failure / degradation / recurrence endpoint:
- collapse or alert boundary, if any:


3. Frozen M-Profile
-------------------

Define the component signals before outcome-bearing evaluation.

| Component | Frozen observation indicator / signal | Source table or log | Direction | Availability before outcome |
|---|---|---|---|---|
| \(M_{\mathrm{buffer}}\) |  |  | higher is better / lower is better | yes / no |
| \(M_{\mathrm{recovery}}\) |  |  | higher is better / lower is better | yes / no |
| \(M_{\mathrm{reconfiguration}}\) |  |  | higher is better / lower is better | yes / no |
| \(M_{\mathrm{ext}\to\mathrm{buffer}}\) |  |  | higher is better / lower is better | yes / no |
| \(M_{\mathrm{ext}\to\mathrm{recovery}}\) |  |  | higher is better / lower is better | yes / no |
| \(M_{\mathrm{ext}\to\mathrm{reconfiguration}}\) |  |  | higher is better / lower is better | yes / no |


4. Weak-Axis Independence Gate
------------------------------

Run this gate on training data only before the primary validation.

- baseline feature set:
- scalar resource indicator:
- existing degradation / capacity features:
- leakage guards:
- redundancy test:
- maximum allowed correlation / predictability from baseline features:
- action if weak-axis gate fails:

The optional M-component readout must not merely rename the baseline, capacity,
age, degradation, or target-leakage features. If the M-axis fails this gate, record weak-axis
failure rather than support.


5. Normalization and Aggregation Families
-----------------------------------------

Freeze all candidate families before outcome-bearing evaluation.

- \(\rho_i\) normalization candidates:
  - candidate 1:
  - candidate 2:
  - candidate 3:
- \(A_j(M_j^{\mathrm{int}},M_{\mathrm{ext}\to j})\) internal/external aggregation candidates:
  - candidate 1:
  - candidate 2:
  - candidate 3:
- \(\Phi(\widetilde M_{\mathrm{buffer}},\widetilde M_{\mathrm{recovery}},\widetilde M_{\mathrm{reconfiguration}})\) candidates:
  - additive:
  - product:
  - CES:
  - bottleneck:


6. Baselines and Models
-----------------------

- simple baseline:
- domain baseline:
- scalar \(M\) baseline:
- domain baseline + optional M-component readout:
- domain baseline + L/B + optional M-component readout:
- model class:
- train / validation / test split:
- primary metric:
- secondary metrics:


7. Support Rules
----------------

M-component diagnostic signal:

- rule:
- minimum effect size:
- uncertainty criterion:

No-support:

- rule:
- weak-axis failure rule:
- leakage failure rule:

8. Non-Claims
-------------

- no universal \(M\)-form is claimed;
- no component decomposition is part of the core \(S=Me^{-L}\) or \(S=Me^{-B}\) claim;
- no support transfers from another domain;
- no post-hoc component remapping after seeing outcome-bearing data;
- no claim that external supply is a fourth M component rather than a channel.
