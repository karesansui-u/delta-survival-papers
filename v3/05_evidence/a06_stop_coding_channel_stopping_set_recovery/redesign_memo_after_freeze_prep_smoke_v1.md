A06-stop Redesign Memo After Freeze-Prep Smoke v1
=================================================

domain_id: coding_channel_stopping_set_recovery

status: redesign_memo_not_validation_evidence

date: 2026-05-01 JST


1. Current Smoke Conclusion
---------------------------

The A06-stop smoke and freeze-prep smoke runs were useful as pre-freeze
engineering and design checks. They are not validation evidence and do not
support a support/no-support decision.

What worked:

- the BEC peeling decoder and residual-core audit executed;
- the all-stopping-set counter through order 5 executed;
- the rank-dependency guardrail feature path executed;
- split and label/sample audits passed;
- the endpoint was nondegenerate;
- the \(q\)-grid produced a useful prevalence range;
- the counter cost for \(n=24,32\), order 5 is feasible for a finite primary
  package.

Key freeze-prep smoke v1 diagnostics:

```text
test prevalence:                         0.2410888671875
B1 test log loss:                        0.4985912785057697
B1 + stop scalar test log loss:          0.4976963432791569
relative improvement:                    0.0017949275592922622
bootstrap positive rate:                 0.769
hazard guardrail relative improvement:   0.00020863202011920496
hazard guardrail bootstrap positive:     0.578
rankdep guardrail relative improvement:  0.0012677426116176013
rankdep guardrail bootstrap positive:    0.835
```

The current scalar coordinate \(\log(1+H_{\mathrm{stop},5})\) is therefore
weak on this surface. The implementation is healthy, but the current scalar
primary should not be frozen as the next primary validation package.


2. Why Not Freeze The Current Scalar Primary
--------------------------------------------

The freeze-prep smoke v1 result does not justify freezing the current scalar
primary. The reasons are:

1. The improvement over \(B1\) is small.
2. The hazard guardrail absorbs most of the gain.
3. The rank-dependency guardrail also weakens the clean stopping-set reading.
4. \(B0\) performs better than \(B1\) on the smoke test split, suggesting that
   baseline design should be separated and stabilized before any primary run.
5. The smoke rows are not frozen validation evidence and cannot be promoted
   into support or no-support after the fact.

This is a design-stop decision, not a negative validation result.


3. Redesign Axes
----------------

The next candidate should be designed as a new draft / frozen manifest, not as
a reinterpretation of the existing smoke rows.

Priority 1: baseline two-tier plus normalized pressure.

- \(B1_{\mathrm{simple}}\): \(q,n,k,r,\mathrm{rate}\), capacity margin, and
  parity-check density.
- \(B1_{\mathrm{degree}}\): \(B1_{\mathrm{simple}}\) plus check-degree and
  variable-degree summaries / histograms.
- Normalized all-stopping pressure:
  \[
  \widetilde H_{\mathrm{stop},r}(H,p)
  =
  \sum_{j=2}^{r}
  \frac{N_j^{\mathrm{stop}}(H)}{\binom{n}{j}}p^j.
  \]

This keeps the all-stopping-set definition but reduces the raw subset-volume
effect from \(n\) and order \(j\).

Priority 2: term-vector candidate.

- Use order-specific normalized terms as separate pre-fixed features:
  \[
  \frac{N_j^{\mathrm{stop}}(H)}{\binom{n}{j}}p^j,\quad j=2,\ldots,r.
  \]
- This cannot be promoted from the existing smoke result. It requires a new
  manifest that fixes the term vector before outcome-bearing execution.

Priority 3: minimal stopping sets.

- Count minimal stopping sets rather than all stopping sets.
- This may be theoretically cleaner because it reduces superset overcounting.
- It requires separate implementation, sanity cases, cost measurement, and a
  separate manifest.

Priority 4: q-grid redesign.

- The current \(q\)-grid is useful for endpoint range, but hazard can dominate
  at higher \(q\).
- A future design may focus on an intermediate regime, but the new grid must
  be fixed before outcome-bearing execution.


4. Governance Rule
------------------

The governance decision after freeze-prep smoke v1 is:

```text
Do not freeze the current log1p_H_stop_5 scalar primary.
```

The existing smoke rows:

- cannot be reinterpreted as validation support;
- cannot be recorded as no-support;
- cannot be used to promote the term-vector diagnostic to primary;
- can only be used as pre-freeze design information.

Any next package must use a new draft or frozen manifest that fixes:

- the structural condition;
- the primary coordinate;
- the baseline tier;
- the guardrails;
- the \(q\)-grid;
- the support rule;
- scripts, hashes, seeds, and commands;
- the interpretation of clean / caveated / no-support outcomes.


5. Recommended Next Design
--------------------------

The recommended next design is:

```text
A06-stop-v1-normalized-pressure
```

with:

- \(B1_{\mathrm{simple}}\) and \(B1_{\mathrm{degree}}\) both reported;
- primary comparison against the pre-fixed stronger baseline tier chosen in
  the manifest;
- normalized all-stopping pressure as the primary scalar;
- normalized term-vector as diagnostic only unless separately promoted before
  freezing;
- the same clean / caveated guardrail governance used in the draft profile.

This design should be reviewed before any support-bearing primary execution.
