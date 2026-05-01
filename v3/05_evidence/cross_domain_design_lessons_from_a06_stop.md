Cross-Domain Design Lessons From A06-stop
=========================================

status: methodological_lesson_memo

date: 2026-05-01 JST

source_domain: coding_channel_stopping_set_recovery

primary source files:

```text
03_domains/01_specification_fixed/coding_channel_stopping_set_recovery.md

05_evidence/a06_stop_coding_channel_stopping_set_recovery/
  row_level_diagnostic_memo_after_normalized_pressure_smoke_v1.md

05_evidence/a06_stop_coding_channel_stopping_set_recovery/
  primary_v2_orderwise_terms_result_summary.md
```


0. Purpose
----------

This memo records cross-domain methodological lessons from the A06-stop
stopping-set recovery package. It is not validation evidence and does not
change any support / no-support decision.

The point is to preserve design lessons that should transfer to future
specification-fixed, structurally inferred, and conditional-embedding packages.


1. Change Of Structural Condition Means A New Package
-----------------------------------------------------

A06/A19 and A06-stop live in the same broad BEC / linear-code domain, but they
do not test the same structure.

- A06/A19 tests rank-based unique recovery / maximum-likelihood-style
  identifiability.
- A06-stop tests decoder-specific recovery by the fixed BEC peeling decoder.

The same row data cannot simply be reinterpreted as support for the new
condition. Once the maintained structure \(G\), feasible set \(V_G\), endpoint,
or collapse boundary changes, the package must be separated with its own
manifest, frozen surface, baselines, guardrails, and decision rule.

Cross-domain rule:

> A new structural condition is a new validation package, even if it uses the
> same physical or computational domain.


2. Exact Anchor And Predictive Support Are Different
----------------------------------------------------

A06-stop has a clean specification-fixed anchor:

```text
peeling failure iff the residual erased core S_infty is nonempty
```

and an exact decoder-specific accounting readout:

\[
L_{\mathrm{stop}}(H,E)=|S_\infty(H,E)|\log 2.
\]

This exact anchor is not itself predictive support. Predictive support requires
pre-outcome coordinates, fixed baselines, held-out labels, and a frozen
decision rule.

Cross-domain rule:

> If a domain has an exact same-time collapse criterion, use it as an
> accounting anchor. Do not count it as predictive support unless the task uses
> held-out, future, or partial-information prediction.


3. Raw Proxies Can Be Predictive And Still Not Clean
----------------------------------------------------

In A06-stop, raw stopping pressure was strongly predictive on smoke rows, but
it was also strongly entangled with generic hazard and rank-dependency
pressure:

```text
corr(log1p_H_stop_5, q):                       Pearson 0.7983
corr(log1p_H_stop_5, log1p_H_dep_4):            Pearson 0.6777
corr(log1p_H_stop_5, rank_failure_fraction):    Pearson 0.8881
```

This made raw stopping pressure a useful diagnostic, but a risky primary
support coordinate.

Cross-domain rule:

> A strong raw coordinate should trigger confound diagnostics before it is
> treated as structural support. Size, exposure, hazard, rank, density, degree,
> and resource proxies are common absorbers.


4. Normalization Can Improve Design While Weakening Signal
----------------------------------------------------------

The normalized stopping pressure was more principled as a design because it
reduced raw subset-volume effects:

\[
\frac{N_j^{\mathrm{stop}}(H)}{\binom{n}{j}}p^j.
\]

But it also compressed the signal:

```text
test n=24, q=0.18 mean log1p_H_stop_5_norm:  0.0001701261
test n=32, q=0.18 mean log1p_H_stop_5_norm:  0.0000427580
```

In the frozen v2 run, the order-wise normalized bundle was directionally
positive but below the support gate.

Cross-domain rule:

> Cleaner coordinates are not automatically stronger predictors. Normalization
> can remove confounding signal and real signal at the same time. Always check
> scale, compression, and regime dependence.


5. Scalar Aggregation Can Hide Order Or Component Structure
-----------------------------------------------------------

The row-level A06-stop diagnostic showed uneven order-wise behavior: \(j=2\)
and \(j=4\) looked more promising than \(j=3\) and \(j=5\), but selecting only
those orders would have been post-hoc. The v2 package therefore used the full
pre-fixed \(j=2,\ldots,5\) bundle as primary and kept order-specific effects as
diagnostics.

Cross-domain rule:

> If a scalar aggregate is weak or ambiguous, decompose it for diagnosis. If a
> component-wise package is justified, freeze the whole component design before
> outcome-bearing execution. Do not promote the best-looking component after
> seeing smoke results.


6. Guardrail Absorption Is Information, Not Just Failure
--------------------------------------------------------

The A06-stop v2 frozen primary was directionally positive:

```text
relative improvement:      0.6366 percent
bootstrap positive rate:   0.9925
```

but failed the pre-fixed 1 percent support gate. The hazard guardrail remained
positive, while the rank-dependency guardrail was weak:

```text
hazard bootstrap positive rate:   0.9895
rankdep bootstrap positive rate:  0.83
```

This says something substantive: stopping-set pressure carries some
peeling-failure signal, but on this surface it overlaps strongly with
rank-dependency structure.

Cross-domain rule:

> A guardrail can teach where a coordinate is being absorbed. Treat guardrail
> failure as structural information about overlap, not merely as an unhelpful
> negative result.


7. Support Gate And Directional Signal Should Be Separated
----------------------------------------------------------

The A06-stop v2 result is not support under the frozen rule because the
improvement was below the pre-fixed 1 percent gate. But it is also not a
zero-signal result: the direction was positive and the bootstrap rate was high.

Recommended vocabulary:

```text
directional_positive:
  improvement > 0 and bootstrap direction is stable

no_support:
  frozen support gate fails

support:
  frozen primary gate passes

clean_support:
  support plus required guardrails pass

caveated_support:
  primary gate passes but one or more guardrails fail
```

Cross-domain rule:

> Record directional-positive no-support explicitly. It is useful design
> information, but it should not be promoted to support after the fact.


8. Smoke Is For Design, Frozen Runs Are For Evidence
----------------------------------------------------

A06-stop used smoke and freeze-prep runs to discover that:

- raw stopping pressure was entangled;
- normalized scalar pressure was over-compressed;
- order-wise normalized terms were more promising;
- rank-dependency was the main clean-support risk.

Those smoke rows were not converted into evidence. They justified a new frozen
manifest, then the frozen v2 result was recorded according to its rule.

Cross-domain rule:

> Smoke can guide successor design. It cannot become support or no-support.
> A successor must use a new manifest, new frozen seeds / commands, and a
> pre-fixed decision rule.


9. No-Support Is A Methodological Asset
---------------------------------------

A06-stop v2 is a no-support result, but it is valuable:

- the specification-fixed peeling anchor remains valid;
- the predictive stopping-set coordinate is directionally positive;
- rank-dependency overlap is the current limiting factor;
- future same-domain work should focus on matched-rank or decoder-gap surfaces.

Cross-domain rule:

> Preserve no-support results with their reason. They tell future packages
> which confounds to control and which structural distinction remains unresolved.


10. Transfer To Other Domains
-----------------------------

For future packages, apply the A06-stop lessons as follows.

Specification-fixed domains:

- Define \(G,V,m\), update process, and collapse boundary before prediction.
- Separate exact accounting anchors from predictive support.
- Use matched surfaces when a guardrail absorbs the main coordinate.

Structurally inferred domains:

- Treat inferred coordinates as candidate readouts, not law-side quantities.
- Expect raw proxies to be entangled with size, exposure, severity, or resource
  measures.
- Preserve directional-positive no-support as design evidence, not validation
  support.

Conditional-embedding domains:

- Do not claim predictive improvement when the package is only mapping an
  existing theorem into \(d_t,r_t,b_t,B_n\) vocabulary.
- Use the embedding to choose meaningful guardrails and endpoints for any
  later empirical package.


11. Immediate Same-Domain Successor Ideas
-----------------------------------------

A06-stop can still be advanced in the same domain, but the next package should
not be a simple rerun. The useful successor direction is to separate
rank-dependency from stopping-set structure:

- matched-rank code families with different stopping spectra;
- degree / \(q\) / hazard matched families with separated stopping spectra;
- endpoints restricted to decoder-gap regimes where peeling can fail even when
  rank-based unique recovery may remain possible;
- construction-controlled parity-check matrices that vary local stopping
  structure while holding coarse rank pressure approximately fixed.

Any such package must be separately manifested before outcome-bearing
execution.
