# Structural Persistence Theory — English Abstract

This note is the shortest public English entry point to the project.

The central hypothesis is that two problems usually discussed separately may share the same structural mechanism: reasoning degradation in long conversations, and catastrophic forgetting under continual learning. Both can be read as cases where the set of states that can still preserve a target structure gradually shrinks as unresolved contradictions or premise-changing updates accumulate.

At the theoretical core, structural loss is defined by the log-ratio of successive shrinkage in the set of states that can still sustain the structure. If a system starts with a structure-preserving state set \(V^{(0)} \supseteq V^{(1)} \supseteq \cdots \supseteq V^{(n)}\), and the stage loss is defined as \(l_i = -\ln \frac{m(V^{(i)})}{m(V^{(i-1)})}\), then the remaining survivable region takes the exponential form \(m(V^{(n)}) = m(V^{(0)}) e^{-L}\), where \(L = \sum_i l_i\). In this framework, the exponential form is not an extra empirical assumption; it follows directly from representing cumulative structural loss as successive multiplicative shrinkage measured in log-ratio form.

Empirically, the inference experiments suggest that long-context degradation is not mainly a length problem, but a contradiction-management problem: externally organizing contradictory updates preserves coherence better than leaving the same contradictions unresolved. The continual-learning experiments suggest that LoRA-style sequential updating behaves more like overwrite than clean accumulation when dependency-linked knowledge must be reorganized after premise changes. Dependency-aware replay and adapter separation help, but do not fully solve high-fidelity long-term retention.

The broader architectural implication is that long-horizon intelligence may require more than prompt engineering or more training alone. The work points toward external contradiction metabolism, multi-layer memory, premise-dependent reorganization, rollbackable state management, and persistent internal-model maintenance across time.

For a longer English entry point, see [`ENGLISH_OVERVIEW.md`](ENGLISH_OVERVIEW.md). For the main Japanese integrated overview, see [`v2/0_構造持続理論の統合版.md`](v2/0_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E7%90%86%E8%AB%96%E3%81%AE%E7%B5%B1%E5%90%88%E7%89%88.md).
