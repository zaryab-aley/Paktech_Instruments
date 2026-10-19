# Setup and execution order

## Required services

- ADLS Gen2 account with hierarchical namespace and containers `bronze`, `silver`, `gold`, `list`.
- Azure Data Factory with an Azure integration runtime.
- Azure Databricks with Unity Catalog, ADLS external locations/volumes and a serverless notebook job.
- Synapse Analytics Built-in serverless SQL endpoint and database `paktech`.
- Log Analytics workspace and Azure Monitor alert/action group configured separately.
- Power BI Desktop for the report.

There is no local Spark fallback in the uploaded notebook. Configure Azure access before execution. Its `try_to_date` and `Column.try_cast` calls require compatible APIs in the chosen Databricks serverless environment; do not assume a generic older PySpark installation can run it.

## Paths and notebook

Bronze volume: `/Volumes/paktechworkspace/default/external_volume`.
Silver volume: `/Volumes/paktechworkspace/default/external_volume_2`.
Map those volumes to the corresponding storage containers. If deploying elsewhere, replace these roots in the notebook. Folders retaining `.csv`/`.jsonl` names contain Silver **Parquet** files.

The notebook uses wildcard input only for customers. Other datasets have fixed input filenames. It processes FX rates into Silver, but FX rates are excluded from the 19-object Gold model. Code cells in both notebook exports preserve the supplied transformations; markdown was added and execution metadata stripped. Diagnostic display calls remain as authored.

## Databricks job and identity

Create a notebook task using `databricks/silver_transformations.ipynb` or import the `.py` Databricks source. Select serverless compute. The original job ID, workspace URL and workspace resource ID in the ARM export are specific to the original environment: replace them when deploying elsewhere.

ADF uses MSI to call Databricks. Assign the factory identity the documented workspace resource access, add its existing Entra service principal to the Databricks workspace, and grant **Can Manage Run** on the job. Azure IAM access and job-level execution permission are separate. Leave Run as configured to an identity that can access the required Unity Catalog volumes.

## SQL and storage access

Use an authorised Entra SQL administrator for initial configuration. The Synapse workspace identity referenced by `cred_paktech` needs storage data-plane access to read Silver and write Gold. The ADF identity is a contained database user with SQL permissions from `sql/01_external_access.sql`.

Replace `YOUR_STORAGE_ACCOUNT`, create the `paktech` database, and configure a database master key privately if needed. Script 01 retains existing external sources; if an existing source points to the wrong account, inspect and correct it rather than assuming rerunning 01 changes it.

Run source-view setup only after Silver exists. The view schema `gold` is historical naming: those views read Silver files.

## Initial deployment versus refresh

`04_build_gold.sql` is the actual tested runtime, extracted from the ADF export. It requires all 19 reporting objects to exist so it can preserve their column contracts.

`03_bootstrap_reporting.sql` is an additional initial-install helper generated for handover. It is **not** a script executed during the original project. It creates initial CETAS outputs and reporting views in a new database. It checks that the reporting names are absent and must not be used on the existing project database. Complete initial data/relationship validation before enabling scheduled refreshes. On partial bootstrap failure, inspect created objects before retrying; it is not a complete automatic installation/rollback system.

After bootstrap, use 04 with validation-only mode first, then build mode. The invoice compatibility fields absent from current Silver are typed NULLs, not restored audit values. The date range and its 730-row assertion must be changed together if extending the calendar.

## ADF export

`adf/arm/` contains the supplied export unchanged, including linked-template alternatives and the factory subtemplate. The root factory template and linked templates are alternative deployment forms, not separate additive deployments. `adf/pipelines/`, `datasets/`, `linkedServices/`, `triggers/` contain readable extracted definitions.

ARM secureString parameters do not supply secret values. The uploaded ADLS account-key parameter is blank. Supply it using a secure deployment channel. Databricks and SQL connections use MSI; the ADLS linked service in this export uses an account key. Do not claim all connections are identity-based.

The export includes environment-specific resource names/IDs, job ID and endpoints, but not complete provisioning for storage, Synapse, Databricks, Unity Catalog, monitoring, or RBAC. The trigger is exported as Started: review/stop it before deployment or modifying shared outputs. See `export_review.md` before publishing.

## Manifest and initial run

Lookup reads `list/list.json` in ADLS. Upload the current `config/list.json` there, retain the GitHub source paths, and configure `https://raw.githubusercontent.com/` as the HTTP base URL. In the supplied export the manifest has `relative_URL`, while the activity expression uses `relative_url`; standardise these to the same spelling when preparing deployment and verify the Lookup/Copy input. Do not change an unrelated dataset parameter just because its local parameter name uses lower case.

For an empty environment, first ingest and run Silver without the Gold activity; initialise SQL reporting objects; then enable the complete pipeline. Protect existing published data when staging deployment.

## Power BI

The PBIX connects to `synapseworkspacepaktech-ondemand.sql.azuresynapse.net`, database `paktech`, `dbo` objects. Change the server and configure credentials locally for a different environment. No credentials are supplied with this handover. Keep Power BI refresh paused during Gold publication. Refresh manually afterwards and save. The four generic page names are retained; renaming/visual polish is optional.
