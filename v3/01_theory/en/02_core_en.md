Core_Structural_Persistence_Minimal_Kernel_and_Balance_Principle_EN
Structural Persistence: Minimal Kernel and Balance Principle
Feasible-region shrinkage, logarithmic exponential kernels, and recovery-aware persistence

Abstract

This paper is a reader-facing synthesis of two companion theoretical papers: *The Minimal Form of Structural Persistence* and *The Balance Principle of Structural Persistence*. It adds no new theoretical kernel, theorem, or empirical support claim. The precise axioms, proofs, and limitations remain those of the two companion papers and the corresponding technical supplements.

The minimal form is not a trivial preliminary. Its first nontrivial move is to treat structural failure not as resource exhaustion, but as shrinkage of the feasible region in which a structure can still be maintained. Under a mild composition principle for measuring already-realized survival ratios, the structural loss scale is forced to be logarithmic. This yields the pathwise exponential kernel
\[
S = M e^{-L},
\]
where \(L\) is cumulative structural consumption and \(M\) is an effective maintenance surplus term on the resource side.

The point is not that resources do not matter. Resources and slack were always part of the usual explanation of persistence. The new separation is between the resource-side term \(M\) and the shrinkage-side term \(L\): even when resources remain, the region compatible with the target structure may shrink until that structure can no longer be maintained.

When repair, recovery, redundancy, rollback, reconfiguration, or external support are made explicit, each time step has structural consumption \(d_t\) and recovery \(r_t\). Their difference
\[
b_t = d_t-r_t
\]
is the net structural consumption. With
\[
B_n=\sum_{t<n} b_t,
\]
the recovery-aware form is
\[
S_n=M_n e^{-B_n}.
\]
The purpose of this core paper is to show, in one reading path, how the closed shrinkage kernel \(S=Me^{-L}\) lifts to the open-system balance kernel \(S=Me^{-B}\).

1. Role of this paper

This paper is the integrated reading path for the main theoretical spine.

| Document | Role |
|---|---|
| Paper 0 | Whole-program map: observability layers, evidence, Lean, supplements |
| This Core Paper | Reader-facing synthesis of Paper 1 and Paper 2 |
| Paper 1 | Strict spine for the loss scale, log-ratio uniqueness, telescoping product, and minimal kernel |
| Paper 2 | Strict spine for two-step updates, recovery, net consumption, and the balance principle |

This paper is therefore not a replacement for the companion papers. It is the shortest public path through them.

Paper 1 is not merely "obvious." It fixes the object that is being measured: the set of states in which a structure can still be maintained. It then shows why the natural loss scale on survival ratios is logarithmic, and why post-hoc choices of the feasible set or measure would make the formalism empty.

2. The question

Long-horizon systems, learning systems, reasoning systems, and constraint systems can lose a structure even when their resources have not literally reached zero. In such cases, the first question is not simply how much resource remains.

The first question is how the region of states compatible with the target structure changes under constraints, contradictions, damage, updates, disturbances, repair, or reconfiguration.

In minimal form, this becomes two questions.

1. In a closed shrinkage mode with no explicit recovery, what is the natural scale for structural consumption?
2. In an open system with recovery, what quantity governs structural persistence?

Paper 1 answers the first question. Paper 2 answers the second. This paper connects them.

3. Pre-fixed structural maintenance problems

Let \(X\) be a system and let \(V\) denote the states compatible with maintaining the target structure. Write the initial feasible region as \(V^{(0)}\). Under accumulating constraints,
\[
V^{(0)} \supseteq V^{(1)} \supseteq \cdots \supseteq V^{(n)}.
\]

A measure \(m\) is fixed to compare the sizes of these feasible regions. Here "measure" simply means the ruler used to read the size of a state set: it may be counting measure, volume, probability weight, or another pre-specified finite measure.

The target structure, measure, stage sequence, and time horizon must be fixed before observing the outcome. If \(V\) or \(m\) can be chosen after seeing the data, almost any monotone sequence can be represented and the theory loses empirical content.

All log-ratios below are read on positive finite masses. Hitting zero is treated separately as a collapse boundary, not as an ordinary finite log-ratio update.

4. Structural consumption and the logarithmic scale

Let \(r\in(0,1]\) be a survival ratio. A structural consumption scale \(f(r)\) should depend on the already-realized ratio, not on the absolute mass. The composition requirement is not a probabilistic independence assumption about how constraints are generated.

It is a measurement requirement. If a shrinkage path factors as
\[
\frac{m(V^{(2)})}{m(V^{(0)})}
=
\frac{m(V^{(1)})}{m(V^{(0)})}
\frac{m(V^{(2)})}{m(V^{(1)})},
\]
then the measured consumption should add:
\[
f(r_1r_2)=f(r_1)+f(r_2).
\]

Overlap, dependence, and redundancy among constraints are already absorbed into the actual feasible sets \(V^{(i)}\) and the ratios \(m(V^{(i)})/m(V^{(i-1)})\). The additivity axiom concerns the scale used to measure those ratios.

Together with normalization and continuity, this functional equation forces
\[
f(r)=-k\log r.
\]
Taking \(k=1\) fixes the unit. The stage consumption is
\[
d_i
=
-\log\frac{m(V^{(i)})}{m(V^{(i-1)})}.
\]

5. Telescoping product and the minimal kernel

Define cumulative structural consumption by
\[
L_n=\sum_{i=1}^{n} d_i.
\]
Then the telescoping product gives
\[
m(V^{(n)})=m(V^{(0)})e^{-L_n}.
\]

This is not the empirical claim that every real system decays exponentially. It is a representation theorem: once a pre-fixed feasible region is measured through log-ratios, the exponential kernel follows algebraically.

Introducing the resource-side term \(M\), the reader-facing structural persistence quantity is
\[
S=Me^{-L}.
\]
The term \(M\) is not derived from the exponential kernel. It represents the effective maintenance surplus available to support the structure. The new law-side coordinate is \(L\), the shrinkage of the feasible region.

6. Recovery and two-step updates

Open systems may repair, restore, buffer, reroute, roll back, or reconfigure. A time step can therefore be read as a two-step update:
\[
V_t^- := K_t(V^{(t)}),
\qquad
V^{(t+1)} := R_t(V_t^-).
\]

Here \(K_t\) is the shrinkage action and \(R_t\) is the recovery action within the fixed observation unit.

Define
\[
d_t
=
-\log\frac{m(V_t^-)}{m(V^{(t)})},
\qquad
r_t
=
\log\frac{m(V^{(t+1)})}{m(V_t^-)}.
\]
Then
\[
b_t=d_t-r_t
=
-\log\frac{m(V^{(t+1)})}{m(V^{(t)})}.
\]

The intermediate set cancels in the log-ratio accounting. This cancellation is not a claim that the physical order of consumption and recovery never matters. If changing the order changes the endpoint \(V^{(t+1)}\), then \(b_t\) changes as well.

7. The balance kernel

Define
\[
B_n=\sum_{t<n}b_t.
\]
The same telescoping argument gives
\[
m(V^{(n)})=m(V^{(0)})e^{-B_n}.
\]
With the resource-side term,
\[
S_n=M_n e^{-B_n}.
\]

If there is no recovery, then \(r_t=0\), \(b_t=d_t\), and \(B_n=L_n\). Thus the balance kernel does not replace the minimal kernel. It extends it.

The central point is simple: in recovery-aware systems, persistence is governed not by consumption alone, but by net consumption.

8. Accounting is not equilibrium

The word "balance" means accounting, not equilibrium. The signs of \(b_t\) give local accounting regimes on a pre-fixed observation unit.

| Condition | Reading |
|---|---|
| \(b_t>0\) | consumption-dominant |
| \(b_t=0\) | locally maintained |
| \(b_t<0\) | recovery-dominant |

These regimes are grain-relative. If two adjacent intervals are merged,
\[
b_{t:t+2}
=
-\log\frac{m(V^{(t+2)})}{m(V^{(t)})}
=
b_t+b_{t+1}.
\]
The cumulative quantity \(B_n\) is additively coherent under time aggregation, but regime labels and hitting boundaries depend on the pre-fixed observation unit. A path that is "consumption followed by recovery" at a fine grain may appear locally maintained at a coarser grain.

9. Observability layers

The same kernel is read through three observability layers.

| Layer | Reading |
|---|---|
| Specification-fixed structural layer | Structure, measure, and boundary are directly fixed by the specification |
| Conditional structural-embedding layer | Existing drift, difference, or hitting-bound theories are mapped conditionally into the structural variables |
| Structurally inferred layer | The structure is not directly counted; observation and inference indicators are frozen and tested |

These are not different theories. They are different observational interfaces to the same kernel.

The law-side claim belongs to the specification-fixed structural layer. The structurally inferred layer is an engineering layer: it uses observation and inference indicators to approximate the law-side coordinates \(L/B/M\). The quality of that approximation is judged only after freezing the mapping and testing whether the structural-persistence indicators add out-of-sample predictive value beyond the domain baseline.

As the approximation improves, the structural persistence coordinates move from explanatory vocabulary toward predictive instrumentation. This is an empirical achievement, not something granted by the notation.

![Figure 1. One structural persistence kernel read through three observability layers.](../figures/figure1_observability_layers_en.svg)

10. Evidence status

In the specification-fixed structural layer, two frozen empirical packages currently provide the hard public entry point:

- Mixed-CSP: three outside rerunners, each with 12,000 primary rows, zero checked core mismatches, and reproduced support flags.
- Exp43c q-coloring: three outside rerunners, each with 4,000 primary rows, zero checked core mismatches, zero timeouts, zero malformed rows, and the same qualitative support decision.

This is not universal-law closure. It is package-scoped outside-rerun support for the first hard law-side footing.

![Figure 2. The minimal kernel lifts to the balance kernel by replacing cumulative consumption \(L\) with cumulative net consumption \(B\).](../figures/figure2_kernel_balance_en.svg)

11. Conclusion

The minimal kernel is
\[
S=Me^{-L}.
\]
The recovery-aware balance kernel is
\[
S=Me^{-B}.
\]

The contribution is not the statement that resources matter. The contribution is the separation between the resource-side term \(M\) and the structural shrinkage coordinates \(L\) and \(B\). This separation makes it possible to say when a structure fails because the feasible region compatible with that structure has been consumed, even if resources have not simply vanished.
