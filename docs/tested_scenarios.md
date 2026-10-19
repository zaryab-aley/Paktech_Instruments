# Tested scenarios

These cloud exercises were completed and reported in the original project session. They were not re-executed in a new subscription during packaging.

| Exercise | Observed result |
|---|---|
| Standalone Databricks serverless job | Silver notebook succeeded |
| Main full-load pipeline | Bronze → Silver → all Gold processing succeeded |
| Gold projection validation | All 19 projections validated |
| Gold-only reprocessing | Recover_Gold succeeded using existing Silver |
| Added same-schema customer source | Five new IDs reached Gold; PBIX now contains 65 customers |
| Invalid source URL | HTTP 404 observed in isolated test; corrected URL copied to test_missing_source |
| Synthetic purchase extract duplicates | Marked duplicate rows removed before Silver write; line-grain check returned no rows |
| Training flattening | Attendee fields available as columns; absent feedback remained NULL |
| Failure monitoring | Intentional Fail pipeline failed; metric/alert subsequently appeared |
| Fix-and-rerun test | Fail activity replaced by one-second Wait; new run succeeded |
| Diagnostic logging | Pipeline and activity log entries queried in Log Analytics |
| Schedule | A scheduled execution was reported successful |
| Sales rollback/restoration | Prior candidate and current version each had 215 unique sales lines and equal net value; view switched and restored |
| Failed-run retention procedure | 14 unreferenced definitions and matching failed-run folders removed; current sales totals preserved |

Published relationship counts were zero for sales without customer/product/branch and purchases without supplier. This covers four checks, not every foreign-key relationship.

Snapshot verified from the supplied PBIX: sales 215 rows, purchase facts 215 rows, customers 65 rows; all five newly added customer IDs present; net sales/order value PKR 1,587,666,826. The PBIX has 20 DAX measures and 10 active, single-direction M:1 relationships. Power Query retains some deduplication and date-conversion steps; the report is not a claim that all cleanup has moved to Silver.

No screenshots have been fabricated. Add original screenshots of the full successful run, logs, alert, recovery, schedule and four report pages under docs/images if desired. No full-model atomic rollback, incremental load, automatic retention, or Power BI Service refresh has been tested or claimed.
