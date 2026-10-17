-- 											>>>>>       Order Overview			>>>>>
-- Q1: Business wants to understand the order data before making decisions. Display the first 10 records. 
-- Show all column values for these records.

SELECT *
FROM food_delivery_orders_dataset
ORDER BY order_id ASC
LIMIT 10;

select * from food_delivery_orders_dataset;

-- Q2: Management wants to know which order statuses exist in the business.
-- Display all unique order statuses.
-- Show the total number of distinct statuses.

Select distinct Order_status 
from food_delivery_orders_dataset;

select count(distinct Order_status) as total_unique_statuses
from food_delivery_orders_dataset;

-- Q3: High-Value Orders (order_total > 1,00)
--     Display the order ID, order date, order value, and order status.
--     Sort orders by order value from highest to lowest.
--     Return only the top 10 orders.


select order_id, order_date, order_total, order_status
from food_delivery_orders_dataset
where order_total > 100
order by order_total desc
limit 10;

-- Q4: Orders by Payment Method
-- Find all orders paid through a specified payment method.
-- Display the order ID, payment method, and order value.
-- Sort by order value in descending order.

select order_id, payment_method, order_total
from food_delivery_orders_dataset
where payment_method='Digital Wallet'
order by Order_total DESC;

-- Q5: Orders Requiring Attention: The operations team wants to identify orders that are either cancelled or delayed.
-- Filter orders using logical operators.
-- Display relevant order details.
-- Sort the results by order date.

select order_id, order_date, late_delivery
from food_delivery_orders_dataset
where late_delivery=1 OR NULLIF(TRIM(cancellation_reason), '') IS NOT NULL
order by order_date;

-- Q6: Order Status Distribution
-- Calculate the number of orders in each order status.
-- Show status and order count.
-- Sort by count in descending order.

select order_status, count(order_id) as Num_Orders
from food_delivery_orders_dataset
group by order_status
order by Num_orders DESC;

-- Q7: Revenue by City
-- Calculate total revenue for each city.
-- Show the number of orders and average order value.
-- Sort cities by revenue, highest first.

select city, Round(sum(order_total),2) as Revenue, count(order_id) as Num_orders, Round(Avg(order_total),2) as Average_order_value
from food_delivery_orders_dataset
group by city
order by Revenue DESC;

-- Q8: Monthly Revenue Trends
-- Calculate monthly revenue.
-- Show total orders and average order value per month.
-- Sort chronologically by year and month.

SELECT
    YEAR(order_date) AS Order_Year,
    MONTH(order_date) AS Order_Month,
    SUM(order_total) AS Monthly_Revenue,
    COUNT(*) AS Total_Orders,
    ROUND(AVG(order_total), 2) AS Average_Order_Value
FROM food_delivery_orders_dataset
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    YEAR(order_date) ASC,
    MONTH(order_date) ASC;
    
-- Q9: High-Performing Restaurants
-- Identify restaurants that have generated more than ₹50,000 in total order value.
-- Display restaurant name, total revenue, and total orders.
-- Include only restaurants meeting the revenue threshold.
-- Rank results by revenue.

select restaurant_id,
count(order_id) as Total_orders, Round(sum(order_total),2) as Revenue
from food_delivery_orders_dataset
group by restaurant_id
having revenue > 50000
order by revenue DESC;
;

-- Q10: Delivery Performance
-- Calculate average delivery time by delivery partner.
-- Include only partners with at least 50 orders.
-- Display the number of orders and average delivery time.
-- Sort from longest to shortest average delivery time.

select driver_id, count(actual_delivery_time_minutes) as Orders, Round(avg(actual_delivery_time_minutes),2) as Avg_time_for_Delivery
from food_delivery_orders_dataset
WHERE driver_id IS NOT NULL
group by driver_id
having Orders>=50
order by Avg_time_for_Delivery DESC;

-- Q11: Customer Spending Analysis
-- Find the top 10 customers by total spending.
-- Display customer ID, total orders, and total spending.
-- Sort by spending in descending order.
-- Use customer and order data appropriately.

select customer_id, Count(*) as Total_orders_placed, ROund(sum(order_total),2) as Total_spendings
from food_delivery_orders_dataset
WHERE customer_id IS NOT NULL
group by customer_id
order by Total_spendings DESC, customer_id ASC
limit 10;

-- Q12: Restaurant Performance by City
-- Compare restaurant performance within each city.
-- Calculate each restaurant's total revenue and order count.
-- Include the corresponding city.
-- Identify the top three restaurants in each city.

With Restaurant as (select restaurant_id, city, count(*) as Total_Orders, Round(sum(order_total),2) as Revenue
from food_delivery_orders_dataset
group by restaurant_id, city
order by Revenue DESC),

Restaurant_Performance as (select restaurant_id, city, Total_orders, Revenue, Rank() OVER(partition by city order by Revenue DESC) as Rest_rank
from Restaurant)

select restaurant_id, city, Total_orders, Revenue, Rest_rank
from Restaurant_Performance
where rest_rank<=3
ORDER BY city, Rest_rank;

-- Q13: Revenue Contribution
-- Calculate city-level revenue.
-- Calculate each city's percentage contribution to overall revenue.
-- Sort by contribution, highest first.

With City_share as (select city, Round(Sum(order_total),2) as Revenue
from food_delivery_orders_dataset
group by city)

select city, Revenue, ROUND(
        Revenue * 100.0 / SUM(Revenue) OVER (),
        2
    ) AS contribution_percentage
FROM City_share
ORDER BY contribution_percentage DESC;

-- Q14: Repeat Customers
-- The retention team wants to identify customers who placed at least three orders.
-- Display customer ID, total orders, and total spending.
-- Categorize customers as One-Time, Occasional, or Frequent based on order count.
-- Sort by total spending.

With Cust_cat as (select customer_id, count(*) as Total_Orders, Round(sum(order_total),2) as Total_spendings
from food_delivery_orders_dataset
group by customer_id
)

select customer_id, Total_orders, Total_Spendings,
case 
  when Total_Orders =1 Then 'One_Time'
  when Total_Orders between 2 and 100 Then 'Occasional'
  when Total_orders >=101 then 'Frequent'
  end as Customer_category
from Cust_cat
order by Total_spendings DESC;

-- Q15: Top Revenue Days
-- Identify the five dates with the highest total revenue.
-- Show date, revenue, and number of orders.
-- Handle multiple orders on the same date correctly.

select DATE(order_date) AS order_day, Round(sum(order_total),2) as Revenue, Count(*) as Total_Orders
from food_delivery_orders_dataset
group by order_day
order by Revenue DESC
Limit 5;

-- Q16: Day-over-Day Growth
-- Calculate daily revenue growth.
-- Display daily revenue, previous day revenue, and growth percentage.
-- Handle the first day, when no previous day exists.
-- Identify days where revenue declined.

with Daily_Revenue as (select Date(order_date) as Date, Month(order_date) as Month, Round(sum(order_total),2) as Revenue
from food_delivery_orders_dataset
group by Date, month
order by date asc),

growth_ratio as (select date, month, revenue as Curr_day_revenue, LAG(revenue,1) OVER (order by Date) as Previous_day_revenue
from Daily_revenue)

select Date, Month, Curr_day_revenue, Previous_day_revenue, Round((Curr_day_revenue-Previous_day_revenue)*100/Previous_day_revenue,2) as Change_Percentage
from growth_ratio;

-- Q17: Above-Average Spending Customers
-- Find customers whose total spending is greater than the average total spending per customer.
-- Calculate each customer's total spending.
-- Compare it with the average across customers.

with Cust_spend as (select customer_id, Round(sum(order_total),2) as Total_spendings
from food_delivery_orders_dataset
group by customer_id),

Average_spend as (select ROund(Avg(Total_spendings),2) as Average_spendings
from cust_spend)

SELECT
    customer_id,
    Total_spendings
FROM Cust_spend
WHERE Total_spendings > (
    SELECT Average_spendings
    FROM Average_spend
)
order by Total_spendings DESC;

-- Q18: Delivery SLA Breaches
-- Identify orders delivered later than their promised delivery time.
-- Calculate delivery delay in minutes or hours.
-- Count delayed orders and calculate the delay percentage.
-- Break down results by city or delivery partner.
-- Exclude or handle missing timestamps appropriately.

    with Delivery_Performance as (SELECT order_id, city, driver_id, actual_delivery_time_minutes, estimated_delivery_time_minutes,
        (actual_delivery_time_minutes
            - estimated_delivery_time_minutes) AS Delivery_delay_min
    FROM food_delivery_orders_dataset
    WHERE actual_delivery_time_minutes IS NOT NULL
      AND estimated_delivery_time_minutes IS NOT NULL),
City_Performance AS (
    SELECT city, COUNT(*) AS Valid_Orders,
        SUM(
            CASE
                WHEN Delivery_delay_min > 0 THEN 1
                ELSE 0
            END
        ) AS Delayed_Orders,
        ROUND(
            100.0 * SUM(
                CASE
                    WHEN Delivery_delay_min > 0 THEN 1
                    ELSE 0
                END
            ) / COUNT(*), 2) AS Delay_Percentage
    FROM Delivery_Performance
    GROUP BY city
)
SELECT
    city, Valid_Orders, Delayed_Orders, Delay_Percentage
FROM City_Performance
ORDER BY Delay_Percentage DESC;

-- Q:19 End-to-End Business Performance Report
-- Create a final management report that combines multiple business KPIs.
-- Include: Total orders and completed orders.
-- Total revenue and average order value, Cancellation rate, Average delivery time
-- Top-performing cities and restaurants.


select city, restaurant_id, count(*) as Total_Orders, Round(sum(order_total),2) as Revenue, Round(Avg(order_total),2) as Average_order_Value,
			sum( case
					when order_status='Completed' then 1
                    else 0
                    end) as Completed_orders,
Round(avg(actual_delivery_time_minutes),2) as Average_delivery_time_min,
SUM(
            CASE
                WHEN order_status = 'Cancelled' THEN 1
                ELSE 0
            END
        ) AS Cancelled_Orders,
(SUM(
            CASE
                WHEN order_status = 'Cancelled' THEN 1
                ELSE 0
            END
        )*100/Nullif(count(*),0)) as Cancellation_rate
from food_delivery_orders_dataset
group by city, restaurant_id;