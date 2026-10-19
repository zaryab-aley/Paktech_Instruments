# Export review and deployment gaps

The source exports were inspected locally. Publishing or applying changes to Azure is outside this package; the repository does not silently change the live workspace.

## Confirmed

- Manifest has 22 entries with unique destination file pairs, including both customer CSV files.
- Notebook customer read is wildcard-based; training attendance is flattened before overwrite; purchase duplicate filtering and synthetic correction rules are present.
- Main and recovery Gold SQL are identical, with validate_only=0.
- Lookup firstRowOnly=false; ForEach iterates Lookup output.value.
- Lookup and Copy retries are 2/60 seconds; downstream retries are zero.
- Databricks uses MSI; Synapse linked service uses managed identity; ADLS linked service uses an account-key secure parameter whose supplied value is empty.
- PBIX decodes successfully; imported rows and five added customer IDs were checked.

## Adjust or verify before deployment

1. **Concurrency:** no explicit concurrency property appears on Main_Pipeline or Recover_Gold in the supplied export. Set each to 1 and re-export; do not run them concurrently. Do not describe that setting as already present in these files.
2. **Lookup dependency:** Main_Pipeline's ForEach depends on Lookup Completed, rather than Succeeded. Use Succeeded so an invalid/unavailable manifest cannot advance the ingestion loop. A failed Lookup is not a usable manifest.
3. **Manifest key spelling:** manifest objects use relative_URL, while Copy reads item().relative_url. Normalise to item().relative_URL for exact correspondence and verify the published activity input. The dataset's parameter name can remain relative_url.
4. **Gold Script type:** the export uses NonQuery. It does execute the batch, but Query should be selected if the final summary result set needs to be returned in activity output. Data writes are controlled by the SQL, not by this label.
5. **Ingestion format:** the export uses DelimitedText source/sink with quoting and type conversion, including the JSONL manifest entry. It is not a byte-preserving Binary copy. Consider a format-specific or Binary landing design as a future change and test JSONL integrity before migrating; no such migration is claimed here.
6. **Environment configuration:** replace workspace resource ID, Databricks domain and job ID, server/storage parameters and notebook volume roots for another environment. Secure parameters are not secret material supplied by this repository.
7. **Schedule:** exported trigger is Started, daily 09:00 Pakistan time, start 2026-10-20. Review before deployment and keep it stopped during bootstrap/recovery/cleanup. A schedule setting is not archival proof of a past execution.
8. **Notebook maintenance:** country/city replacements and source-ID filters are pack-specific; dates such as purchase expected_receipt_date and service closed_date are not fully typed in Silver; some values are floats and Power Query retains conversions/deduplication. Preserve the tested reconstruction and make future improvements through separately validated changes.
9. **Standalone installation:** helper 03 is new and only statically checked. The original runtime was tested against existing reporting objects, not an empty database. Initial installation requires staged provisioning, identity configuration and validation.
10. **Visual review:** PBIX metadata, DAX and imported records were inspected, but native Power BI visuals were not rendered in this packaging environment. Generic Page 1–4 names and layout polish remain optional.

These findings are documented rather than overwritten into the uploaded exports. The notebook's business code and exported ADF resource properties remain unchanged.
