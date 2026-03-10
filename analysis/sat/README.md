# SAT Experiments (Papers 1 & 2)

Random 3-SAT phase transition, constraint types, and solver sensitivity analysis.

## Scripts

### Paper 1 (Constraint types & first moment)
| Script | Description |
|---|---|
| `exp2_sat_transition.py` | Basic 3-SAT phase transition at α ≈ 4.27 |
| `exp_sat_contradiction.py` | Constraint type effects (negation, XOR) |
| `exp_sat_scaling.py` | Scaling behavior |
| `prediction_test.py` | XOR-SAT threshold ratio prediction (5.19×) |

### Paper 2 (Sensitivity exponent c)
| Script | Description |
|---|---|
| `phase2_solver_comparison.py` | CDCL vs WalkSAT vs Random (c values) |
| `phase2_alpha_density.py` | α density analysis |
| `phase2_n_scaling.py` | N-scaling of sensitivity |
| `phase2c_universal_curve.py` | Universal S(δ) curve |
| `phase2c_fine_grid.py` | Fine-grid transition zone |
| `phase2c_model_comparison.py` | Model comparison (AIC/BIC) |
| `phase3_bootstrap_ci.py` | Bootstrap confidence intervals |
| `phase3_k_sat.py` | k-SAT generalization |
| `exp_sat_scaling_extended.py` | Extended scaling analysis |

## Requirements

- Python 3.10+
- `pysat` (PySAT solver library)
- `numpy`, `scipy`, `matplotlib`
