# Flow-Network M Testbed Calibration Review v1

Status: calibration review only.

Generated with:

```bash
python3 analysis/m_flow_network_testbed/scripts/run_calibration_sweep.py \
  --q-values 4 \
  --damage-values 0.26,0.28,0.30,0.32,0.34 \
  --horizon-values 8,9,10,12 \
  --out-dir analysis/m_flow_network_testbed/dry_runs/calibration_review_v1
```

This review narrows the v0 sweep around \(Q=4\), varying damage intensity and
horizon length.  It is intended to choose a plausible calibration region before
any primary freeze.  It is not support evidence.

Default held-out-allocation review:

- candidates screened: 20
- top heuristic candidate: \(Q=4\), damage intensity \(0.28\), horizon \(T=9\)
- top-candidate collapse fraction: 0.6970
- top-candidate no-collapse fraction: 0.3030
- top-candidate far-above-\(Q\) fraction: 0.0000
- top-candidate first-step-collapse fraction: 0.0076
- top-candidate group recommendations: 10 keep, 2 review

The top candidates are close rather than decisive.  In particular, several
nearby \(Q=4\) settings with damage intensity in \([0.28,0.34]\) and
\(T \in \{8,9,10,12\}\) remain plausible calibration candidates.

Full-grid smoke:

```bash
python3 analysis/m_flow_network_testbed/scripts/run_calibration_sweep.py \
  --q-values 4 \
  --damage-values 0.26,0.28,0.30,0.32,0.34 \
  --horizon-values 8,9,10,12 \
  --full-grid \
  --out-dir analysis/m_flow_network_testbed/dry_runs/calibration_review_v1/full_grid_smoke
```

The full-grid smoke screens the same neighborhood over the full allocation
grid.  Its top heuristic candidate is \(Q=4\), damage intensity \(0.34\),
horizon \(T=8\).  This difference is a guardrail: the review does not freeze a
single candidate solely from the held-out-allocation candidate score.

Freeze use:

- use this review to define a short candidate region, not a final primary
  setting;
- any freeze decision must be made in the freeze manifest;
- candidate-score ranks are calibration pointers only;
- support/no-support decisions require the later primary protocol.
