-- Run as administrator after Silver exists. Each view DDL uses its own SQL batch.

IF OBJECT_ID(N'gold.[branches]', N'V') IS NULL
    EXEC sp_executesql N'CREATE VIEW gold.[branches] AS SELECT * FROM OPENROWSET(BULK ''branches/branches.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
ELSE
    EXEC sp_executesql N'ALTER VIEW gold.[branches] AS SELECT * FROM OPENROWSET(BULK ''branches/branches.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';

IF OBJECT_ID(N'gold.[customers]', N'V') IS NULL
    EXEC sp_executesql N'CREATE VIEW gold.[customers] AS SELECT * FROM OPENROWSET(BULK ''customers/customers.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
ELSE
    EXEC sp_executesql N'ALTER VIEW gold.[customers] AS SELECT * FROM OPENROWSET(BULK ''customers/customers.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';

IF OBJECT_ID(N'gold.[employees]', N'V') IS NULL
    EXEC sp_executesql N'CREATE VIEW gold.[employees] AS SELECT * FROM OPENROWSET(BULK ''employees/employees.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
ELSE
    EXEC sp_executesql N'ALTER VIEW gold.[employees] AS SELECT * FROM OPENROWSET(BULK ''employees/employees.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';

IF OBJECT_ID(N'gold.[fx_rates]', N'V') IS NULL
    EXEC sp_executesql N'CREATE VIEW gold.[fx_rates] AS SELECT * FROM OPENROWSET(BULK ''fx_rates/fx_rates.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
ELSE
    EXEC sp_executesql N'ALTER VIEW gold.[fx_rates] AS SELECT * FROM OPENROWSET(BULK ''fx_rates/fx_rates.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';

IF OBJECT_ID(N'gold.[goods_receipts]', N'V') IS NULL
    EXEC sp_executesql N'CREATE VIEW gold.[goods_receipts] AS SELECT * FROM OPENROWSET(BULK ''goods_receipts/goods_receipts.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
ELSE
    EXEC sp_executesql N'ALTER VIEW gold.[goods_receipts] AS SELECT * FROM OPENROWSET(BULK ''goods_receipts/goods_receipts.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';

IF OBJECT_ID(N'gold.[import_shipments]', N'V') IS NULL
    EXEC sp_executesql N'CREATE VIEW gold.[import_shipments] AS SELECT * FROM OPENROWSET(BULK ''import_shipments/import_shipments.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
ELSE
    EXEC sp_executesql N'ALTER VIEW gold.[import_shipments] AS SELECT * FROM OPENROWSET(BULK ''import_shipments/import_shipments.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';

IF OBJECT_ID(N'gold.[installations]', N'V') IS NULL
    EXEC sp_executesql N'CREATE VIEW gold.[installations] AS SELECT * FROM OPENROWSET(BULK ''installations/installations.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
ELSE
    EXEC sp_executesql N'ALTER VIEW gold.[installations] AS SELECT * FROM OPENROWSET(BULK ''installations/installations.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';

IF OBJECT_ID(N'gold.[installed_assets]', N'V') IS NULL
    EXEC sp_executesql N'CREATE VIEW gold.[installed_assets] AS SELECT * FROM OPENROWSET(BULK ''installed_assets/installed_assets.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
ELSE
    EXEC sp_executesql N'ALTER VIEW gold.[installed_assets] AS SELECT * FROM OPENROWSET(BULK ''installed_assets/installed_assets.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';

IF OBJECT_ID(N'gold.[invoices]', N'V') IS NULL
    EXEC sp_executesql N'CREATE VIEW gold.[invoices] AS SELECT * FROM OPENROWSET(BULK ''invoices/invoices.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
ELSE
    EXEC sp_executesql N'ALTER VIEW gold.[invoices] AS SELECT * FROM OPENROWSET(BULK ''invoices/invoices.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';

IF OBJECT_ID(N'gold.[opportunities]', N'V') IS NULL
    EXEC sp_executesql N'CREATE VIEW gold.[opportunities] AS SELECT * FROM OPENROWSET(BULK ''opportunities/opportunities.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
ELSE
    EXEC sp_executesql N'ALTER VIEW gold.[opportunities] AS SELECT * FROM OPENROWSET(BULK ''opportunities/opportunities.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';

IF OBJECT_ID(N'gold.[payments]', N'V') IS NULL
    EXEC sp_executesql N'CREATE VIEW gold.[payments] AS SELECT * FROM OPENROWSET(BULK ''payments/payments.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
ELSE
    EXEC sp_executesql N'ALTER VIEW gold.[payments] AS SELECT * FROM OPENROWSET(BULK ''payments/payments.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';

IF OBJECT_ID(N'gold.[purchase_order_lines]', N'V') IS NULL
    EXEC sp_executesql N'CREATE VIEW gold.[purchase_order_lines] AS SELECT * FROM OPENROWSET(BULK ''purchase_order_lines/purchase_order_lines.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
ELSE
    EXEC sp_executesql N'ALTER VIEW gold.[purchase_order_lines] AS SELECT * FROM OPENROWSET(BULK ''purchase_order_lines/purchase_order_lines.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';

IF OBJECT_ID(N'gold.[purchase_orders]', N'V') IS NULL
    EXEC sp_executesql N'CREATE VIEW gold.[purchase_orders] AS SELECT * FROM OPENROWSET(BULK ''purchase_orders/purchase_orders.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
ELSE
    EXEC sp_executesql N'ALTER VIEW gold.[purchase_orders] AS SELECT * FROM OPENROWSET(BULK ''purchase_orders/purchase_orders.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';

IF OBJECT_ID(N'gold.[quotations]', N'V') IS NULL
    EXEC sp_executesql N'CREATE VIEW gold.[quotations] AS SELECT * FROM OPENROWSET(BULK ''quotations/quotations.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
ELSE
    EXEC sp_executesql N'ALTER VIEW gold.[quotations] AS SELECT * FROM OPENROWSET(BULK ''quotations/quotations.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';

IF OBJECT_ID(N'gold.[sales_order_lines]', N'V') IS NULL
    EXEC sp_executesql N'CREATE VIEW gold.[sales_order_lines] AS SELECT * FROM OPENROWSET(BULK ''sales_order_lines/sales_order_lines.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
ELSE
    EXEC sp_executesql N'ALTER VIEW gold.[sales_order_lines] AS SELECT * FROM OPENROWSET(BULK ''sales_order_lines/sales_order_lines.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';

IF OBJECT_ID(N'gold.[sales_orders]', N'V') IS NULL
    EXEC sp_executesql N'CREATE VIEW gold.[sales_orders] AS SELECT * FROM OPENROWSET(BULK ''sales_orders/sales_orders.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
ELSE
    EXEC sp_executesql N'ALTER VIEW gold.[sales_orders] AS SELECT * FROM OPENROWSET(BULK ''sales_orders/sales_orders.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';

IF OBJECT_ID(N'gold.[service_tickets]', N'V') IS NULL
    EXEC sp_executesql N'CREATE VIEW gold.[service_tickets] AS SELECT * FROM OPENROWSET(BULK ''service_tickets/service_tickets.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
ELSE
    EXEC sp_executesql N'ALTER VIEW gold.[service_tickets] AS SELECT * FROM OPENROWSET(BULK ''service_tickets/service_tickets.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';

IF OBJECT_ID(N'gold.[suppliers]', N'V') IS NULL
    EXEC sp_executesql N'CREATE VIEW gold.[suppliers] AS SELECT * FROM OPENROWSET(BULK ''suppliers/suppliers.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
ELSE
    EXEC sp_executesql N'ALTER VIEW gold.[suppliers] AS SELECT * FROM OPENROWSET(BULK ''suppliers/suppliers.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';

IF OBJECT_ID(N'gold.[training_sessions]', N'V') IS NULL
    EXEC sp_executesql N'CREATE VIEW gold.[training_sessions] AS SELECT * FROM OPENROWSET(BULK ''training_sessions/training_sessions.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
ELSE
    EXEC sp_executesql N'ALTER VIEW gold.[training_sessions] AS SELECT * FROM OPENROWSET(BULK ''training_sessions/training_sessions.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';

IF OBJECT_ID(N'gold.[products]', N'V') IS NULL
    EXEC sp_executesql N'CREATE VIEW gold.[products] AS SELECT * FROM OPENROWSET(BULK ''products/products.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
ELSE
    EXEC sp_executesql N'ALTER VIEW gold.[products] AS SELECT * FROM OPENROWSET(BULK ''products/products.csv/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';

IF OBJECT_ID(N'gold.[training_attendance]', N'V') IS NULL
    EXEC sp_executesql N'CREATE VIEW gold.[training_attendance] AS SELECT * FROM OPENROWSET(BULK ''training_attendance/training_attendance.jsonl/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
ELSE
    EXEC sp_executesql N'ALTER VIEW gold.[training_attendance] AS SELECT * FROM OPENROWSET(BULK ''training_attendance/training_attendance.jsonl/*.parquet'', DATA_SOURCE = ''source_silver'', FORMAT = ''PARQUET'') AS q;';
