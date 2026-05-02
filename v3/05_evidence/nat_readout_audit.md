Nat Readout Audit
=================

status: audit_note_no_new_evidence

date: 2026-05-03 JST

This note records where existing v3 artifacts already support nat-scale
readouts, and where they only support proxy or estimation-layer indicators. It
does not create a new support decision, change any no-support / invalid-run
record, or re-score any frozen package.


1. Reading Rule
---------------

There are three different objects that are easy to confuse.

| class | formula | what it means |
|---|---|---|
| exact structural nat | \(-\log(m(V_{\mathrm{after}})/m(V_{\mathrm{before}}))\) | a pre-fixed structural mass or distinguishable mass ratio |
| sampled scenario nat | \(-\log(\text{successful future mass})\) | a nat readout under a fixed sampled future-scenario distribution |
| predictive log loss | held-out negative log likelihood | a model-scoring quantity; not automatically structural consumption |

Thus, a held-out log loss may be reported in nats if natural logarithms are
used, but it is not the same object as the structural consumption \(L\) unless
the scored probability is explicitly the retained structural or scenario
maintenance mass.


2. A31 Graph Spanning-Tree Persistence
--------------------------------------

Relevant artifacts:

- `05_evidence/a31_graph_spanning_tree_persistence/primary_v0/states.csv`
- `05_evidence/a31_graph_spanning_tree_persistence/primary_v0/labels_by_horizon.csv`
- `05_evidence/a31_graph_spanning_tree_persistence/primary_v0/future_paths.csv`

Current row counts:

- `states.csv`: 1,065 state rows plus header.
- `labels_by_horizon.csv`: 3,195 label rows plus header.
- future trajectories per state / horizon label: \(K=64\).

Exact nat readout:

`states.csv` contains `tau0`, `tau`, `log_tau0`, `log_tau`, and `L_t`.
For any row with positive spanning-tree count,

\[
L_\tau(G_t)
=-\log\frac{\tau(G_t)}{\tau(G_0)}
=\log\tau(G_0)-\log\tau(G_t).
\]

This is an exact specification-fixed accounting nat for retained spanning-tree
mass. It is not by itself a predictive support claim. In particular, A31
primary_v0 remains no-support for the original incremental log-loss prediction
gate; the later matched residual package is a separate successor package.

Sampled future-scenario nat:

`labels_by_horizon.csv` contains `K`, `z`, and `collapse_fraction`, where
`z/K` is the sampled future collapse fraction at the fixed horizon. If the
maintained function is future connectivity, the sampled retained scenario mass is

\[
\widehat p_{\mathrm{maintain}} = 1-\frac{z}{K}.
\]

When \(0<\widehat p_{\mathrm{maintain}}\le 1\), the sampled maintenance loss is

\[
\widehat C_{\mathrm{maintain}}
=-\log\widehat p_{\mathrm{maintain}}
=-\log\left(1-\frac{z}{K}\right).
\]

If \(z=K\), the sampled retained mass is zero and the row hits the chosen
collapse boundary for that sampled horizon.


3. A06/A19 BEC Linear-Code Recovery
-----------------------------------

Relevant artifacts:

- `05_evidence/a06_a19_coding_channel_recovery/primary_v0/erasure_samples.csv`
- `05_evidence/a06_a19_coding_channel_recovery/primary_v0/labels.csv`
- `05_evidence/a06_a19_coding_channel_recovery/primary_v0/features.csv`

Current row counts:

- `erasure_samples.csv`: 245,760 sample rows plus header.
- `labels.csv`: 960 label rows plus header.
- future erasure samples per code / \(q\) row: \(K=256\).

Exact rank nat readout:

`erasure_samples.csv` contains `erased_count`, `erased_rank`,
`ambiguity_dim`, and `failure`. For a sampled erasure set \(E\),

\[
a(E)=|E|-\operatorname{rank}(H_E).
\]

The compatible ambiguity grows as \(2^{a(E)}\), but the structural-loss
coordinate is defined on retained distinguishable message-cell mass:

\[
\frac{m(V_E)}{m(V_0)}=2^{-a(E)},
\qquad
L_E=a(E)\log 2.
\]

Thus `ambiguity_dim * log 2` is an exact per-sample rank-accounting nat for the
fixed sampled erasure set. `labels.csv` also contains `mean_ambiguity_dim`,
which gives a sample mean of this exact rank nat after multiplication by
\(\log 2\). This mean is not identical to the sampled survival nat below.

Sampled future-scenario nat:

`labels.csv` contains `K`, `z`, and `failure_fraction`, where `z/K` is the
sampled unique-recovery failure fraction. The retained future scenario mass for
unique recovery is

\[
\widehat p_{\mathrm{unique}}=1-\frac{z}{K}.
\]

When \(0<\widehat p_{\mathrm{unique}}\le 1\),

\[
\widehat C_{\mathrm{unique}}
=-\log\widehat p_{\mathrm{unique}}
=-\log\left(1-\frac{z}{K}\right).
\]

Proxy warning:

`features.csv` contains low-order dependency coordinates such as
`log1p_H_dep_4`. These are frozen predictive coordinates. They are not the exact
rank nat \(a(E)\log 2\) for a realized erasure set.


4. A12 s-t Cut-Spectrum Reliability
-----------------------------------

Relevant artifacts:

- `05_evidence/a12_st_cut_spectrum_reliability/primary_v0b_kappa2/labels.csv`
- `05_evidence/a12_st_cut_spectrum_reliability/primary_v0b_kappa2/features.csv`
- `05_evidence/a12_st_cut_spectrum_reliability/primary_v0b_kappa2/cutsets.csv`

Current row counts:

- `labels.csv`: 320 label rows plus header.
- `features.csv`: 320 feature rows plus header.
- future edge-failure samples per graph / \(q\) row: \(K=256\).

Sampled future-scenario nat:

`labels.csv` contains `K`, `z`, and `disconnect_fraction`, where `z/K` is the
sampled future disconnection fraction. The retained scenario mass for
\(s\)-\(t\) connection is

\[
\widehat p_{\mathrm{connect}}=1-\frac{z}{K}.
\]

When \(0<\widehat p_{\mathrm{connect}}\le 1\),

\[
\widehat C_{\mathrm{connect}}
=-\log\widehat p_{\mathrm{connect}}
=-\log\left(1-\frac{z}{K}\right).
\]

Cutset pressure warning:

`features.csv` contains exact low-order cutset counts and the derived
`log1p_H_cut_2`. This is a low-order union-bound pressure coordinate. It is a
specification-fixed proxy for cutset risk, not the exact nat of retained
\(s\)-\(t\) connectivity mass and not exact reliability superiority.


5. Finite CSP Packages
----------------------

The finite CSP theorem-side anchor supplies a first-moment collapse coordinate
\(L_n^{\mathrm{FM}}\) and a second-moment survival scaffold. When an artifact
contains a pre-fixed candidate-count or first-moment mass ratio, the same
structural nat rule applies:

\[
L=-\log\frac{m(V_{\mathrm{after}})}{m(V_{\mathrm{before}})}.
\]

The current evidence dashboard records finite CSP and q-coloring support
packages and outside reruns, but this audit does not re-open their row-level
artifacts or change those support records.


6. What Is Not Yet Nat-Measured
-------------------------------

The following records should not be cited as exact structural nat unless a
separate artifact fixes \(F\), the future scenario set, the success rule, and
the mass \(m\):

- LLM reasoning observational anchors;
- continual-learning observational anchors;
- software contract-coherence field demonstrations;
- Backblaze observational packages;
- optional \(M\)-side component diagnostics.

These may contain useful observation or prediction metrics. They are not
automatically nat-scale structural consumption. To promote them, a successor
package must freeze a maintenance function \(F\), scenario / observation unit,
success boundary, mass or probability measure \(m\), comparator, metric, and
decision rule.


7. Practical Use
----------------

When adding a new result summary, use the following checklist.

1. If the artifact contains a direct mass ratio such as `tau/tau0` or
   \(2^{-a(E)}\), record it as exact structural nat.
2. If the artifact contains sampled future scenarios with \(K\) and failure
   count \(z\), record sampled maintenance nat as
   \(-\log(1-z/K)\), with an explicit boundary convention for \(z=K\).
3. If the artifact contains a predictive feature such as `log1p_H_cut_2` or
   `log1p_H_dep_4`, do not call it exact nat unless the feature is itself a
   retained mass ratio.
4. If the artifact only contains observational indicators, keep it in the
   estimation layer as a candidate readout.
