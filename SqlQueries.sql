
select * from orders

--1.  Show the total sales (grand_total), total quantity ordered, and number of orders for each status,
--ordered by total sales from highest to lowest.


select 
	status,
	sum(grand_total_dedup) as Total_sales,
	sum(qty_ordered) as Total_qty,
	count(DISTINCT increment_id)as No_of_orders
from orders
group by status
order by total_sales desc;


--2.  Find the average grand_total and average discount_amount for each payment_method, showing only
--payment methods with more than 100 orders.

select 
	payment_method,
	sum(grand_total_dedup)*1.0 / count(DISTINCT increment_id) as Avg_total_sales,
	avg(discount_amount) as Avg_dis,
	count(DISTINCT increment_id) AS No_of_orders
from orders
group by payment_method
Having count(DISTINCT increment_id) > 100
order by Avg_total_sales desc


--3.  List the top 5 category_name_1 values by total qty_ordered.
select 
	category_name_1,
	sum(qty_ordered) as Total_qty_ordered
from orders
group by category_name_1 
order by [Total_qty_ordered] desc


--4.  Retrieve all orders where grand_total is greater than the overall average grand_total.

select *
from orders
where grand_total > (select sum(grand_total_dedup)*1.0 / count(DISTINCT increment_id) from orders)

--5.  For each category_name_1, calculate the total discount, average discount, and number of discounted
--orders where discount_amount > 0.
select 
	category_name_1,
	sum(discount_amount) as Total_dis,
	avg(discount_amount) as Avg_dis,
	count(discount_amount) as Num_dis_orders
from orders
where discount_amount > 0
group by category_name_1
order by [Total_dis] desc


--6.  For each category, show the number of distinct sku values and the total number of orders.
select category_name_1,
       count(DISTINCT sku) as Distinct_skus,
       count(DISTINCT increment_id) as total_orders
from orders
group by category_name_1
order by total_orders desc;

--7.  Show customers with more than 5 orders, including their total spending and average order value,
--ordered by total spending descending.
select
	Customer_ID,
	count(DISTINCT increment_id) as Num_orders,
	sum(grand_total_dedup) Total_spent,
	sum(grand_total_dedup)*1.0 / count(DISTINCT increment_id) as Avg_order_value
from orders
group by Customer_ID
having count(DISTINCT increment_id) > 5
order by [Total_spent] desc


--8.  Find the sku values whose average price is greater than the overall average price.
select 
	sku,
	avg(price) Avg_price
from orders
group by sku
having avg(price) > (select avg(price) from orders)
order by [Avg_price] desc

--9.  Use a CASE expression to classify orders as Low (< 500), Medium (500-1,999), or High (>= 2,000)
--based on grand_total. Show the order count and total sales for each class.

--Can not use an alis just made in the case for groupby
select
    count(distinct increment_id) as Num_orders,
    sum(grand_total_dedup) as Total_sales,
    case
        when grand_total < 500 then 'Low'
        when grand_total >= 500 and grand_total < 2000 then 'Medium'
        else 'High'
    end as Order_class
from orders
group by
    case
        when grand_total < 500 then 'Low'
        when grand_total >= 500 and grand_total < 2000 then 'Medium'
        else 'High'
    end
order by Total_sales desc;

--10.  Using a subquery or CTE, show the categories whose total sales are greater than the average total
--sales across all categories

--Gbena el total sales bta3et kol category el 2wl
select
    category_name_1,
    sum(grand_total_dedup) as Total_sales
from orders
group by category_name_1 
-- then we get each category total sales and compares it with the average of all category sales
having sum(grand_total_dedup) > 
	(select avg(category_sales)
	from(select sum(grand_total_dedup) as category_sales from orders 
	group by category_name_1) as Category_total_sales
);


--11.  Use RANK() to rank orders by grand_total from highest to lowest within each category_name_1.
select 
	category_name_1, 
	grand_total,
	RANK() OVER (partition by category_name_1 order by grand_total) as Rank_category
from orders

--12.  Use DENSE_RANK() to rank payment methods by their total sales amount.
select 
	payment_method,
	sum(grand_total_dedup) Total_sales,
	DENSE_RANK() OVER (Order by sum(grand_total_dedup) DESC) as Dense_rank_sales
from orders
group by payment_method
order by [Dense_rank_sales]

--13.  Use a window function to calculate a running total of grand_total for each customer, ordered by item_id.
select 
	Customer_ID,
	item_id,
	grand_total_dedup,
	sum(grand_total_dedup) over(partition by Customer_ID order by item_id) as Running_grand_total
from orders
order by Customer_ID, item_id

--14.  Use ROW_NUMBER() to identify the highest-value order for each customer.

SELECT
    Customer_ID,
    increment_id,
    grand_total_dedup
FROM
(
--To rank the orders each customer made desc and then just take the 1st ranked value 
    SELECT
        Customer_ID,
        increment_id,
        grand_total_dedup,
        ROW_NUMBER() OVER (
            PARTITION BY Customer_ID
            ORDER BY grand_total_dedup DESC
        ) AS row_num
    FROM orders
    WHERE grand_total_dedup > 0
) AS ranked_orders
WHERE row_num = 1;

--15.  For every order, show its grand_total, the average grand_total of its category, and the difference
--between the order value and the category average using AVG() OVER (PARTITION BY ...).
Select 
	category_name_1,
	grand_total,
	avg(grand_total) over (partition by category_name_1) as Category_avg,
	grand_total - avg(grand_total) over (partition by category_name_1) as Diff_from_avg
from orders



--16.  Show total sales and total number of orders for each Year, ordered from newest to oldest.

select 
	Year,
    sum(grand_total_dedup) as Total_sales,
	count(DISTINCT increment_id) as Num_orders
from orders
group by Year
order by Year desc;

--17.  Show monthly total sales and order count grouped by Year and Month, without filtering to a fixed year.

select 
	Year,
	Month,
    sum(grand_total_dedup) as Total_sales,
	count(DISTINCT increment_id) as Num_orders
from orders
group by Year, Month
order by Year, Month;

--18.  For each customer, find the first order date using MIN(created_at) and the latest order date using MAX(created_at).

select 
	Customer_ID,
	MIN(created_at) as First_order,
	MAX(created_at) as Last_order
from orders
group by Customer_ID


--19.  Calculate monthly sales, the previous month's sales using LAG(), and the month-over-month growth percentage.



--20.  Use DENSE_RANK() to rank months within each year according to total monthly sales.
SELECT
    Year,
    Month,
    monthly_sales,
    DENSE_RANK() OVER (
        PARTITION BY Year
        ORDER BY monthly_sales DESC
    ) AS sales_rank
FROM
(
    SELECT
        Year,
        Month,
        SUM(grand_total_dedup) AS monthly_sales
    FROM orders
    GROUP BY Year, Month
) AS monthly_data;



SELECT payment_method,
       ROUND(AVG(grand_total), 2)     AS avg_grand_total,
       ROUND(AVG(discount_amount), 2) AS avg_discount,
       COUNT(*)                       AS num_orders
FROM orders
GROUP BY payment_method
HAVING COUNT(*) > 100
ORDER BY avg_grand_total DESC;