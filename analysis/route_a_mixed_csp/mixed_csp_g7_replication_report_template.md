# Mixed-CSP G7 Replication Report Template

Status: fill-in template for a returned true outside-group rerun. This file is
not itself evidence until completed with an actual outside-group return
bundle.

## 1. Package Identity

- Published commit used by outside group:
- Date package sent:
- Date return bundle received:
- Outside group / lab / collaborator identifier:
- Local contact:

## 2. Outside-Group Environment Note

- OS:
- Python version:
- solver / dependency notes:
- any required workaround:

## 3. Returned Artifacts

| artifact | received? | sha256 | notes |
|---|---|---|---|
| rerun JSONL |  |  |  |
| rerun results JSON |  |  |  |
| rerun summary MD |  |  |  |
| environment note |  |  |  |

## 4. Frozen-Design Compliance

Record whether the outside group followed the frozen design without redesign.

Checklist:

1. cloned published repository state as requested;
2. used separate outputs;
3. did not overwrite official artifacts;
4. did not alter predictors or support criteria;
5. recorded any workaround explicitly.

Overall compliance judgment:

```text
pass / partial / fail
```

Rationale:

## 5. Core Reproduction Checks

| check | result | notes |
|---|---|---|
| row count reproduced |  |  |
| support flags reproduced |  |  |
| `L_plus_n < raw_plus_n` |  |  |
| `first_moment < raw_plus_n` |  |  |
| `L_plus_n <= cnf_count_plus_n` |  |  |
| malformed / timeout pathology materially changed? |  |  |

## 6. Quantitative Summary

- rerun `L_plus_n` log loss:
- rerun `raw_plus_n` log loss:
- rerun `first_moment` log loss:
- rerun `cnf_count_plus_n` log loss:
- official support decision:
- outside-group support decision:

## 7. Interpretation

Choose one:

```text
Successful outside-group reproduction
```

```text
Non-failure with minor runtime / floating-point drift
```

```text
Replication failure requiring dedicated follow-up
```

Interpretation note:

## 8. What This Does And Does Not Change

If successful:

- strengthens G7 for Mixed-CSP;
- raises external reproducibility credibility for Route A;
- does not by itself close G7 for Exp43c or observational branches.

If non-failure:

- keep the result below clean outside-group reproduction;
- record exact ambiguity source.

If failure:

- do not rescue the result informally;
- open a dedicated replication-failure note.

## 9. One-Line Program Update

Use one of:

```text
Mixed-CSP now has a true outside-group rerun that reproduces the qualitative
support decision.
```

```text
Mixed-CSP outside-group rerun is partially consistent but not yet cleanly
reproduced.
```

```text
Mixed-CSP outside-group rerun failed to reproduce the qualitative support
decision.
```
