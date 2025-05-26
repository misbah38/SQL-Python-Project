
use retail_sales;
-- Data Cleaning
-- rename the column 
alter table retail_sales
rename column quantiy to quantity ;


-- is there any null values in the table
select * from retail_sales
where 
transactions_id is null or 
sale_date is null or 
sale_time is null or
customer_id is null or
gender is null or
category is null or
quantity is null or 
price_per_unit is null or
cogs is null or
total_sale is null;

-- data exploration
-- how many total sales are in retail sales 
select count(total_sale) from retail_sales;
-- how many unique customers we have
 select count(distinct customer_id) from retail_sales;
 
 -- how many categories we have
 select distinct category from retail_sales;
 
 -- Data analysis
 
 -- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
 select * 
 from retail_sales
 where sale_date = '2022-11-05';

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
select *
from retail_sales
where 
	category = 'clothing'
	and 	
    quantity >= 4  # we dont have quantity more than 4 so on 10 it shows empty
	and 
	sale_date >= date '2022-11-01'
    and sale_date <date '2022-12-01'; 
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
select category, 
sum(total_sale) as total_sale,
count(*) as total_orders
from retail_sales
group by category;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
select 
 round(avg(age),2) as avg_age
 from retail_sales
 where category = 'beauty';
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
select *
from retail_sales
where total_sale >=1000;
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
select count(transactions_id) as total_transactions,
 gender,
 category
from retail_sales
group by gender,category
order by gender,category;
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
select 
extract(year from sale_date) as year,
extract(month from sale_date) as month,
avg(total_sale) as avg_monthly_sale
from retail_sales
group by 
extract(year from sale_date),
extract(month from sale_date)
order by year, month ;

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
select 
customer_id,
sum(total_sale) as total_sales
from retail_sales
group by customer_id 
order by total_sales desc
limit 5;
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
select 
count(distinct customer_id) as unique_customer,
category
from retail_sales
group by category
order by unique_customer desc;

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) as total_orders    
FROM hourly_sale
GROUP BY shift;

 
