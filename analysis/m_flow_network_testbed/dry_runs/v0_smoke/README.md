# Flow-Network M Testbed Dry Run v0

Status: schema smoke test only.

Generated with:

```bash
python3 analysis/m_flow_network_testbed/scripts/simulate_flow_network.py dry-run
python3 analysis/m_flow_network_testbed/scripts/evaluate_flow_network.py
```

This run checks that simulator v0 can emit:

- graph, damage, and allocation identifiers;
- held-out allocation tags;
- max-flow, margin, collapse-time, and maintained-flow readouts;
- energy-spend readouts for buffer, recovery, and reconfiguration;
- degeneracy flags.
- evaluator v0 can form intervention-ranking groups and compare total-resource,
  policy-prior, and M-profile ranking predictors.

It is not primary validation and does not count as M-support.
