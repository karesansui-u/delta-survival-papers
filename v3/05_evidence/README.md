Evidence Ledgers
================

Evidence is separated from theory claims.

- Large row-level artifacts should follow
  `../04_operations/55_artifact_storage_policy.md`.
- `evidence_status_dashboard.md`: reader-facing snapshot of supported,
  observational, no-support, invalid-run, and exact-anchor records.
- `specification_fixed_replication_strengthening_plan.md`: next-step plan for
  strengthening rerun discipline around supported non-CSP specification-fixed
  packages.
- `frozen_packages.tsv`: frozen tests or packages that define a support decision.
- `outside_reruns.tsv`: independent or outside reruns.
- `no_support.tsv`: failed frozen tests, weak-axis failures, and silence records.
- `field_demonstrations.tsv`: operational field evidence such as maintainer
  acceptance, deployments, or third-party practical use. These are not
  no-cut benchmark endpoints.
- `bounded_benchmarks.tsv`: controlled internal or external benchmark surfaces
  whose endpoint, comparator, validation depth, and support scope are bounded.
- `cross_domain_failure_lessons.md`: reusable design lessons from invalid,
  no-support, and below-gate packages across domains.
- `nat_readout_audit.md`: audit note separating exact structural nat, sampled
  future-scenario nat, predictive log loss, and estimation-layer proxy
  indicators.
- `cross_domain_design_lessons_from_a06_stop.md`: focused lessons from the
  A06-stop stopping-set package.
- Software contract-coherence diagnostics evidence is tracked as two layers:
  public OSS field demonstration / maintainer-acceptance evidence, and bounded
  internal benchmark calibration. DeltaLint is the current implementation name.
  The former is operational evidence, not raw precision / recall; the latter is
  the controlled support surface.

Current strongest outside-rerun anchors:

- Mixed-CSP: frozen specification-fixed package, 3/3 clean outside reruns.
- q-coloring (Exp43c package): frozen specification-fixed package, 3/3 clean outside
  reruns.

These two records are the current hard entry point for the law-side layer. They
do not prove the whole theory and do not declare a universal law. They show that
two frozen specification-fixed packages can be rerun outside the author's
environment while preserving the support decision for the structural coordinate
against raw baselines.

Do not delete failed attempts. They are part of the research program.

For optional M-side component diagnostics, use:

- `../06_templates/m_profile_validation_manifest_template.md` for component
  diagnostic validation and weak-axis gates when the effective resource side is
  operationalized through optional component readouts.
