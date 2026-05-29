# Structural Persistence Theory for Language-Model Systems — English Overview

This note is a short English entry point to the `delta-survival-paper` repository.
It explains the main claim, the supporting evidence, and the architectural implications without requiring the Japanese preprints first.
For the shortest PDF entry point, see [`v3/07_exports/pdf/02_core_en.pdf`](v3/07_exports/pdf/02_core_en.pdf).

## Core Claim

The central claim is simple: reasoning degradation in long conversations and catastrophic forgetting under continual learning may be two expressions of the same structural problem in language-model systems. In both cases, unresolved contradictions and premise-changing updates reduce the set of states that can still preserve coherent behavior. Here, “structure” does not mean generic form, but the relations, functions, and identity whose persistence is at issue in the system under study.

This means the project is not only about giving long-horizon systems a persistent state. Durable state is the substrate, but the stronger claim is that persistence as that structure depends on explicitly reducing contradiction load and maintaining coherence through revision.

## Minimal Theory

At the theoretical core, structural loss is defined by the log-ratio of successive shrinkage in the set of states that can still sustain the structure.
The intended reading is that of a representation theorem for a pre-fixed structure-maintenance problem, not a license to redefine the target structure after seeing the outcome.

If a system starts with a structure-preserving state set
\[
V^{(0)} \supseteq V^{(1)} \supseteq \cdots \supseteq V^{(n)},
\]
and the stage loss is defined as
\[
l_i = -\ln \frac{m(V^{(i)})}{m(V^{(i-1)})},
\]
then the remaining survivable region takes the exponential form
\[
m(V^{(n)}) = m(V^{(0)}) e^{-L}, \qquad L = \sum_i l_i.
\]

In the current v2 core, the log-ratio form itself is no longer treated as a mere definition. Paper 1 characterizes it axiomatically on ratio space, in explicit analogy with the Hartley/Shannon style of uniqueness arguments. The exponential form is therefore not an extra empirical assumption; it follows from cumulative multiplicative shrinkage once the loss scale is fixed in that way. In that sense, collapse here means loss of persistence as that structure, not necessarily annihilation of the underlying substrate.

## Formal Layer and Limited-Class Unification

Lean formalization is maintained in a dedicated repository:
**[persistence-lean](https://github.com/karesansui-u/persistence-lean)** —
406 `Persistence/*.lean` modules, sorry/admit/axiom = 0.

The historical copy in this repo (`lean_archive/`, namespace `Survival`)
is no longer maintained.

Of the 406 modules, ~20 are core-routed bridges that mechanically invoke
the kernel, ~40 are structural core and necessity theorems, and ~160 are
vocabulary mappings (naming conventions, not theorems). See the
[persistence-lean README](https://github.com/karesansui-u/persistence-lean#honest-assessment)
for the full tier classification.

The formal layer includes the minimal exponential kernel, representation
and impossibility theorems, resource dynamics, structural second law
(three-layer: deterministic, stochastic, coarse-graining), SAT/CSP
finite-horizon chain, Mathlib-backed connections (Category instance,
Galois connection, KL embedding, Cesaro ergodic extension), identity
and asymptotic identity theory, phase transition sharpness, interaction
defect, and the epistemic-control bridge with toy instantiations.

The strongest cross-class statement is intentionally phrased as limited-class unification rather than as a universal law over all domains. Bernoulli-CSP, Foster-Lyapunov / queueing, and Repair-Maintenance are registered as limited classes that instantiate a common structural-persistence interface:

- an ordered Sigma carrier
- a nonnegative tendency driver
- a finite-horizon certificate route
- an admissible-transfer guard

This means that the project has a machine-checked interface closure for registered classes. It does not claim a single universal inequality for arbitrary domains. New domains must either be registered as new limited classes or treated as structural-inference settings whose support depends on frozen validation.

## Two Experimental Regimes

### 1. Inference-time reasoning degradation

The inference-side experiments study what happens when contradictory or unresolved updates accumulate inside a conversation. The key observation is:

- long context by itself does not explain the full degradation
- unresolved contradiction accumulation degrades logical consistency much more sharply
- externally organizing contradictions into old/new state relations preserves coherence better than leaving the same contradictions unresolved

That points to contradiction management rather than sheer context length as the main issue in these settings.

### 2. Continual-learning structural forgetting

The continual-learning experiments study premise-changing updates under LoRA-based sequential training. Not all forgetting looks the same. When an upstream premise changes, many dependency-linked pieces of knowledge must be reorganized together. If that reorganization fails, the system does not merely miss one fact; it falls into an internally inconsistent state.

Across the tested settings, LoRA-style sequential updating often overwrote old organization instead of adding cleanly to it. Dependency-aware replay improved consistency, and multi-adapter separation reduced some interference, but neither fully kept older knowledge intact.

## Architectural Implication

The target here is a system that can stay coherent through revision, not just answer well in isolated sessions. That likely requires more than better prompting or more training alone.

The work points toward an architecture with:

- external contradiction metabolism
- multi-layer memory rather than a single undifferentiated memory store
- premise-dependent reorganization of knowledge
- rollbackable state management
- maintenance of an internal model across time

The intended target is not just a stronger stateless chatbot, but a system that can remain coherent across updates, revisions, and long-running interaction.

## What This Repository Contains

- Theory map: [`v3/01_theory/00_map.md`](v3/01_theory/00_map.md)
- Integrated overview: [`v3/01_theory/01_overview.md`](v3/01_theory/01_overview.md)
- Core paper (accounting framework): [`v3/01_theory/02_accounting_framework.md`](v3/01_theory/02_accounting_framework.md)
- Claim boundaries: [`v3/CLAIMS.md`](v3/CLAIMS.md)
- Domain registry: [`v3/03_domains/registry.tsv`](v3/03_domains/registry.tsv)
- Evidence ledger: [`v3/05_evidence/README.md`](v3/05_evidence/README.md)
- English core paper: [`v3/01_theory/en/02_core_en.md`](v3/01_theory/en/02_core_en.md)
- PDFs: [`v3/07_exports/pdf/`](v3/07_exports/pdf/)
- Lean formalization: [persistence-lean](https://github.com/karesansui-u/persistence-lean)
- Older `v1/` and `v2/` materials remain as archive

## Suggested Reading Path

For external readers, the cleanest route is:

1. [`v3/01_theory/00_map.md`](v3/01_theory/00_map.md) — construction map
2. [`v3/01_theory/01_overview.md`](v3/01_theory/01_overview.md) — integrated overview
3. [`v3/01_theory/02_accounting_framework.md`](v3/01_theory/02_accounting_framework.md) — core paper
4. [`v3/CLAIMS.md`](v3/CLAIMS.md) — claim boundaries
5. [`v3/03_domains/registry.tsv`](v3/03_domains/registry.tsv) — domain registry
6. [`v3/05_evidence/README.md`](v3/05_evidence/README.md) — evidence ledger

English entry:

1. [`v3/01_theory/en/02_core_en.md`](v3/01_theory/en/02_core_en.md)
2. [`v3/01_theory/en/10_paper1_minimal_form_en.md`](v3/01_theory/en/10_paper1_minimal_form_en.md)
3. [`v3/01_theory/en/11_paper2_balance_principle_en.md`](v3/01_theory/en/11_paper2_balance_principle_en.md)

## Scope and Caution

This project does **not** claim that all long-horizon failure in AI has already been fully explained or formally proven.

The stronger claim is intentionally avoided.
The current claim is narrower:

- the minimal exponential form is a consequence of a pre-fixed representation of structural loss
- the contradiction-related reasoning results are empirical and directional
- the continual-learning results show limits of a specific update regime rather than all possible training regimes

The framework only has empirical bite when the target structure, measure, stage boundaries, and time horizon are fixed in advance in a non-trivial and representationally stable way. If those are allowed to vary post hoc, the same mathematics can be made to fit arbitrary finite monotone sequences and the theory becomes vacuous. The value of the framework, at this stage, is that it offers a common language connecting theory, experiments, and architecture without hiding that scope condition.

As of 2026-04-28, both frozen specification-fixed finite-domain packages have also been rerun by three outside executors each. Mixed-CSP returned three clean 12,000-row primary runs with zero checked core-field mismatches and all support flags true. Exp43c q-coloring returned three clean 4,000-row primary runs with zero checked core-field mismatches, zero timeouts, zero malformed rows, and the same qualitative support decision. This strengthens package-level reproducibility for the specification-fixed layer, but it is not a claim that the full replication program is closed.
