# Phase 7 Unifying Schema V1

Status: Phase 7 v1 schema extraction / statement candidate.

This note records the first generic schema extracted from the Phase 7 v0
cross-class registry. It is not a universal second-law theorem, not a proof over
all structural-maintenance problems, and not a necessary/sufficient
admissible-map characterization.

The purpose of v1 is narrower:

> identify the smallest common statement shape that explains why the three
> registered limited classes belong to the same law-like profile.

The corresponding Lean registry is:

```text
lean/Survival/CrossClassUnificationV1.lean
```

## 1. What Phase 7 v1 Closes

Phase 7 v0 showed that the three registered limited classes share a profile:

```text
Sigma grammar
  + expectation-level tendency
  + finite-horizon high-probability certificate
  + conditional coarse transfer
```

Phase 7 v1 adds the first explanation layer:

```text
ordered Sigma carrier
  + nonnegative tendency driver
  + finite-horizon certificate route
  + admissible-transfer guard
```

This is the first generic schema candidate. It is still a schema, not a
universal theorem.

The important correction is that **subadditivity is not promoted as the single
generic core**. It may be one useful engine in future classes, but the three
registered classes are more cleanly unified by a broader pattern: an ordered
additive Sigma carrier plus an explicit class-specific driver that supplies the
nonnegative tendency.

## 2. The V1 Schema

A limited structural template belongs to the Phase 7 v1 schema when it supplies:

1. **Sigma carrier**: an ordered additive cumulative quantity \(\Sigma_n\).
2. **Tendency driver**: a class-specific mechanism that yields the relevant
   nonnegative tendency under explicit assumptions.
3. **Certificate route**: a finite-horizon high-probability route after margin
   and concentration assumptions are supplied.
4. **Admissible-transfer guard**: explicit conditions under which the tendency
   or certificate transfers through a coarse / proxy / admissible readout.
5. **Pathwise nondecrease discipline**: Bernoulli-style pathwise nondecrease is
   allowed when available, but it is not required by the cross-class schema.

In compact form:

```text
V1(T) :=
  SigmaCarrier(T)
  ∧ TendencyDriver(T)
  ∧ CertificateRoute(T)
  ∧ TransferGuard(T)
  ∧ not RequiresPathwiseNondecrease(T)
```

The last clause does not mean pathwise nondecrease is false. It means that
pathwise nondecrease is not part of the generic cross-class requirement.

## 3. The Three Registered Classes

| Class template | Tendency driver | Certificate route | Transfer guard | Pathwise nondecrease required? |
|---|---|---|---|---:|
| Bernoulli-CSP | one-sided pathwise emission | Chernoff / KL | endpoint-defect budget | no |
| Foster-Lyapunov / queueing | conditional drift lower bound | conditional Azuma | stochastic compatibility | no |
| Repair-Maintenance | resource-cost lower bound | resource-bounded Azuma | resource-bounded compatibility | no |

Bernoulli-CSP has the stronger pathwise component, but v1 deliberately does not
lift that component into the generic schema. This avoids the main overclaim
risk exposed by Phase 7 v0.

## 4. Why Subadditivity Is Not the Right Single Axis

The Phase 7 v0 registry made subadditivity tempting as the unifying language.
However, forcing all three classes through a subadditivity statement would hide
important differences:

- Bernoulli-CSP is driven by one-sided nonnegative emissions and Chernoff / KL
  concentration.
- Foster-Lyapunov / queueing is driven by conditional drift and martingale
  concentration.
- Repair-Maintenance is driven by explicit damage / repair balance and
  resource-cost lower bounds.

The common object is not a single subadditive process. The common object is a
Sigma carrier equipped with a driver that can supply a nonnegative tendency and
then feed a finite-horizon certificate route.

Subadditivity remains a possible future theorem engine. It is not the v1 schema
itself.

## 5. Generic Statement Candidate

The Phase 7 v1 statement candidate is:

> For any registered limited structural template \(T\), if \(T\) supplies an
> ordered Sigma carrier, a nonnegative tendency driver, a finite-horizon
> certificate route, and an admissible-transfer guard, then \(T\) belongs to the
> law-like limited-class profile. Expected tendency and finite-horizon
> certificate statements may then be invoked only through the class-specific
> driver and its explicit assumptions.

This should be read with two constraints.

First, it is not a theorem over all structural-maintenance problems. It is a
schema over registered limited templates.

Second, it does not erase the difference between engines. Chernoff / KL,
conditional Azuma, and resource-bounded Azuma remain separate certificate
routes.

## 6. Lean Correspondence

`Survival.CrossClassUnificationV1` records:

- `TendencyDriver`: one-sided pathwise emission, conditional drift lower bound,
  resource-cost lower bound.
- `CertificateRoute`: Chernoff / KL, conditional Azuma, resource-bounded Azuma.
- `TransferGuard`: endpoint-defect budget, stochastic compatibility,
  resource-bounded compatibility.
- `Phase7V1SchemaProfile`: the v1 schema fields.
- `supportsPhase7V1Schema`: the schema candidate.
- `all_registered_classes_supportPhase7V1Schema`: all three registered classes
  instantiate the v1 schema.
- `phase7V1Schema_implies_phase7V0`: v1 extends the v0 registry rather than
  replacing it.
- `no_registered_class_requires_pathwiseNondecrease`: pathwise nondecrease is
  not a generic requirement.

The file intentionally stays at registry / schema level. It does not prove:

- a generic theorem over arbitrary future classes;
- an unconditional coarse-graining theorem;
- a necessary/sufficient admissible-map characterization;
- a physical second law;
- that the three listed engines exhaust all future certificate routes.

## 7. What Remains for Phase 7 v2

Phase 7 v2 is the first place where a true generic theorem can be attempted.
The candidate theorem should decide whether the v1 schema can be upgraded from
registry to theorem.

Open choices:

1. **Ordered-additive theorem**: formalize the Sigma carrier as an ordered
   additive object with a supplied lower-bound driver.
2. **Driver interface theorem**: abstract over tendency drivers and certificate
   routes, proving that any driver satisfying a small interface yields the
   limited-class profile.
3. **Admissible-transfer theorem**: isolate the minimal transfer guard that
   moves a certificate through defect-controlled or stochastic coarse maps.
4. **Subadditivity branch**: keep subadditivity as one possible driver, not as
   the whole cross-class law.

The main discipline remains:

```text
Do not promote Phase 7 v1 from schema extraction to universal law.
Use it to decide what the Phase 7 v2 theorem should quantify over.
```
