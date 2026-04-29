Software / SaaS M-Profile
=========================

domain_id: software_saas_m_profile

domain_name: Software / SaaS operational M-profile

observability_layer: structurally_inferred

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
- \(m\): not directly counted; represented through frozen operational proxies.
- \(d_t\): deployment risk, dependency drift, incident load, unresolved defect accumulation, or structural-risk proxy.
- \(r_t\): rollback, repair workflow, runbook execution, replay, or verified remediation.
- \(L\): accumulated structural-risk proxy.
- \(B\): net structural-risk proxy after recovery / repair signals.
- \(M\)-side readout: \(M_{\mathrm{buffer}}\), \(M_{\mathrm{recovery}}\), \(M_{\mathrm{reconfiguration}}\), plus external supply channels.


3. M-Profile Candidate Signals
------------------------------

| Component | Candidate software / SaaS indicators |
|---|---|
| \(M_{\mathrm{buffer}}\) | redundancy, spare capacity, error budget, deployment margin, blast-radius containment |
| \(M_{\mathrm{recovery}}\) | rollback success, MTTR, runbook coverage, restore drill recency, replay capability |
| \(M_{\mathrm{reconfiguration}}\) | feature flags, modular boundaries, migration tooling, replaceability, dependency isolation |
| external supply channel | vendor support, SRE escalation, platform team intervention, upstream fix latency |


4. Baselines
------------

- simple baseline: activity count, deployment count, incident count, age, team size, or traffic volume.
- domain baseline: standard software-delivery / incident-risk model.
- domain baseline + SP: domain baseline plus frozen L/B/M-profile coordinates.
- wide baseline, if any: domain-specific operational model with all pre-approved covariates.


5. Validation Status
--------------------

- current status: candidate / silence until an operational log with intervention records and outcome windows is frozen.
- M-profile manifest: use `../../06_templates/m_profile_validation_manifest_template.md`.
- intervention-ranking preregistration: use `../../06_templates/intervention_ranking_prereg_template.md`.
- evidence record: not yet supported.


6. Claims
---------

This domain may support:

- preparatory support if M-profile features improve held-out risk prediction over a domain baseline;
- primary support if pre-frozen M-component deficits predict which intervention family works best;
- strong support only if the intervention-ranking direction is robust across \(\rho_i\), \(A_j\), and \(\Phi\) candidate families.

This domain does not support:

- theorem-side evidence;
- a universal \(M\)-law;
- causal intervention claims without identification;
- support transfer from LLM, CSP, battery, or maintenance datasets.
