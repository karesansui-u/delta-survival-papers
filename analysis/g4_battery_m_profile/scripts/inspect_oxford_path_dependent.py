#!/usr/bin/env python3
"""Oxford Path Dependent battery archive manifest / parser smoke.

Modes:
- --manifest-only: record local file identity and zip-entry structure only.
- --inspect-mat:   legacy pre-split mode for top-level keys and array shapes;
                   now requires an explicit legacy acknowledgement flag.

This script intentionally does not compute degradation features, future
capacity endpoints, validation metrics, or M/SP support flags. It is a
pre-freeze archive/parser smoke tool. After the fixed train/test split is
selected, `--inspect-mat` must not be used for new evidence.
"""

from __future__ import annotations

import argparse
import hashlib
import io
import json
import zipfile
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

DEFAULT_MAX_MAT_BYTES = 25 * 1024 * 1024


EXPECTED_FILES: dict[str, tuple[str, ...]] = {
    "part1": (
        "Guide_to_Datafiles.pdf",
        "Guide_to_Datafiles.xlsx",
        "Half_Cell.zip",
        "Group_1.zip",
        "Group_2.zip",
        "Group_3.zip",
        "Group_4.zip",
        "Readme.txt",
        "EIS.zip",
    ),
    "part2": (
        "EIS.zip",
        "Group_1.zip",
        "Group_2.zip",
        "Group_3.zip",
        "Group_4.zip",
        "Group_5.zip",
        "Group_6.zip",
        "Guide_to_Datafiles_2.pdf",
        "Guide_to_Datafiles_2.xlsx",
        "Readme.txt",
    ),
    "part3": (
        "EIS.zip",
        "Group_7.zip",
        "Group_8.zip",
        "Group_9.zip",
        "Group_10.zip",
        "Guide_to_Datafiles_3.pdf",
        "Guide_to_Datafiles_3.xlsx",
        "Readme.txt",
    ),
}

NAME_COUNTS: dict[str, int] = {
    name: sum(1 for filenames in EXPECTED_FILES.values() if name in filenames)
    for filenames in EXPECTED_FILES.values()
    for name in filenames
}


@dataclass(frozen=True)
class FileRecord:
    part: str
    expected_name: str
    path: str | None
    present: bool
    bytes: int | None = None
    sha256: str | None = None
    zip_entries: int | None = None
    zip_mat_entries: int | None = None
    error: str | None = None


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        required=True,
        help="Directory containing Oxford Path Dependent files, either flat or split into part1/part2/part3.",
    )
    parser.add_argument("--output", required=True, help="JSON output path.")
    parser.add_argument(
        "--manifest-only",
        action="store_true",
        help="Record file hashes and zip structure only.",
    )
    parser.add_argument(
        "--inspect-mat",
        action="store_true",
        help="Legacy pre-split mode: inspect top-level keys and shapes from a small number of .mat files.",
    )
    parser.add_argument(
        "--allow-legacy-presplit-mat-smoke",
        action="store_true",
        help="Required with --inspect-mat to acknowledge this is not post-split evidence.",
    )
    parser.add_argument(
        "--max-mat-files",
        type=int,
        default=3,
        help="Maximum number of .mat files to inspect across all zips.",
    )
    parser.add_argument(
        "--max-mat-bytes",
        type=int,
        default=DEFAULT_MAX_MAT_BYTES,
        help="Maximum uncompressed bytes per .mat member inspected.",
    )
    parser.add_argument(
        "--max-mat-files-per-zip",
        type=int,
        default=0,
        help="Optional per-zip cap for .mat inspection; 0 means no per-zip cap.",
    )
    args = parser.parse_args()
    if sum(bool(x) for x in (args.manifest_only, args.inspect_mat)) != 1:
        raise SystemExit("Choose exactly one mode: --manifest-only or --inspect-mat.")
    if args.max_mat_files < 0:
        raise SystemExit("--max-mat-files must be nonnegative.")
    if args.max_mat_bytes <= 0:
        raise SystemExit("--max-mat-bytes must be positive.")
    if args.max_mat_files_per_zip < 0:
        raise SystemExit("--max-mat-files-per-zip must be nonnegative.")
    if args.inspect_mat and not args.allow_legacy_presplit_mat_smoke:
        raise SystemExit(
            "--inspect-mat is legacy pre-split smoke and is disabled after the "
            "fixed train/test split; pass --allow-legacy-presplit-mat-smoke only "
            "for historical reproduction, not new evidence."
        )
    return args


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def has_part_component(root: Path, path: Path, part: str) -> bool:
    try:
        relative_parts = path.relative_to(root).parts[:-1]
    except ValueError:
        relative_parts = path.parts[:-1]
    return any(component.lower() == part.lower() for component in relative_parts)


def find_expected_file(root: Path, part: str, name: str) -> Path | None:
    direct_candidates = [
        root / part / name,
        root / part.upper() / name,
        root / part.capitalize() / name,
    ]
    if NAME_COUNTS[name] == 1:
        direct_candidates.append(root / name)
    for candidate in direct_candidates:
        if candidate.exists():
            return candidate

    matches = sorted(root.rglob(name))
    if not matches:
        return None

    part_matches = [path for path in matches if has_part_component(root, path, part)]
    if len(part_matches) == 1:
        return part_matches[0]
    if NAME_COUNTS[name] == 1 and len(matches) == 1:
        return matches[0]
    if not part_matches:
        return None
    raise SystemExit(f"Ambiguous matches for {part}/{name}: {[str(x) for x in matches]}")


def zip_summary(path: Path) -> tuple[int, int]:
    with zipfile.ZipFile(path) as archive:
        names = archive.namelist()
    mat_names = [name for name in names if name.lower().endswith(".mat")]
    return len(names), len(mat_names)


def build_manifest(root: Path) -> list[FileRecord]:
    records: list[FileRecord] = []
    for part, filenames in EXPECTED_FILES.items():
        for name in filenames:
            path = find_expected_file(root, part, name)
            if path is None:
                records.append(FileRecord(part=part, expected_name=name, path=None, present=False))
                continue

            try:
                zip_entries = None
                zip_mat_entries = None
                file_bytes = path.stat().st_size
                file_sha256 = sha256_file(path)
                if path.suffix.lower() == ".zip":
                    zip_entries, zip_mat_entries = zip_summary(path)
                records.append(
                    FileRecord(
                        part=part,
                        expected_name=name,
                        path=str(path),
                        present=True,
                        bytes=file_bytes,
                        sha256=file_sha256,
                        zip_entries=zip_entries,
                        zip_mat_entries=zip_mat_entries,
                    )
                )
            except Exception as exc:  # noqa: BLE001 - report archive-specific parser failures.
                file_bytes = path.stat().st_size if path.exists() else None
                file_sha256 = sha256_file(path) if path.exists() and path.is_file() else None
                records.append(
                    FileRecord(
                        part=part,
                        expected_name=name,
                        path=str(path),
                        present=True,
                        bytes=file_bytes,
                        sha256=file_sha256,
                        error=f"{type(exc).__name__}: {exc}",
                    )
                )
    return records


def mat_shape(value: Any) -> str:
    shape = getattr(value, "shape", None)
    dtype = getattr(value, "dtype", None)
    if shape is None:
        return type(value).__name__
    if dtype is None:
        return f"shape={tuple(shape)}"
    return f"shape={tuple(shape)}, dtype={dtype}"


def inspect_mat_files(
    records: list[FileRecord],
    max_mat_files: int,
    max_mat_bytes: int,
    max_mat_files_per_zip: int,
) -> list[dict[str, Any]]:
    try:
        from scipy.io import loadmat
    except ImportError as exc:
        raise SystemExit("scipy is required for --inspect-mat. Use --manifest-only otherwise.") from exc

    inspected: list[dict[str, Any]] = []
    for record in records:
        if len(inspected) >= max_mat_files:
            break
        if not record.present or record.path is None or not record.path.lower().endswith(".zip"):
            continue
        try:
            archive = zipfile.ZipFile(record.path)
            mat_infos = [info for info in archive.infolist() if info.filename.lower().endswith(".mat")]
        except Exception as exc:  # noqa: BLE001 - keep corrupt zip smoke bounded.
            inspected.append(
                {
                    "zip_path": record.path,
                    "status": "zip_error",
                    "error": f"{type(exc).__name__}: {exc}",
                    "max_mat_bytes": max_mat_bytes,
                }
            )
            continue
        inspected_in_zip = 0
        with archive:
            for info in mat_infos:
                if len(inspected) >= max_mat_files:
                    break
                if max_mat_files_per_zip and inspected_in_zip >= max_mat_files_per_zip:
                    break
                if info.file_size > max_mat_bytes:
                    inspected.append(
                        {
                            "zip_path": record.path,
                            "mat_entry": info.filename,
                            "uncompressed_bytes": info.file_size,
                            "status": "skipped_too_large",
                            "max_mat_bytes": max_mat_bytes,
                            "max_mat_files_per_zip": max_mat_files_per_zip,
                        }
                    )
                    inspected_in_zip += 1
                    continue
                try:
                    with archive.open(info) as handle:
                        payload = handle.read(max_mat_bytes + 1)
                    if len(payload) > max_mat_bytes:
                        inspected.append(
                            {
                                "zip_path": record.path,
                                "mat_entry": info.filename,
                                "uncompressed_bytes": info.file_size,
                                "status": "skipped_read_exceeded_limit",
                                "max_mat_bytes": max_mat_bytes,
                                "max_mat_files_per_zip": max_mat_files_per_zip,
                            }
                        )
                        inspected_in_zip += 1
                        continue
                    loaded = loadmat(io.BytesIO(payload), squeeze_me=False, struct_as_record=False)
                    public_keys = sorted(key for key in loaded.keys() if not key.startswith("__"))
                    inspected.append(
                        {
                            "zip_path": record.path,
                            "mat_entry": info.filename,
                            "uncompressed_bytes": info.file_size,
                            "status": "inspected",
                            "max_mat_bytes": max_mat_bytes,
                            "max_mat_files_per_zip": max_mat_files_per_zip,
                            "keys": public_keys,
                            "key_shapes": {key: mat_shape(loaded[key]) for key in public_keys},
                        }
                    )
                    inspected_in_zip += 1
                except Exception as exc:  # noqa: BLE001 - keep parser smoke bounded.
                    inspected.append(
                        {
                            "zip_path": record.path,
                            "mat_entry": info.filename,
                            "uncompressed_bytes": info.file_size,
                            "status": "error",
                            "error": f"{type(exc).__name__}: {exc}",
                            "max_mat_bytes": max_mat_bytes,
                            "max_mat_files_per_zip": max_mat_files_per_zip,
                        }
                    )
                    inspected_in_zip += 1
    return inspected


def main() -> None:
    args = parse_args()
    root = Path(args.root)
    output = Path(args.output)
    records = build_manifest(root)
    payload: dict[str, Any] = {
        "status": "pre-freeze parser smoke",
        "root": str(root),
        "mode": "inspect_mat" if args.inspect_mat else "manifest_only",
        "legacy_presplit_mat_smoke_acknowledged": args.allow_legacy_presplit_mat_smoke,
        "limits": {
            "max_mat_files": args.max_mat_files,
            "max_mat_bytes": args.max_mat_bytes,
            "max_mat_files_per_zip": args.max_mat_files_per_zip,
        },
        "expected_parts": sorted(EXPECTED_FILES),
        "records": [asdict(record) for record in records],
        "summary": {
            "expected_files": sum(len(files) for files in EXPECTED_FILES.values()),
            "present_files": sum(1 for record in records if record.present),
            "missing_files": sum(1 for record in records if not record.present),
            "zip_files_present": sum(
                1
                for record in records
                if record.present and record.path is not None and record.path.lower().endswith(".zip")
            ),
            "records_with_errors": sum(1 for record in records if record.error is not None),
        },
    }
    if args.inspect_mat:
        payload["mat_inspection"] = inspect_mat_files(
            records,
            max_mat_files=args.max_mat_files,
            max_mat_bytes=args.max_mat_bytes,
            max_mat_files_per_zip=args.max_mat_files_per_zip,
        )

    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("w", encoding="utf-8") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2, sort_keys=True)
        handle.write("\n")


if __name__ == "__main__":
    main()
