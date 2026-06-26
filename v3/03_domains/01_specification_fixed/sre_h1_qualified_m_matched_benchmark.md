SRE-H1 Qualified M Matched Benchmark
=====================================

domain_id: sre_h1_qualified_m_matched

domain_name: SRE-H1 qualified-M matched finite benchmark

classification: specification_fixed

status: finite_benchmark_support_signal_outside_computational_rerun_reproduced_with_packaging_note


1. Purpose
----------

SRE-H1 is a frozen finite / synthetic matched benchmark for the current M-side
reading:

> M licenses qualified support for a claim.

The benchmark asks whether qualified-M license status carries recovery-readout
information when nominal resource, L/R controls, and matched finite structure
are controlled.

It is not an external incident archive validation and is not real SRE
typicality evidence.


2. Fixed Contrast
-----------------

The benchmark compares models including:

- `R_plus_L_plus_M`
- `R_plus_L`
- `R_plus_L_plus_shuffled_M`
- `R_plus_L_plus_stratified_shuffled_M`
- missingness / report-style / archive / team fixed-effect controls

The primary support readout requires the qualified-M model to beat L/R controls
and shuffled-M controls under the frozen matched finite surface.


3. External Rerun Status
------------------------

The returned outside rerun reproduced the finite benchmark decision:

```text
primary_decision: h1_qualified_M_prediction_support
fresh_decision:   h1_qualified_M_prediction_support
```

Returned environment:

```text
OS: Microsoft Windows 11 Pro 10.0.26200 (64-bit)
Python: 3.12.10
numpy: 2.4.6
virtual environment: yes
primary: success
fresh: success
audit: success
```

The returned reports matched after CRLF normalization. Matched-pairs CSVs
matched exactly. Numeric-only CSV differences were at floating-point string
precision.

A packaging note remains: the external runner manually created an empty
`data/` directory after the first run failed at file-writing. The companion
script has since been updated to create `data/` and `outputs/` before writing.
This is recorded as a packaging note, not as result invalidation.


4. Safe Claim
-------------

Allowed:

```text
SRE-H1 is externally rerunnable as a frozen finite / synthetic matched
benchmark, and the returned Windows/Python rerun reproduced the primary/fresh
qualified-M finite-benchmark decision.
```

Not allowed:

```text
external SRE support is licensed
real SRE typicality is established
M-only sufficiency is established
recovery is guaranteed
```


5. Evidence References
----------------------

- `external:persistence-lean/outputs/sre_h1_qualified_m_matched_primary_report.md`
- `external:persistence-lean/outputs/sre_h1_qualified_m_matched_fresh_report.md`
- `external:persistence-lean/outputs/sre_h1_qualified_m_matched_review.md`
- `external:persistence-lean/outputs/sre_h1_external_rerun_result_review.md`
