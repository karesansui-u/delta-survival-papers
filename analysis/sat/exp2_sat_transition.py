"""
Experiment 2: SAT Phase Transition with δ Injection

目的:
- α_c ≈ 4.27（節/変数比）での相転移を再現
- δ_protocol（矛盾節）が能力を超越して即死を引き起こすことを証明

変数対応:
- α (節/変数比) ↔ μ_c に対する距離
- α_c ≈ 4.27 ↔ μ_c（臨界点）
- SAT/UNSAT ↔ 生存/崩壊
- 矛盾節 (x ∧ ¬x) ↔ δ_protocol（手段の禁止）

δタイプの実装:
- δ_none: 通常のランダム3-SAT
- δ_protocol: 矛盾節を追加 (x ∧ ¬x) → 数学的に必ずUNSAT
- δ_reference: ランダムに一部のリテラルを反転 → ソルバー能力依存
"""

import numpy as np
from dataclasses import dataclass
from typing import List, Tuple, Optional, Set
import json
from pathlib import Path
import time


@dataclass
class SATResult:
    """単一試行の結果"""
    n_vars: int
    n_clauses: int
    alpha: float  # n_clauses / n_vars
    delta_type: str
    is_sat: bool
    solve_time: float
    n_decisions: int  # DPLLの決定回数


@dataclass
class ConditionStats:
    """条件ごとの統計"""
    n_vars: int
    alpha: float
    delta_type: str
    n_trials: int
    sat_probability: float
    mean_solve_time: float
    std_solve_time: float
    cv_solve_time: float
    mean_decisions: float


# =============================================================================
# DPLL Solver (Simple Implementation)
# =============================================================================

class DPLLSolver:
    """シンプルなDPLLソルバー"""

    def __init__(self, n_vars: int, clauses: List[List[int]]):
        """
        Args:
            n_vars: 変数の数
            clauses: 節のリスト。各節は整数のリスト（正=そのまま、負=否定）
        """
        self.n_vars = n_vars
        self.clauses = [set(c) for c in clauses]
        self.n_decisions = 0

    def solve(self) -> Tuple[bool, int]:
        """
        DPLLアルゴリズムでSAT判定

        Returns:
            (is_sat, n_decisions)
        """
        self.n_decisions = 0
        assignment = {}
        result = self._dpll(self.clauses, assignment)
        return result, self.n_decisions

    def _dpll(self, clauses: List[Set[int]], assignment: dict) -> bool:
        """再帰的DPLL"""
        # 単位伝播
        clauses, assignment = self._unit_propagate(clauses, assignment)

        # 空節があればUNSAT
        if any(len(c) == 0 for c in clauses):
            return False

        # 全ての節が消えればSAT
        if len(clauses) == 0:
            return True

        # 純粋リテラル除去
        clauses, assignment = self._pure_literal_eliminate(clauses, assignment)

        if len(clauses) == 0:
            return True

        # 分岐（決定）
        self.n_decisions += 1

        # 未割当の変数を選択
        all_vars = set()
        for c in clauses:
            for lit in c:
                all_vars.add(abs(lit))

        var = min(all_vars)  # 最小変数を選択（ヒューリスティックは単純化）

        # True を試す
        new_clauses = self._assign(clauses, var, True)
        new_assignment = assignment.copy()
        new_assignment[var] = True
        if self._dpll(new_clauses, new_assignment):
            return True

        # False を試す
        new_clauses = self._assign(clauses, var, False)
        new_assignment = assignment.copy()
        new_assignment[var] = False
        return self._dpll(new_clauses, new_assignment)

    def _unit_propagate(self, clauses: List[Set[int]], assignment: dict) -> Tuple[List[Set[int]], dict]:
        """単位伝播"""
        changed = True
        while changed:
            changed = False
            for c in clauses:
                if len(c) == 1:
                    lit = next(iter(c))
                    var = abs(lit)
                    val = lit > 0
                    assignment[var] = val
                    clauses = self._assign(clauses, var, val)
                    changed = True
                    break
        return clauses, assignment

    def _pure_literal_eliminate(self, clauses: List[Set[int]], assignment: dict) -> Tuple[List[Set[int]], dict]:
        """純粋リテラル除去"""
        all_lits = set()
        for c in clauses:
            all_lits.update(c)

        pure = []
        for lit in all_lits:
            if -lit not in all_lits:
                pure.append(lit)

        for lit in pure:
            var = abs(lit)
            val = lit > 0
            assignment[var] = val
            clauses = self._assign(clauses, var, val)

        return clauses, assignment

    def _assign(self, clauses: List[Set[int]], var: int, val: bool) -> List[Set[int]]:
        """変数に値を割り当てて節を更新"""
        true_lit = var if val else -var
        false_lit = -true_lit

        new_clauses = []
        for c in clauses:
            if true_lit in c:
                # この節は充足される
                continue
            if false_lit in c:
                # このリテラルを除去
                new_c = c - {false_lit}
                new_clauses.append(new_c)
            else:
                new_clauses.append(c)

        return new_clauses


# =============================================================================
# Random 3-SAT Generator
# =============================================================================

def generate_random_3sat(
    n_vars: int,
    n_clauses: int,
    rng: np.random.Generator,
    delta_type: str = "none",
    delta_param: float = 0.0
) -> List[List[int]]:
    """
    ランダム3-SAT問題を生成

    Args:
        n_vars: 変数の数
        n_clauses: 節の数
        rng: 乱数生成器
        delta_type: δのタイプ
        delta_param: δのパラメータ

    Returns:
        節のリスト
    """
    clauses = []

    for _ in range(n_clauses):
        # 3つの異なる変数を選択
        vars_selected = rng.choice(n_vars, size=3, replace=False) + 1
        # 各変数の極性をランダムに決定
        signs = rng.choice([-1, 1], size=3)
        clause = [int(v * s) for v, s in zip(vars_selected, signs)]
        clauses.append(clause)

    # δの注入
    if delta_type == "protocol":
        # 矛盾節を追加: (x) ∧ (¬x)
        var = 1  # 変数1を使用
        clauses.append([var])
        clauses.append([-var])

    elif delta_type == "reference":
        # ランダムにリテラルを反転（ノイズ）
        flip_rate = delta_param
        for i, clause in enumerate(clauses):
            new_clause = []
            for lit in clause:
                if rng.random() < flip_rate:
                    new_clause.append(-lit)  # 反転
                else:
                    new_clause.append(lit)
            clauses[i] = new_clause

    return clauses


# =============================================================================
# Experiment Runner
# =============================================================================

def run_single_trial(
    n_vars: int,
    alpha: float,
    delta_type: str,
    delta_param: float,
    seed: int
) -> SATResult:
    """単一試行を実行"""
    rng = np.random.default_rng(seed)

    n_clauses = int(alpha * n_vars)
    clauses = generate_random_3sat(n_vars, n_clauses, rng, delta_type, delta_param)

    solver = DPLLSolver(n_vars, clauses)

    start_time = time.time()
    is_sat, n_decisions = solver.solve()
    solve_time = time.time() - start_time

    return SATResult(
        n_vars=n_vars,
        n_clauses=len(clauses),
        alpha=alpha,
        delta_type=delta_type,
        is_sat=is_sat,
        solve_time=solve_time,
        n_decisions=n_decisions
    )


def run_condition(
    n_vars: int,
    alpha: float,
    delta_type: str,
    delta_param: float,
    n_trials: int,
    base_seed: int
) -> ConditionStats:
    """指定条件で複数試行を実行"""
    results = []
    for i in range(n_trials):
        result = run_single_trial(n_vars, alpha, delta_type, delta_param, base_seed + i)
        results.append(result)

    sat_count = sum(1 for r in results if r.is_sat)
    solve_times = [r.solve_time for r in results]
    decisions = [r.n_decisions for r in results]

    mean_time = np.mean(solve_times)
    std_time = np.std(solve_times)
    cv_time = std_time / mean_time if mean_time > 0 else 0

    return ConditionStats(
        n_vars=n_vars,
        alpha=alpha,
        delta_type=delta_type,
        n_trials=n_trials,
        sat_probability=sat_count / n_trials,
        mean_solve_time=mean_time,
        std_solve_time=std_time,
        cv_solve_time=cv_time,
        mean_decisions=np.mean(decisions)
    )


def run_experiment(
    n_vars_list: List[int] = [20, 30, 50],
    alpha_range: Tuple[float, float] = (2.0, 6.0),
    n_alpha_points: int = 25,
    delta_types: List[str] = ["none", "protocol", "reference"],
    delta_params: dict = {"reference": [0.1, 0.2, 0.3]},
    n_trials: int = 100,
    verbose: bool = True
) -> List[ConditionStats]:
    """
    全条件で実験を実行
    """
    alphas = np.linspace(alpha_range[0], alpha_range[1], n_alpha_points)

    # 条件リストを生成
    conditions = []
    for n_vars in n_vars_list:
        for alpha in alphas:
            for delta_type in delta_types:
                if delta_type == "reference":
                    for param in delta_params.get("reference", [0.1]):
                        conditions.append((n_vars, alpha, delta_type, param))
                else:
                    conditions.append((n_vars, alpha, delta_type, 0.0))

    total_conditions = len(conditions)
    if verbose:
        print(f"Total conditions: {total_conditions}")
        print(f"Total trials: {total_conditions * n_trials:,}")

    results = []
    base_seed = 42

    for i, (n_vars, alpha, delta_type, delta_param) in enumerate(conditions):
        if verbose and (i + 1) % 20 == 0:
            print(f"Progress: {i + 1}/{total_conditions}")

        stats = run_condition(n_vars, alpha, delta_type, delta_param, n_trials,
                             base_seed + i * n_trials)
        results.append(stats)

    return results


# =============================================================================
# Analysis
# =============================================================================

def analyze_phase_transition(results: List[ConditionStats]) -> dict:
    """相転移の分析"""
    analysis = {
        'critical_alpha': {},
        'transition_width': {},
        'cv_peak': {}
    }

    # δ_none での分析
    none_results = [r for r in results if r.delta_type == "none"]

    for n_vars in set(r.n_vars for r in none_results):
        var_results = sorted([r for r in none_results if r.n_vars == n_vars],
                            key=lambda r: r.alpha)

        # SAT確率が0.5を跨ぐ点を見つける
        alphas = [r.alpha for r in var_results]
        probs = [r.sat_probability for r in var_results]

        critical_alpha = None
        for i in range(len(probs) - 1):
            if probs[i] >= 0.5 >= probs[i + 1]:
                # 線形補間
                if probs[i] != probs[i + 1]:
                    t = (0.5 - probs[i]) / (probs[i + 1] - probs[i])
                    critical_alpha = alphas[i] + t * (alphas[i + 1] - alphas[i])
                break

        analysis['critical_alpha'][n_vars] = critical_alpha

        # CV最大の位置
        cv_values = [r.cv_solve_time for r in var_results]
        if cv_values:
            max_idx = np.argmax(cv_values)
            analysis['cv_peak'][n_vars] = {
                'alpha': alphas[max_idx],
                'cv': cv_values[max_idx]
            }

    return analysis


def analyze_delta_protocol(results: List[ConditionStats]) -> dict:
    """δ_protocol の効果分析"""
    analysis = {
        'protocol_sat_rate': {},
        'is_always_unsat': True
    }

    protocol_results = [r for r in results if r.delta_type == "protocol"]

    for r in protocol_results:
        key = f"n={r.n_vars}, α={r.alpha:.2f}"
        analysis['protocol_sat_rate'][key] = r.sat_probability

        if r.sat_probability > 0:
            analysis['is_always_unsat'] = False

    # 全体のSAT率
    if protocol_results:
        total_sat = sum(r.sat_probability for r in protocol_results)
        analysis['overall_sat_rate'] = total_sat / len(protocol_results)

    return analysis


def save_results(results: List[ConditionStats], filepath: Path):
    """結果をJSONで保存"""
    data = []
    for r in results:
        data.append({
            'n_vars': r.n_vars,
            'alpha': r.alpha,
            'delta_type': r.delta_type,
            'n_trials': r.n_trials,
            'sat_probability': r.sat_probability,
            'mean_solve_time': r.mean_solve_time,
            'std_solve_time': r.std_solve_time,
            'cv_solve_time': r.cv_solve_time,
            'mean_decisions': r.mean_decisions
        })

    with open(filepath, 'w') as f:
        json.dump(data, f, indent=2)


def main():
    """メイン実行"""
    print("=" * 60)
    print("Experiment 2: SAT Phase Transition with δ Injection")
    print("=" * 60)

    # 実験パラメータ
    n_vars_list = [20, 30, 50]
    alpha_range = (2.0, 6.0)
    n_alpha_points = 25
    delta_types = ["none", "protocol", "reference"]
    delta_params = {"reference": [0.1, 0.2, 0.3]}
    n_trials = 100

    print(f"\nParameters:")
    print(f"  n_vars: {n_vars_list}")
    print(f"  α range: {alpha_range[0]:.1f} - {alpha_range[1]:.1f} ({n_alpha_points} points)")
    print(f"  δ types: {delta_types}")
    print(f"  trials per condition: {n_trials}")
    print(f"  Theoretical α_c ≈ 4.27")

    # 実験実行
    print("\nRunning experiment...")
    start_time = time.time()

    results = run_experiment(
        n_vars_list=n_vars_list,
        alpha_range=alpha_range,
        n_alpha_points=n_alpha_points,
        delta_types=delta_types,
        delta_params=delta_params,
        n_trials=n_trials,
        verbose=True
    )

    elapsed = time.time() - start_time
    print(f"\nExperiment completed in {elapsed:.1f}s")

    # 結果保存
    output_dir = Path(__file__).parent.parent / "results" / "exp2"
    output_dir.mkdir(parents=True, exist_ok=True)

    save_results(results, output_dir / "sat_results.json")
    print(f"\nResults saved to {output_dir / 'sat_results.json'}")

    # 分析
    print("\n" + "=" * 60)
    print("Analysis: Phase Transition")
    print("=" * 60)

    transition_analysis = analyze_phase_transition(results)

    print("\nCritical α (SAT probability = 0.5):")
    for n_vars, alpha_c in transition_analysis['critical_alpha'].items():
        if alpha_c:
            diff = (alpha_c - 4.27) / 4.27 * 100
            print(f"  n={n_vars}: α_c = {alpha_c:.3f} ({diff:+.1f}% from theory)")

    print("\nCV peak location (critical fluctuation):")
    for n_vars, peak in transition_analysis['cv_peak'].items():
        print(f"  n={n_vars}: α = {peak['alpha']:.2f}, CV = {peak['cv']:.3f}")

    # δ_protocol の分析
    print("\n" + "=" * 60)
    print("Analysis: δ_protocol (Contradiction)")
    print("=" * 60)

    protocol_analysis = analyze_delta_protocol(results)

    if protocol_analysis['is_always_unsat']:
        print("\n✅ SUCCESS: δ_protocol always causes UNSAT")
        print("   This proves that contradiction transcends solver capability")
    else:
        print("\n⚠️ WARNING: Some SAT cases found with δ_protocol")
        print("   SAT rate by condition:")
        for key, rate in list(protocol_analysis['protocol_sat_rate'].items())[:5]:
            print(f"     {key}: {rate:.1%}")

    print(f"\nOverall SAT rate with δ_protocol: {protocol_analysis.get('overall_sat_rate', 0):.3%}")

    print("\n" + "=" * 60)
    print("Experiment 2 Complete")
    print("=" * 60)


if __name__ == "__main__":
    main()
