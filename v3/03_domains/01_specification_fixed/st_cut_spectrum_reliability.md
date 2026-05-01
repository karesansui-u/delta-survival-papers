S-t Cut-Spectrum Reliability
============================

domain_id: st_cut_spectrum_reliability

domain_name: S-t cut-spectrum reliability

classification: specification_fixed

status: supported_kappa2_kappa3; invalid_run_v0


1. Maintenance Target
---------------------

- Target structure: a finite undirected graph maintains connectivity between a
  fixed source terminal \(s\) and sink terminal \(t\).
- Failure / collapse boundary: \(s\) and \(t\) are disconnected after edge
  failures.
- Observation unit: a finite graph \(G=(U,E,s,t)\) with fixed terminals and a
  pre-fixed independent edge-failure law. Unless a later package states
  otherwise, every edge fails independently with probability \(q\) and survives
  with probability \(1-q\).
- Prediction unit: a graph / terminal / \(q\) row, or a pre-fixed held-out
  failure sample for that row.
- Initial condition: \(s\) and \(t\) are connected in the intact graph.

This domain is the natural prediction-side companion to A31. A31 reads global
spanning-tree redundancy. This domain reads low-order cutset pressure, which is
closer to short-horizon disconnection probability and network reliability.


2. Exact Reliability Kernel
---------------------------

Let \(\Omega_G=\{0,1\}^{E}\) be the set of edge survival states, where
\(\omega_e=1\) means edge \(e\) survives. Define

\[
V_G=\{\omega\in\Omega_G:\ s\leftrightarrow t\text{ in }(U,\{e:\omega_e=1\})\}.
\]

Under the product edge-failure measure \(m_q\),

\[
m_q(\omega)=
\prod_{e\in E}(1-q)^{\omega_e}q^{1-\omega_e}.
\]

The exact \(s\)-\(t\) reliability is

\[
R_G(q)=m_q(V_G)=\Pr_q(s\leftrightarrow t).
\]

The exact loss coordinate is

\[
L_G(q)=-\log R_G(q),
\]

with \(L_G(q)=+\infty\) when \(R_G(q)=0\). This is a specification-fixed
accounting anchor, not a prediction win. Exact \(R_G(q)\), exact future
connectivity for a realized failure state, or a Monte Carlo estimate of
\(R_G(q)\) must not be used as primary baseline features in a prediction
support package.


3. Cut-Spectrum Coordinate
--------------------------

An \(s\)-\(t\) cutset is an edge set \(C\subseteq E\) such that removing \(C\)
disconnects \(s\) from \(t\). It is minimal if no proper subset of \(C\)
disconnects \(s\) from \(t\). Let

\[
\kappa(G;s,t)=\min\{|C|:\ C\text{ is an }s\text{-}t\text{ cutset}\}
\]

and let \(N_j(G;s,t)\) be the number of minimal \(s\)-\(t\) cutsets of size
\(j\). For a frozen bandwidth \(r\), the low-order cut-spectrum pressure is

\[
H_{\mathrm{cut},r}(G,q)=
\sum_{j=\kappa}^{\kappa+r}N_j(G;s,t)q^j.
\]

The primary SP coordinate for the A12 frozen packages is the scalar
log-pressure:

\[
\log(1+H_{\mathrm{cut},2}(G,q)).
\]

The term vector
\((N_{\kappa}q^{\kappa},N_{\kappa+1}q^{\kappa+1},
N_{\kappa+2}q^{\kappa+2})\) and the scalar-plus-vector bundle may be reported as
attribution diagnostics, but they are not the primary support coordinate for
the v0b/v0c successor packages.

The coordinate is intentionally local in cut order. It is not the exact
reliability and should be described as a frozen low-order loss proxy.

For the supported v0b/v0c successor packages, the scalar log-pressure is
support-bearing. Term-vector and bundle variants are attribution ablations and
must not be promoted to primary after test results are known.


4. Operational Cutset Embedding
-------------------------------

A12 does not claim a new general network reliability theorem. The point is
more modest: for fixed finite \(s\)-\(t\) reliability systems under independent
edge failures, the frozen cut-pressure coordinate corresponds to the low-order
cutset expansion of the operational failure probability.

Let

\[
\mathcal C_{\mathrm{inc}}(G;s,t)
=\{C\subseteq E:\ C\text{ is inclusion-minimal among }s\text{-}t\text{ cutsets}\}.
\]

This is the set of inclusion-minimal cutsets, not only the cutsets of minimum
cardinality. Define

\[
\kappa=\min_{C\in\mathcal C_{\mathrm{inc}}}|C|,
\qquad
N_j=\left|\{C\in\mathcal C_{\mathrm{inc}}:\ |C|=j\}\right|.
\]

If \(F\subseteq E\) is the random failed-edge set under independent edge
failure probability \(q\), then

\[
\{s\not\leftrightarrow t\}
=
\bigcup_{C\in\mathcal C_{\mathrm{inc}}}\{C\subseteq F\}.
\]

Therefore the cutset union-bound pressure gives

\[
\Pr_q(s\not\leftrightarrow t)
\le
\sum_{C\in\mathcal C_{\mathrm{inc}}}q^{|C|}
=
\sum_j N_jq^j.
\]

For a fixed finite graph whose intact graph connects \(s\) and \(t\), with
\(\kappa\ge1\), distinct minimum-size cutset events overlap only through
failures of at least \(\kappa+1\) distinct edges. Hence their intersections
contribute \(O(q^{\kappa+1})\), and the low-failure expansion has leading term

\[
\Pr_q(s\not\leftrightarrow t)
=
N_\kappa q^\kappa + O(q^{\kappa+1})
\qquad(q\to0).
\]

The A12 coordinate

\[
H_{\mathrm{cut},2}(G,q)
=
\sum_{j=\kappa}^{\kappa+2}N_j(G;s,t)q^j
\]

is therefore a frozen low-order truncation of the cutset union-bound pressure,
not the full reliability and not the full union bound. The v0b/v0c frozen
support records that this low-order pressure coordinate added prediction value
over the pre-fixed natural graph baseline on two finite synthetic surfaces. It
does not prove exact reliability superiority, arbitrary-\(\kappa\) support, or
real-network support.


5. Prediction Surface
---------------------

Empirical support, if sought, must use held-out graphs, held-out graph families,
or held-out failure samples. The clean A12 target is:

\[
Y_{G,q,k}=1\{\text{failure sample }k\text{ disconnects }s\text{ from }t\}.
\]

Evaluation may aggregate \(K\) held-out failure samples per graph / \(q\) row as
a binomial label. A graph-id grouped binomial log loss is preferred so that
rows with more simulated samples do not receive extra weight.

Acceptable primary targets:

- \(s\)-\(t\) disconnection probability under the pre-fixed independent failure
  law;
- binary held-out \(s\)-\(t\) disconnection under sampled failure states;
- matched-family reliability ranking when the primary endpoint remains
  disconnection / reliability.

Secondary targets:

- all-terminal connectivity;
- retained spanning-tree mass;
- long-horizon degradation under sequential deletion.

Secondary targets should not be silently substituted for the primary target
after results are known.


6. Baselines and Oracle Exclusions
----------------------------------

Primary comparison:

\[
B1 + \log(1+H_{\mathrm{cut},2})
\quad\text{vs}\quad
B1.
\]

Recommended \(B1\) natural graph baseline:

- \(n=|U|\), \(m=|E|\), density;
- terminal degrees \(\deg(s)\), \(\deg(t)\);
- average degree and degree variance;
- \(s\)-\(t\) min-cut size \(\kappa\);
- shortest \(s\)-\(t\) path length;
- global bridge count, but not \(s\)-\(t\)-separating bridge count;
- \(q\) and simple interactions with size or min-cut if frozen before the run.

The \(B1\) baseline must include \(\kappa\). Otherwise the SP coordinate could
win merely by rediscovering min-cut size.

The supported v0b/v0c surfaces are restricted to \(\kappa\in\{2,3\}\). If a
later package allows \(\kappa=1\), \(s\)-\(t\)-separating bridge indicators
become too close to first-order cutset counts and must remain outside the
baseline unless the package is explicitly redesigned.

The \(B1_{\mathrm{hazard}}\) guardrail adds \(q^{\kappa}\),
\(q^{\kappa+1}\), and \(q^{\kappa+2}\), but no cutset counts. This diagnostic
checks whether any scalar SP gain is merely a nonlinear \(q,\kappa\) hazard
transform.

Primary summaries must report both the main \(B1\) comparison and the hazard
guardrail comparison. If the main gate passes but the hazard guardrail absorbs
the gain, the claim should be phrased as support for a low-order pressure proxy,
not clean evidence for cutset-count information beyond nonlinear
\((q,\kappa)\) terms.

Forbidden primary features:

- exact \(R_G(q)\) or exact failure probability;
- Monte Carlo reliability estimates;
- realized failed-edge set for the label being predicted;
- final \(s\)-\(t\) connectivity of the realized failure state;
- \(N_j\) low-order cutset counts or \(H_{\mathrm{cut},r}\) inside the baseline.

Wide guardrail baseline, if used:

- algebraic connectivity or spectral summaries;
- effective resistance between \(s\) and \(t\);
- betweenness summaries;
- richer graph invariants fixed before the run.

The wide baseline is a guardrail unless a manifest explicitly makes it primary.


7. Frozen Validation Status
---------------------------

The first frozen primary package is recorded as an invalid run:

```text
05_evidence/a12_st_cut_spectrum_reliability/primary_v0_invalid_run_summary.md
```

This was not support and not no-support. The generator reached the frozen
attempt cap for the \(n=16,m=24,\kappa=3\) cell with zero eligible candidates
and therefore produced no prediction labels or model metrics. The result is a
frozen-surface feasibility failure, not evidence against the cut-spectrum
coordinate.

A successor A12 package must be frozen separately. Natural successor routes are
a \(\kappa=2\)-only finite surface, a redesigned \(\kappa=3\) graph generator
with pre-run feasibility checks, or a larger graph family where \(\kappa=3\)
feasibility is established before outcome-bearing labels are generated.

The first successor package is recorded here:

```text
05_evidence/a12_st_cut_spectrum_reliability/primary_v0b_kappa2_result_summary.md
```

This package passed its frozen primary gate on a \(\kappa=2\)-only finite
two-cluster synthetic surface. The result is support for scalar low-order
cut-spectrum pressure in that restricted surface only. It is not support for
\(\kappa=3\), broader graph families, exact reliability superiority, A31, or
\(M\)-side validation.

The second successor package is recorded here:

```text
05_evidence/a12_st_cut_spectrum_reliability/primary_v0c_kappa3_result_summary.md
```

This package passed its frozen primary gate on a \(\kappa=3\)-only finite
two-cluster synthetic surface using a constructive cluster generator and a
higher exact-enumeration cap. Together with v0b, the A12 coordinate has two
separate finite synthetic support surfaces:

```text
05_evidence/a12_st_cut_spectrum_reliability/replication_summary.md
```

The joint claim remains bounded: finite \(\kappa=2\) and \(\kappa=3\)
synthetic support for the scalar low-order cut-spectrum pressure coordinate,
not arbitrary-\(\kappa\), real-world network, exact-reliability, A31, or
\(M\)-side support.


8. Frozen Validation Candidate Discipline
-----------------------------------------

Any future A12 prediction package should freeze:

1. graph generator or external graph source;
2. terminal selection rule;
3. \(q\)-grid;
4. minimal cutset enumeration algorithm and maximum order \(r=2\);
5. \(K\) failure samples per graph / \(q\) row, if simulated labels are used;
6. train / validation / test split by graph id;
7. model class and tuning grid;
8. graph-id grouped log-loss metric;
9. support gate, for example:
   - \(B1+SP\) has lower held-out log loss than \(B1\);
   - relative improvement is at least 1 percent;
   - paired graph-id bootstrap positive rate is at least 90 percent;
   - oracle-exclusion and label audits pass.

Horizon selection is not needed for an independent edge-failure A12 surface.
If a sequential deletion version is used later, the horizon rule must be
prevalence-only and must not inspect model performance.


9. A31 Boundary
---------------

A31 should not be rescued by moving its no-support endpoint into this domain.
The intended division is:

- A31: exact spanning-tree accounting anchor and global redundancy coordinate.
- A12 / this domain: disconnection probability, network reliability, and
  cut-spectrum prediction.

If this domain obtains support, it supports the low-order cut-spectrum
prediction claim under its frozen surface. It does not retroactively convert
A31 primary_v0 into support.

If a frozen A12 package fails, the result should be recorded as no-support for
that exact surface. A later attempt remains possible only as a new successor
package with a separately frozen graph family, seed block, external archive, or
endpoint. The failed rows may be used for diagnosis, not relabeled as support.


10. Validation Status
--------------------

- current status: `supported_kappa2_kappa3; invalid_run_v0`.
- invalid frozen primary:
  `../../05_evidence/a12_st_cut_spectrum_reliability/primary_v0_invalid_run_summary.md`.
- supported successor records:
  `../../05_evidence/a12_st_cut_spectrum_reliability/primary_v0b_kappa2_result_summary.md`;
  `../../05_evidence/a12_st_cut_spectrum_reliability/primary_v0c_kappa3_result_summary.md`.
- replication summary:
  `../../05_evidence/a12_st_cut_spectrum_reliability/replication_summary.md`.
- smoke harness:
  `../../05_evidence/a12_st_cut_spectrum_reliability/`; smoke outputs are not
  evidence.


11. Claims
---------

This domain currently supports, within the two frozen finite synthetic
successor surfaces:

- incremental predictive support for a low-order cut-spectrum coordinate in
  finite \(\kappa=2\) and \(\kappa=3\) \(s\)-\(t\) reliability prediction;
- a specification-fixed reliability kernel based on
  \(V_G\), \(m_q\), \(R_G(q)\), and \(L_G(q)\);
- a disciplined separation between exact reliability accounting and empirical
  prediction support.

This domain does not support:

- a new network reliability theorem;
- superiority over exact reliability computation;
- arbitrary-\(\kappa\) support;
- real-world infrastructure reliability;
- all-terminal reliability unless separately frozen;
- A31 spanning-tree prediction support;
- \(M\)-side component validation;
- universal-law closure outside the registered finite graph setting.
