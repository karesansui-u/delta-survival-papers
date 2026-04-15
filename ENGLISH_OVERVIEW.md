# Structural Persistence Theory — English Overview

This note is a short English entry point to the `delta-survival-paper` repository.
It is not a full translation of the Japanese preprints. Its purpose is to explain the main claim, the supporting evidence, and the architectural implications in a compact form.

## Core Claim

The central hypothesis is that two problems usually discussed separately may share the same structural mechanism:

- reasoning degradation in long conversations
- catastrophic forgetting under continual learning

The proposed view is that both can be read as cases where the set of states that can still preserve a target structure gradually shrinks as unresolved contradictions or premise-changing updates accumulate.

## Minimal Theory

At the theoretical core, structural loss is defined by the log-ratio of successive shrinkage in the set of states that can still sustain the structure.

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

In this framework, the exponential form is not an extra empirical assumption. It follows directly from representing cumulative structural loss as successive multiplicative shrinkage measured in log-ratio form.

## Two Experimental Regimes

### 1. Inference-time reasoning degradation

The inference-side experiments study what happens when contradictory or unresolved updates accumulate inside a conversation.

The main empirical observation is narrow but important:

- long context by itself does not explain the full degradation
- unresolved contradiction accumulation degrades logical consistency much more sharply
- externally organizing contradictions into old/new state relations preserves coherence better than leaving the same contradictions unresolved

In other words, the problem looks less like a pure context-length issue and more like a contradiction-management issue.

### 2. Continual-learning structural forgetting

The continual-learning experiments study premise-changing updates under LoRA-based sequential training.

The main observation is that not all forgetting looks the same. When an upstream premise changes, many dependency-linked pieces of knowledge have to be reorganized together. If that reorganization fails, the system does not merely lose one fact; it enters an internally inconsistent state.

Across the tested settings, LoRA-style sequential updating behaved more like overwrite than clean accumulation. Dependency-aware replay improved dependency consistency, and multi-adapter separation partially reduced interference, but neither fully solved high-fidelity long-term retention.

## Architectural Implication

The broader implication is that long-horizon intelligence may require more than better prompt engineering or more training alone.

The work points toward an architecture with:

- external contradiction metabolism
- multi-layer memory rather than a single undifferentiated memory store
- premise-dependent reorganization of knowledge
- rollbackable state management
- persistent internal-model maintenance across time

The intended target is not just a stronger stateless chatbot, but a system that can remain coherent across updates, revisions, and long-running interaction.

## What This Repository Contains

- Japanese preprints (`v2/1` to `v2/4`)
- an integrated Japanese overview: [`v2/0_構造持続理論の統合版.md`](v2/0_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E7%90%86%E8%AB%96%E3%81%AE%E7%B5%B1%E5%90%88%E7%89%88.md)
- PDFs in [`v2/pdf用/`](v2/pdf%E7%94%A8/)
- Lean 4 formalization in [`lean/`](lean/)
- raw data and summaries in [`DATA.md`](DATA.md)

## Suggested Reading Path

If you want the shortest route:

1. [`v2/0_構造持続理論の統合版.md`](v2/0_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E7%90%86%E8%AB%96%E3%81%AE%E7%B5%B1%E5%90%88%E7%89%88.md)
2. [`v2/3_構造持続と推論性能の劣化.md`](v2/3_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%A8%E6%8E%A8%E8%AB%96%E6%80%A7%E8%83%BD%E3%81%AE%E5%8A%A3%E5%8C%96.md)
3. [`v2/4_構造持続と継続学習における破滅的忘却.md`](v2/4_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%A8%E7%B6%99%E7%B6%9A%E5%AD%A6%E7%BF%92%E3%81%AB%E3%81%8A%E3%81%91%E3%82%8B%E7%A0%B4%E6%BB%85%E7%9A%84%E5%BF%98%E5%8D%B4.md)

If you want the theoretical core:

1. [`v2/1_構造持続の最小形式.md`](v2/1_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9C%80%E5%B0%8F%E5%BD%A2%E5%BC%8F.md)
2. [`v2/2_構造持続の条件つき導出.md`](v2/2_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9D%A1%E4%BB%B6%E3%81%A4%E3%81%8D%E5%B0%8E%E5%87%BA.md)

## Scope and Caution

This project does **not** claim that all long-horizon failure in AI has already been fully explained or formally proven.

The stronger claim is intentionally avoided.
The current claim is narrower:

- the minimal exponential form is a consequence of the chosen representation of structural loss
- the contradiction-related reasoning results are empirical and directional
- the continual-learning results show limits of a specific update regime rather than all possible training regimes

The value of the framework, at this stage, is that it offers a common language connecting theory, experiments, and architecture.
