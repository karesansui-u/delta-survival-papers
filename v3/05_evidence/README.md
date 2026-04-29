Evidence Ledgers
================

Evidence is separated from theory claims.

- `frozen_packages.tsv`: frozen tests or packages that define a support decision.
- `outside_reruns.tsv`: independent or outside reruns.
- `no_support.tsv`: failed frozen tests, weak-axis failures, and silence records.
- `field_demonstrations.tsv`: operational field evidence such as maintainer
  acceptance, deployments, or third-party practical use. These are not
  no-cut benchmark endpoints.
- `bounded_benchmarks.tsv`: controlled internal or external benchmark surfaces
  whose endpoint, comparator, validation depth, and support scope are bounded.
- Software contract-coherence diagnostics evidence is tracked as two layers:
  public OSS field demonstration / maintainer-acceptance evidence, and bounded
  internal benchmark calibration. DeltaLint is the current implementation name.
  The former is operational evidence, not raw precision / recall; the latter is
  the controlled support surface.

Do not delete failed attempts. They are part of the research program.

For M-side validation, use:

- `../06_templates/m_profile_validation_manifest_template.md` for M-profile
  validation and weak-axis gates when the effective resource side is
  operationalized through component readouts.
