# Flow-Network M Testbed Calibration Sweep v0

Status: calibration smoke test only.

Generated with:

```bash
python3 analysis/m_flow_network_testbed/scripts/run_calibration_sweep.py
```

This sweep screens candidate values of required flow \(Q\), damage intensity,
and horizon length.  The goal is to reduce obvious degeneracy before any
primary freeze:

- too many no-collapse cells;
- too many far-above-\(Q\) cells;
- too many first-step collapses;
- too many group-level review recommendations.

The heuristic `candidate_score` is only a calibration-screening score.  It is
not support evidence and must not be used as a primary metric.

Default smoke summary:

- candidates screened: 18
- top heuristic candidate: \(Q=4\), damage intensity \(0.30\), horizon \(T=8\)
- top-candidate collapse fraction: 0.7045
- top-candidate no-collapse fraction: 0.2955
- top-candidate far-above-\(Q\) fraction: 0.0303
- top-candidate first-step-collapse fraction: 0.0076
- top-candidate group recommendations: 10 keep, 2 review

This summary is a calibration pointer only.  A freeze decision still requires
the preregistered freeze manifest and subsequent calibration/freeze review.
