QSA Qualified Support Assignment Benchmark
==========================================

domain_id: qsa_m_hard_anchor

domain_name: Qualified Support Assignment finite benchmark

classification: specification_fixed

status: finite_benchmark_support_signal_outside_computational_rerun_reproduced


1. Purpose
----------

QSA is a finite M-side support benchmark. Its role is to test whether qualified
support can be reduced to raw resource count or a simple support sum under a
fixed finite benchmark surface.

The benchmark is deliberately narrow:

- raw resource summary is matched;
- simple support sum is matched;
- required support is matched;
- L / damage demand is matched;
- only qualified support gate / path / license differs.

The primary readout is a stochastic repair-attempt endpoint with noisy
observation, action choice, delay, and execution. The endpoint is not a direct
recomputation of the M license.


2. Safe Claim
-------------

The safe positive claim is:

> In this finite benchmark, raw resource count and simple support sum do not
> identify qualified support. Qualified support gate / path / license carries
> held-out recovery-readout information under matched raw R, simple support
> sum, required support, and L / damage demand.

This is the M-side anti-collapse point paired with the L-side finite CSP
anti-collapse point:

| Side | Anti-collapse point |
|---|---|
| L | raw constraint count is not structural loss |
| M | raw resource count / simple support sum is not qualified support |


3. Non-Claims
-------------

QSA does not claim:

- external SRE support;
- real-domain typicality;
- M-only sufficiency;
- recovery theorem or survival theorem;
- max-flow / min-cut optimality;
- that its synthetic stochastic endpoint is a real operational mechanism;
- empirical parity with the L-side finite CSP anchor in real domains.


4. Evidence References
----------------------

Primary / fresh reports are stored in the companion Lean-preprint repository:

- `external:persistence-lean/outputs/qsa_m_hard_anchor_primary_report.md`
- `external:persistence-lean/outputs/qsa_m_hard_anchor_fresh_report.md`
- `external:persistence-lean/outputs/qsa_m_hard_anchor_review.md`
- `external:persistence-lean/outputs/qsa_external_rerun_result_review.md`

External rerun status:

- outside environment: Windows 11 / Python 3.12.10 / numpy 2.4.6
- primary finite-benchmark decision reproduced
- fresh finite-benchmark decision reproduced
- the companion rerun review preserves the original script-level decision label;
  this public profile reads it only as a finite benchmark support signal
- summary CSV hashes matched exactly
- report differences were CRLF line endings only
- instance CSV differences were float-string microdiffs at `1e-16` scale

This domain entry records a finite-benchmark support signal and outside
computational rerun status. It does not import the benchmark as external
operational evidence.
