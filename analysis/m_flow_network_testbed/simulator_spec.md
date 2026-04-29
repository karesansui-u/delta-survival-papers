# M Flow Network Testbed Simulator Spec

Status: simulator specification draft.

Date: 2026-04-29

## 1. Inputs

The simulator takes a config with these fields:

```yaml
seed: integer
graph_family: layered_dag | grid | random_geometric | series_parallel
n_layers: integer
width: integer
edge_density: float
capacity_grid: [0, C_max]
source: fixed
sink: fixed
required_flow_Q: integer
horizon_T: integer
damage_family: random_attrition | bottleneck_attack | clustered_failure | demand_shock | repairable_wear | scalar_only_control
damage_intensity: float
total_energy_E: integer
policy: buffer_heavy | recovery_heavy | reconfiguration_heavy | balanced
allocation: {buffer: integer, recovery: integer, reconfiguration: integer}
```

All primary configs must be frozen before outcome-bearing runs.


## 2. Graph Generation

Required graph families:

1. `layered_dag`

   A source connects through \(L\) layers of width \(W\) to a sink. Edges only go
   forward. This gives interpretable paths and cuts.

2. `grid`

   A directed rectangular grid with right/down edges and optional diagonal
   bypasses.

3. `series_parallel`

   Compositions of serial bottlenecks and parallel redundancy.

4. `random_geometric`

   Nodes embedded in \([0,1]^2\), edges from lower x-coordinate to higher
   x-coordinate within radius \(r\).

At least one graph family must be held out from calibration and used only in
primary evaluation.


## 3. Capacity Model

Capacities are integers:

\[
  c_e \in \{0,1,\ldots,C_{\max}\}.
\]

Initial capacity is generated from the config and then modified by the policy.
All capacities are clipped to the frozen range.


## 4. Policies

### 4.1 Buffer action

Before damage, buffer energy adds capacity to selected edges.

Selection rules to test:

- min-cut reinforcement;
- path-diversity reinforcement;
- random eligible edge reinforcement.

The primary rule must be frozen. Alternative rules are sensitivity checks.

### 4.2 Recovery action

After each damage step, recovery energy restores capacity on damaged edges.

Selection rules to test:

- largest recent loss first;
- min-cut damaged edge first;
- oldest unrepaired damage first.

### 4.3 Reconfiguration action

After damage, reconfiguration energy activates bypass edges or adds alternate
edges from a pre-generated candidate pool.

Selection rules to test:

- bypass current min-cut;
- increase path diversity;
- connect around damaged cluster.

Candidate bypass edges must be generated before the run. No post-hoc edge
creation from outcome information is allowed.


## 5. Damage Families

### random_attrition

Each step, each edge loses capacity with probability \(p\), or selected edges
lose one unit of capacity.

### bottleneck_attack

Damage is concentrated on edges in an approximate min-cut computed from the
pre-damage graph.

### clustered_failure

A cluster of nearby or same-layer edges is selected, and capacity loss is
applied within that cluster.

### demand_shock

The required flow \(Q\) increases temporarily. The graph may remain physically
unchanged while the maintenance condition becomes harder.

### repairable_wear

Small repeated losses occur on edges used by recent max-flow paths.

### scalar_only_control

Uniform mild losses are applied so that total resource and initial margin should
carry most predictive information. This regime guards against a simulator where
M-profile always wins by construction.


## 6. Readouts

For every run, record:

- config hash;
- graph hash;
- damage seed;
- policy;
- total energy \(E\);
- allocation vector;
- initial max-flow;
- max-flow at each step;
- required \(Q_t\);
- margin \(\mu_t\);
- collapse time \(\tau_Q\);
- maintained-flow ratio;
- minimum margin;
- repair energy spent;
- reconfiguration energy spent;
- active bypass edges;
- final graph hash.


## 7. Baseline Feature Sets

The total-resource baseline receives:

- graph family;
- graph size;
- edge count;
- initial max-flow;
- initial margin;
- total energy \(E\);
- damage intensity;
- horizon \(T\).

It does not receive the allocation split.

The M-profile model receives all baseline features plus:

- \(E_{\mathrm{buffer}}/E\);
- \(E_{\mathrm{recovery}}/E\);
- \(E_{\mathrm{reconfiguration}}/E\);
- pre-frozen interaction features, if allowed.


## 8. Degeneracy Flags

Mark a run or cell as degenerate when:

- all policies have identical readouts;
- no policy collapses and all margins remain far above \(Q\);
- all policies collapse at the first step;
- the graph has no alternate path and reconfiguration is impossible;
- repair has no damaged edge to act on for most of the horizon;
- \(Q\) is outside the calibrated nontrivial range.

Degenerate cells are reported. They are not silently dropped from primary
analysis unless the preregistration explicitly defines the exclusion.


## 9. Reproducibility

Every primary run must be reproducible from:

- config file;
- graph seed;
- damage seed;
- policy name;
- simulator commit hash;
- evaluator commit hash.

The outside rerun package should contain only frozen configs, code, seeds, and
expected schema, not primary outcome summaries.
