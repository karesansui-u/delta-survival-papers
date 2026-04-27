#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent


BUNDLES = {
    "main-spine-only": {
        "output": "AI_HANDOFF_MAIN_SPINE_ONLY.md",
        "title": "AI Handoff Main Spine Only",
        "description": [
            "This file is a single-file handoff bundle for a human to give to another AI.",
            "It contains only the current main theory spine, without companion papers or supplements.",
            "",
            "Use this when the goal is to understand the core theory with minimal distraction.",
            "- Main public-facing center of gravity: Paper 3.",
            "- Foundation notes: Paper 1 and Paper 2.",
            "- Route C companion anchors and supplements are intentionally omitted.",
        ],
        "parts": [
            ("v2/3_構造持続の収支原理と崩壊傾向.md", "Main Theory Spine: Paper 3"),
            ("v2/1_構造持続の最小形式.md", "Foundation: Paper 1"),
            ("v2/2_構造持続の条件つき導出.md", "Foundation: Paper 2"),
        ],
    },
    "theory-first-full": {
        "output": "AI_HANDOFF_THEORY_FIRST_FULL_BUNDLE.md",
        "title": "AI Handoff Theory-First Full Bundle",
        "description": [
            "This file is a single-file handoff bundle for a human to give to another AI.",
            "It is intentionally ordered to foreground the main theory spine before the LLM-facing companion papers.",
            "",
            "Use this file as follows:",
            "- Primary center of gravity: Papers 1/2/3 are the main theory spine.",
            "- Public-facing shortest route: Paper 0 -> Paper 3 -> Paper 1 -> Paper 2.",
            "- Route C companion papers are observational companion anchors, not the main claim.",
            "- Historical drafts, chat memos, and old archive notes are intentionally omitted.",
            "",
            "Why earlier LLMs often over-focused on LLM reasoning / continual-learning:",
            "- the repository title and earlier paper ordering foregrounded LLM-facing examples,",
            "- Route C companion papers are more concrete and easier to summarize than the abstract theory,",
            "- if files are ingested as an unordered set, salience tends to drift toward the most concrete experimental narrative.",
            "",
            "This bundle corrects that by placing status, integrated map, and the main theory spine first.",
        ],
        "parts": [
            ("analysis/current_evidence_map.md", "Current Evidence Map"),
            ("README.md", "Repository README"),
            ("v2/0_構造持続理論の統合版.md", "Integrated Map (Paper 0)"),
            ("v2/3_構造持続の収支原理と崩壊傾向.md", "Main Theory Spine: Paper 3"),
            ("v2/1_構造持続の最小形式.md", "Foundation: Paper 1"),
            ("v2/2_構造持続の条件つき導出.md", "Foundation: Paper 2"),
            ("v2/Companion_RouteC_推論時の構造劣化.md", "Route C Companion I"),
            ("v2/Companion_RouteC_継続学習時の構造的忘却.md", "Route C Companion II"),
        ],
    },
    "full-theory-with-supplements": {
        "output": "AI_HANDOFF_FULL_THEORY_WITH_SUPPLEMENTS.md",
        "title": "AI Handoff Full Theory With Supplements",
        "description": [
            "This file is a single-file handoff bundle for a human to give to another AI.",
            "It contains the main theory spine, the current active supplements, and the Route C companion anchors.",
            "",
            "Use this when the goal is to capture the broadest active theory state in one file.",
            "- Primary center of gravity remains Papers 1/2/3.",
            "- Supplements are placed after the main spine so they do not overshadow the core claim.",
            "- Route C companion papers are placed last because they are observational companion anchors.",
            "- Historical drafts, chat memos, and old archive notes are intentionally omitted.",
        ],
        "parts": [
            ("analysis/current_evidence_map.md", "Current Evidence Map"),
            ("README.md", "Repository README"),
            ("v2/0_構造持続理論の統合版.md", "Integrated Map (Paper 0)"),
            ("v2/3_構造持続の収支原理と崩壊傾向.md", "Main Theory Spine: Paper 3"),
            ("v2/1_構造持続の最小形式.md", "Foundation: Paper 1"),
            ("v2/2_構造持続の条件つき導出.md", "Foundation: Paper 2"),
            ("v2/補論_構造持続の集合値力学的表現と符号付き指数核.md", "Supplement: Signed Exponential Kernel"),
            ("v2/補論_構造持続の収支原理とFoster-Lyapunovドリフトの形式的埋め込み.md", "Supplement: Foster-Lyapunov Embedding"),
            ("v2/補論_構造持続における資源項Mの操作的定式化.md", "Supplement: M Operationalization"),
            ("v2/補論_非CSP古典例における構造持続の収支原理の最小アンカー.md", "Supplement: Non-CSP Classical Anchors"),
            ("v2/補論_有限CSPにおける構造持続の予測力.md", "Supplement: Finite CSP Predictive Power"),
            ("v2/補論_計算コストの構造的予測.md", "Supplement: Structural Prediction of Compute Cost"),
            ("v2/補論_構造持続写像の標準手順.md", "Supplement: Standard Mapping Procedure"),
            ("v2/Companion_RouteC_推論時の構造劣化.md", "Route C Companion I"),
            ("v2/Companion_RouteC_継続学習時の構造的忘却.md", "Route C Companion II"),
        ],
    },
}


TERMINOLOGY_BLOCK = [
    "Preferred terminology:",
    "- `構造持続理論` = the umbrella theory.",
    "- `構造持続の収支原理` = the principle-level statement developed in Paper 3.",
    "- Do not collapse these into `構造持続律`.",
]


def render_bundle(name: str) -> str:
    spec = BUNDLES[name]
    lines: list[str] = []
    lines.append(f"# {spec['title']}")
    lines.append("")
    lines.append("> Auto-generated by `scripts/build_ai_handoff_bundles.py`. Do not edit manually.")
    lines.append("")
    lines.extend(spec["description"])
    lines.append("")
    lines.extend(TERMINOLOGY_BLOCK)
    lines.append("")
    lines.append("Source files in order:")
    lines.append("")
    for idx, (path, label) in enumerate(spec["parts"], 1):
        lines.append(f"{idx}. `{path}` - {label}")
    lines.append("")
    lines.append("---")
    lines.append("")
    for path, _label in spec["parts"]:
        source = ROOT / path
        if not source.exists():
            raise FileNotFoundError(f"Missing source file: {path}")
        lines.append(f"# Source: `{path}`")
        lines.append("")
        lines.append(source.read_text(encoding="utf-8").rstrip())
        lines.append("")
        lines.append("")
        lines.append("---")
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def write_bundle(name: str) -> Path:
    spec = BUNDLES[name]
    output = ROOT / spec["output"]
    output.write_text(render_bundle(name), encoding="utf-8")
    return output


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate AI handoff bundle markdown files from the active theory docs."
    )
    parser.add_argument(
        "--bundle",
        choices=sorted(BUNDLES.keys()),
        action="append",
        help="Generate only the named bundle. May be passed multiple times.",
    )
    parser.add_argument(
        "--list",
        action="store_true",
        help="List available bundle names and exit.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.list:
        for name, spec in sorted(BUNDLES.items()):
            print(f"{name}: {spec['output']}")
        return 0

    selected = args.bundle or sorted(BUNDLES.keys())
    for name in selected:
        output = write_bundle(name)
        print(output.relative_to(ROOT))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
