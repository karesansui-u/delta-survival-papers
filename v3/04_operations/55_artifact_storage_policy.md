Artifact Storage Policy
=======================

status: operational_policy

date: 2026-05-01 JST

This policy governs how evidence artifacts are stored after a package becomes
large enough that raw row data can dominate the repository.

The policy does not change any existing support, no-support, or invalid-run
decision. It only defines how future artifacts should be packaged.


1. Default Rule
---------------

Evidence must remain auditable. The repository should always contain enough
information for a reader to know:

- what was frozen;
- what command was run;
- what scripts and hashes were used;
- what the primary decision was;
- where the raw artifacts can be found.

However, the repository does not always need to store every raw sample row as a
plain tracked file.


2. Keep In Git
--------------

The following files should normally remain as ordinary tracked files:

- freeze manifests;
- result summaries;
- governance summaries;
- script files used to generate or evaluate the package;
- small diagnostic tables;
- checksums, file sizes, and artifact manifests;
- README files explaining the package.

These files are the human-readable and machine-readable decision surface.


2b. Public / Private Boundary
-----------------------------

This public `v3` tree is for theory-facing and reader-facing materials. It may
contain high-level summaries, non-enabling explanations, frozen public ledgers,
hashes, manifests, and abstract figures.

Do not place patent-sensitive or non-public implementation work products in
this tree. In particular, keep the following outside `v3` unless an explicit
release decision has been made:

- raw experiment results;
- full configs and run requests;
- local scripts or implementation details for private mechanisms;
- controller rules, thresholds, selection policies, or routing internals;
- detailed claim-boundary tables tied to private experiments;
- notes mapping an experiment directly to a patent claim;
- model checkpoints, adapters, embeddings, caches, databases, and run logs;
- copied files from private repositories.

Private or patent-sensitive continual-learning work should live in the private
experiment repositories, such as `delta-infinity-seed` for experiments and
`delta-memorygit` for versioned memory implementation work. Public `v3`
materials should summarize the problem and the non-sensitive claim boundary
without exposing enabling implementation detail.


3. Bundle Or Externalize When Large
-----------------------------------

Large row-level artifacts may be stored as an artifact bundle instead of plain
tracked CSV files when they are not needed for ordinary review.

Examples:

- sampled trajectory rows;
- erasure samples;
- future-path samples;
- large row-level prediction tables;
- repeated bootstrap or simulation records.

Preferred handling:

1. create a compressed artifact bundle, such as `.zip` or `.tar.gz`;
2. record SHA256, byte size, file list, and generation command;
3. keep a small summary table in Git;
4. keep the result summary and governance decision in Git;
5. place the bundle in the agreed artifact location or release archive.


4. Threshold Guidance
---------------------

Use judgment, but the following are practical triggers for bundling:

- more than 50 MB for one package directory;
- more than 100,000 generated sample rows;
- more than 100,000 inserted lines in a single commit;
- repeated packages with the same type of raw sample table.

These thresholds are not evidence rules. They are repository-hygiene triggers.


5. Existing Artifacts
---------------------

Existing committed artifacts remain valid. They do not need to be rewritten
solely to satisfy this policy.

For example, the A06/A19 and A06-stop packages committed on 2026-05-01 keep raw
CSV artifacts in Git to preserve the evidence snapshot at that time. Future
large packages should prefer the bundle-plus-manifest pattern unless there is a
specific reason to keep raw rows as ordinary tracked files.


6. Required Bundle Manifest
---------------------------

When raw artifacts are bundled, the package directory should include an
artifact manifest with at least:

```text
bundle_name
bundle_sha256
bundle_bytes
created_at
generator_command
evaluator_command
script_hashes
included_files
row_counts
primary_summary_pointer
governance_summary_pointer
```

The manifest may be JSON, TSV, or Markdown, but it must be easy to audit.


7. Non-Claims
-------------

Bundling raw artifacts is not:

- a weakening of the evidence record;
- permission to omit hashes or commands;
- permission to keep only a prose result;
- a way to hide failed rows.

Bundled artifacts must remain reproducible and inspectable.


8. Relation To Failure Ledger
-----------------------------

The failure ledger policy still applies. Failed, invalid, no-support, and
below-gate packages should not be deleted or renamed into support. If their raw
rows are bundled, the no-support or invalid-run summaries and ledger entries
must remain ordinary tracked files.
