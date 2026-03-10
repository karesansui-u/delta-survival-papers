"""
Exp.18: Strategy Diversity as a Function of δ — N_eff(δ) Direct Measurement

Goal: Test the Lean theorem N_eff(δ) = N·exp(-αδ) empirically.
Design: 15 δ levels × 30 trials × 2 models = 900 API calls
Measures: Shannon entropy → N_eff, strategy distribution, survival rate

Hypotheses:
  H1: N_eff(δ) fits exponential decay with R² > 0.8
  H2: N_eff decline precedes survival_rate decline
  H3: N_eff → 1 near δ_c ≈ 0.62
"""

import os
import sys
import json
import time
import argparse
from pathlib import Path
from datetime import datetime
import numpy as np

from openai import OpenAI

# --- Setup ---
ENV_PATH = "/Users/sunagawa/Project/chinju-protocol/chinju-sidecar/.env"

def load_env_file(path):
    if not os.path.exists(path):
        print(f"Warning: .env file not found at {path}")
        return
    with open(path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "=" in line:
                key, value = line.split("=", 1)
                os.environ[key.strip()] = value.strip().strip('"').strip("'")

load_env_file(ENV_PATH)

client = OpenAI(
    api_key=os.environ.get("OPENROUTER_API_KEY"),
    base_url="https://openrouter.ai/api/v1"
)

# --- Import local modules ---
sys.path.insert(0, str(Path(__file__).parent))
from run_exp14_v3_continuous import (
    get_ceo_instruction_continuous,
    get_cso_instruction_continuous,
    get_field_report,
    get_system_prompt,
    compute_statistics,
)
from strategy_classifier import classify_response_llm, ALL_STRATEGIES, STRATEGY_NAMES
from neff_analysis import (
    compute_neff,
    fit_exponential,
    generate_full_report,
)

# --- Configuration ---
DELTAS = [0.00, 0.10, 0.20, 0.30, 0.40, 0.50, 0.55, 0.58, 0.60, 0.62, 0.64, 0.66, 0.70, 0.80, 1.00]

MODELS = {
    "claude": "anthropic/claude-sonnet-4.6",
    "gpt4o": "openai/gpt-4o",
}

CLASSIFIER_MODEL = "anthropic/claude-opus-4.6"

N_TRIALS = 30
TEMPERATURE = 0.7
MAX_TOKENS = 2000
RATE_LIMIT_SLEEP = 0.3
CLASSIFIER_SLEEP = 0.15


def run_single_trial(delta: float, model: str, trial: int) -> dict:
    """Run a single double-bind trial."""
    ceo_inst = get_ceo_instruction_continuous(delta)
    cso_inst = get_cso_instruction_continuous(delta)
    field_report = get_field_report()
    system_prompt = get_system_prompt()

    user_message = f"""CEO INSTRUCTION:
{ceo_inst}

CSO INSTRUCTION:
{cso_inst}

{field_report}

Please provide your response as a JSON object."""

    try:
        response = client.chat.completions.create(
            model=model,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_message}
            ],
            temperature=TEMPERATURE,
            max_tokens=MAX_TOKENS
        )

        content = response.choices[0].message.content

        import re
        json_match = re.search(r'\{[\s\S]*\}', content)
        if json_match:
            manager_output = json.loads(json_match.group())
        else:
            manager_output = {"decision": -1, "reasoning": content, "error": "No JSON found"}

        return {
            "delta": delta,
            "model": model,
            "trial": trial,
            "manager_output": manager_output,
            "raw_response": content[:2000],
            "ceo_prompt": ceo_inst,
            "cso_prompt": cso_inst,
        }

    except Exception as e:
        return {
            "delta": delta,
            "model": model,
            "trial": trial,
            "error": str(e),
            "manager_output": {"decision": -1, "reasoning": f"API error: {e}"},
            "ceo_prompt": get_ceo_instruction_continuous(delta),
            "cso_prompt": get_cso_instruction_continuous(delta),
        }


def classify_all(results: list[dict]) -> list[dict]:
    """Classify all results using LLM evaluator."""
    print(f"\nClassifying {len(results)} responses with {CLASSIFIER_MODEL}...")
    for i, r in enumerate(results):
        classification = classify_response_llm(
            r["manager_output"],
            r["ceo_prompt"],
            r["cso_prompt"],
            model=CLASSIFIER_MODEL,
        )
        r["strategy"] = classification["strategy"]
        r["strategy_confidence"] = classification["confidence"]
        r["strategy_reasoning"] = classification["reasoning"]

        if (i + 1) % 50 == 0:
            print(f"  Classified {i + 1}/{len(results)}")
        time.sleep(CLASSIFIER_SLEEP)

    return results


def analyze_by_delta(results: list[dict], deltas: list[float]) -> dict:
    """Compute N_eff and survival metrics per delta level."""
    analysis = {}
    for delta in deltas:
        delta_results = [r for r in results if abs(r["delta"] - delta) < 0.001]
        if not delta_results:
            continue

        strategies = [r["strategy"] for r in delta_results]
        neff_metrics = compute_neff(strategies)

        # Survival rate (legacy metric from Exp.14)
        # "Normal" = decision 1 or 2 (not paralyzed)
        categories = []
        for r in delta_results:
            d = r.get("manager_output", {}).get("decision", -1)
            if d == 1 or d == 2:
                categories.append("Normal")
            else:
                categories.append("Abnormal")
        survival_stats = compute_statistics(categories)

        analysis[delta] = {
            "n_trials": len(delta_results),
            "neff": neff_metrics,
            "survival": survival_stats,
            "strategy_counts": {s: strategies.count(s) for s in ALL_STRATEGIES},
        }

    return analysis


def run_experiment(models_to_run=None, n_trials=None, deltas=None, dry_run=False):
    """Main experiment runner."""
    if models_to_run is None:
        models_to_run = ["claude"]
    if n_trials is None:
        n_trials = N_TRIALS
    if deltas is None:
        deltas = DELTAS

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_dir = Path(__file__).parent / "results"
    output_dir.mkdir(exist_ok=True)

    total_calls = len(deltas) * n_trials * len(models_to_run)
    classifier_calls = total_calls  # 1 classification per trial

    print("=" * 70)
    print("Exp.18: Strategy Diversity as a Function of δ")
    print("=" * 70)
    print(f"Start time: {datetime.now().isoformat()}")
    print(f"\nConfiguration:")
    print(f"  Models: {[MODELS[m] for m in models_to_run]}")
    print(f"  Delta levels: {len(deltas)} {deltas}")
    print(f"  Trials per δ/model: {n_trials}")
    print(f"  Total manager API calls: {total_calls}")
    print(f"  Total classifier API calls: {classifier_calls}")
    print(f"  Estimated cost: ~${total_calls * 0.005 + classifier_calls * 0.001:.1f}")
    if dry_run:
        print(f"\n  *** DRY RUN — no API calls will be made ***")
    print("-" * 70)

    all_results = {}

    for model_key in models_to_run:
        model = MODELS[model_key]
        print(f"\n{'='*50}")
        print(f"Model: {model}")
        print(f"{'='*50}")

        results = []

        for delta in deltas:
            print(f"\nδ = {delta:.2f}:", end=" ")
            sys.stdout.flush()

            for trial in range(n_trials):
                if dry_run:
                    # Simulate a response
                    fake_strategies = ["S2", "S3", "S4", "S5", "S6"]
                    import random
                    # At low δ, more diversity; at high δ, concentrate on S5
                    if delta < 0.3:
                        weights = [0.3, 0.25, 0.15, 0.1, 0.2]
                    elif delta < 0.6:
                        weights = [0.25, 0.25, 0.2, 0.2, 0.1]
                    else:
                        weights = [0.1, 0.05, 0.05, 0.7, 0.1]
                    strategy = random.choices(fake_strategies, weights=weights, k=1)[0]
                    result = {
                        "delta": delta, "model": model, "trial": trial,
                        "manager_output": {"decision": 0, "reasoning": "dry run"},
                        "raw_response": "dry run",
                        "ceo_prompt": "dry run", "cso_prompt": "dry run",
                        "strategy": strategy,
                        "strategy_confidence": 0.9,
                        "strategy_reasoning": "dry run simulation",
                    }
                else:
                    result = run_single_trial(delta, model, trial)
                    time.sleep(RATE_LIMIT_SLEEP)

                results.append(result)

                # Progress
                s = result.get("strategy", "?")
                symbol = s[1] if len(s) > 1 else "?"
                print(symbol, end="")
                sys.stdout.flush()

            # Quick summary for this delta
            strats = [r.get("strategy", "S7") for r in results if abs(r["delta"] - delta) < 0.001]
            neff = compute_neff(strats)
            print(f" → N_eff={neff['N_eff_entropy']:.2f}, N_dist={neff['N_distinct']}")

        # Classify (skip if dry_run since we already set strategies)
        if not dry_run:
            results = classify_all(results)

        # Analyze
        analysis = analyze_by_delta(results, deltas)

        all_results[model_key] = {
            "model": model,
            "raw_results": results,
            "analysis": analysis,
        }

        # Print per-delta summary
        print(f"\n{'Delta':<8} {'N_eff':<8} {'N_dist':<8} {'Conc':<8} {'Surv%':<8} {'Top Strategy'}")
        print("-" * 60)
        for delta in deltas:
            if delta not in analysis:
                continue
            a = analysis[delta]
            neff = a["neff"]
            surv = a["survival"]["survival_rate"]
            top_strat = max(a["strategy_counts"], key=a["strategy_counts"].get)
            top_count = a["strategy_counts"][top_strat]
            print(f"{delta:<8.2f} {neff['N_eff_entropy']:<8.2f} {neff['N_distinct']:<8} "
                  f"{neff['concentration']:<8.2f} {surv*100:<8.0f} {top_strat}({STRATEGY_NAMES[top_strat]}):{top_count}/{a['n_trials']}")

    # --- Cross-model analysis ---
    print("\n" + "=" * 70)
    print("FITTING & HYPOTHESIS TESTING")
    print("=" * 70)

    for model_key, data in all_results.items():
        analysis = data["analysis"]
        d_list = sorted(analysis.keys())
        neffs = [analysis[d]["neff"]["N_eff_entropy"] for d in d_list]
        survivals = [analysis[d]["survival"]["survival_rate"] for d in d_list]
        distributions = [analysis[d]["neff"]["distribution"] for d in d_list]

        print(f"\n--- {model_key} ({data['model']}) ---")

        # H1: Exponential fit
        fit = fit_exponential(d_list, neffs)
        if fit.get("N0") is not None:
            print(f"  Exponential fit: N_eff = {fit['N0']:.2f} · exp(-{fit['alpha']:.2f} · δ)")
            print(f"  R² = {fit['R2']:.4f}  (H1 {'SUPPORTED' if fit['R2'] > 0.8 else 'NOT SUPPORTED'}: threshold R² > 0.8)")
            print(f"  α = {fit['alpha']:.3f} ± {fit.get('alpha_se', 0):.3f}")
            print(f"  AIC = {fit['AIC']:.2f}")
        else:
            print(f"  Fitting failed: {fit.get('error')}")

        # Generate plots
        model_plot_dir = output_dir / f"exp18_plots_{model_key}"
        report = generate_full_report(d_list, neffs, survivals, distributions, fit, model_plot_dir)

        # H2: Causal ordering
        causal = report["hypothesis_tests"]["H2_causal_ordering"]
        print(f"  Causal ordering: {causal['interpretation']}")
        print(f"    N_eff 50% drop at δ = {causal['delta_neff_half']}")
        print(f"    Survival 50% drop at δ = {causal['delta_survival_half']}")

        # H3: Convergence at δ_c
        for d in [0.60, 0.62, 0.64, 0.66]:
            if d in analysis:
                ne = analysis[d]["neff"]["N_eff_entropy"]
                print(f"  N_eff at δ={d}: {ne:.2f} {'(≈1, H3 supported)' if ne < 1.5 else ''}")

        # Model comparison
        mc = report["model_comparison"]
        print(f"  Model comparison: {mc['preferred']} preferred (AIC: exp={mc['exponential_AIC']:.1f}, lin={mc['linear_AIC']:.1f})")

        # Store fit results
        all_results[model_key]["fit"] = fit
        all_results[model_key]["report"] = report

    # --- Save everything ---
    def make_serializable(obj):
        if isinstance(obj, (np.integer,)):
            return int(obj)
        if isinstance(obj, (np.floating,)):
            return float(obj)
        if isinstance(obj, np.ndarray):
            return obj.tolist()
        if isinstance(obj, dict):
            return {str(k): make_serializable(v) for k, v in obj.items()}
        if isinstance(obj, list):
            return [make_serializable(v) for v in obj]
        return obj

    # Raw results — save full manager output for re-classification
    raw_save = []
    for model_key, data in all_results.items():
        for r in data["raw_results"]:
            raw_save.append({
                "delta": r["delta"],
                "model": r["model"],
                "trial": r["trial"],
                "manager_output": r.get("manager_output", {}),
                "strategy": r.get("strategy"),
                "strategy_confidence": r.get("strategy_confidence"),
                "strategy_reasoning": r.get("strategy_reasoning", ""),
                "ceo_prompt": r.get("ceo_prompt", ""),
                "cso_prompt": r.get("cso_prompt", ""),
            })

    with open(output_dir / f"exp18_raw_{timestamp}.json", "w") as f:
        json.dump(make_serializable(raw_save), f, indent=2)

    # Summary with analysis
    summary_save = {}
    for model_key, data in all_results.items():
        summary_save[model_key] = {
            "model": data["model"],
            "analysis": make_serializable(data["analysis"]),
            "fit": make_serializable(data.get("fit", {})),
            "report": make_serializable(data.get("report", {})),
        }

    summary_save["metadata"] = {
        "timestamp": timestamp,
        "n_trials": n_trials,
        "deltas": deltas,
        "classifier_model": CLASSIFIER_MODEL,
        "dry_run": dry_run,
    }

    with open(output_dir / f"exp18_summary_{timestamp}.json", "w") as f:
        json.dump(summary_save, f, indent=2)

    print(f"\n{'='*70}")
    print(f"Results saved to: {output_dir}")
    print(f"  Raw: exp18_raw_{timestamp}.json")
    print(f"  Summary: exp18_summary_{timestamp}.json")
    print(f"  Plots: exp18_plots_*/")
    print(f"End time: {datetime.now().isoformat()}")
    print(f"{'='*70}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Exp.18: N_eff(δ) measurement")
    parser.add_argument("--models", nargs="+", default=["claude"],
                        choices=list(MODELS.keys()),
                        help="Models to test (default: claude)")
    parser.add_argument("--n-trials", type=int, default=N_TRIALS,
                        help=f"Trials per δ/model (default: {N_TRIALS})")
    parser.add_argument("--dry-run", action="store_true",
                        help="Simulate without API calls")
    parser.add_argument("--deltas", nargs="+", type=float, default=None,
                        help="Custom delta levels (default: 15 levels)")
    args = parser.parse_args()

    run_experiment(
        models_to_run=args.models,
        n_trials=args.n_trials,
        deltas=args.deltas,
        dry_run=args.dry_run,
    )
