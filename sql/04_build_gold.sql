-- Exported Main_Pipeline / Recover_Gold runtime. Build mode is enabled.
SET NOCOUNT ON;
SET LANGUAGE us_english;
IF DB_NAME() <> N'paktech'
BEGIN
    THROW 50000, 'Select the paktech database.', 1;
END;
DECLARE @validate_only bit = 0; -- 1 = validate only; 0 = validate, build, publish
DECLARE @run_id varchar(32) = REPLACE(CONVERT(varchar(36), NEWID()), '-', '');
DECLARE @phase nvarchar(30) = N'preflight';
DECLARE @target sysname;
DECLARE @new_table sysname;
DECLARE @columns nvarchar(max);
DECLARE @sql nvarchar(max);
DECLARE @view_sql nvarchar(max);
DECLARE @publish_sql nvarchar(max) = N'';
DECLARE @rows bigint;
DECLARE @bad bigint;
DECLARE @summary nvarchar(max) = N'';
DECLARE @message nvarchar(2048);
BEGIN TRY
    IF OBJECT_ID(N'dbo.[dim_branches]') IS NULL
    BEGIN
        THROW 50001, 'Missing existing reporting object dbo.dim_branches.', 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID(N'dbo.[dim_branches]'))
       AND NOT EXISTS (SELECT 1 FROM sys.external_tables WHERE object_id = OBJECT_ID(N'dbo.[dim_branches]'))
    BEGIN
        THROW 50002, 'Expected a view or external table: dbo.dim_branches.', 1;
    END;
    IF OBJECT_ID(N'dbo.[dim_customers]') IS NULL
    BEGIN
        THROW 50001, 'Missing existing reporting object dbo.dim_customers.', 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID(N'dbo.[dim_customers]'))
       AND NOT EXISTS (SELECT 1 FROM sys.external_tables WHERE object_id = OBJECT_ID(N'dbo.[dim_customers]'))
    BEGIN
        THROW 50002, 'Expected a view or external table: dbo.dim_customers.', 1;
    END;
    IF OBJECT_ID(N'dbo.[dim_dates]') IS NULL
    BEGIN
        THROW 50001, 'Missing existing reporting object dbo.dim_dates.', 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID(N'dbo.[dim_dates]'))
       AND NOT EXISTS (SELECT 1 FROM sys.external_tables WHERE object_id = OBJECT_ID(N'dbo.[dim_dates]'))
    BEGIN
        THROW 50002, 'Expected a view or external table: dbo.dim_dates.', 1;
    END;
    IF OBJECT_ID(N'dbo.[dim_employees]') IS NULL
    BEGIN
        THROW 50001, 'Missing existing reporting object dbo.dim_employees.', 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID(N'dbo.[dim_employees]'))
       AND NOT EXISTS (SELECT 1 FROM sys.external_tables WHERE object_id = OBJECT_ID(N'dbo.[dim_employees]'))
    BEGIN
        THROW 50002, 'Expected a view or external table: dbo.dim_employees.', 1;
    END;
    IF OBJECT_ID(N'dbo.[dim_installed_assets]') IS NULL
    BEGIN
        THROW 50001, 'Missing existing reporting object dbo.dim_installed_assets.', 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID(N'dbo.[dim_installed_assets]'))
       AND NOT EXISTS (SELECT 1 FROM sys.external_tables WHERE object_id = OBJECT_ID(N'dbo.[dim_installed_assets]'))
    BEGIN
        THROW 50002, 'Expected a view or external table: dbo.dim_installed_assets.', 1;
    END;
    IF OBJECT_ID(N'dbo.[dim_products]') IS NULL
    BEGIN
        THROW 50001, 'Missing existing reporting object dbo.dim_products.', 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID(N'dbo.[dim_products]'))
       AND NOT EXISTS (SELECT 1 FROM sys.external_tables WHERE object_id = OBJECT_ID(N'dbo.[dim_products]'))
    BEGIN
        THROW 50002, 'Expected a view or external table: dbo.dim_products.', 1;
    END;
    IF OBJECT_ID(N'dbo.[dim_suppliers]') IS NULL
    BEGIN
        THROW 50001, 'Missing existing reporting object dbo.dim_suppliers.', 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID(N'dbo.[dim_suppliers]'))
       AND NOT EXISTS (SELECT 1 FROM sys.external_tables WHERE object_id = OBJECT_ID(N'dbo.[dim_suppliers]'))
    BEGIN
        THROW 50002, 'Expected a view or external table: dbo.dim_suppliers.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_goods_receipts]') IS NULL
    BEGIN
        THROW 50001, 'Missing existing reporting object dbo.fact_goods_receipts.', 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID(N'dbo.[fact_goods_receipts]'))
       AND NOT EXISTS (SELECT 1 FROM sys.external_tables WHERE object_id = OBJECT_ID(N'dbo.[fact_goods_receipts]'))
    BEGIN
        THROW 50002, 'Expected a view or external table: dbo.fact_goods_receipts.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_import_shipments]') IS NULL
    BEGIN
        THROW 50001, 'Missing existing reporting object dbo.fact_import_shipments.', 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID(N'dbo.[fact_import_shipments]'))
       AND NOT EXISTS (SELECT 1 FROM sys.external_tables WHERE object_id = OBJECT_ID(N'dbo.[fact_import_shipments]'))
    BEGIN
        THROW 50002, 'Expected a view or external table: dbo.fact_import_shipments.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_installations]') IS NULL
    BEGIN
        THROW 50001, 'Missing existing reporting object dbo.fact_installations.', 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID(N'dbo.[fact_installations]'))
       AND NOT EXISTS (SELECT 1 FROM sys.external_tables WHERE object_id = OBJECT_ID(N'dbo.[fact_installations]'))
    BEGIN
        THROW 50002, 'Expected a view or external table: dbo.fact_installations.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_invoices]') IS NULL
    BEGIN
        THROW 50001, 'Missing existing reporting object dbo.fact_invoices.', 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID(N'dbo.[fact_invoices]'))
       AND NOT EXISTS (SELECT 1 FROM sys.external_tables WHERE object_id = OBJECT_ID(N'dbo.[fact_invoices]'))
    BEGIN
        THROW 50002, 'Expected a view or external table: dbo.fact_invoices.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_opportunities]') IS NULL
    BEGIN
        THROW 50001, 'Missing existing reporting object dbo.fact_opportunities.', 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID(N'dbo.[fact_opportunities]'))
       AND NOT EXISTS (SELECT 1 FROM sys.external_tables WHERE object_id = OBJECT_ID(N'dbo.[fact_opportunities]'))
    BEGIN
        THROW 50002, 'Expected a view or external table: dbo.fact_opportunities.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_payments]') IS NULL
    BEGIN
        THROW 50001, 'Missing existing reporting object dbo.fact_payments.', 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID(N'dbo.[fact_payments]'))
       AND NOT EXISTS (SELECT 1 FROM sys.external_tables WHERE object_id = OBJECT_ID(N'dbo.[fact_payments]'))
    BEGIN
        THROW 50002, 'Expected a view or external table: dbo.fact_payments.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_purchases]') IS NULL
    BEGIN
        THROW 50001, 'Missing existing reporting object dbo.fact_purchases.', 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID(N'dbo.[fact_purchases]'))
       AND NOT EXISTS (SELECT 1 FROM sys.external_tables WHERE object_id = OBJECT_ID(N'dbo.[fact_purchases]'))
    BEGIN
        THROW 50002, 'Expected a view or external table: dbo.fact_purchases.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_quotations]') IS NULL
    BEGIN
        THROW 50001, 'Missing existing reporting object dbo.fact_quotations.', 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID(N'dbo.[fact_quotations]'))
       AND NOT EXISTS (SELECT 1 FROM sys.external_tables WHERE object_id = OBJECT_ID(N'dbo.[fact_quotations]'))
    BEGIN
        THROW 50002, 'Expected a view or external table: dbo.fact_quotations.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_sales]') IS NULL
    BEGIN
        THROW 50001, 'Missing existing reporting object dbo.fact_sales.', 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID(N'dbo.[fact_sales]'))
       AND NOT EXISTS (SELECT 1 FROM sys.external_tables WHERE object_id = OBJECT_ID(N'dbo.[fact_sales]'))
    BEGIN
        THROW 50002, 'Expected a view or external table: dbo.fact_sales.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_service_tickets]') IS NULL
    BEGIN
        THROW 50001, 'Missing existing reporting object dbo.fact_service_tickets.', 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID(N'dbo.[fact_service_tickets]'))
       AND NOT EXISTS (SELECT 1 FROM sys.external_tables WHERE object_id = OBJECT_ID(N'dbo.[fact_service_tickets]'))
    BEGIN
        THROW 50002, 'Expected a view or external table: dbo.fact_service_tickets.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_training_attendance]') IS NULL
    BEGIN
        THROW 50001, 'Missing existing reporting object dbo.fact_training_attendance.', 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID(N'dbo.[fact_training_attendance]'))
       AND NOT EXISTS (SELECT 1 FROM sys.external_tables WHERE object_id = OBJECT_ID(N'dbo.[fact_training_attendance]'))
    BEGIN
        THROW 50002, 'Expected a view or external table: dbo.fact_training_attendance.', 1;
    END;
    IF OBJECT_ID(N'dbo.[fact_training_sessions]') IS NULL
    BEGIN
        THROW 50001, 'Missing existing reporting object dbo.fact_training_sessions.', 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID(N'dbo.[fact_training_sessions]'))
       AND NOT EXISTS (SELECT 1 FROM sys.external_tables WHERE object_id = OBJECT_ID(N'dbo.[fact_training_sessions]'))
    BEGIN
        THROW 50002, 'Expected a view or external table: dbo.fact_training_sessions.', 1;
    END;


    -- VALIDATE ALL QUERIES BEFORE ANY CETAS WRITES
    SET @phase = N'validation';

    SET @target = N'dim_branches';
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[dim_branches]');
    SET @sql = N'SELECT TOP (0) ' + @columns + N' FROM ('
        + N'SELECT * FROM gold.branches' + N') AS validation_source;';
    EXEC sp_executesql @sql;
    PRINT N'Validated ' + @target;

    SET @target = N'dim_customers';
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[dim_customers]');
    SET @sql = N'SELECT TOP (0) ' + @columns + N' FROM ('
        + N'SELECT * FROM gold.customers' + N') AS validation_source;';
    EXEC sp_executesql @sql;
    PRINT N'Validated ' + @target;

    SET @target = N'dim_dates';
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[dim_dates]');
    SET @sql = N'WITH digits AS (
SELECT n FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) AS d(n)
), calendar AS (
SELECT DATEADD(day, a.n + b.n * 10 + c.n * 100,
CAST(''2026-01-01'' AS date)) AS full_date
FROM digits AS a CROSS JOIN digits AS b CROSS JOIN digits AS c
), validation_source AS (
SELECT full_date, YEAR(full_date) AS calendar_year,
MONTH(full_date) AS month_number, DATENAME(month, full_date) AS month_name,
DAY(full_date) AS day_of_month
FROM calendar WHERE full_date <= ''2027-12-31''
)
' + N'SELECT TOP (0) ' + @columns + N' FROM validation_source;';
    EXEC sp_executesql @sql;
    PRINT N'Validated ' + @target;

    SET @target = N'dim_employees';
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[dim_employees]');
    SET @sql = N'SELECT TOP (0) ' + @columns + N' FROM ('
        + N'SELECT * FROM gold.employees' + N') AS validation_source;';
    EXEC sp_executesql @sql;
    PRINT N'Validated ' + @target;

    SET @target = N'dim_installed_assets';
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[dim_installed_assets]');
    SET @sql = N'SELECT TOP (0) ' + @columns + N' FROM ('
        + N'SELECT * FROM gold.installed_assets' + N') AS validation_source;';
    EXEC sp_executesql @sql;
    PRINT N'Validated ' + @target;

    SET @target = N'dim_products';
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[dim_products]');
    SET @sql = N'SELECT TOP (0) ' + @columns + N' FROM ('
        + N'SELECT * FROM gold.products' + N') AS validation_source;';
    EXEC sp_executesql @sql;
    PRINT N'Validated ' + @target;

    SET @target = N'dim_suppliers';
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[dim_suppliers]');
    SET @sql = N'SELECT TOP (0) ' + @columns + N' FROM ('
        + N'SELECT * FROM gold.suppliers' + N') AS validation_source;';
    EXEC sp_executesql @sql;
    PRINT N'Validated ' + @target;

    SET @target = N'fact_goods_receipts';
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_goods_receipts]');
    SET @sql = N'SELECT TOP (0) ' + @columns + N' FROM ('
        + N'SELECT * FROM gold.goods_receipts' + N') AS validation_source;';
    EXEC sp_executesql @sql;
    PRINT N'Validated ' + @target;

    SET @target = N'fact_import_shipments';
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_import_shipments]');
    SET @sql = N'SELECT TOP (0) ' + @columns + N' FROM ('
        + N'SELECT * FROM gold.import_shipments' + N') AS validation_source;';
    EXEC sp_executesql @sql;
    PRINT N'Validated ' + @target;

    SET @target = N'fact_installations';
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_installations]');
    SET @sql = N'SELECT TOP (0) ' + @columns + N' FROM ('
        + N'SELECT * FROM gold.installations' + N') AS validation_source;';
    EXEC sp_executesql @sql;
    PRINT N'Validated ' + @target;

    SET @target = N'fact_invoices';
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_invoices]');
    SET @sql = N'SELECT TOP (0) ' + @columns + N' FROM ('
        + N'SELECT invoice_id, order_id, invoice_date, due_date,
net_amount_pkr, tax_amount_pkr, gross_amount_pkr,
_source_row_id, _source_system,
CAST(NULL AS varchar(8000)) AS tax_basis,
CAST(NULL AS datetime2(7)) AS updated_at,
CAST(NULL AS varchar(8000)) AS is_synthetic,
CAST(NULL AS datetime2(7)) AS _extract_at
FROM gold.invoices' + N') AS validation_source;';
    EXEC sp_executesql @sql;
    PRINT N'Validated ' + @target;

    SET @target = N'fact_opportunities';
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_opportunities]');
    SET @sql = N'SELECT TOP (0) ' + @columns + N' FROM ('
        + N'SELECT * FROM gold.opportunities' + N') AS validation_source;';
    EXEC sp_executesql @sql;
    PRINT N'Validated ' + @target;

    SET @target = N'fact_payments';
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_payments]');
    SET @sql = N'SELECT TOP (0) ' + @columns + N' FROM ('
        + N'SELECT * FROM gold.payments' + N') AS validation_source;';
    EXEC sp_executesql @sql;
    PRINT N'Validated ' + @target;

    SET @target = N'fact_purchases';
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_purchases]');
    SET @sql = N'SELECT TOP (0) ' + @columns + N' FROM ('
        + N'SELECT pol.purchase_line_id, pol.purchase_order_id, pol.order_line_id,
pol.product_id, pol.quantity, pol.unit_landed_cost_pkr, po.supplier_id,
po.order_date, po.expected_receipt_date, po.status, po.currency
FROM gold.purchase_order_lines AS pol
LEFT JOIN gold.purchase_orders AS po ON pol.purchase_order_id = po.purchase_order_id' + N') AS validation_source;';
    EXEC sp_executesql @sql;
    PRINT N'Validated ' + @target;

    SET @target = N'fact_quotations';
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_quotations]');
    SET @sql = N'SELECT TOP (0) ' + @columns + N' FROM ('
        + N'SELECT * FROM gold.quotations' + N') AS validation_source;';
    EXEC sp_executesql @sql;
    PRINT N'Validated ' + @target;

    SET @target = N'fact_sales';
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_sales]');
    SET @sql = N'SELECT TOP (0) ' + @columns + N' FROM ('
        + N'SELECT sol.order_line_id, sol.order_id, sol.product_id, sol.quantity,
sol.unit_price_pkr, sol.[discount_rate_%] AS discount_rate, sol.line_net_pkr,
so.opportunity_id, so.customer_id, so.branch_id, so.order_date,
so.promised_delivery_date, so.status, so.currency
FROM gold.sales_order_lines AS sol
LEFT JOIN gold.sales_orders AS so ON sol.order_id = so.order_id' + N') AS validation_source;';
    EXEC sp_executesql @sql;
    PRINT N'Validated ' + @target;

    SET @target = N'fact_service_tickets';
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_service_tickets]');
    SET @sql = N'SELECT TOP (0) ' + @columns + N' FROM ('
        + N'SELECT * FROM gold.service_tickets' + N') AS validation_source;';
    EXEC sp_executesql @sql;
    PRINT N'Validated ' + @target;

    SET @target = N'fact_training_attendance';
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_training_attendance]');
    SET @sql = N'SELECT TOP (0) ' + @columns + N' FROM ('
        + N'SELECT * FROM gold.training_attendance' + N') AS validation_source;';
    EXEC sp_executesql @sql;
    PRINT N'Validated ' + @target;

    SET @target = N'fact_training_sessions';
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_training_sessions]');
    SET @sql = N'SELECT TOP (0) ' + @columns + N' FROM ('
        + N'SELECT * FROM gold.training_sessions' + N') AS validation_source;';
    EXEC sp_executesql @sql;
    PRINT N'Validated ' + @target;

    IF @validate_only = 1
    BEGIN
        SELECT N'Validation succeeded' AS status,
               19 AS validated_objects,
               N'No Gold tables, files, or reporting views were changed.' AS details;
        RETURN;
    END;

    SET @phase = N'build';

    -- BUILD dim_branches
    SET @target = N'dim_branches';
    SET @new_table = @target + N'_run_' + @run_id;
    SET @columns = NULL;
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[dim_branches]');
    IF @columns IS NULL
    BEGIN
        THROW 50003, 'Cannot read reporting columns for dbo.dim_branches.', 1;
    END;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@new_table)
        + N' WITH (LOCATION = ' + QUOTENAME(@target + N'/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.branches' + N';';
    EXEC sp_executesql @sql;

    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N') AS checked_snapshot;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @rows OUTPUT;
    SET @summary = @summary + @target + N'=' + CONVERT(nvarchar(30), @rows) + N'; ';
    PRINT N'Built ' + @new_table;

    -- Save publication commands; do NOT execute them until all 19 builds pass.
    SET @view_sql = CASE WHEN OBJECT_ID(N'dbo.[dim_branches]', N'V') IS NOT NULL
        THEN N'ALTER VIEW ' ELSE N'CREATE VIEW ' END
        + N'dbo.[dim_branches] AS SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N';';
    SET @publish_sql = @publish_sql + N'
IF EXISTS (SELECT 1 FROM sys.external_tables
           WHERE object_id = OBJECT_ID(N''dbo.[dim_branches]''))
BEGIN
    EXEC sp_executesql N''DROP EXTERNAL TABLE dbo.[dim_branches];'';
END;
EXEC sp_executesql N''' + REPLACE(@view_sql, '''', '''''') + N''';
';

    -- BUILD dim_customers
    SET @target = N'dim_customers';
    SET @new_table = @target + N'_run_' + @run_id;
    SET @columns = NULL;
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[dim_customers]');
    IF @columns IS NULL
    BEGIN
        THROW 50003, 'Cannot read reporting columns for dbo.dim_customers.', 1;
    END;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@new_table)
        + N' WITH (LOCATION = ' + QUOTENAME(@target + N'/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.customers' + N';';
    EXEC sp_executesql @sql;

    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N') AS checked_snapshot;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @rows OUTPUT;
    SET @summary = @summary + @target + N'=' + CONVERT(nvarchar(30), @rows) + N'; ';
    PRINT N'Built ' + @new_table;

    -- Save publication commands; do NOT execute them until all 19 builds pass.
    SET @view_sql = CASE WHEN OBJECT_ID(N'dbo.[dim_customers]', N'V') IS NOT NULL
        THEN N'ALTER VIEW ' ELSE N'CREATE VIEW ' END
        + N'dbo.[dim_customers] AS SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N';';
    SET @publish_sql = @publish_sql + N'
IF EXISTS (SELECT 1 FROM sys.external_tables
           WHERE object_id = OBJECT_ID(N''dbo.[dim_customers]''))
BEGIN
    EXEC sp_executesql N''DROP EXTERNAL TABLE dbo.[dim_customers];'';
END;
EXEC sp_executesql N''' + REPLACE(@view_sql, '''', '''''') + N''';
';

    -- BUILD dim_dates
    SET @target = N'dim_dates';
    SET @new_table = @target + N'_run_' + @run_id;
    SET @columns = NULL;
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[dim_dates]');
    IF @columns IS NULL
    BEGIN
        THROW 50003, 'Cannot read reporting columns for dbo.dim_dates.', 1;
    END;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@new_table)
        + N' WITH (LOCATION = ' + QUOTENAME(@target + N'/run_' + @run_id + N'/', '''')
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

    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N') AS checked_snapshot;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @rows OUTPUT;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (
        SELECT [full_date] FROM dbo.' + QUOTENAME(@new_table)
        + N' GROUP BY [full_date] HAVING COUNT_BIG(*) > 1 OR [full_date] IS NULL) AS bad_keys;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @bad OUTPUT;
    IF @bad > 0
    BEGIN
        THROW 50004, 'Duplicate or null full_date in new dim_dates.', 1;
    END;
    IF @rows <> 730
    BEGIN
        THROW 50005, 'Expected 730 dates for 2026-2027.', 1;
    END;
    SET @summary = @summary + @target + N'=' + CONVERT(nvarchar(30), @rows) + N'; ';
    PRINT N'Built ' + @new_table;

    -- Save publication commands; do NOT execute them until all 19 builds pass.
    SET @view_sql = CASE WHEN OBJECT_ID(N'dbo.[dim_dates]', N'V') IS NOT NULL
        THEN N'ALTER VIEW ' ELSE N'CREATE VIEW ' END
        + N'dbo.[dim_dates] AS SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N';';
    SET @publish_sql = @publish_sql + N'
IF EXISTS (SELECT 1 FROM sys.external_tables
           WHERE object_id = OBJECT_ID(N''dbo.[dim_dates]''))
BEGIN
    EXEC sp_executesql N''DROP EXTERNAL TABLE dbo.[dim_dates];'';
END;
EXEC sp_executesql N''' + REPLACE(@view_sql, '''', '''''') + N''';
';

    -- BUILD dim_employees
    SET @target = N'dim_employees';
    SET @new_table = @target + N'_run_' + @run_id;
    SET @columns = NULL;
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[dim_employees]');
    IF @columns IS NULL
    BEGIN
        THROW 50003, 'Cannot read reporting columns for dbo.dim_employees.', 1;
    END;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@new_table)
        + N' WITH (LOCATION = ' + QUOTENAME(@target + N'/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.employees' + N';';
    EXEC sp_executesql @sql;

    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N') AS checked_snapshot;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @rows OUTPUT;
    SET @summary = @summary + @target + N'=' + CONVERT(nvarchar(30), @rows) + N'; ';
    PRINT N'Built ' + @new_table;

    -- Save publication commands; do NOT execute them until all 19 builds pass.
    SET @view_sql = CASE WHEN OBJECT_ID(N'dbo.[dim_employees]', N'V') IS NOT NULL
        THEN N'ALTER VIEW ' ELSE N'CREATE VIEW ' END
        + N'dbo.[dim_employees] AS SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N';';
    SET @publish_sql = @publish_sql + N'
IF EXISTS (SELECT 1 FROM sys.external_tables
           WHERE object_id = OBJECT_ID(N''dbo.[dim_employees]''))
BEGIN
    EXEC sp_executesql N''DROP EXTERNAL TABLE dbo.[dim_employees];'';
END;
EXEC sp_executesql N''' + REPLACE(@view_sql, '''', '''''') + N''';
';

    -- BUILD dim_installed_assets
    SET @target = N'dim_installed_assets';
    SET @new_table = @target + N'_run_' + @run_id;
    SET @columns = NULL;
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[dim_installed_assets]');
    IF @columns IS NULL
    BEGIN
        THROW 50003, 'Cannot read reporting columns for dbo.dim_installed_assets.', 1;
    END;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@new_table)
        + N' WITH (LOCATION = ' + QUOTENAME(@target + N'/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.installed_assets' + N';';
    EXEC sp_executesql @sql;

    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N') AS checked_snapshot;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @rows OUTPUT;
    SET @summary = @summary + @target + N'=' + CONVERT(nvarchar(30), @rows) + N'; ';
    PRINT N'Built ' + @new_table;

    -- Save publication commands; do NOT execute them until all 19 builds pass.
    SET @view_sql = CASE WHEN OBJECT_ID(N'dbo.[dim_installed_assets]', N'V') IS NOT NULL
        THEN N'ALTER VIEW ' ELSE N'CREATE VIEW ' END
        + N'dbo.[dim_installed_assets] AS SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N';';
    SET @publish_sql = @publish_sql + N'
IF EXISTS (SELECT 1 FROM sys.external_tables
           WHERE object_id = OBJECT_ID(N''dbo.[dim_installed_assets]''))
BEGIN
    EXEC sp_executesql N''DROP EXTERNAL TABLE dbo.[dim_installed_assets];'';
END;
EXEC sp_executesql N''' + REPLACE(@view_sql, '''', '''''') + N''';
';

    -- BUILD dim_products
    SET @target = N'dim_products';
    SET @new_table = @target + N'_run_' + @run_id;
    SET @columns = NULL;
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[dim_products]');
    IF @columns IS NULL
    BEGIN
        THROW 50003, 'Cannot read reporting columns for dbo.dim_products.', 1;
    END;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@new_table)
        + N' WITH (LOCATION = ' + QUOTENAME(@target + N'/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.products' + N';';
    EXEC sp_executesql @sql;

    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N') AS checked_snapshot;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @rows OUTPUT;
    SET @summary = @summary + @target + N'=' + CONVERT(nvarchar(30), @rows) + N'; ';
    PRINT N'Built ' + @new_table;

    -- Save publication commands; do NOT execute them until all 19 builds pass.
    SET @view_sql = CASE WHEN OBJECT_ID(N'dbo.[dim_products]', N'V') IS NOT NULL
        THEN N'ALTER VIEW ' ELSE N'CREATE VIEW ' END
        + N'dbo.[dim_products] AS SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N';';
    SET @publish_sql = @publish_sql + N'
IF EXISTS (SELECT 1 FROM sys.external_tables
           WHERE object_id = OBJECT_ID(N''dbo.[dim_products]''))
BEGIN
    EXEC sp_executesql N''DROP EXTERNAL TABLE dbo.[dim_products];'';
END;
EXEC sp_executesql N''' + REPLACE(@view_sql, '''', '''''') + N''';
';

    -- BUILD dim_suppliers
    SET @target = N'dim_suppliers';
    SET @new_table = @target + N'_run_' + @run_id;
    SET @columns = NULL;
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[dim_suppliers]');
    IF @columns IS NULL
    BEGIN
        THROW 50003, 'Cannot read reporting columns for dbo.dim_suppliers.', 1;
    END;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@new_table)
        + N' WITH (LOCATION = ' + QUOTENAME(@target + N'/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.suppliers' + N';';
    EXEC sp_executesql @sql;

    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N') AS checked_snapshot;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @rows OUTPUT;
    SET @summary = @summary + @target + N'=' + CONVERT(nvarchar(30), @rows) + N'; ';
    PRINT N'Built ' + @new_table;

    -- Save publication commands; do NOT execute them until all 19 builds pass.
    SET @view_sql = CASE WHEN OBJECT_ID(N'dbo.[dim_suppliers]', N'V') IS NOT NULL
        THEN N'ALTER VIEW ' ELSE N'CREATE VIEW ' END
        + N'dbo.[dim_suppliers] AS SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N';';
    SET @publish_sql = @publish_sql + N'
IF EXISTS (SELECT 1 FROM sys.external_tables
           WHERE object_id = OBJECT_ID(N''dbo.[dim_suppliers]''))
BEGIN
    EXEC sp_executesql N''DROP EXTERNAL TABLE dbo.[dim_suppliers];'';
END;
EXEC sp_executesql N''' + REPLACE(@view_sql, '''', '''''') + N''';
';

    -- BUILD fact_goods_receipts
    SET @target = N'fact_goods_receipts';
    SET @new_table = @target + N'_run_' + @run_id;
    SET @columns = NULL;
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_goods_receipts]');
    IF @columns IS NULL
    BEGIN
        THROW 50003, 'Cannot read reporting columns for dbo.fact_goods_receipts.', 1;
    END;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@new_table)
        + N' WITH (LOCATION = ' + QUOTENAME(@target + N'/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.goods_receipts' + N';';
    EXEC sp_executesql @sql;

    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N') AS checked_snapshot;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @rows OUTPUT;
    SET @summary = @summary + @target + N'=' + CONVERT(nvarchar(30), @rows) + N'; ';
    PRINT N'Built ' + @new_table;

    -- Save publication commands; do NOT execute them until all 19 builds pass.
    SET @view_sql = CASE WHEN OBJECT_ID(N'dbo.[fact_goods_receipts]', N'V') IS NOT NULL
        THEN N'ALTER VIEW ' ELSE N'CREATE VIEW ' END
        + N'dbo.[fact_goods_receipts] AS SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N';';
    SET @publish_sql = @publish_sql + N'
IF EXISTS (SELECT 1 FROM sys.external_tables
           WHERE object_id = OBJECT_ID(N''dbo.[fact_goods_receipts]''))
BEGIN
    EXEC sp_executesql N''DROP EXTERNAL TABLE dbo.[fact_goods_receipts];'';
END;
EXEC sp_executesql N''' + REPLACE(@view_sql, '''', '''''') + N''';
';

    -- BUILD fact_import_shipments
    SET @target = N'fact_import_shipments';
    SET @new_table = @target + N'_run_' + @run_id;
    SET @columns = NULL;
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_import_shipments]');
    IF @columns IS NULL
    BEGIN
        THROW 50003, 'Cannot read reporting columns for dbo.fact_import_shipments.', 1;
    END;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@new_table)
        + N' WITH (LOCATION = ' + QUOTENAME(@target + N'/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.import_shipments' + N';';
    EXEC sp_executesql @sql;

    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N') AS checked_snapshot;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @rows OUTPUT;
    SET @summary = @summary + @target + N'=' + CONVERT(nvarchar(30), @rows) + N'; ';
    PRINT N'Built ' + @new_table;

    -- Save publication commands; do NOT execute them until all 19 builds pass.
    SET @view_sql = CASE WHEN OBJECT_ID(N'dbo.[fact_import_shipments]', N'V') IS NOT NULL
        THEN N'ALTER VIEW ' ELSE N'CREATE VIEW ' END
        + N'dbo.[fact_import_shipments] AS SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N';';
    SET @publish_sql = @publish_sql + N'
IF EXISTS (SELECT 1 FROM sys.external_tables
           WHERE object_id = OBJECT_ID(N''dbo.[fact_import_shipments]''))
BEGIN
    EXEC sp_executesql N''DROP EXTERNAL TABLE dbo.[fact_import_shipments];'';
END;
EXEC sp_executesql N''' + REPLACE(@view_sql, '''', '''''') + N''';
';

    -- BUILD fact_installations
    SET @target = N'fact_installations';
    SET @new_table = @target + N'_run_' + @run_id;
    SET @columns = NULL;
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_installations]');
    IF @columns IS NULL
    BEGIN
        THROW 50003, 'Cannot read reporting columns for dbo.fact_installations.', 1;
    END;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@new_table)
        + N' WITH (LOCATION = ' + QUOTENAME(@target + N'/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.installations' + N';';
    EXEC sp_executesql @sql;

    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N') AS checked_snapshot;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @rows OUTPUT;
    SET @summary = @summary + @target + N'=' + CONVERT(nvarchar(30), @rows) + N'; ';
    PRINT N'Built ' + @new_table;

    -- Save publication commands; do NOT execute them until all 19 builds pass.
    SET @view_sql = CASE WHEN OBJECT_ID(N'dbo.[fact_installations]', N'V') IS NOT NULL
        THEN N'ALTER VIEW ' ELSE N'CREATE VIEW ' END
        + N'dbo.[fact_installations] AS SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N';';
    SET @publish_sql = @publish_sql + N'
IF EXISTS (SELECT 1 FROM sys.external_tables
           WHERE object_id = OBJECT_ID(N''dbo.[fact_installations]''))
BEGIN
    EXEC sp_executesql N''DROP EXTERNAL TABLE dbo.[fact_installations];'';
END;
EXEC sp_executesql N''' + REPLACE(@view_sql, '''', '''''') + N''';
';

    -- BUILD fact_invoices
    SET @target = N'fact_invoices';
    SET @new_table = @target + N'_run_' + @run_id;
    SET @columns = NULL;
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_invoices]');
    IF @columns IS NULL
    BEGIN
        THROW 50003, 'Cannot read reporting columns for dbo.fact_invoices.', 1;
    END;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@new_table)
        + N' WITH (LOCATION = ' + QUOTENAME(@target + N'/run_' + @run_id + N'/', '''')
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

    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N') AS checked_snapshot;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @rows OUTPUT;
    SET @summary = @summary + @target + N'=' + CONVERT(nvarchar(30), @rows) + N'; ';
    PRINT N'Built ' + @new_table;

    -- Save publication commands; do NOT execute them until all 19 builds pass.
    SET @view_sql = CASE WHEN OBJECT_ID(N'dbo.[fact_invoices]', N'V') IS NOT NULL
        THEN N'ALTER VIEW ' ELSE N'CREATE VIEW ' END
        + N'dbo.[fact_invoices] AS SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N';';
    SET @publish_sql = @publish_sql + N'
IF EXISTS (SELECT 1 FROM sys.external_tables
           WHERE object_id = OBJECT_ID(N''dbo.[fact_invoices]''))
BEGIN
    EXEC sp_executesql N''DROP EXTERNAL TABLE dbo.[fact_invoices];'';
END;
EXEC sp_executesql N''' + REPLACE(@view_sql, '''', '''''') + N''';
';

    -- BUILD fact_opportunities
    SET @target = N'fact_opportunities';
    SET @new_table = @target + N'_run_' + @run_id;
    SET @columns = NULL;
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_opportunities]');
    IF @columns IS NULL
    BEGIN
        THROW 50003, 'Cannot read reporting columns for dbo.fact_opportunities.', 1;
    END;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@new_table)
        + N' WITH (LOCATION = ' + QUOTENAME(@target + N'/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.opportunities' + N';';
    EXEC sp_executesql @sql;

    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N') AS checked_snapshot;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @rows OUTPUT;
    SET @summary = @summary + @target + N'=' + CONVERT(nvarchar(30), @rows) + N'; ';
    PRINT N'Built ' + @new_table;

    -- Save publication commands; do NOT execute them until all 19 builds pass.
    SET @view_sql = CASE WHEN OBJECT_ID(N'dbo.[fact_opportunities]', N'V') IS NOT NULL
        THEN N'ALTER VIEW ' ELSE N'CREATE VIEW ' END
        + N'dbo.[fact_opportunities] AS SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N';';
    SET @publish_sql = @publish_sql + N'
IF EXISTS (SELECT 1 FROM sys.external_tables
           WHERE object_id = OBJECT_ID(N''dbo.[fact_opportunities]''))
BEGIN
    EXEC sp_executesql N''DROP EXTERNAL TABLE dbo.[fact_opportunities];'';
END;
EXEC sp_executesql N''' + REPLACE(@view_sql, '''', '''''') + N''';
';

    -- BUILD fact_payments
    SET @target = N'fact_payments';
    SET @new_table = @target + N'_run_' + @run_id;
    SET @columns = NULL;
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_payments]');
    IF @columns IS NULL
    BEGIN
        THROW 50003, 'Cannot read reporting columns for dbo.fact_payments.', 1;
    END;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@new_table)
        + N' WITH (LOCATION = ' + QUOTENAME(@target + N'/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.payments' + N';';
    EXEC sp_executesql @sql;

    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N') AS checked_snapshot;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @rows OUTPUT;
    SET @summary = @summary + @target + N'=' + CONVERT(nvarchar(30), @rows) + N'; ';
    PRINT N'Built ' + @new_table;

    -- Save publication commands; do NOT execute them until all 19 builds pass.
    SET @view_sql = CASE WHEN OBJECT_ID(N'dbo.[fact_payments]', N'V') IS NOT NULL
        THEN N'ALTER VIEW ' ELSE N'CREATE VIEW ' END
        + N'dbo.[fact_payments] AS SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N';';
    SET @publish_sql = @publish_sql + N'
IF EXISTS (SELECT 1 FROM sys.external_tables
           WHERE object_id = OBJECT_ID(N''dbo.[fact_payments]''))
BEGIN
    EXEC sp_executesql N''DROP EXTERNAL TABLE dbo.[fact_payments];'';
END;
EXEC sp_executesql N''' + REPLACE(@view_sql, '''', '''''') + N''';
';

    -- BUILD fact_purchases
    SET @target = N'fact_purchases';
    SET @new_table = @target + N'_run_' + @run_id;
    SET @columns = NULL;
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_purchases]');
    IF @columns IS NULL
    BEGIN
        THROW 50003, 'Cannot read reporting columns for dbo.fact_purchases.', 1;
    END;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@new_table)
        + N' WITH (LOCATION = ' + QUOTENAME(@target + N'/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT pol.purchase_line_id, pol.purchase_order_id, pol.order_line_id,
pol.product_id, pol.quantity, pol.unit_landed_cost_pkr, po.supplier_id,
po.order_date, po.expected_receipt_date, po.status, po.currency
FROM gold.purchase_order_lines AS pol
LEFT JOIN gold.purchase_orders AS po ON pol.purchase_order_id = po.purchase_order_id' + N';';
    EXEC sp_executesql @sql;

    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N') AS checked_snapshot;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @rows OUTPUT;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (
        SELECT [purchase_line_id] FROM dbo.' + QUOTENAME(@new_table)
        + N' GROUP BY [purchase_line_id] HAVING COUNT_BIG(*) > 1 OR [purchase_line_id] IS NULL) AS bad_keys;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @bad OUTPUT;
    IF @bad > 0
    BEGIN
        THROW 50004, 'Duplicate or null purchase_line_id in new fact_purchases.', 1;
    END;
    SET @summary = @summary + @target + N'=' + CONVERT(nvarchar(30), @rows) + N'; ';
    PRINT N'Built ' + @new_table;

    -- Save publication commands; do NOT execute them until all 19 builds pass.
    SET @view_sql = CASE WHEN OBJECT_ID(N'dbo.[fact_purchases]', N'V') IS NOT NULL
        THEN N'ALTER VIEW ' ELSE N'CREATE VIEW ' END
        + N'dbo.[fact_purchases] AS SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N';';
    SET @publish_sql = @publish_sql + N'
IF EXISTS (SELECT 1 FROM sys.external_tables
           WHERE object_id = OBJECT_ID(N''dbo.[fact_purchases]''))
BEGIN
    EXEC sp_executesql N''DROP EXTERNAL TABLE dbo.[fact_purchases];'';
END;
EXEC sp_executesql N''' + REPLACE(@view_sql, '''', '''''') + N''';
';

    -- BUILD fact_quotations
    SET @target = N'fact_quotations';
    SET @new_table = @target + N'_run_' + @run_id;
    SET @columns = NULL;
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_quotations]');
    IF @columns IS NULL
    BEGIN
        THROW 50003, 'Cannot read reporting columns for dbo.fact_quotations.', 1;
    END;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@new_table)
        + N' WITH (LOCATION = ' + QUOTENAME(@target + N'/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.quotations' + N';';
    EXEC sp_executesql @sql;

    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N') AS checked_snapshot;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @rows OUTPUT;
    SET @summary = @summary + @target + N'=' + CONVERT(nvarchar(30), @rows) + N'; ';
    PRINT N'Built ' + @new_table;

    -- Save publication commands; do NOT execute them until all 19 builds pass.
    SET @view_sql = CASE WHEN OBJECT_ID(N'dbo.[fact_quotations]', N'V') IS NOT NULL
        THEN N'ALTER VIEW ' ELSE N'CREATE VIEW ' END
        + N'dbo.[fact_quotations] AS SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N';';
    SET @publish_sql = @publish_sql + N'
IF EXISTS (SELECT 1 FROM sys.external_tables
           WHERE object_id = OBJECT_ID(N''dbo.[fact_quotations]''))
BEGIN
    EXEC sp_executesql N''DROP EXTERNAL TABLE dbo.[fact_quotations];'';
END;
EXEC sp_executesql N''' + REPLACE(@view_sql, '''', '''''') + N''';
';

    -- BUILD fact_sales
    SET @target = N'fact_sales';
    SET @new_table = @target + N'_run_' + @run_id;
    SET @columns = NULL;
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_sales]');
    IF @columns IS NULL
    BEGIN
        THROW 50003, 'Cannot read reporting columns for dbo.fact_sales.', 1;
    END;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@new_table)
        + N' WITH (LOCATION = ' + QUOTENAME(@target + N'/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT sol.order_line_id, sol.order_id, sol.product_id, sol.quantity,
sol.unit_price_pkr, sol.[discount_rate_%] AS discount_rate, sol.line_net_pkr,
so.opportunity_id, so.customer_id, so.branch_id, so.order_date,
so.promised_delivery_date, so.status, so.currency
FROM gold.sales_order_lines AS sol
LEFT JOIN gold.sales_orders AS so ON sol.order_id = so.order_id' + N';';
    EXEC sp_executesql @sql;

    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N') AS checked_snapshot;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @rows OUTPUT;
    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (
        SELECT [order_line_id] FROM dbo.' + QUOTENAME(@new_table)
        + N' GROUP BY [order_line_id] HAVING COUNT_BIG(*) > 1 OR [order_line_id] IS NULL) AS bad_keys;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @bad OUTPUT;
    IF @bad > 0
    BEGIN
        THROW 50004, 'Duplicate or null order_line_id in new fact_sales.', 1;
    END;
    SET @summary = @summary + @target + N'=' + CONVERT(nvarchar(30), @rows) + N'; ';
    PRINT N'Built ' + @new_table;

    -- Save publication commands; do NOT execute them until all 19 builds pass.
    SET @view_sql = CASE WHEN OBJECT_ID(N'dbo.[fact_sales]', N'V') IS NOT NULL
        THEN N'ALTER VIEW ' ELSE N'CREATE VIEW ' END
        + N'dbo.[fact_sales] AS SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N';';
    SET @publish_sql = @publish_sql + N'
IF EXISTS (SELECT 1 FROM sys.external_tables
           WHERE object_id = OBJECT_ID(N''dbo.[fact_sales]''))
BEGIN
    EXEC sp_executesql N''DROP EXTERNAL TABLE dbo.[fact_sales];'';
END;
EXEC sp_executesql N''' + REPLACE(@view_sql, '''', '''''') + N''';
';

    -- BUILD fact_service_tickets
    SET @target = N'fact_service_tickets';
    SET @new_table = @target + N'_run_' + @run_id;
    SET @columns = NULL;
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_service_tickets]');
    IF @columns IS NULL
    BEGIN
        THROW 50003, 'Cannot read reporting columns for dbo.fact_service_tickets.', 1;
    END;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@new_table)
        + N' WITH (LOCATION = ' + QUOTENAME(@target + N'/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.service_tickets' + N';';
    EXEC sp_executesql @sql;

    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N') AS checked_snapshot;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @rows OUTPUT;
    SET @summary = @summary + @target + N'=' + CONVERT(nvarchar(30), @rows) + N'; ';
    PRINT N'Built ' + @new_table;

    -- Save publication commands; do NOT execute them until all 19 builds pass.
    SET @view_sql = CASE WHEN OBJECT_ID(N'dbo.[fact_service_tickets]', N'V') IS NOT NULL
        THEN N'ALTER VIEW ' ELSE N'CREATE VIEW ' END
        + N'dbo.[fact_service_tickets] AS SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N';';
    SET @publish_sql = @publish_sql + N'
IF EXISTS (SELECT 1 FROM sys.external_tables
           WHERE object_id = OBJECT_ID(N''dbo.[fact_service_tickets]''))
BEGIN
    EXEC sp_executesql N''DROP EXTERNAL TABLE dbo.[fact_service_tickets];'';
END;
EXEC sp_executesql N''' + REPLACE(@view_sql, '''', '''''') + N''';
';

    -- BUILD fact_training_attendance
    SET @target = N'fact_training_attendance';
    SET @new_table = @target + N'_run_' + @run_id;
    SET @columns = NULL;
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_training_attendance]');
    IF @columns IS NULL
    BEGIN
        THROW 50003, 'Cannot read reporting columns for dbo.fact_training_attendance.', 1;
    END;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@new_table)
        + N' WITH (LOCATION = ' + QUOTENAME(@target + N'/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.training_attendance' + N';';
    EXEC sp_executesql @sql;

    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N') AS checked_snapshot;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @rows OUTPUT;
    SET @summary = @summary + @target + N'=' + CONVERT(nvarchar(30), @rows) + N'; ';
    PRINT N'Built ' + @new_table;

    -- Save publication commands; do NOT execute them until all 19 builds pass.
    SET @view_sql = CASE WHEN OBJECT_ID(N'dbo.[fact_training_attendance]', N'V') IS NOT NULL
        THEN N'ALTER VIEW ' ELSE N'CREATE VIEW ' END
        + N'dbo.[fact_training_attendance] AS SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N';';
    SET @publish_sql = @publish_sql + N'
IF EXISTS (SELECT 1 FROM sys.external_tables
           WHERE object_id = OBJECT_ID(N''dbo.[fact_training_attendance]''))
BEGIN
    EXEC sp_executesql N''DROP EXTERNAL TABLE dbo.[fact_training_attendance];'';
END;
EXEC sp_executesql N''' + REPLACE(@view_sql, '''', '''''') + N''';
';

    -- BUILD fact_training_sessions
    SET @target = N'fact_training_sessions';
    SET @new_table = @target + N'_run_' + @run_id;
    SET @columns = NULL;
    SELECT @columns = STRING_AGG(CAST(QUOTENAME(name) AS nvarchar(max)), N', ')
        WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[fact_training_sessions]');
    IF @columns IS NULL
    BEGIN
        THROW 50003, 'Cannot read reporting columns for dbo.fact_training_sessions.', 1;
    END;
    SET @sql = N'CREATE EXTERNAL TABLE dbo.' + QUOTENAME(@new_table)
        + N' WITH (LOCATION = ' + QUOTENAME(@target + N'/run_' + @run_id + N'/', '''')
        + N', DATA_SOURCE = source_gold, FILE_FORMAT = format_parquet) AS '
        + N'SELECT * FROM gold.training_sessions' + N';';
    EXEC sp_executesql @sql;

    SET @sql = N'SELECT @n = COUNT_BIG(*) FROM (SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N') AS checked_snapshot;';
    EXEC sp_executesql @sql, N'@n bigint OUTPUT', @n = @rows OUTPUT;
    SET @summary = @summary + @target + N'=' + CONVERT(nvarchar(30), @rows) + N'; ';
    PRINT N'Built ' + @new_table;

    -- Save publication commands; do NOT execute them until all 19 builds pass.
    SET @view_sql = CASE WHEN OBJECT_ID(N'dbo.[fact_training_sessions]', N'V') IS NOT NULL
        THEN N'ALTER VIEW ' ELSE N'CREATE VIEW ' END
        + N'dbo.[fact_training_sessions] AS SELECT ' + @columns
        + N' FROM dbo.' + QUOTENAME(@new_table) + N';';
    SET @publish_sql = @publish_sql + N'
IF EXISTS (SELECT 1 FROM sys.external_tables
           WHERE object_id = OBJECT_ID(N''dbo.[fact_training_sessions]''))
BEGIN
    EXEC sp_executesql N''DROP EXTERNAL TABLE dbo.[fact_training_sessions];'';
END;
EXEC sp_executesql N''' + REPLACE(@view_sql, '''', '''''') + N''';
';

    -- PUBLISH: reached only after all 19 snapshots pass the checks.
    -- Each view is created/altered in its own nested SQL batch.
    SET @phase = N'publish';
    SET @target = N'(reporting views)';
    EXEC sp_executesql @publish_sql;
    SELECT @run_id AS gold_run_id, N'Succeeded' AS status,
           19 AS published_objects, @summary AS row_counts;
END TRY
BEGIN CATCH
    SET @message = N'Gold run ' + @run_id + N' failed during ' + @phase
        + N' for ' + COALESCE(@target, N'(preflight)') + N'. ' + ERROR_MESSAGE();
    PRINT @message;
    THROW;
END CATCH;
