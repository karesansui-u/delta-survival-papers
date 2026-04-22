# Paper 5 §1-7 Review Summary

Date: 2026-04-22

Status: review summary for promotion decision. Local only.

Target eventual file:

```text
v2/5_構造持続における資源項Mの操作的定式化.md
```

---

## 1. Essence

Paper 5 is not a new universality proof. It is the operational support-side
coordinate system: given structural loss $L$ described by Papers 1/2 and
observed empirically in Papers 3/4, Paper 5 asks which maintenance mode should
be strengthened first.

Its distinctive claim is not better risk prediction by itself, but better
intervention ranking under mode decomposition.

In short:

```text
same L, same R, same scalar M_total;
different mode composition;
different best first intervention.
```

## 2. Structure Of The Draft

| Section | Role | Main claim |
|---|---|---|
| §1 | Problem setting | Scalar $M$ cannot explain why equal resources require different interventions. |
| §2 | Minimal form | $F / \Sigma / R / M$ plus internal modes and external supply channels. |
| §3 | Paper 3/4 mapping | Existing LLM and continual-learning observations can be reread as mode indicators. |
| §4-5 | Software Route C | Software / SaaS gives a tractable first domain for intervention-ranking prediction. |
| §6 | Validation protocol | Risk prediction is preparatory; intervention-ranking agreement is primary. |
| §7 | Limitations | The draft is a framework / protocol paper, not completed empirical validation. |

## 3. Provisional Decisions

The current draft is governed by nine decisions recorded in
`PAPER5_DRAFT_PLAN.md` §12.

| Decision | Content | Status |
|---|---|---|
| D1 | Two-level $F$: broad safe-change continuity + narrow bug-detection pilot | reflected in §4-6 |
| D2 | Representation discipline, not product-form theorem | reflected in §2.5 / §6.8 / §7.7 |
| D3 | Time-split primary + leave-one-project-out secondary | reflected in §6 |
| D4 | Mode labels are persistence manners; external support is a supply channel | reflected in §2.2 / §3 / §4.6 |
| D5 | Software is Route C, not Route A | reflected in §4.1 / §6 / §7.2 |
| D6 | DeltaLint split from Paper 5 validation | reflected in §5.4 / §6 / §7.10 |
| D7 | Strong §6 protocol with scalar baseline, robustness, power, causal caveat | reflected in §6 / §7 |
| D8 | §7 closure: framework / protocol paper, four-domain comparison future work | reflected in §7 |
| D9 | Promotion summary and Lean non-blocker | reflected in this summary / §1 |

## 4. Non-Claims

Paper 5 does not claim:

1. a new universal law;
2. a completed empirical pilot;
3. that software / SaaS is Route A;
4. that $\hat L_{\mathrm{pilot}}$ is true $L$;
5. that a single $\rho_i$, $\Phi$, or $A_j$ is correct across domains;
6. that risk prediction alone validates intervention ranking;
7. that observational intervention-ranking support is causal proof;
8. that DeltaLint validates Paper 5;
9. that product-form $\Phi$ has Paper 1-level uniqueness;
10. that four-domain generalization has already been established.

## 5. Promotion Readiness

§7.11 gives the promotion checklist. The current review draft satisfies it.

| Checklist item | Status |
|---|---|
| Framework / protocol paper wording is not overclaiming | pass |
| DeltaLint is not returned as Paper 5 empirical anchor | pass |
| Risk prediction and intervention-ranking support are separated | pass |
| $\rho_i$, $\Phi$, and $A_j$ robustness are built into the claim | pass |
| Empirical pilot is explicitly not complete | pass |
| Software is Route C, not Route A | pass |
| Reader should not infer "Paper 5 is already empirically proven" | pass |

Conclusion: promotion is conceptually permitted. Remaining work is mechanical
cleanup and author review.

## 6. Mechanical Cleanup Before Promotion

If promoted to the main preprint file, do the following:

1. Write a short abstract from this summary.
2. Merge §1-2, §3, §4-5, §6, and §7 into one file.
3. Remove review-draft metadata, source notes, "Resolved by draft" blocks, and
   next-action blocks from the main text.
4. Normalize numbering and cross-references.
5. Keep the DeltaLint extension note separate.
6. Keep the empirical-pilot limitation prominent in the abstract and conclusion.
7. Do not add Lean formalization as a blocker for promotion.

## 7. Lean Status

Lean is not the current blocker for Paper 5.

The useful Lean target for Paper 5 is not a new universality proof. At most, a
later thin scaffold could formalize:

- internal modes and external supply channels as types;
- $\widetilde M_j = A_j(M_j^{\mathrm{int}}, M_{x\to j})$;
- monotonicity of $S=\Phi(\widetilde M_b,\widetilde M_r,\widetilde M_a)e^{-L}$;
- a robustness quantifier saying that an intervention ranking is stable across
  preregistered $\rho_i$, $\Phi$, and $A_j$ candidate families.

This would protect the §6 support criterion, but it would not replace the
operational data needed for Paper 5's empirical claim. Therefore Lean work is
optional and should wait until the paper text or empirical pilot needs it.

## 8. Remaining Research Work

The real remaining work is empirical / operational:

1. identify an operational dataset with intervention history and outcomes;
2. choose the first primary outcome;
3. preregister the §6 validation protocol on that dataset;
4. run the pilot;
5. in parallel, develop the separate DeltaLint Phase 2 preregistration if desired.

## 9. Recommendation

Proceed to promotion cleanup if the author agrees with the current thin-paper
position:

```text
Paper 5 = support-side coordinate system + intervention-ranking protocol.
Not a universality proof.
Not empirically complete yet.
DeltaLint remains separate.
Lean is optional, not a gate.
```
