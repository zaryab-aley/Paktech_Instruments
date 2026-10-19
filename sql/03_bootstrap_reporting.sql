-- INITIAL INSTALL ONLY. This helper was added during handover and statically checked;
-- it has not been executed in the original Azure workspace. Do NOT run it on that
-- existing workspace. Use 04_build_gold.sql for normal refresh/recovery.
-- Prerequisites: completed Silver files, 01 and 02; no dbo reporting objects exist.
-- All versions build before initial reporting views are created. No file deletion.
SET NOCOUNT ON;
SET LANGUAGE us_english;
IF DB_NAME() <> N'paktech'
BEGIN
    THROW 50000, 'Use the paktech database.', 1;
END;
DECLARE @run_id varchar(32) = REPLACE(CONVERT(varchar(36), NEWID()), '-', '');
DECLARE @table sysname;
DECLARE @sql nvarchar(max);
DECLARE @publish nvarchar(max) = N'';
DECLARE @view nvarchar(max);
DECLARE @n bigint;
BEGIN TRY
    IF OBJECT_ID(N'dbo.[dim_branches]') IS NOT NULL
    BEGIN
        THROW 50001, 'Existing reporting objects: use the refresh script instead.', 1;
    END;
    IF OBJECT_ID(N'dbo.[dim_customers]') IS NOT NULL
    BEGIN
        THROW 50001, 'Existing reporting objects: use the refresh script instead.', 1;
    END;
    IF OBJECT_ID(N'dbo.[dim_dates]') IS NOT NULL
    BEGIN
        THROW 50001, 'Existing reporting objects: use the refresh script instead.', 1;
    END;
    IF OBJECT_ID(N'dbo.[dim_employees]') IS NOT NULL
    BEGIN
        THROW 50001, 'Existing reporting objects: use the refresh script instead.', 1;
    END;
    IF OBJECT_ID(N'dbo.[dim_installed_assets]') IS NOT NULL
    BEGIN
        THROW 50001, 'Existing reporting objects: use the refresh script instead.', 1;
    END;
    IF OBJECT_ID(N'dbo.[dim_products]') IS NOT NULL
    BEGIN
        THROW 50001, 'Existing reporting objects: use the refresh script instead.', 1;
    END;
    IF OBJECT_ID(N'dbo.[dim_suppliers]') IS NOT NULL
    BEGIN
        THROW 50001, 'Existing reporting objects: use the refresh script instead.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_goods_receipts]') IS NOT NULL
    BEGIN
        THROW 50001, 'Existing reporting objects: use the refresh script instead.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_import_shipments]') IS NOT NULL
    BEGIN
        THROW 50001, 'Existing reporting objects: use the refresh script instead.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_installations]') IS NOT NULL
    BEGIN
        THROW 50001, 'Existing reporting objects: use the refresh script instead.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_invoices]') IS NOT NULL
    BEGIN
        THROW 50001, 'Existing reporting objects: use the refresh script instead.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_opportunities]') IS NOT NULL
    BEGIN
        THROW 50001, 'Existing reporting objects: use the refresh script instead.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_payments]') IS NOT NULL
    BEGIN
        THROW 50001, 'Existing reporting objects: use the refresh script instead.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_purchases]') IS NOT NULL
    BEGIN
        THROW 50001, 'Existing reporting objects: use the refresh script instead.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_quotations]') IS NOT NULL
    BEGIN
        THROW 50001, 'Existing reporting objects: use the refresh script instead.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_sales]') IS NOT NULL
    BEGIN
        THROW 50001, 'Existing reporting objects: use the refresh script instead.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_service_tickets]') IS NOT NULL
    BEGIN
        THROW 50001, 'Existing reporting objects: use the refresh script instead.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_training_attendance]') IS NOT NULL
    BEGIN
        THROW 50001, 'Existing reporting objects: use the refresh script instead.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_training_sessions]') IS NOT NULL
    BEGIN
        THROW 50001, 'Existing reporting objects: use the refresh script instead.', 1;
    END;

    SET @table = N'dim_branches_run_' + @run_id;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@table)
        + N' WITH (LOCATION = ' + QUOTENAME(N'dim_branches/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.branches' + N';';
    EXEC sp_executesql @sql;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM dbo.' + QUOTENAME(@table) + N';';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @n OUTPUT;
    SET @view = N'CREATE VIEW dbo.[dim_branches] AS SELECT * FROM dbo.' + QUOTENAME(@table) + N';';
    SET @publish = @publish + N'EXEC sp_executesql N''' + REPLACE(@view, '''', '''''') + N''';' + CHAR(10);

    SET @table = N'dim_customers_run_' + @run_id;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@table)
        + N' WITH (LOCATION = ' + QUOTENAME(N'dim_customers/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.customers' + N';';
    EXEC sp_executesql @sql;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM dbo.' + QUOTENAME(@table) + N';';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @n OUTPUT;
    SET @view = N'CREATE VIEW dbo.[dim_customers] AS SELECT * FROM dbo.' + QUOTENAME(@table) + N';';
    SET @publish = @publish + N'EXEC sp_executesql N''' + REPLACE(@view, '''', '''''') + N''';' + CHAR(10);

    SET @table = N'dim_dates_run_' + @run_id;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@table)
        + N' WITH (LOCATION = ' + QUOTENAME(N'dim_dates/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'WITH digits AS (
SELECT n FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) AS d(n)
), calendar AS (
SELECT DATEADD(day, a.n + b.n * 10 + c.n * 100,
CAST(''2026-01-01'' AS date)) AS full_date
FROM digits AS a CROSS JOIN digits AS b CROSS JOIN digits AS c
)
SELECT full_date, YEAR(full_date) AS calendar_year,
MONTH(full_date) AS month_number, DATENAME(month, full_date) AS month_name,
DAY(full_date) AS day_of_month
FROM calendar WHERE full_date <= ''2027-12-31''' + N';';
    EXEC sp_executesql @sql;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM dbo.' + QUOTENAME(@table) + N';';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @n OUTPUT;
    SET @view = N'CREATE VIEW dbo.[dim_dates] AS SELECT * FROM dbo.' + QUOTENAME(@table) + N';';
    SET @publish = @publish + N'EXEC sp_executesql N''' + REPLACE(@view, '''', '''''') + N''';' + CHAR(10);

    SET @table = N'dim_employees_run_' + @run_id;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@table)
        + N' WITH (LOCATION = ' + QUOTENAME(N'dim_employees/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.employees' + N';';
    EXEC sp_executesql @sql;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM dbo.' + QUOTENAME(@table) + N';';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @n OUTPUT;
    SET @view = N'CREATE VIEW dbo.[dim_employees] AS SELECT * FROM dbo.' + QUOTENAME(@table) + N';';
    SET @publish = @publish + N'EXEC sp_executesql N''' + REPLACE(@view, '''', '''''') + N''';' + CHAR(10);

    SET @table = N'dim_installed_assets_run_' + @run_id;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@table)
        + N' WITH (LOCATION = ' + QUOTENAME(N'dim_installed_assets/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.installed_assets' + N';';
    EXEC sp_executesql @sql;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM dbo.' + QUOTENAME(@table) + N';';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @n OUTPUT;
    SET @view = N'CREATE VIEW dbo.[dim_installed_assets] AS SELECT * FROM dbo.' + QUOTENAME(@table) + N';';
    SET @publish = @publish + N'EXEC sp_executesql N''' + REPLACE(@view, '''', '''''') + N''';' + CHAR(10);

    SET @table = N'dim_products_run_' + @run_id;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@table)
        + N' WITH (LOCATION = ' + QUOTENAME(N'dim_products/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.products' + N';';
    EXEC sp_executesql @sql;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM dbo.' + QUOTENAME(@table) + N';';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @n OUTPUT;
    SET @view = N'CREATE VIEW dbo.[dim_products] AS SELECT * FROM dbo.' + QUOTENAME(@table) + N';';
    SET @publish = @publish + N'EXEC sp_executesql N''' + REPLACE(@view, '''', '''''') + N''';' + CHAR(10);

    SET @table = N'dim_suppliers_run_' + @run_id;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@table)
        + N' WITH (LOCATION = ' + QUOTENAME(N'dim_suppliers/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.suppliers' + N';';
    EXEC sp_executesql @sql;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM dbo.' + QUOTENAME(@table) + N';';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @n OUTPUT;
    SET @view = N'CREATE VIEW dbo.[dim_suppliers] AS SELECT * FROM dbo.' + QUOTENAME(@table) + N';';
    SET @publish = @publish + N'EXEC sp_executesql N''' + REPLACE(@view, '''', '''''') + N''';' + CHAR(10);

    SET @table = N'fact_goods_receipts_run_' + @run_id;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@table)
        + N' WITH (LOCATION = ' + QUOTENAME(N'fact_goods_receipts/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.goods_receipts' + N';';
    EXEC sp_executesql @sql;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM dbo.' + QUOTENAME(@table) + N';';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @n OUTPUT;
    SET @view = N'CREATE VIEW dbo.[fact_goods_receipts] AS SELECT * FROM dbo.' + QUOTENAME(@table) + N';';
    SET @publish = @publish + N'EXEC sp_executesql N''' + REPLACE(@view, '''', '''''') + N''';' + CHAR(10);

    SET @table = N'fact_import_shipments_run_' + @run_id;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@table)
        + N' WITH (LOCATION = ' + QUOTENAME(N'fact_import_shipments/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.import_shipments' + N';';
    EXEC sp_executesql @sql;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM dbo.' + QUOTENAME(@table) + N';';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @n OUTPUT;
    SET @view = N'CREATE VIEW dbo.[fact_import_shipments] AS SELECT * FROM dbo.' + QUOTENAME(@table) + N';';
    SET @publish = @publish + N'EXEC sp_executesql N''' + REPLACE(@view, '''', '''''') + N''';' + CHAR(10);

    SET @table = N'fact_installations_run_' + @run_id;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@table)
        + N' WITH (LOCATION = ' + QUOTENAME(N'fact_installations/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.installations' + N';';
    EXEC sp_executesql @sql;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM dbo.' + QUOTENAME(@table) + N';';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @n OUTPUT;
    SET @view = N'CREATE VIEW dbo.[fact_installations] AS SELECT * FROM dbo.' + QUOTENAME(@table) + N';';
    SET @publish = @publish + N'EXEC sp_executesql N''' + REPLACE(@view, '''', '''''') + N''';' + CHAR(10);

    SET @table = N'fact_invoices_run_' + @run_id;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@table)
        + N' WITH (LOCATION = ' + QUOTENAME(N'fact_invoices/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT invoice_id, order_id, invoice_date, due_date,
net_amount_pkr, tax_amount_pkr, gross_amount_pkr,
_source_row_id, _source_system,
CAST(NULL AS varchar(8000)) AS tax_basis,
CAST(NULL AS datetime2(7)) AS updated_at,
CAST(NULL AS varchar(8000)) AS is_synthetic,
CAST(NULL AS datetime2(7)) AS _extract_at
FROM gold.invoices' + N';';
    EXEC sp_executesql @sql;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM dbo.' + QUOTENAME(@table) + N';';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @n OUTPUT;
    SET @view = N'CREATE VIEW dbo.[fact_invoices] AS SELECT * FROM dbo.' + QUOTENAME(@table) + N';';
    SET @publish = @publish + N'EXEC sp_executesql N''' + REPLACE(@view, '''', '''''') + N''';' + CHAR(10);

    SET @table = N'fact_opportunities_run_' + @run_id;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@table)
        + N' WITH (LOCATION = ' + QUOTENAME(N'fact_opportunities/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.opportunities' + N';';
    EXEC sp_executesql @sql;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM dbo.' + QUOTENAME(@table) + N';';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @n OUTPUT;
    SET @view = N'CREATE VIEW dbo.[fact_opportunities] AS SELECT * FROM dbo.' + QUOTENAME(@table) + N';';
    SET @publish = @publish + N'EXEC sp_executesql N''' + REPLACE(@view, '''', '''''') + N''';' + CHAR(10);

    SET @table = N'fact_payments_run_' + @run_id;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@table)
        + N' WITH (LOCATION = ' + QUOTENAME(N'fact_payments/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.payments' + N';';
    EXEC sp_executesql @sql;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM dbo.' + QUOTENAME(@table) + N';';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @n OUTPUT;
    SET @view = N'CREATE VIEW dbo.[fact_payments] AS SELECT * FROM dbo.' + QUOTENAME(@table) + N';';
    SET @publish = @publish + N'EXEC sp_executesql N''' + REPLACE(@view, '''', '''''') + N''';' + CHAR(10);

    SET @table = N'fact_purchases_run_' + @run_id;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@table)
        + N' WITH (LOCATION = ' + QUOTENAME(N'fact_purchases/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT pol.purchase_line_id, pol.purchase_order_id, pol.order_line_id,
pol.product_id, pol.quantity, pol.unit_landed_cost_pkr, po.supplier_id,
po.order_date, po.expected_receipt_date, po.status, po.currency
FROM gold.purchase_order_lines AS pol
LEFT JOIN gold.purchase_orders AS po ON pol.purchase_order_id = po.purchase_order_id' + N';';
    EXEC sp_executesql @sql;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM dbo.' + QUOTENAME(@table) + N';';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @n OUTPUT;
    SET @view = N'CREATE VIEW dbo.[fact_purchases] AS SELECT * FROM dbo.' + QUOTENAME(@table) + N';';
    SET @publish = @publish + N'EXEC sp_executesql N''' + REPLACE(@view, '''', '''''') + N''';' + CHAR(10);

    SET @table = N'fact_quotations_run_' + @run_id;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@table)
        + N' WITH (LOCATION = ' + QUOTENAME(N'fact_quotations/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.quotations' + N';';
    EXEC sp_executesql @sql;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM dbo.' + QUOTENAME(@table) + N';';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @n OUTPUT;
    SET @view = N'CREATE VIEW dbo.[fact_quotations] AS SELECT * FROM dbo.' + QUOTENAME(@table) + N';';
    SET @publish = @publish + N'EXEC sp_executesql N''' + REPLACE(@view, '''', '''''') + N''';' + CHAR(10);

    SET @table = N'fact_sales_run_' + @run_id;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@table)
        + N' WITH (LOCATION = ' + QUOTENAME(N'fact_sales/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT sol.order_line_id, sol.order_id, sol.product_id, sol.quantity,
sol.unit_price_pkr, sol.[discount_rate_%] AS discount_rate, sol.line_net_pkr,
so.opportunity_id, so.customer_id, so.branch_id, so.order_date,
so.promised_delivery_date, so.status, so.currency
FROM gold.sales_order_lines AS sol
LEFT JOIN gold.sales_orders AS so ON sol.order_id = so.order_id' + N';';
    EXEC sp_executesql @sql;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM dbo.' + QUOTENAME(@table) + N';';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @n OUTPUT;
    SET @view = N'CREATE VIEW dbo.[fact_sales] AS SELECT * FROM dbo.' + QUOTENAME(@table) + N';';
    SET @publish = @publish + N'EXEC sp_executesql N''' + REPLACE(@view, '''', '''''') + N''';' + CHAR(10);

    SET @table = N'fact_service_tickets_run_' + @run_id;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@table)
        + N' WITH (LOCATION = ' + QUOTENAME(N'fact_service_tickets/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.service_tickets' + N';';
    EXEC sp_executesql @sql;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM dbo.' + QUOTENAME(@table) + N';';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @n OUTPUT;
    SET @view = N'CREATE VIEW dbo.[fact_service_tickets] AS SELECT * FROM dbo.' + QUOTENAME(@table) + N';';
    SET @publish = @publish + N'EXEC sp_executesql N''' + REPLACE(@view, '''', '''''') + N''';' + CHAR(10);

    SET @table = N'fact_training_attendance_run_' + @run_id;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@table)
        + N' WITH (LOCATION = ' + QUOTENAME(N'fact_training_attendance/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.training_attendance' + N';';
    EXEC sp_executesql @sql;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM dbo.' + QUOTENAME(@table) + N';';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @n OUTPUT;
    SET @view = N'CREATE VIEW dbo.[fact_training_attendance] AS SELECT * FROM dbo.' + QUOTENAME(@table) + N';';
    SET @publish = @publish + N'EXEC sp_executesql N''' + REPLACE(@view, '''', '''''') + N''';' + CHAR(10);

    SET @table = N'fact_training_sessions_run_' + @run_id;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@table)
        + N' WITH (LOCATION = ' + QUOTENAME(N'fact_training_sessions/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.training_sessions' + N';';
    EXEC sp_executesql @sql;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM dbo.' + QUOTENAME(@table) + N';';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @n OUTPUT;
    SET @view = N'CREATE VIEW dbo.[fact_training_sessions] AS SELECT * FROM dbo.' + QUOTENAME(@table) + N';';
    SET @publish = @publish + N'EXEC sp_executesql N''' + REPLACE(@view, '''', '''''') + N''';' + CHAR(10);

    EXEC sp_executesql @publish;
    SELECT @run_id AS bootstrap_run_id, 19 AS reporting_views_created;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
