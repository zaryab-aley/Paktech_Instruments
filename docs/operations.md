# Operations runbook

## Normal run

Publish reviewed ADF changes, trigger the main pipeline once, and monitor under **Pipeline runs**. `Trigger now` is a manual run, distinct from scheduled **Trigger runs**. Inspect Lookup, ForEach/Copy, Databricks and Gold statuses. Never queue repeated full runs because a portal page appears stale; refresh monitoring first.

After all Gold publication succeeds, refresh Power BI Desktop manually. SQL views select the published version; Power BI does not automatically find the latest storage folder.

## Logs and alerts

Configure `PipelineRuns`, `ActivityRuns`, `TriggerRuns` diagnostics to a Log Analytics workspace in resource-specific mode. Use the two queries in `monitoring/`. Delivery is asynchronous. Pipeline `RunId` links to activity `PipelineRunId`.

The project alert uses Data Factory scope, metric `PipelineFailedRuns` / Failed pipeline runs, Total/Sum greater than 0, static threshold, all pipeline names and failure types, one-minute evaluation and a five-minute window. Attach the configured email action group. The action group delivers notifications; it is not the resource to monitor for pipeline failures. Test actual failures with a published, triggered test pipeline. The provided Test_Failure_Alert export is now a successful Wait activity after the exercise, not a currently failing test.

Log Analytics and alert/action-group resources are not in this ADF ARM export. Recreate and verify them separately. Durable correlation between the ADF Run ID and the script-generated Gold GUID is not implemented; SQL outputs and activity details assist investigation.

## Retry and recovery

Lookup and Copy: retry 2, interval 60 seconds (one initial attempt plus up to two retries). Databricks and Gold: retry 0. A permanent HTTP 404 is a source/configuration problem, not a transient outage cured by retrying.

If Bronze fails, inspect the manifest, raw URL, published dataset parameters, sink path, and Copy error. If Silver fails, inspect the job's task error and exact input schema; fix before rebuilding downstream outputs. Do not treat an earlier partially written Silver container as a completed load.

If Silver completed and only Gold needs rebuilding, run **Recover_Gold**, which contains the same Gold script and reads the saved Silver files. Stop the main pipeline/schedule and confirm Silver is stable before running recovery. It creates another snapshot; it does not repair missing or wrong Silver.

The supplied export has no explicit pipeline concurrency. Set each writing pipeline to 1, and separately prevent cross-pipeline/manual overlap. This is an operator-controlled procedure, not a global distributed lock.

## Gold publication and rollback

The Gold script validates all projections, creates all 19 versions and selected grain checks, then publishes reporting views sequentially. Build failure leaves the previous reporting views in place. A publication failure can leave mixed versions; inspect every view before refreshing Power BI.

For rollback, save the current view definitions, identify the target external tables and verify schema, row counts, key uniqueness and business totals. A table's creation timestamp alone does not prove validity. Use ALTER VIEW with explicit reporting columns to point at a verified retained table; run each view DDL in its own batch. Verify object definitions and query results. Restore the saved view definition to return to the current snapshot. The exercised rollback was sales-only; full-model rollback was not tested and requires a consistent retained set of facts and dimensions.

## Adding a source file

For another same-schema customer file containing genuinely new IDs: upload to raw_csv; add a manifest object with relative_URL, directory_name=customers, distinct file_name; upload the revised manifest to ADLS list/list.json. Customers' wildcard read includes both files. The existing source-ID filter only retains IDs starting customers:00. Replacing an existing full snapshot is different from adding disjoint new records: avoid overlapping snapshots without a defined update/deduplication policy.

Verify the entry in Lookup output, Copy status and Bronze folder before investigating Silver. Verify the five new IDs in Silver, Gold and the refreshed report. Other fixed-filename reads require explicit development to onboard extra files. New datasets also need transformations, SQL mapping and modelling; the pipeline is not automatic schema/table discovery.

## Retention and cost

Inventory external tables and dependencies with `sql/06_retention_inventory.sql`. Protect every referenced table plus two previous **verified complete** Gold runs. Do not equate 19 physical tables with a successfully published/validated run. Check logs and data as needed. Unreferenced tables may still have direct clients or be rollback copies.

The project manually removed metadata and the 14 exact storage folders for one identified failed run, then checked current sales remained 215 lines and PKR 1,587,666,826. This tested a procedure; it did not implement automatic cleanup of all history.

Before cleanup: stop the schedule and both writing pipelines, export the exact approved table/folder list, exclude protected versions, and review direct consumers. Drop only approved external-table definitions, then delete only their exact child run folders in Gold. Dropping metadata does not remove files; deleting a parent dataset folder would destroy retained versions. No age-only lifecycle deletion has been enabled for Gold.

The exported schedule is daily 09:00 Pakistan Standard Time. Stop it when not practising to avoid unnecessary compute and snapshot growth. No platform-wide budget or lifecycle resources are included here.
