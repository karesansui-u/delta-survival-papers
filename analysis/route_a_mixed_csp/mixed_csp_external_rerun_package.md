# Mixed-CSP External Rerun Package Note

Status: external-replication packaging note. Not a new empirical result and not
validation evidence.

Date: 2026-04-27

Upstream notes:

- `analysis/g7_mixed_csp_replication_package_plan.md`
- `analysis/route_a_mixed_csp/mixed_csp_audit_replay_note.md`
- `analysis/route_a_mixed_csp/mixed_csp_level2_rerun_note.md`

Purpose:

Define the exact external rerun package shape for Mixed-CSP after internal
Level 1 audit replay and Level 2 local fresh rerun are complete.

This note is about what to hand to an outside replicator. It does not change
the frozen Mixed-CSP design.

## 1. Current Replication Status

Mixed-CSP now has:

1. official frozen primary package;
2. Level 1 artifact-audit replay complete;
3. Level 2 local fresh rerun complete;
4. external independent rerun still open.

So the next clean G7 move is no longer "should we rerun Mixed-CSP?" but:

```text
what exact bundle should an outside replicator receive so that the rerun is
clean, bounded, and evidence-tier appropriate?
```

## 2. Package Boundary

The external rerun package should contain only the files required to:

1. understand the frozen design;
2. install dependencies;
3. run smoke / diagnostics / primary;
4. compare results to the official reference.

It should not contain:

- aborted experimental branches;
- Backblaze or q-coloring code;
- private local notes unrelated to Mixed-CSP;
- local rerun outputs from `replication_outputs/`.

## 3. Minimum File Bundle

Recommended external bundle contents:

| File | Role |
|---|---|
| `analysis/route_a_mixed_csp/README.md` | human entry point |
| `analysis/route_a_mixed_csp/mixed_csp_preregistration.md` | frozen design |
| `analysis/route_a_mixed_csp/run_mixed_csp.py` | smoke / primary runner |
| `analysis/route_a_mixed_csp/analyze_mixed_csp.py` | held-out analysis |
| `analysis/route_a_mixed_csp/mixed_csp_generator.py` | deterministic instance generation |
| `analysis/route_a_mixed_csp/mixed_csp_solvers.py` | solver wrapper |
| `analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py` | regression / agreement diagnostics |
| `analysis/route_a_mixed_csp/mixed_csp_primary_official_2026-04-22.jsonl` | official raw reference |
| `analysis/route_a_mixed_csp/mixed_csp_results.json` | official machine-readable summary |
| `analysis/route_a_mixed_csp/mixed_csp_results_summary.md` | official human-readable summary |
| `requirements.txt` | install surface |

Optional but useful:

| File | Role |
|---|---|
| `analysis/route_a_mixed_csp/mixed_csp_audit_replay_note.md` | Level 1 history |
| `analysis/route_a_mixed_csp/mixed_csp_level2_rerun_note.md` | Level 2 local rerun history |

## 4. Reference Artifact Hashes

Official reference artifacts to publish with the package:

| File | sha256 |
|---|---|
| `mixed_csp_primary_official_2026-04-22.jsonl` | `bcc01d7ddf74a898119eab69ce34a8a38b9005db8a89d1eb6206da6d9158e01c` |
| `mixed_csp_results.json` | `1d49c63281eec9a78e1b2be1e4361fc4c657c1bf2edb31daa34dcef1762f8375` |
| `mixed_csp_results_summary.md` | `e67025d9995ce13eed93abf22ed484134563eeccc7fe29cd8405ad1be4391136` |

These hashes give the outside replicator a stable target before any fresh rerun
is attempted.

## 5. External Quickstart

Recommended external rerun order:

Install:

```bash
pip install -r requirements.txt
```

Smoke dry-run:

```bash
python3 analysis/route_a_mixed_csp/run_mixed_csp.py smoke dry-run
```

Smoke execution:

```bash
python3 analysis/route_a_mixed_csp/run_mixed_csp.py smoke run --execute
```

Diagnostics:

```bash
python3 analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py regression
python3 analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py agreement --instances 1000
python3 analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py agreement --instances 500 --n 80 --density 2.0
python3 analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py agreement --instances 500 --n 160 --density 2.0
```

Primary dry-run:

```bash
python3 analysis/route_a_mixed_csp/run_mixed_csp.py primary dry-run
```

Primary rerun:

```bash
python3 analysis/route_a_mixed_csp/run_mixed_csp.py primary run --execute
python3 analysis/route_a_mixed_csp/analyze_mixed_csp.py analyze
```

## 6. Success Criterion To Hand Off

The external rerun should be judged primarily on:

1. `L_plus_n < raw_plus_n`;
2. `first_moment < raw_plus_n`;
3. `L_plus_n <= cnf_count_plus_n`;
4. support flags all passing;
5. no new malformed-encoding pathology;
6. timeout pattern still low enough that interpretation does not change.

Exact floating identity is welcome, but qualitative reproduction is the
required threshold.

## 7. What The Package Should Explicitly Say

The handoff should state all three of these:

```text
Mixed-CSP is already primary validated.
The external rerun is a replication exercise, not a new design.
Observational branches such as Backblaze sit below Mixed-CSP in evidence tier.
```

That prevents accidental scope inflation.

## 8. Relation To The Next Replication Target

Once this external Mixed-CSP package is assembled, the next Route A replication
target remains:

```text
Exp43c q-coloring
```

That preserves the intended G7 order:

```text
Mixed-CSP external package -> Exp43c rerun -> observational branches later
```
