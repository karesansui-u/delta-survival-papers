Software / SaaS Qualified Support Diagnostic
==============================================

domain_id: software_saas_m_profile

domain_name: Software / SaaS qualified-support diagnostic candidate

classification: inference

status: candidate


1. Maintenance Target
---------------------

- Target structure: service or software system maintains a pre-fixed operational function \(F\) under deployments, incidents, and repairs.
- Failure / collapse boundary: incident recurrence, change failure, escaped defects, excessive MTTR, or service-level violation, fixed before validation.
- Observation unit: service, repository, team, subsystem, or deployment stream.
- Time horizon: frozen before validation.


2. Structural Coordinates
-------------------------

- \(V\): operational states compatible with the target function and service contract.
- \(m\): not directly counted; represented through frozen operational observation / estimation indicators.
- \(d_t\): deployment risk, dependency drift, incident load, unresolved defect accumulation, or structural-risk indicator.
- \(r_t\): rollback, repair workflow, runbook execution, replay, or verified remediation.
- \(L\): accumulated structural-risk indicator.
- \(B\): net structural-risk indicator after recovery / repair signals.
- \(M\)-side readout: claim-scoped qualified support projection, optionally decomposed into buffer, recovery, reconfiguration, and external-support readouts when their gates, horizon, path, and certificates are observable without leakage.


3. Qualified Support Candidate Signals
--------------------------------------

| Support readout | Candidate software / SaaS indicators |
|---|---|
| \(M_{\mathrm{buffer}}\) | redundancy, spare capacity, error budget, deployment margin, blast-radius containment |
| \(M_{\mathrm{recovery}}\) | rollback success, MTTR, runbook coverage, restore drill recency, replay capability |
| \(M_{\mathrm{reconfiguration}}\) | feature flags, modular boundaries, migration tooling, replaceability, dependency isolation |
| external supply channel | vendor support, SRE escalation, platform team intervention, upstream fix latency |


4. Baselines
------------

- simple baseline: activity count, deployment count, incident count, age, team size, or traffic volume.
- domain baseline: standard software-delivery / incident-risk model.
- domain baseline + SP: domain baseline plus frozen L/B coordinates and, optionally, qualified-support readouts.
- wide baseline, if any: domain-specific operational model with all pre-approved covariates.


5. Validation Status
--------------------

- current status: candidate / silence until an operational log with intervention records and outcome windows is frozen.
- qualified-support diagnostic manifest: use `../../06_templates/m_profile_validation_manifest_template.md` until a QSA-style support-gate manifest replaces it.
- evidence record: not yet supported.


6. Claims
---------

This domain may support:

- qualified-support diagnostic support if support-gate / path / horizon readouts improve held-out risk prediction or diagnosis over a domain baseline;

This domain does not support:

- theorem-side evidence;
- a universal \(M\)-law;
- causal intervention claims without identification;
- support transfer from LLM, CSP, battery, or maintenance datasets.
