WITH total_revenue_cte AS (
    SELECT hellofresh_week, SUM(item_revenue) AS total_revenue
    FROM materialized_views.us_cpi_market
    WHERE country = 'US' 
      AND addon_code IS NOT NULL
    GROUP BY hellofresh_week
),
total_add_ons_cte AS (
    SELECT hellofresh_week, COUNT(addon_code) AS total_number_add_ons
    FROM materialized_views.us_cpi_market
    WHERE country = 'US'
      AND website_category != 'Free Add-Ons'
    GROUP BY hellofresh_week
),
total_recipes_cte AS (
    SELECT hellofresh_week, SUM(items_ordered) AS total_recipes
    FROM materialized_views.us_cpi_market
    WHERE country = 'US'
      AND addon_code IS NOT NULL
      AND website_category <> 'Free Add-Ons'
    GROUP BY hellofresh_week
),
weekly_orders_cte AS (
    SELECT hellofresh_week, MAX(weekly_order_count) AS weekly_order_count
    FROM materialized_views.us_cpi_seamless
    WHERE country = 'US'
    GROUP BY hellofresh_week
)
SELECT 
    tr.hellofresh_week,
    tr.total_revenue,
    ta.total_number_add_ons,
    (tr.total_revenue / wo.weekly_order_count) AS average_order_value,
    (trr.total_recipes / wo.weekly_order_count) * 100 AS take_rate_percentage
FROM 
    total_revenue_cte tr
JOIN 
    total_add_ons_cte ta ON tr.hellofresh_week = ta.hellofresh_week
JOIN 
    total_recipes_cte trr ON tr.hellofresh_week = trr.hellofresh_week
JOIN 
    weekly_orders_cte wo ON tr.hellofresh_week = wo.hellofresh_week
ORDER BY 
    tr.hellofresh_week DESC;