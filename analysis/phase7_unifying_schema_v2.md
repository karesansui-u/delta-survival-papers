# Phase 7 Unifying Schema V2

Status: Phase 7 v2 interface / registered-instance closure.

Phase 7 v1 extracted the unifying schema:

```text
ordered Sigma carrier
  + nonnegative tendency driver
  + finite-horizon certificate route
  + admissible-transfer guard
```

Phase 7 v2 turns that schema into an explicit interface and records that the
three currently registered limited classes instantiate it.

This is still not a theorem over all future structural-maintenance problems.
It is a meta-theorem interface plus registered-instance closure.

The corresponding Lean file is:

```text
lean/Survival/CrossClassUnificationV2.lean
```

## 1. What Phase 7 v2 Closes

Phase 7 v2 closes the following narrow claim:

> The v1 schema can be expressed as an interface, and Bernoulli-CSP,
> Foster-Lyapunov / queueing, and Repair-Maintenance all instantiate that
> interface as currently registered limited classes.

Lean names:

- `AbstractUnifyingSchemaInstance`
- `AbstractLawLikeLimitedClassProfile`
- `abstractLawLikeProfile_of_instance`
- `RegisteredUnifyingSchemaInstance`
- `registeredInstanceOf`
- `bernoulliCSP_unifyingSchemaInstance`
- `fosterLyapunovQueueing_unifyingSchemaInstance`
- `repairMaintenance_unifyingSchemaInstance`
- `all_registered_classes_satisfy_unifyingSchema`

## 2. The Interface

The abstract interface asks a class template to supply:

1. an ordered Sigma carrier;
2. a nonnegative tendency driver;
3. a finite-horizon certificate route;
4. an admissible-transfer guard;
5. the discipline that Bernoulli-style pathwise nondecrease is not a generic
   requirement.

The generic interface theorem is intentionally small:

```text
AbstractUnifyingSchemaInstance
  -> AbstractLawLikeLimitedClassProfile
```

This is not mathematically empty, but it is also not a hidden universal law.  It
is a formal unpacking of the obligations that any future class must discharge
before it can be counted as part of the same law-like profile.

## 3. The Three Registered Instances

| Class template | v2 instance | Driver | Certificate | Transfer guard |
|---|---|---|---|---|
| Bernoulli-CSP | `bernoulliCSP_unifyingSchemaInstance` | one-sided pathwise emission | Chernoff / KL | endpoint-defect budget |
| Foster-Lyapunov / queueing | `fosterLyapunovQueueing_unifyingSchemaInstance` | conditional drift lower bound | conditional Azuma | stochastic compatibility |
| Repair-Maintenance | `repairMaintenance_unifyingSchemaInstance` | resource-cost lower bound | resource-bounded Azuma | resource-bounded compatibility |

The v2 theorem

```text
all_registered_classes_satisfy_unifyingSchema
```

is the registered-class closure: every currently registered limited class
satisfies the v1 schema via a v2 instance.

## 4. Why This Is the Right Strength

Phase 7 v2 does not try to force the three classes into one concentration
engine, one subadditivity statement, or one pathwise monotonicity statement.
That would erase the distinctions that made the v1 schema accurate.

Instead, v2 proves that the common shape is stable enough to be an interface:

```text
class-specific driver
  -> expected tendency / certificate route
  -> guarded transfer
  -> law-like limited-class profile
```

The phrase "law-like" should be read in this limited sense.  It means that a
class has the same schema obligations as the three registered templates.  It
does not mean physical universality or an unconditional second law.

## 5. Non-Claims

Phase 7 v2 does not claim:

- a theorem over arbitrary future domains;
- that every structural-maintenance problem admits such an interface;
- a necessary/sufficient characterization of admissible maps;
- a single universal inequality;
- an unconditional coarse-graining theorem;
- that Chernoff / KL, conditional Azuma, and resource-bounded Azuma exhaust all
  possible certificate routes;
- that subadditivity is the unique engine behind structural persistence.

## 6. What Remains

Phase 7 v2 reaches a stable meta-theorem form:

```text
registered limited classes instantiate a common interface.
```

The remaining work is no longer to show that the current three classes fit the
schema.  That is now closed.  The next possible refinements are:

1. **Phase 7 v3**: connect each interface field back to richer class-specific
   theorem wrappers, making the instance evidence less Boolean and more
   semantic.
2. **Phase 5 open ladder**: strengthen admissible-map set-level and
   necessary-side conditions.
3. **Future class admission rule**: define what a fourth class must supply to
   enter the registry without weakening the schema.

The main discipline remains:

```text
Phase 7 v2 is interface closure, not universal-law closure.
```
