# Gold model and reporting relationships

The warehouse has 7 dimensions and 12 facts. Sales and purchases join header context onto line-level records. Standalone events retain their source grains. No direct many-fact mega-join is performed to calculate invoice/payment totals.

| Reporting object | Source / grain |
|---|---|
| `dim_branches` | Standalone source projection |
| `dim_customers` | Standalone source projection |
| `dim_dates` | Daily calendar, 2026–2027 |
| `dim_employees` | Standalone source projection |
| `dim_installed_assets` | Standalone source projection |
| `dim_products` | Standalone source projection |
| `dim_suppliers` | Standalone source projection |
| `fact_goods_receipts` | Standalone source projection |
| `fact_import_shipments` | Standalone source projection |
| `fact_installations` | Standalone source projection |
| `fact_invoices` | Standalone source projection |
| `fact_opportunities` | Standalone source projection |
| `fact_payments` | Standalone source projection |
| `fact_purchases` | Purchase order line plus purchase header |
| `fact_quotations` | Standalone source projection |
| `fact_sales` | Sales order line plus order header |
| `fact_service_tickets` | Standalone source projection |
| `fact_training_attendance` | Flattened attendee occurrence (not distinct person) |
| `fact_training_sessions` | Standalone source projection |

These are the actual active relationships extracted from the PBIX. All are M:1 and single-direction. A relationship involving two fact-named objects is an explicit reporting choice in this model, not a general instruction to join all facts together.

| Many side | One side |
|---|---|
| `fact_sales.branch_id` | `dim_branches.branch_id` |
| `fact_sales.customer_id` | `dim_customers.customer_id` |
| `fact_sales.product_id` | `dim_products.product_id` |
| `fact_sales.order_date` | `dim_dates.full_date` |
| `fact_payments.invoice_id` | `fact_invoices.invoice_id` |
| `fact_invoices.OrderCustomers.customer_id` | `dim_customers.customer_id` |
| `fact_purchases.supplier_id` | `dim_suppliers.supplier_id` |
| `fact_goods_receipts.purchase_line_id` | `fact_purchases.purchase_line_id` |
| `fact_training_sessions.session_date` | `dim_dates.full_date` |
| `fact_training_attendance.training_id` | `fact_training_sessions.training_id` |

The Power Query OrderCustomers helper derives order/customer pairs from sales and merges customer_id into invoices. Invoice/payment and purchase/receipt relationships support the related DAX measures. Attendance counts occurrences; missing feedback remains blank in averages. Date relationships shown above do not imply all fact dates are connected to the calendar. Several imported dimensions/facts are currently standalone in the report.

Invoice compatibility columns absent from current Silver are CAST(NULL AS varchar(8000)) for tax_basis/is_synthetic, and CAST(NULL AS datetime2(7)) for updated_at/_extract_at. These are schema compatibility fields, not a restored audit history. The calendar generator covers 1,000 potential offsets and filters to 730 actual days; extend generator capacity and update the row assertion together for longer ranges.
