#!/usr/bin/env python3
from __future__ import annotations

import re
import shutil
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
PREPRINT_DIR = ROOT / "preprints" / "ja"
OUT = PREPRINT_DIR / "pdf"
SOURCE_PREAMBLE = Path(
    "/Users/sunagawa/Project/delta-survival-paper/v4/pdf用/survival_whitepaper_preamble.tex"
)

DOCS = [
    {
        "src": PREPRINT_DIR / "PREPRINT_THEORY_SHORT_ja.md",
        "stem": "PREPRINT_THEORY_SHORT_ja_whitepaper",
        "title": "構造持続理論 短縮版",
        "subtitle": "持続・停止・崩壊を計算可能な境界問題として立てるための必要文法",
        "date": "2026年6月26日",
        "drop_prefix_headings": 2,
    },
    {
        "src": PREPRINT_DIR / "構造持続理論.md",
        "stem": "PREPRINT_THEORY_ja_whitepaper",
        "title": "構造持続理論",
        "subtitle": "— 構造維持における可能性と不可能性の境界を形式化する理論 —",
        "date": "2026年6月5日",
        "drop_prefix_headings": 2,
    },
    {
        "src": PREPRINT_DIR / "PREPRINT_LEAN_ARTIFACT_ja.md",
        "stem": "PREPRINT_LEAN_ARTIFACT_ja_whitepaper",
        "title": "構造持続理論は Lean で何を保証するか",
        "subtitle": "— 証明書つき入力から境界主張を検証する —",
        "date": "2026年6月5日",
        "drop_prefix_headings": 2,
    },
    {
        "src": PREPRINT_DIR / "M_補論.md",
        "stem": "PREPRINT_M_SIDE_SUPPLEMENT_ja_whitepaper",
        "title": "M側補論",
        "subtitle": "— 名目資源から有効資源へ —",
        "date": "2026年6月6日",
        "drop_prefix_headings": 2,
    },
    {
        "src": PREPRINT_DIR / "L_補論.md",
        "stem": "L_Mixed-SAT_NAE-SAT_L_non_degeneracy_whitepaper",
        "title": "制約は個数ではなく削減量で数える",
        "subtitle": "— Mixed-SAT/NAE-SAT による構造消耗量 L の非縮退検証 —",
        "date": "2026年6月7日",
        "drop_prefix_headings": 2,
    },
]


def latex_escape(text: str) -> str:
    return (
        text.replace("\\", r"\textbackslash{}")
        .replace("&", r"\&")
        .replace("%", r"\%")
        .replace("#", r"\#")
    )


def latex_block_escape(text: str) -> str:
    return (
        latex_escape(text)
        .replace("_", r"\_")
        .replace("{", r"\{")
        .replace("}", r"\}")
        .replace("$", r"\$")
        .replace("~", r"\textasciitilde{}")
        .replace("^", r"\textasciicircum{}")
    )


def math_line_to_tex(line: str) -> str:
    line = line.strip()
    line = line.replace("F -> K -> V_K,m -> L/B -> R/M -> S", r"F \to K \to (V_K,m) \to (L,B) \to (R,M) \to S")
    line = line.replace("loss contribution", r"\mathrm{loss}")
    line = line.replace("repair contribution", r"\mathrm{repair}")
    line = re.sub(r"\brank\(", r"\\operatorname{rank}(", line)
    line = re.sub(r"\blog\b", r"\\log", line)
    line = line.replace("->", r"\to")
    line = line.replace("*", r"\,")
    line = re.sub(r"\bsum_\{([^}]+)\}", r"\\sum_{\1}", line)
    line = re.sub(r"\bexp\(([^)]+)\)", r"\\exp(\1)", line)
    line = re.sub(r"\b([A-Za-z])_([A-Za-z0-9]+)", r"\1_{\2}", line)
    line = line.replace("C_req", r"C_{\mathrm{req}}")
    return line


def block_is_mathish(block: list[str]) -> bool:
    nonempty = [line.strip() for line in block if line.strip()]
    text = "\n".join(nonempty)
    if re.search(r"[一-龯ぁ-んァ-ヶ]", text):
        return False
    if len(nonempty) == 1 and "->" in nonempty[0]:
        return True
    if not nonempty or not all("=" in line for line in nonempty):
        return False
    return all(re.match(r"^[A-Za-z][A-Za-z0-9_{}()]*\s*=", line) for line in nonempty)


def block_is_indented_structure(block: list[str]) -> bool:
    # Keep line-by-line layout when the block conveys structure rather than prose:
    #  - any line uses leading indentation (identifier/taxonomy listings), or
    #  - it is a short multi-line block with no blank-line paragraph breaks
    #    (e.g. contrast pairs like `A = x` / `A != y`).
    nonempty = [line for line in block if line.strip()]
    if any(re.match(r"^\s+\S", line) for line in nonempty):
        return True
    has_blank_break = any(not line.strip() for line in block[1:-1] if block)
    short_lines = all(len(line.strip()) <= 60 for line in nonempty)
    return len(nonempty) >= 2 and not has_blank_break and short_lines


def markdown_heading(line: str) -> tuple[int, str] | None:
    match = re.match(r"^(#{1,6})\s+(.+?)\s*$", line)
    if not match:
        return None
    return len(match.group(1)), strip_heading_number(match.group(2))


def remove_draft_notes(lines: list[str]) -> list[str]:
    # Remove draft-note style one-liners from the final whitepaper view.
    return [
        line
        for line in lines
        if not line.startswith("作業中の日本語プレプリント草稿")
        and not line.startswith("この文書は、構造持続理論そのものの価値")
        and not line.startswith("この文書は、構造持続理論そのものの理論プレプリントではない。")
    ]


def promote_body_headings(lines: list[str]) -> list[str]:
    # Promote Markdown H2/H3 one level down because the title block owns the title.
    promoted: list[str] = []
    for line in lines:
        if line.startswith("### "):
            promoted.append("## " + strip_heading_number(line[4:]))
        elif line.startswith("## "):
            promoted.append("# " + strip_heading_number(line[3:]))
        elif line.startswith("# "):
            promoted.append("# " + strip_heading_number(line[2:]))
        else:
            promoted.append(line)
    return promoted


def fallback_body_after_prefix_headings(lines: list[str], drop_prefix_headings: int) -> list[str]:
    kept: list[str] = []
    dropped = 0
    for line in lines:
        if dropped < drop_prefix_headings and line.startswith("#"):
            dropped += 1
            continue
        if dropped >= drop_prefix_headings:
            kept.append(line)
    return kept


def trim_blank_edges(lines: list[str]) -> list[str]:
    while lines and not lines[0].strip():
        lines.pop(0)
    while lines and not lines[-1].strip():
        lines.pop()
    return lines


def split_intro_and_body(text: str, drop_prefix_headings: int) -> tuple[str, str]:
    text = soften_fenced_text_blocks(text)
    lines = text.splitlines()
    abstract_names = {"概要", "要旨", "最大のメッセージ"}

    abstract_idx = None
    abstract_level = None
    for i, line in enumerate(lines):
        heading = markdown_heading(line)
        if heading is None:
            continue
        level, title = heading
        if title in abstract_names:
            abstract_idx = i
            abstract_level = level
            break

    if abstract_idx is not None and abstract_level is not None:
        body_start = len(lines)
        for i in range(abstract_idx + 1, len(lines)):
            heading = markdown_heading(lines[i])
            if heading is not None and heading[0] <= abstract_level:
                body_start = i
                break
        abstract_lines = lines[abstract_idx + 1 : body_start]
        body_lines = lines[body_start:]
    else:
        body_lines = fallback_body_after_prefix_headings(lines, drop_prefix_headings)
        abstract_lines = []

    abstract_lines = trim_blank_edges(remove_draft_notes(abstract_lines))
    body_lines = trim_blank_edges(promote_body_headings(remove_draft_notes(body_lines)))

    if not body_lines:
        raise ValueError("no body content found")

    return "\n".join(abstract_lines).strip() + "\n", "\n".join(body_lines).strip() + "\n"


def strip_heading_number(title: str) -> str:
    return re.sub(r"^\d+(?:\.\d+)*\.?\s+", "", title.strip())


def soften_fenced_text_blocks(text: str) -> str:
    lines = text.splitlines()
    out: list[str] = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.strip() == "```text":
            block: list[str] = []
            i += 1
            while i < len(lines) and lines[i].strip() != "```":
                block.append(lines[i])
                i += 1
            if i < len(lines) and lines[i].strip() == "```":
                i += 1
            out.append("")
            if block_is_mathish(block):
                nonempty = [item for item in block if item.strip()]
                out.append("$$")
                if len(nonempty) == 1:
                    out.append(math_line_to_tex(nonempty[0]))
                else:
                    out.append(r"\begin{aligned}")
                    rendered: list[str] = []
                    for item in nonempty:
                        tex_line = math_line_to_tex(item)
                        if "=" in tex_line:
                            tex_line = tex_line.replace("=", "&=", 1)
                        rendered.append(tex_line)
                    out.extend([line + (r" \\" if idx < len(rendered) - 1 else "") for idx, line in enumerate(rendered)])
                    out.append(r"\end{aligned}")
                out.append("$$")
            elif block_is_indented_structure(block):
                # Indented identifier/structure lists keep their alignment.
                stripped = [item for item in block if item.strip() or True]
                while stripped and not stripped[0].strip():
                    stripped.pop(0)
                while stripped and not stripped[-1].strip():
                    stripped.pop()
                out.append(r"\begin{quote}")
                out.append(r"{\small\ttfamily\noindent")
                rendered_lines = [
                    latex_block_escape(item).replace(" ", r"~") if item.strip() else r"~"
                    for item in stripped
                ]
                out.append(r" \\".join(rendered_lines) if rendered_lines else "")
                out.append(r"}")
                out.append(r"\end{quote}")
            else:
                # Prose blocks flow as normal wrapped paragraphs.
                out.append(r"\begin{quote}")
                out.append(r"\small")
                paragraph: list[str] = []
                for item in block:
                    if item.strip():
                        paragraph.append(latex_block_escape(item.strip()))
                    else:
                        if paragraph:
                            out.append(" ".join(paragraph) + r"\par")
                            paragraph = []
                if paragraph:
                    out.append(" ".join(paragraph))
                out.append(r"\end{quote}")
            out.append("")
            continue
        out.append(line)
        i += 1
    return "\n".join(out)


def polish_latex(latex: str) -> str:
    replacements = {
        r"\texttt{F}": r"$F$",
        r"\texttt{K}": r"$K$",
        r"\texttt{V\_K}": r"$V_K$",
        r"\texttt{V\_K,m}": r"$(V_K,m)$",
        r"\texttt{L}": r"$L$",
        r"\texttt{B}": r"$B$",
        r"\texttt{L/B}": r"$(L,B)$",
        r"\texttt{R}": r"$R$",
        r"\texttt{M}": r"$M$",
        r"\texttt{R/M}": r"$(R,M)$",
        r"\texttt{S}": r"$S$",
        r"\texttt{F/K}": r"$F/K$",
        r"\texttt{M\ *\ exp(-L)}": r"$M\exp(-L)$",
        r"\texttt{M\ *\ exp(-B)}": r"$M\exp(-B)$",
        r"\texttt{C\_req}": r"$C_{\mathrm{req}}$",
    }
    for old, new in replacements.items():
        latex = latex.replace(old, new)

    def path_repl(match: re.Match[str]) -> str:
        content = match.group(1)
        if len(content) < 28:
            return match.group(0)
        if not re.fullmatch(r"[A-Za-z0-9.\\_]+", content):
            return match.group(0)
        return r"{\scriptsize\path{" + content.replace(r"\_", "_") + "}}"

    return re.sub(r"\\texttt\{([^{}]+)\}", path_repl, latex)


def pandoc_to_latex(markdown: str) -> str:
    tmp = OUT / "_tmp_whitepaper.md"
    tmp.write_text(markdown, encoding="utf-8")
    try:
        result = subprocess.run(
            [
                "/opt/homebrew/bin/pandoc",
                str(tmp),
                "--from=markdown+raw_tex+pipe_tables+fenced_code_blocks+backtick_code_blocks",
                "--to=latex",
                "--wrap=none",
                "--no-highlight",
            ],
            cwd=OUT,
            check=True,
            capture_output=True,
            text=True,
        )
    finally:
        tmp.unlink(missing_ok=True)

    latex = result.stdout.strip() + "\n"
    latex = latex.replace(r"\def\LTcaptype{none}", r"\def\LTcaptype{table}")
    return polish_latex(latex)


def build_doc(doc: dict[str, object]) -> Path:
    source = Path(doc["src"])
    abstract_md, body_md = split_intro_and_body(
        source.read_text(encoding="utf-8"),
        int(doc["drop_prefix_headings"]),
    )
    abstract_tex = pandoc_to_latex(abstract_md)
    body_tex = pandoc_to_latex(body_md)

    title = latex_escape(str(doc["title"]))
    subtitle = latex_escape(str(doc["subtitle"]))
    date = latex_escape(str(doc["date"]))
    stem = str(doc["stem"])

    tex = (
        "\\documentclass[12pt,a4paper]{article}\n"
        "\\input{survival_whitepaper_preamble.tex}\n\n"
        "\\usepackage{microtype}\n"
        "\\makeatletter\n"
        "\\g@addto@macro\\UrlBreaks{\\do\\.\\do\\_\\do\\-}\n"
        "\\makeatother\n"
        "\\setmonofont{Hiragino Sans}\n\n"
        "\\begin{document}\n\n"
        f"\\PaperTitleBlock\n  {{{title}}}\n  {{{subtitle}}}\n  {{{date}}}\n\n"
        "\\begin{abstract}\n"
        f"{abstract_tex}"
        "\\end{abstract}\n\n"
        f"{body_tex}"
        "\\end{document}\n"
    )

    tex_path = OUT / f"{stem}.tex"
    tex_path.write_text(tex, encoding="utf-8")
    return tex_path


def compile_tex(tex_path: Path) -> None:
    for _ in range(2):
        subprocess.run(
            ["/Library/TeX/texbin/xelatex", "-interaction=nonstopmode", tex_path.name],
            cwd=OUT,
            check=True,
        )


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    shutil.copy2(SOURCE_PREAMBLE, OUT / "survival_whitepaper_preamble.tex")
    for doc in DOCS:
        tex_path = build_doc(doc)
        compile_tex(tex_path)
        print(f"built: {tex_path.with_suffix('.pdf')}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
