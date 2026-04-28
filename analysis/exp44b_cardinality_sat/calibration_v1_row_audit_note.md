# Exp44b Cardinality-SAT Calibration v1 Row Audit Note

Status: row-level audit of a calibration-only no-go result. This note does not
promote Exp44b v1 to a freeze package, primary validation, or Route A evidence.

Date: 2026-04-28

## 1. Bottom Line

Exp44b calibration v1 failed the precommitted closeout because
`M3_threeway_low` violated the strict monotonicity gate.

The failure is small and local:

```text
M3_threeway_low pooled SAT rate
rho 0.64: 0.63
rho 0.68: 0.66  <- local upward reversal
rho 0.72: 0.61
rho 0.76: 0.44
rho 0.80: 0.25
rho 0.84: 0.14
rho 0.88: 0.10
rho 0.92: 0.02
```

This is a real closeout failure under the v1 rule. It is not a substantive
collapse of the Cardinality-SAT direction. The row data show a broad downward
transition with a small low-rho local reversal.

## 2. What Failed

The strict monotonicity gate required no local upward SAT-rate reversals along
the calibration rho grid. `M3_threeway_low` failed:

| n | local reversal |
|---|---|
| `60` | `rho 0.68 -> 0.72`, SAT rate `0.62 -> 0.66` |
| `100` | `rho 0.64 -> 0.68`, SAT rate `0.62 -> 0.70` |
| pooled | `rho 0.64 -> 0.68`, SAT rate `0.63 -> 0.66` |

The pooled reversal is `+0.03` over `100` samples per rho. A rough binomial
standard error for the difference is about `0.068`, so the observed reversal is
well within ordinary finite-sample noise. The v1 gate was intentionally strict
and treated even this small local reversal as no-go.

## 3. What Did Not Fail

The calibration did not fail by execution or data corruption:

- completed rows: `4800/4800`
- completed cells: `96/96`
- timeout records: `0`
- malformed records: `0`
- runtime gate: pass
- informative rho gate: pass
- n-specific window gate: pass
- power-collapse diagnostic: pass

The power-collapse diagnostic did not detect collapse into trivial size or
density proxies:

| Baseline proxy | Spearman with `fm_plus_n` |
|---|---:|
| `raw_plus_n` | `0.1186629419562746` |
| `density_plus_n` | `0.5532757671712318` |
| `cnf_density_plus_n` | `0.5241522816947377` |
| `cnf_count_plus_n` | `0.3788697343361324` |

This means the no-go decision is specifically about the monotonic calibration
rule, not about timeout, malformed instances, or power-proxy collapse.

## 4. Mixture-Level Pattern

All mixtures showed broad decreasing SAT rate as rho increased. Most local
reversals were small.

| Mixture | Pooled monotonicity |
|---|---|
| `M0_low` | no pooled reversal |
| `M1_low_med` | no pooled reversal |
| `M2_bal_low_med` | no pooled reversal |
| `M3_threeway_low` | one pooled reversal: `0.63 -> 0.66` |
| `M4_threeway_med` | no pooled reversal |
| `M5_med_high` | no pooled reversal |

The strict closeout script marked `M3_threeway_low` as non-monotone because it
also checks the n-specific curves. That is appropriate under the v1 rule.

## 5. Interpretation

Exp44b v1 is a calibration no-go, but it is a retryable design failure.

The useful lesson is:

```text
strict pointwise monotonicity at 50 instances per n/rho cell is too brittle for
this heterogeneous Cardinality-SAT calibration surface.
```

This does not justify rescuing Exp44b v1. It justifies a later versioned
Cardinality-SAT attempt with a better precommitted calibration gate.

## 6. Requirements For A Later Version

A later Exp44c / Exp44b-v2 style attempt should be opened as a fresh versioned
design. It should not reuse this v1 outcome as confirmatory evidence.

Minimum changes before another calibration:

1. Replace strict pointwise monotonicity with a noise-aware rule.
   Candidate rules include isotonic-fit monotonicity, confidence-interval
   monotonicity, Spearman-direction plus bounded-reversal tolerance, or a
   two-stage targeted replication rule. The choice must be fixed before the
   next solver run.
2. Add a targeted replication stage for light cells where row-level noise can
   dominate.
   `M3_threeway_low` around `rho = 0.64, 0.68, 0.72` is the concrete example.
3. Keep power-collapse and timeout/malformed gates.
   The v1 diagnostics were useful and should remain part of the boundary.
4. Keep primary validation separate.
   No primary package should be generated until the new calibration closeout
   passes under its precommitted rule.

## 7. Non-Claims

This audit does not claim:

1. Exp44b support.
2. Cardinality-SAT empirical validation.
3. A right to tune Exp44b v1 into a primary package.
4. That strict monotonicity was wrong as a v1 discipline rule.

It only records that the observed no-go is small, local, and informative for a
future versioned calibration design.
