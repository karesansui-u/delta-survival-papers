#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations

import re
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parent
V2_DIR = ROOT.parent
DEFAULT_DATE = "2026年4月12日"
TARGET_FILES = [
    V2_DIR / "0_構造持続理論の統合版.md",
    V2_DIR / "1_構造持続の最小形式.md",
    V2_DIR / "2_構造持続の条件つき導出.md",
    V2_DIR / "3_構造持続と推論性能の劣化.md",
    V2_DIR / "4_構造持続と継続学習における破滅的忘却.md",
    V2_DIR / "補論_計算コストの構造的予測.md",
]

CJK = "一-龯ぁ-んァ-ヶ々ー"


def latex_escape(text: str) -> str:
    return (
        text.replace("\\", r"\textbackslash{}")
        .replace("&", r"\&")
        .replace("%", r"\%")
        .replace("#", r"\#")
    )


def convert_math(expr: str) -> str:
    expr = expr.strip()
    expr = expr.replace("...", r"\cdots")
    expr = expr.replace("⊇", r"\supseteq")
    expr = expr.replace("≤", r"\le")
    expr = expr.replace("≥", r"\ge")
    expr = expr.replace("×", r"\times")
    expr = expr.replace("Π", r"\prod")
    expr = expr.replace("Σ", r"\sum")
    expr = expr.replace("∞", r"\infty")
    expr = expr.replace("η²", r"\eta^2")
    expr = expr.replace("μ", r"\mu")
    expr = expr.replace("δ", r"\delta")
    expr = expr.replace("ρ", r"\rho")
    expr = expr.replace("α", r"\alpha")
    expr = expr.replace("γ", r"\gamma")
    expr = expr.replace("L̃", r"\tilde{L}")
    expr = re.sub(r"([A-Za-z])\^\(([^)]+)\)", r"\1^{(\2)}", expr)
    expr = re.sub(r"([A-Za-z])_\(([^\)]+)\)", r"\1_{(\2)}", expr)
    expr = re.sub(r"([A-Za-z])_([A-Za-z][A-Za-z0-9]*)", r"\1_{\2}", expr)
    expr = re.sub(r"(?<![A-Za-z\\])ln(?![A-Za-z])", r"\\ln", expr)
    expr = re.sub(r"(?<![A-Za-z\\])exp(?![A-Za-z])", r"\\exp", expr)
    expr = expr.replace("∏", r"\prod")
    return expr


INLINE_OPERATOR_RE = re.compile(
    rf"(?:^|(?<=\s)|(?<=[{CJK}(（。、，,:;]))"
    r"([A-Za-z0-9μδρL̃ΠΣ∏αγ][A-Za-z0-9μδρL̃ΠΣ∏αγ\(\)\^\{\}_/\-\+\.\s]*"
    r"(?:(?::=|=|≤|≥|<|>|⊇|×|≈)\s*[-+]?[A-Za-z0-9μδρL̃ΠΣ∏αγ][A-Za-z0-9μδρL̃ΠΣ∏αγ\(\)\^\{\}_/\-\+\.\s]*)+)"
    rf"(?=(?:\s|$|[{CJK}。、，,:;)\]）]))"
)

INLINE_FUNC_RE = re.compile(
    rf"(?:^|(?<=\s)|(?<=[{CJK}(（。、，,:;]))"
    r"([A-Za-z]+\([A-Za-z0-9μδρL̃ΠΣ∏αγ\(\)\^\{\}_/\-\+\.\s]+\))"
    rf"(?=(?:\s|$|[{CJK}。、，,:;)\]）]))"
)

INLINE_TOKEN_RE = re.compile(
    rf"(?:^|(?<=\s)|(?<=[{CJK}(（。、，,:;]))"
    r"(([A-Za-zμδρL̃ΠΣ∏αγ]\^\([^)]+\))|([A-Za-zμδρL̃ΠΣ∏αγ]_(?:\{[^}]+\}|ref|n|i|c|k|j|[A-Za-z0-9]+)))"
    rf"(?=(?:\s|$|[{CJK}。、，,:;)\]）]))"
)

INLINE_PAREN_RE = re.compile(
    rf"(?:^|(?<=\s)|(?<=[{CJK}(（。、，,:;]))"
    r"(\([A-Za-z0-9μδρL̃ΠΣ∏αγ,\.\s_\-\+\^\{\}]+\))"
    rf"(?=(?:\s|$|[{CJK}。、，,:;)\]）]))"
)


def wrap_inline_math(text: str) -> str:
    if not text or text.lstrip().startswith("|"):
        return text

    text = re.sub(
        r"\\\((.+?)\\\)",
        lambda m: f"${convert_math(m.group(1))}$",
        text,
    )

    parts = text.split('$')
    for i in range(0, len(parts), 2):
        part = parts[i]
        part = INLINE_OPERATOR_RE.sub(
            lambda m: f"${convert_math(m.group(1))}$",
            part,
        )
        part = INLINE_FUNC_RE.sub(
            lambda m: f"${convert_math(m.group(1))}$",
            part,
        )
        part = INLINE_TOKEN_RE.sub(
            lambda m: f"${convert_math(m.group(1))}$",
            part,
        )
        part = INLINE_PAREN_RE.sub(
            lambda m: f"${convert_math(m.group(1))}$",
            part,
        )
        parts[i] = part

    return '$'.join(parts)


def is_math_line(text: str) -> bool:
    stripped = text.strip()
    if not stripped:
        return False
    if re.search(rf"[{CJK}]", stripped):
        return False
    if any(ch in stripped for ch in ("=", "⊇", "≤", "≥", "<", ">", "Σ", "Π", "∞", "^", "_", "(", ")")):
        return True
    return False


def classify_indented_block(lines: list[str]) -> str:
    stripped = [line.strip() for line in lines if line.strip()]
    if not stripped:
        return "prose"
    if any(any(ch in line for ch in ("├", "└", "│", "─")) for line in stripped):
        return "code"
    if any(line.startswith("Question:") or line.startswith("Answer:") for line in stripped):
        return "code"
    if all(re.fullmatch(r"[A-Za-z](?:\^\([^)]+\)|_[A-Za-z0-9]+)?", line) for line in stripped):
        return "math"
    if all(is_math_line(line) for line in stripped):
        return "math"
    if any(re.search(rf"[{CJK}]", line) for line in stripped):
        return "prose"
    if sum(line.endswith("。") or line.endswith("ある。") for line in stripped) >= max(1, len(stripped) // 2):
        return "prose"
    return "code"


def render_math_block(lines: list[str]) -> list[str]:
    stripped = [convert_math(line.strip()) for line in lines if line.strip()]
    if not stripped:
        return []
    if len(stripped) == 1:
        return ["$$", stripped[0], "$$", ""]

    rendered = ["$$", r"\begin{aligned}"]
    for line in stripped:
        if line.startswith("="):
            rendered.append(f"&{line} \\\\")
        elif "=" in line:
            rendered.append(re.sub(r"=", r"&=", line, count=1) + r" \\")
        else:
            rendered.append(line + r" \\")
    rendered[-1] = rendered[-1].removesuffix(r" \\").rstrip()
    rendered.append(r"\end{aligned}")
    rendered.append("$$")
    rendered.append("")
    return rendered


def render_code_block(lines: list[str]) -> list[str]:
    return ["```text", *[line.strip() for line in lines], "```", ""]


def render_prose_block(lines: list[str]) -> list[str]:
    return [wrap_inline_math(line.strip()) for line in lines if line.strip()] + [""]


def is_top_level_heading(line: str, current_section: int) -> tuple[bool, str]:
    m = re.match(r"^(\d+)\.\s+(.+)$", line.strip())
    if not m:
        return False, ""
    value = int(m.group(1))
    if value == current_section + 1:
        return True, m.group(2)
    return False, ""


def is_sub_heading(line: str, current_section: int, current_sub: int) -> tuple[bool, str]:
    m = re.match(r"^(\d+)\.(\d+)\s+(.+)$", line.strip())
    if not m:
        return False, ""
    sec = int(m.group(1))
    sub = int(m.group(2))
    if sec == current_section and sub == current_sub + 1:
        return True, m.group(3)
    return False, ""


def normalize_markdown(md_path: Path) -> tuple[str, str, str, str]:
    lines = md_path.read_text(encoding="utf-8").splitlines()
    if len(lines) < 5:
        raise ValueError(f"{md_path.name} is too short to parse.")

    identifier = lines[0].strip()
    title = lines[1].strip()
    subtitle = lines[2].strip()

    idx = 3
    while idx < len(lines) and not lines[idx].strip():
        idx += 1
    if idx >= len(lines) or lines[idx].strip() != "要旨":
        raise ValueError(f"{md_path.name} does not contain a parseable abstract header.")
    idx += 1

    abstract_lines: list[str] = []
    while idx < len(lines):
        line = lines[idx]
        if re.match(r"^\d+\.\s+.+$", line.strip()):
            break
        abstract_lines.append(line)
        idx += 1

    body_lines = lines[idx:]

    def process_blocks(lines_to_process: list[str], is_body: bool = False) -> list[str]:
        normalized: list[str] = []
        current_section = 0
        current_sub = 0
        i = 0
        while i < len(lines_to_process):
            line = lines_to_process[i]
            if not line.strip():
                normalized.append("")
                i += 1
                continue

            if line.strip() == r"\[":
                block: list[str] = []
                i += 1
                while i < len(lines_to_process) and lines_to_process[i].strip() != r"\]":
                    block.append(lines_to_process[i])
                    i += 1
                if i < len(lines_to_process) and lines_to_process[i].strip() == r"\]":
                    i += 1
                if normalized and normalized[-1] != "":
                    normalized.append("")
                normalized.extend(render_math_block(block))
                continue

            if is_body:
                is_sec, sec_title = is_top_level_heading(line, current_section)
                if is_sec:
                    current_section += 1
                    current_sub = 0
                    normalized.extend([f"# {sec_title}", ""])
                    i += 1
                    continue

                is_sub, sub_title = is_sub_heading(line, current_section, current_sub)
                if is_sub:
                    current_sub += 1
                    normalized.extend([f"## {sub_title}", ""])
                    i += 1
                    continue

            if line.startswith("  "):
                block: list[str] = []
                while i < len(lines_to_process) and (lines_to_process[i].startswith("  ") or not lines_to_process[i].strip()):
                    block.append(lines_to_process[i])
                    i += 1
                kind = classify_indented_block(block)
                if kind == "math":
                    normalized.extend(render_math_block(block))
                elif kind == "code":
                    normalized.extend(render_code_block(block))
                else:
                    normalized.extend(render_prose_block(block))
                continue

            normalized.append(wrap_inline_math(line))
            i += 1
        return normalized

    abstract_normalized = process_blocks(abstract_lines, is_body=False)
    body_normalized = process_blocks(body_lines, is_body=True)

    abstract = "\n".join(abstract_normalized).strip() + "\n"
    body = "\n".join(body_normalized).strip() + "\n"
    return identifier, title, subtitle, abstract, body


def pandoc_markdown_to_latex(markdown_text: str) -> str:
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", suffix=".md", delete=False) as tmp:
        tmp.write(markdown_text)
        tmp_path = Path(tmp.name)

    try:
        result = subprocess.run(
            [
                "/opt/homebrew/bin/pandoc",
                str(tmp_path),
                "--from=markdown+raw_tex+pipe_tables+fenced_code_blocks+backtick_code_blocks",
                "--to=latex",
                "--wrap=none",
                "--no-highlight",
            ],
            check=True,
            capture_output=True,
            text=True,
            cwd=ROOT,
        )
        latex = result.stdout.strip() + "\n"
        latex = latex.replace(r"\def\LTcaptype{none}", r"\def\LTcaptype{table}")
        return latex
    finally:
        tmp_path.unlink(missing_ok=True)


def build_tex(md_path: Path) -> Path:
    _, title, subtitle, abstract_md, body_md = normalize_markdown(md_path)
    abstract_tex = pandoc_markdown_to_latex(abstract_md)
    body_tex = pandoc_markdown_to_latex(body_md)

    tex = (
        "\\documentclass[12pt,a4paper]{article}\n"
        "\\input{survival_whitepaper_preamble.tex}\n\n"
        "\\begin{document}\n\n"
        f"\\PaperTitleBlock\n  {{{latex_escape(title)}}}\n  {{{latex_escape(subtitle)}}}\n  {{{DEFAULT_DATE}}}\n\n"
        "\\begin{abstract}\n"
        f"{abstract_tex}"
        "\\end{abstract}\n\n"
        f"{body_tex}"
        "\\end{document}\n"
    )

    tex_path = ROOT / f"{md_path.stem}.tex"
    tex_path.write_text(tex, encoding="utf-8")
    return tex_path


def compile_tex(tex_path: Path) -> None:
    for _ in range(2):
        subprocess.run(
            [
                "/Library/TeX/texbin/xelatex",
                "-interaction=nonstopmode",
                "-halt-on-error",
                tex_path.name,
            ],
            check=True,
            cwd=ROOT,
        )


def main(paths: list[str]) -> int:
    targets = [Path(p) for p in paths] if paths else TARGET_FILES
    for md_path in targets:
        tex_path = build_tex(md_path)
        compile_tex(tex_path)
        print(f"built: {tex_path.with_suffix('.pdf')}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
