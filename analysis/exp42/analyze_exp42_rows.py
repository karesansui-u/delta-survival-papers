#!/usr/bin/env python3
"""Row-level diagnostics for Exp.42 scope-gradient results."""

from __future__ import annotations

import argparse
import json
import re
from collections import Counter, defaultdict
from datetime import datetime
from pathlib import Path
from typing import Any


EXP42_DIR = Path(__file__).resolve().parent
DEFAULT_MODEL = "gpt-4.1-mini"
PRIMARY_CONDITIONS = ["strong_scope", "medium_scope", "weak_scope", "subtle"]
DIAGNOSTIC_CONDITIONS = ["zero_sanity", "structural_anchor"]


def safe_name(model_name: str) -> str:
    return model_name.replace(":", "_").replace("/", "_").replace(".", "_")


def trials_path(model_name: str) -> Path:
    return EXP42_DIR / f"exp42_{safe_name(model_name)}_trials.jsonl"


def row_analysis_json_path(model_name: str) -> Path:
    return EXP42_DIR / f"exp42_{safe_name(model_name)}_row_analysis.json"


def row_analysis_md_path(model_name: str) -> Path:
    return EXP42_DIR / f"exp42_{safe_name(model_name)}_row_analysis.md"


def load_records(model_name: str) -> list[dict[str, Any]]:
    path = trials_path(model_name)
    if not path.exists():
        raise SystemExit(f"No trials file found: {path}")
    with path.open() as f:
        return [json.loads(line) for line in f if line.strip()]


def accuracy(rows: list[dict[str, Any]]) -> float | None:
    if not rows:
        return None
    return sum(1 for row in rows if row["is_correct"]) / len(rows)


def template_key(sentence: str | None) -> str:
    if not sentence:
        return "(none)"
    text = sentence
    text = re.sub(r"\b[abc]\s*=\s*-?\d+", "{var} = {wrong_val}", text)
    text = re.sub(r"\b[abc]\s+as\s+-?\d+", "{var} as {wrong_val}", text)
    text = re.sub(r"\b[abc]\s+would be\s+-?\d+", "{var} would be {wrong_val}", text)
    text = re.sub(
        r"\b[abc]\s+was temporarily recorded as\s+-?\d+",
        "{var} was temporarily recorded as {wrong_val}",
        text,
    )
    text = re.sub(r"\s+", " ", text).strip()
    return text


def target_key(row: dict[str, Any]) -> str:
    target = row["target"]
    return f"{target['a']}:{target['b']}:{target['c']}"


def summarize_group(
    rows: list[dict[str, Any]],
    key_fn,
) -> dict[str, dict[str, Any]]:
    grouped: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for row in rows:
        grouped[str(key_fn(row))].append(row)
    return {
        key: {
            "correct": sum(1 for row in group if row["is_correct"]),
            "n": len(group),
            "accuracy": accuracy(group),
            "exact_wrong_sum_adoptions": sum(
                1
                for row in group
                if not row["is_correct"]
                and row.get("wrong_sum") is not None
                and row.get("answer") == row.get("wrong_sum")
            ),
        }
        for key, group in sorted(grouped.items())
    }


def mistake_summary(rows: list[dict[str, Any]]) -> dict[str, Any]:
    mistakes = [row for row in rows if not row["is_correct"]]
    exact_wrong_sum = [
        row
        for row in mistakes
        if row.get("wrong_sum") is not None and row.get("answer") == row.get("wrong_sum")
    ]
    no_numeric_answer = [row for row in mistakes if row.get("answer") is None]
    other_numeric = [
        row
        for row in mistakes
        if row.get("answer") is not None
        and not (row.get("wrong_sum") is not None and row.get("answer") == row.get("wrong_sum"))
    ]
    examples = []
    for row in mistakes[:20]:
        examples.append(
            {
                "condition": row["condition"],
                "trial_idx": row["trial_idx"],
                "target_key": target_key(row),
                "expected": row["expected"],
                "answer": row["answer"],
                "wrong_sum": row.get("wrong_sum"),
                "injected_var": row.get("injected_var"),
                "injected_wrong_val": row.get("injected_wrong_val"),
                "template": template_key(row.get("injected_sentence")),
            }
        )
    return {
        "mistakes": len(mistakes),
        "exact_wrong_sum_adoptions": len(exact_wrong_sum),
        "exact_wrong_sum_rate_all_trials": len(exact_wrong_sum) / len(rows) if rows else None,
        "exact_wrong_sum_rate_among_mistakes": len(exact_wrong_sum) / len(mistakes) if mistakes else None,
        "no_numeric_answer": len(no_numeric_answer),
        "other_numeric_wrong": len(other_numeric),
        "first_20_examples": examples,
    }


def detailed_mistakes(rows: list[dict[str, Any]]) -> list[dict[str, Any]]:
    details = []
    for row in rows:
        if row["is_correct"]:
            continue
        details.append(
            {
                "condition": row["condition"],
                "trial_idx": row["trial_idx"],
                "target_key": target_key(row),
                "expected": row["expected"],
                "answer": row["answer"],
                "wrong_sum": row.get("wrong_sum"),
                "injected_var": row.get("injected_var"),
                "injected_original_val": row.get("injected_original_val"),
                "injected_wrong_val": row.get("injected_wrong_val"),
                "injected_sentence": row.get("injected_sentence"),
                "template": template_key(row.get("injected_sentence")),
                "mode": (
                    "exact_wrong_sum_adoption"
                    if row.get("wrong_sum") is not None and row.get("answer") == row.get("wrong_sum")
                    else "no_numeric_answer"
                    if row.get("answer") is None
                    else "other_numeric_wrong"
                ),
            }
        )
    return details


def analyze(model_name: str) -> dict[str, Any]:
    records = load_records(model_name)
    succeeded = [row for row in records if row["result_type"] == "succeeded"]
    conditions = PRIMARY_CONDITIONS + DIAGNOSTIC_CONDITIONS

    by_condition: dict[str, Any] = {}
    for condition in conditions:
        rows = [row for row in succeeded if row["condition"] == condition]
        by_condition[condition] = {
            "correct": sum(1 for row in rows if row["is_correct"]),
            "n": len(rows),
            "accuracy": accuracy(rows),
            "mistakes": mistake_summary(rows),
        }

    primary = [row for row in succeeded if row["condition"] in PRIMARY_CONDITIONS]
    analysis = {
        "experiment": "exp42_scope_gradient",
        "model": model_name,
        "n_records": len(records),
        "n_succeeded": len(succeeded),
        "result_type_counts": dict(Counter(row["result_type"] for row in records)),
        "condition_counts": dict(Counter(row["condition"] for row in records)),
        "by_condition": by_condition,
        "by_condition_target": {
            condition: summarize_group(
                [row for row in succeeded if row["condition"] == condition],
                target_key,
            )
            for condition in conditions
        },
        "by_condition_template": {
            condition: summarize_group(
                [row for row in succeeded if row["condition"] == condition],
                lambda row: template_key(row.get("injected_sentence")),
            )
            for condition in conditions
        },
        "by_condition_template_injected_var": {
            condition: {
                template: summarize_group(group, lambda row: row.get("injected_var"))
                for template, group in _group_rows(
                    [row for row in succeeded if row["condition"] == condition and row.get("injected_sentence")],
                    lambda row: template_key(row.get("injected_sentence")),
                ).items()
            }
            for condition in PRIMARY_CONDITIONS
        },
        "by_condition_injected_var": {
            condition: summarize_group(
                [row for row in succeeded if row["condition"] == condition and row.get("injected_var")],
                lambda row: row.get("injected_var"),
            )
            for condition in PRIMARY_CONDITIONS
        },
        "by_condition_abs_offset": {
            condition: summarize_group(
                [row for row in succeeded if row["condition"] == condition and row.get("injected_var")],
                lambda row: abs(row["injected_wrong_val"] - row["injected_original_val"]),
            )
            for condition in PRIMARY_CONDITIONS
        },
        "primary_wrong_answer_modes": mistake_summary(primary),
        "medium_scope_mistakes": detailed_mistakes(
            [row for row in succeeded if row["condition"] == "medium_scope"]
        ),
        "weak_scope_mistakes": detailed_mistakes(
            [row for row in succeeded if row["condition"] == "weak_scope"]
        ),
        "subtle_mistakes": detailed_mistakes(
            [row for row in succeeded if row["condition"] == "subtle"]
        ),
        "generated_at": datetime.now().isoformat(),
    }
    return analysis


def _group_rows(rows: list[dict[str, Any]], key_fn) -> dict[str, list[dict[str, Any]]]:
    grouped: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for row in rows:
        grouped[str(key_fn(row))].append(row)
    return grouped


def fmt_acc(cell: dict[str, Any]) -> str:
    acc = cell.get("accuracy")
    if acc is None:
        return "NA"
    return f"{cell['correct']}/{cell['n']} = {acc:.2f}"


def fmt_rate(value: float | None) -> str:
    if value is None:
        return "NA"
    return f"{value:.3f}"


def render_markdown(analysis: dict[str, Any]) -> str:
    lines = [
        "# Exp.42 Row-Level Analysis",
        "",
        f"- Model: `{analysis['model']}`",
        f"- Records: {analysis['n_records']} ({analysis['n_succeeded']} succeeded)",
        f"- Generated: {analysis['generated_at']}",
        "",
        "## Condition-Level Error Modes",
        "",
        "| condition | accuracy | exact wrong-sum adoptions | rate / all trials | rate / mistakes | no numeric answer | other numeric wrong |",
        "|---|---:|---:|---:|---:|---:|---:|",
    ]
    for condition, cell in analysis["by_condition"].items():
        mistakes = cell["mistakes"]
        lines.append(
            "| "
            + " | ".join(
                [
                    condition,
                    fmt_acc(cell),
                    str(mistakes["exact_wrong_sum_adoptions"]),
                    fmt_rate(mistakes["exact_wrong_sum_rate_all_trials"]),
                    fmt_rate(mistakes["exact_wrong_sum_rate_among_mistakes"]),
                    str(mistakes["no_numeric_answer"]),
                    str(mistakes["other_numeric_wrong"]),
                ]
            )
            + " |"
        )

    lines.extend(
        [
            "",
            "## Mechanistic Notes",
            "",
            "- `exact wrong-sum adoption` is the most conservative row-level proxy for contradiction-taking: the model used the injected wrong value and returned the corresponding corrupted sum exactly.",
            "- `medium_scope` has one miss, but it is not an exact wrong-sum adoption. The row is `expected=690`, `wrong_sum=685`, `answer=775`, so it is classified as an arithmetic/parsing error rather than clean contradiction-taking.",
            "- The strong-support margin failure is therefore ceiling-limited: `strong_scope` and `medium_scope` both block contradiction-taking in this run.",
            "- The observed contradiction-taking rate drops from `subtle` 25/50 = 0.50 over all trials (25/40 = 0.62 among mistakes), to `weak_scope` 1/50 = 0.02 over all trials (1/8 = 0.13 among mistakes), to 0 in `medium_scope` and `strong_scope`.",
        ]
    )

    lines.extend(
        [
            "",
            "## Target Balance",
            "",
        ]
    )
    for condition in PRIMARY_CONDITIONS:
        lines.append(f"### {condition}")
        lines.append("")
        lines.append("| target_key | accuracy |")
        lines.append("|---|---:|")
        for key, cell in analysis["by_condition_target"][condition].items():
            lines.append(f"| `{key}` | {fmt_acc(cell)} |")
        lines.append("")

    lines.extend(
        [
            "## Template Sensitivity",
            "",
        ]
    )
    for condition in PRIMARY_CONDITIONS:
        lines.append(f"### {condition}")
        lines.append("")
        lines.append("| template | accuracy | exact wrong-sum adoptions |")
        lines.append("|---|---:|---:|")
        for key, cell in sorted(
            analysis["by_condition_template"][condition].items(),
            key=lambda item: (item[1]["accuracy"], item[0]),
        ):
            lines.append(f"| `{key}` | {fmt_acc(cell)} | {cell['exact_wrong_sum_adoptions']} |")
        lines.append("")

    lines.extend(
        [
            "## Injected Variable Sensitivity",
            "",
            "| condition | a | b | c |",
            "|---|---:|---:|---:|",
        ]
    )
    for condition in PRIMARY_CONDITIONS:
        cells = analysis["by_condition_injected_var"][condition]
        lines.append(
            f"| {condition} | {fmt_acc(cells.get('a', {'accuracy': None}))} "
            f"| {fmt_acc(cells.get('b', {'accuracy': None}))} "
            f"| {fmt_acc(cells.get('c', {'accuracy': None}))} |"
        )

    lines.extend(
        [
            "",
            "## Subtle Template x Variable Check",
            "",
            "| subtle template | a | b | c |",
            "|---|---:|---:|---:|",
        ]
    )
    for template, cells in sorted(analysis["by_condition_template_injected_var"]["subtle"].items()):
        lines.append(
            f"| `{template}` | {fmt_acc(cells.get('a', {'accuracy': None}))} "
            f"| {fmt_acc(cells.get('b', {'accuracy': None}))} "
            f"| {fmt_acc(cells.get('c', {'accuracy': None}))} |"
        )

    lines.extend(
        [
            "",
            "## Offset Sensitivity",
            "",
            "| condition | offset=2 | offset=3 | offset=5 | offset=7 |",
            "|---|---:|---:|---:|---:|",
        ]
    )
    for condition in PRIMARY_CONDITIONS:
        cells = analysis["by_condition_abs_offset"][condition]
        lines.append(
            f"| {condition} | {fmt_acc(cells.get('2', {'accuracy': None}))} "
            f"| {fmt_acc(cells.get('3', {'accuracy': None}))} "
            f"| {fmt_acc(cells.get('5', {'accuracy': None}))} "
            f"| {fmt_acc(cells.get('7', {'accuracy': None}))} |"
        )

    lines.extend(
        [
            "",
            "## Medium-Scope Miss",
            "",
            "| trial_idx | target_key | expected | answer | wrong_sum | injected_var | sentence | mode |",
            "|---:|---|---:|---:|---:|---|---|---|",
        ]
    )
    for row in analysis["medium_scope_mistakes"]:
        lines.append(
            f"| {row['trial_idx']} | `{row['target_key']}` | {row['expected']} "
            f"| {row['answer']} | {row['wrong_sum']} | {row['injected_var']} "
            f"| `{row['injected_sentence']}` | {row['mode']} |"
        )

    lines.extend(
        [
            "",
            "## Interpretation Notes",
            "",
            "- The failed strong-support margin is driven by a ceiling effect: strong_scope was perfect and medium_scope missed only one row.",
            "- The single medium_scope miss was not an exact wrong-sum adoption, so it is better read as an arithmetic/parsing error than a clean scope failure.",
            "- subtle shows a qualitatively different failure mode: many errors exactly adopt the injected wrong sum, while weak_scope mostly avoids exact adoption. This specifies attribution-as-repair at the row level.",
            "- structural_anchor failures are qualitatively different from subtle and weak_scope failures: 18/20 structural failures returned no numeric answer at all, suggesting self-referential impossibility induces refusal/output-format collapse rather than wrong-value uptake.",
            "- subtle failures are not target-specific; each target cell is 2/10 correct, which points to the manipulation rather than one unlucky arithmetic target.",
            "- injected_var matters most in subtle: `a` retains partial performance, while `b` and `c` collapse in this run. The aggregate subtle accuracy of 0.20 therefore understates the collapse for later variables.",
            "- subtle shows a template x variable interaction, not a pure position artifact. `A later record contains...` and `A later note lists...` preserve `a` in 10/12 combined rows, while `A later entry gives...` and `A later note records...` collapse even on `a` in 0/11 rows. All four subtle templates collapse on `b` and `c`.",
            "- Offset effects are secondary in this run: the subtle condition remains poor at every offset, although offset=7 retains more accuracy than the smaller offsets.",
        ]
    )
    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", default=DEFAULT_MODEL)
    args = parser.parse_args()

    analysis = analyze(args.model)
    row_analysis_json_path(args.model).write_text(
        json.dumps(analysis, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    row_analysis_md_path(args.model).write_text(
        render_markdown(analysis),
        encoding="utf-8",
    )
    print(f"Wrote {row_analysis_json_path(args.model)}")
    print(f"Wrote {row_analysis_md_path(args.model)}")


if __name__ == "__main__":
    main()
