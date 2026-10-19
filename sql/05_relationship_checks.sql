-- Read-only checks on published Gold. Missing/null keys count as unmatched.
SELECT 'Sales without customer' AS check_name, COUNT_BIG(*) AS unmatched_rows
FROM dbo.fact_sales f WHERE NOT EXISTS (SELECT 1 FROM dbo.dim_customers d WHERE d.customer_id = f.customer_id)
UNION ALL
SELECT 'Sales without product', COUNT_BIG(*) FROM dbo.fact_sales f
WHERE NOT EXISTS (SELECT 1 FROM dbo.dim_products d WHERE d.product_id = f.product_id)
UNION ALL
SELECT 'Sales without branch', COUNT_BIG(*) FROM dbo.fact_sales f
WHERE NOT EXISTS (SELECT 1 FROM dbo.dim_branches d WHERE d.branch_id = f.branch_id)
UNION ALL
SELECT 'Purchases without supplier', COUNT_BIG(*) FROM dbo.fact_purchases f
WHERE NOT EXISTS (SELECT 1 FROM dbo.dim_suppliers d WHERE d.supplier_id = f.supplier_id);

-- Read-only grain checks on Silver joins: no rows expected.
SELECT pol.purchase_line_id, COUNT_BIG(*) AS row_count
FROM gold.purchase_order_lines pol LEFT JOIN gold.purchase_orders po
ON pol.purchase_order_id = po.purchase_order_id
GROUP BY pol.purchase_line_id
HAVING COUNT_BIG(*) > 1 OR pol.purchase_line_id IS NULL;
SELECT sol.order_line_id, COUNT_BIG(*) AS row_count
FROM gold.sales_order_lines sol LEFT JOIN gold.sales_orders so ON sol.order_id = so.order_id
GROUP BY sol.order_line_id
HAVING COUNT_BIG(*) > 1 OR sol.order_line_id IS NULL;
