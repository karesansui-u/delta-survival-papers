#!/usr/bin/env python3
"""
Sequential batch runner: submit part N, wait for complete, repeat.
Safe to re-run after sleep/crash — skips already-collected parts,
resumes polling for in-progress batches.
"""
import sys, os, time, json
sys.path.insert(0, os.path.join(os.path.dirname(__file__)))

from exp36_batch import (
    submit_batch, check_status, collect_results,
    _create_client, _find_parts, _batch_meta_path
)
from exp36_context_delta_matrix import load_completed_keys

MODEL = "gpt-4.1-mini"
PARTS = [1, 2, 3, 4]
EXPECTED_PER_PART = {1: 78, 2: 78, 3: 72, 4: 42}


def poll(batch_id, label, interval=120, max_wait=14400):
    start = time.time()
    while time.time() - start < max_wait:
        info = check_status(batch_id)
        if info["status"] in ("completed", "failed", "expired", "cancelled"):
            return info
        elapsed = int(time.time() - start)
        print(f"  [{label}] {info['status']} ... ({elapsed}s elapsed)", flush=True)
        time.sleep(interval)
    print(f"  [{label}] Timeout after {max_wait}s")
    return {"status": "timeout"}


def get_batch_id_for_part(part):
    """Read batch_id from part's metadata file, if already submitted."""
    meta_path = _batch_meta_path(MODEL, part)
    if meta_path.exists():
        with open(meta_path) as f:
            meta = json.load(f)
        return meta.get("batch_id")
    return None


def count_collected_for_part(part):
    """Count how many trials from this part are already in trials.jsonl."""
    meta_path = _batch_meta_path(MODEL, part)
    if not meta_path.exists():
        return 0
    with open(meta_path) as f:
        meta = json.load(f)
    part_keys = set()
    for cid, t in meta["trials"].items():
        part_keys.add((t["delta_level"], t["context_length"], t["trial_idx"]))

    completed = load_completed_keys(MODEL)
    return len(part_keys & completed)


def cleanup_files(part):
    try:
        client = _create_client()
        files = client.files.list(purpose="batch")
        for f in files.data:
            if f"part{part}" in f.filename:
                client.files.delete(f.id)
                print(f"  Deleted file {f.id}")
    except Exception as e:
        print(f"  File cleanup error: {e}")


def main():
    print(f"Sequential Batch Runner for {MODEL}")
    print(f"Parts: {PARTS}")
    print()

    for part in PARTS:
        label = f"Part {part}"
        expected = EXPECTED_PER_PART.get(part, 0)
        collected = count_collected_for_part(part)

        print(f"\n{'='*60}")
        print(f"  {label} ({collected}/{expected} collected)")
        print(f"{'='*60}")

        if collected >= expected:
            print(f"  Already fully collected. Skipping.")
            continue

        batch_id = get_batch_id_for_part(part)

        if batch_id:
            info = check_status(batch_id)
            status = info["status"]

            if status == "completed":
                print(f"  Batch {batch_id} already completed. Collecting...")
                collect_results(batch_id, MODEL, part)
                cleanup_files(part)
                time.sleep(10)
                continue
            elif status in ("failed", "expired", "cancelled"):
                print(f"  Previous batch {batch_id} {status}. Re-submitting...")
                cleanup_files(part)
                time.sleep(30)
                batch_id = submit_batch(MODEL, part)
            elif status in ("validating", "in_progress", "finalizing"):
                print(f"  Batch {batch_id} is {status}. Polling...")
            else:
                print(f"  Unknown status {status}. Polling...")
        else:
            print(f"  No batch_id found. Submitting...")
            batch_id = submit_batch(MODEL, part)

        info = poll(batch_id, label)
        print(f"  Final status: {info['status']}")

        if info["status"] == "completed":
            print(f"  Collecting results...")
            collect_results(batch_id, MODEL, part)
        else:
            print(f"  {label} ended with: {info['status']}")

        cleanup_files(part)
        time.sleep(30)

    print("\n\nAll parts processed. Running summary...")
    from exp36_context_delta_matrix import _print_summary
    _print_summary(MODEL)


if __name__ == "__main__":
    main()
