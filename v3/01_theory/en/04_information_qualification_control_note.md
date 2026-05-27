Information Qualification Control for Long-Term Memory
==================================================

This note is a compact cross-layer map for Information Qualification Control (IQC).

Information Qualification Control (IQC) is a finite control-layer design for
long-term LLM memory where each candidate memory or update is qualified before
it can be used.

IQC does not mean “a safer LLM.”
It means a structured control interface with explicit obligations that can be
connected to the existing structural-persistence kernel.


What this layer controls
------------------------

Each event is evaluated by qualification attributes before store/read/reason/update:

- source: who introduced the content and whether it is still attributable;
- speechAct: whether an utterance is request, command, correction, or
  meta-commentary;
- permission: whether storage or use is allowed by current policy;
- scope: whether the content is safe for this context (e.g., persona and
  bounded purpose);
- versionState: whether the supporting premise is current, stale, or superseded;
- stability / use condition: whether the memory content is still acceptable for
  immediate use.

The control policy then applies one of:

- qualified admit (store with a freshness / permission tag);
- blocked admit or delayed admit;
- targeted invalidation and localized repair after premise revision;
- abstain / defer when qualification cannot be trusted.


Lean chain in three lines
-------------------------

1. Abstraction entry: `EpistemicControlBridge` maps contradiction, repair,
   filter, and rewrite operations to a finite `ProblemSpec`.

2. Assumption package: `EpistemicControlComparison` and
   `EpistemicControlEvaluationContract` show that at a fixed finite horizon,
   same initial mass and no-worse cumulative net action imply
   `coherentMass_controlled >= coherentMass_baseline`.

3. Execution layer:
   `EpistemicBenchmarkProtocol`, `EpistemicBenchmarkResultCertificate`, and
   `SoftwareEvidenceNetActionBridge` define the witnesses needed for invoking
   that comparison chain from result artifacts and evidence packets.

So the Lean side proves this contract, not a model behavior claim:

```text
assumptions + frozen protocol + witnesses
  -> NetActionNoWorse
  -> coherent mass comparison
```


Implementation-facing reading
----------------------------

The implementation summary is in
`v3/05_evidence/iqc_failure_suite_final_result_ja.md`.

With corrected benchmark injection policy, the latest table is:

- M1 source attribution: IQC 96%
- M2 speechAct qualification: IQC 100%
- M3 permission/retain safety: IQC 100%
- M4 versionState dependency update: IQC 96%

The same result set records that M2 and M3 are best-in-class against all baselines,
M4 is tied with naive retrieval, and M1 is neutral.

This is empirical package evidence only.
It is not a Lean theorem proof and does not certify real benchmark semantics,
LLM natural-language semantics, or product-level reliability.


How to read this with confidence
-------------------------------

The strongest practical boundary is:

- Lean: if explicit witnesses are supplied, the comparison theorem runs;
- Runner: validates artifact shape and dominance aggregation;
- Protocol: fixes frozen task surface / readout / horizon before execution;
- Evidence: shows whether those witnesses are available for a concrete run.

A result is strongest when it is:

- outcome-bearing in a frozen package,
- protocol-aligned,
- and certificate-mapped through the result-certificate layer.


Where to go next
----------------

- Lean bridge and contracts: `v3/03_domains/02_structurally_inferred/llm_epistemic_control_bridge.md`
- Claim boundary: `v3/CLAIMS.md`
- Result-certificate layer: `lean/Survival/EpistemicBenchmarkResultCertificate.lean`
- Diagram: `../figures/figure5_iqc_assumption_to_guarantee_chain_en.svg`
- Evidence summary: `v3/05_evidence/iqc_failure_suite_final_result_ja.md`

