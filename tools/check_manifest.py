"""Validate the repository's explicit ingestion manifest without cloud calls."""
import csv
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
entries = json.loads((root / 'config/list.json').read_text())
assert isinstance(entries, list) and entries, 'Manifest must be a nonempty array'
seen = set()
for entry in entries:
    assert all(isinstance(entry.get(k), str) and entry[k] for k in
               ('relative_URL', 'directory_name', 'file_name')), entry
    key = (entry['directory_name'], entry['file_name'])
    assert key not in seen, f'Duplicate sink destination: {key}'
    seen.add(key)
    prefix = 'zaryab-aley/Paktech_Instruments/refs/heads/main/'
    assert entry['relative_URL'].startswith(prefix), 'Unexpected source prefix'
    relative = entry['relative_URL'][len(prefix):]
    assert (root / relative).is_file(), f'Missing repository source: {relative}'
with (root / 'raw_csv/customers.csv').open(encoding='utf-8-sig', newline='') as f:
    old = csv.DictReader(f)
    old_rows = list(old)
    old_header = old.fieldnames
with (root / 'raw_csv/customers_new.csv').open(encoding='utf-8-sig', newline='') as f:
    new = csv.DictReader(f)
    new_rows = list(new)
    assert new.fieldnames == old_header, 'Customer schemas differ'
assert len(new_rows) == 5
assert not ({r['customer_id'] for r in old_rows} & {r['customer_id'] for r in new_rows})
assert all(r['_source_row_id'].startswith('customers:00') for r in new_rows)
print(f'Validated {len(entries)} manifest entries and five disjoint customer additions.')
