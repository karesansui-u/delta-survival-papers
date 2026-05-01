A12 Primary v0 Invalid-Run Summary
==================================

domain_id: st_cut_spectrum_reliability

package_id: a12_st_cut_spectrum_reliability_v0

manifest: 05_evidence/a12_st_cut_spectrum_reliability/freeze_manifest_v0.md

date: 2026-05-01 JST

decision: invalid_run_generation_infeasible


1. What Was Frozen
------------------

The frozen v0 surface attempted to evaluate whether the scalar low-order
cut-spectrum pressure

\[
\log(1+H_{\mathrm{cut},2})
\]

improves a natural graph baseline \(B1\) for held-out \(s\)-\(t\)
disconnection probability in finite two-cluster synthetic graphs.

The frozen primary grid included:

- \(n\in\{16,20\}\);
- edge-factor \(1.5\);
- \(\kappa\in\{2,3\}\);
- \(q\in\{0.20,0.30,0.40,0.50\}\);
- `candidate-count=20`;
- `graphs-per-cell=10`;
- `failure-samples=256`;
- exact low-order cutset enumeration with `max-cutset-subset-tests=250000`.


2. What Happened
----------------

Generation was run from the frozen manifest command and was not interrupted.
The generator completed the first cell:

```text
n=16, m=24, kappa=2
```

It then attempted:

```text
n=16, m=24, kappa=3
```

and reached the generator attempt cap without finding eligible candidates:

```text
attempts=600
accepted=0
elapsed_s=5873.7
RuntimeError: not enough candidates for n=16, m=24, kappa=3
```

No prediction labels, model metrics, or support-bearing evaluation artifacts
were produced for this package.


3. Decision
-----------

This is not support and not no-support. It is an invalid run caused by an
infeasible frozen generation surface.

The primary support rule was not evaluated because the dataset was not
generated. Therefore the result should not be counted as evidence against the
A12 cut-spectrum coordinate.


4. Interpretation
-----------------

The failure indicates that the v0 two-cluster generator, under the exact
enumeration cap and the frozen \(n=16,m=24,\kappa=3\) cell, does not reliably
produce enough eligible graphs. The bottleneck is the frozen graph-generation
surface, not the downstream prediction comparison.

A successor A12 package must be frozen separately. Safe successor options
include:

- a \(\kappa=2\)-only v0b surface;
- a redesigned \(\kappa=3\) graph generator with pre-run feasibility checks;
- a larger but separately frozen graph family where \(\kappa=3\) cells are
  structurally feasible before any outcome-bearing labels are generated.

Any successor run must use a new manifest and must not promote diagnostics from
this invalid v0 attempt into a support-bearing claim.
