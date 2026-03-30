/* ==============================================================================
  Revenue Analysis
Calculate monthly revenue trend.
Show MoM (Month-over-Month) growth percentage.
============================================================================== */
---- Monthly Revenue and  growth percentage
WITH monthly_revenue AS (  --creating common table expresion that live inside our query
    SELECT 
        datetrunc(order_date) AS month,
        SUM(total_amount) AS total_sales
    FROM orders
    GROUP BY datetrunc(order_date)
)

SELECT *,
       ROUND(
            (total_sales - LAG(total_sales) OVER (ORDER BY month)) 
            / LAG(total_sales) OVER (ORDER BY month) * 100
       ,2) AS mom_growth_percentage--calculate percentage growth
FROM monthly_revenue;

/* ==============================================================================
   Product Performance
Find Top 3 products per category by revenue.
Find products selling below their cost (loss-making).
============================================================================== */


--Find Top 3 products per category by revenue.
select*
from(
    select
      product_id,
      category,
      revenue,
      rank() over(partition by category order by revenue desc)rank
    from(
      select
        p.product_id,
        p.category,
        SUM(o.quantity*o.price_per_unit) as revenue
      from products p
      left join order_items o
      on p.product_id=o.product_id
      group by p.product_id,p.category)t)t
where rank<=3 --filtering Top 3 products per category by revenue

--Finding products selling below their cost (loss-making)
select
o.product_id,

sum((o.price_per_unit-p.cost_price)*quantity) profit

from order_items o
left join products p
on o.product_id=p.product_id
group by o.product_id
having sum((o.price_per_unit-p.cost_price)*quantity) <=0
/* ==============================================================================
   Customer Behavior
Calculate Customer Lifetime Value (CLV).
Find repeat customers.
Rank customers by total spending.
============================================================================== */


--Calculate Customer Lifetime Value (CLV).
with CLV_table as(--temprary table 
  select
    customer_id,
    count(distinct order_id) total_orders,
    sum(revenue) total_revenue,
    round(cast(sum(revenue) as float)/count(distinct order_id),2) avg_order_value
  from(
    select
      t.order_id,
      o.customer_id,
      t.quantity*t.price_per_unit revenue
    from order_items t
    left join  orders o
    on t.order_id=o.order_id)t
    group by customer_id
  )

--ranked clv table by total spending
select*,
dense_rank() over(order by total_revenue desc) as Rank
from CLV_table

--Find repeat customers.



