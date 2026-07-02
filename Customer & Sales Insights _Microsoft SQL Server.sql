
--Section 1: Sales Performance Analysis.

--1.What is the total sales and total profit generated?

select SUM(Sales * Quantity) as Total_Sales , SUM(Profit) as Total_Profit from Orders_

--2.What is the total sales by year?

select YEAR(Order_Date) as Year_ , SUM(Sales * Quantity) as Total_Sales_By_Year from Orders_ 
Group By YEAR(Order_Date)
Order By Year_

--3.What is the monthly sales trend?

select MONTH(Order_Date) as Month_ , SUM(Sales * Quantity) as Total_Sales  from Orders_ 
Group By MONTH(Order_Date) 
Order By Month_ desc

--4.Which region generates the highest sales?

select Region , SUM(Sales * Quantity) as Total_Sales_By_Region from Orders_
Group By Region 
Order By Total_Sales_By_Region desc


--5.Which city has the lowest profit?

select City, Sum(Profit) as Total_Profit_By_City from Orders_
Group by City
Order By Total_Profit_By_City asc

--6.What is the average order value?

select Avg(Order_Value) as Avg_Order_Value from (
select Order_ID ,SUM(Sales * Quantity) as Order_Value from Orders_ 
Group By Order_ID) as Avg_

--7.Which category contributes the most to total sales?

select Category , SUM(Sales * Quantity) as Total_Sales  from Orders_
Group By Category 
Order By Total_Sales desc

--8.What are the top 5 best-selling products?

select Top 5 Product_Name , SUM(Sales * Quantity) as Total_Sales  from Orders_
Group By Product_Name 
Order By Total_Sales desc

--9.Which products are generating losses?

select Product_Name , SUM(Profit) as Total_Profit from Orders_
Group By Product_Name
Having SUM(Profit) < 0
Order By Total_Profit asc

--10.What is the sales growth percentage month-over-month?

with cte as (
select Year(Order_Date) as Year_, Month(Order_Date) Month_ , SUM(Sales * Quantity) as Total_Sales from Orders_ 
Group By Year(Order_Date) , Month(Order_Date))
select Year_ , Month_ ,
LAG(Total_Sales) over (order by   Year_ , Month_) as Previous_Month_Sales,
((Total_Sales - LAG(Total_Sales) over (Order By Year_ , Month_ )) * 100.00 / LAG(Total_Sales) Over (Order By Year_ , Month_ ))
as Month_Over_Month from cte 

--Section 2: Product Performance Analysis

--11.What are the top 10 best-selling products by sales?

select TOP 10 Product_ID , SUM(Sales * Quantity) as Sum_Sales  from Orders_
Group By Product_ID 
Order By Sum_Sales desc 

--12.Which product generated the highest profit?

select Top 1 Product_ID , Sum(Profit) as Sum_Profit from Orders_
Group by Product_ID
Order By Sum_Profit desc


--13.Which products are generating loss?

select Product_ID , SUM(Profit) as Sum_Profit  from Orders_ 
Group By Product_ID
Having SUM(Profit) < 0 

--14.Which category has the highest average profit?

select Category , AVG(Profit) as Avg_Profit from Orders_ 
Group By Category 
Order By Avg_Profit desc

--15. What is the total quantity sold per product?

select Product_ID , SUM(Quantity) as Total_Quantity from Orders_ 
Group By Product_ID

--16.Which sub-category has the highest sales?

select Sub_Category, Sum(Sales * Quantity) as Total_Sales  from Orders_ 
Group By Sub_Category 
Order By Total_Sales desc

--17.Rank products based on total sales within each category.

with cte as (
select Category , Product_ID, SUM(Sales * Quantity) as Total_Sales 
from Orders_
Group By Category , Product_ID )
select *,
Rank() over(Partition By Category Order By Total_Sales desc) as Rannk_
from cte

--18.Find the second highest selling product in each category.

with cte as(
select Category , Product_ID  , Sum(sales * Quantity) as Total_Sales from Orders_
Group By Category , Product_ID)
select *,
Rank() over(Partition By Category Order By Total_Sales desc) as Rank_
from cte 
where Rank_ = 2

--Section 3: Customer Analysis

--21.Who are the top 10 customers by total sales?

select Top 10 Customer_Name , SUM(Sales * Quantity) as Total_Sales  from Orders_ 
Group By Customer_Name 
Order By Total_Sales desc 

select Top 10 Customer_Name , SUM(Sales * Quantity) as Total_Sales ,
Dense_Rank() over (Order By SUM(Sales * Quantity) desc) as Rank_
from Orders_
Group By Customer_Name 


--22.Which customers have placed the highest number of orders?

select Top 1 Customer_Name , Count(Distinct Order_ID) as Count_of_Order from Orders_
Group By Customer_Name 
Order By Count_of_Order desc

select Customer_Name ,
Dense_Rank() over (Order By Count(Distinct Order_ID) desc) as Count_of_Order
from Orders_
Group By Customer_Name 

--23.Find the latest order placed by each customer.

with cte as (
select *,
Row_Number() over(Partition By Customer_Name Order By Order_Date desc) as Rank_
from Orders_)
select * from cte 
where Rank_ = 1

--24.How many unique customers are there?

select Count(Distinct Customer_ID) as Unique_Customers  from Orders_ 

--25.What is the average sales per customer?
with cte as ( 
select Customer_ID  , SUM(Sales * Quantity) as Total_Sales  from Orders_ 
Group By Customer_ID)
select AVG(Total_Sales) as Avg_Total_Sales from cte 


--26.Which customers have placed more than 5 orders?

with cte as(
select Customer_Name , COUNT(Distinct Order_ID) as Count_of_Order_ID  from Orders_ 
Group by Customer_Name)
select * from cte 
Where Count_of_Order_ID > 5

--27.Find the most recent order for each customer.

with cte as (
select *,
ROW_Number() over(Partition By Customer_ID Order By Order_Date desc) as Rank_
from orders_)
select * from cte 
where Rank_ = 1

--28.Rank customers based on total sales.

with cte as (
select Customer_ID , SUM(Sales * Quantity) as Total_Sales 
from Orders_
Group By Customer_ID)
select *,
Rank() over (Order By Total_Sales desc) as Rank_
from cte 

--29.Which customers only made one purchase?

with cte as (
select Customer_ID ,COUNT(Distinct Order_ID) as Count_of_Order_ID  from Orders_
Group By Customer_ID) 
select * from cte 
Where Count_of_Order_ID = 1


select Customer_ID ,COUNT(Distinct Order_ID) as Count_of_Order_ID  from Orders_
Group By Customer_ID 
Having COUNT(Distinct Order_ID) = 1

--30.Identify customers who purchased from multiple categories.

select Customer_ID , COUNT(Distinct Category) as Count_of_Order_ID  from Orders_ 
Group By Customer_ID 
Having COUNT(Distinct Category) > 1

--Section 4: Returns Analysis

--31.What is the total number of returned orders?

 select Count(*) as Returned_ from Returns_
 Where Returned = 'Yes'


--32.What percentage of total orders were returned?

  select(COUNT(DISTINCT 
  Case 
      WHEN r.Returned = 'YES' THEN r.Order_ID 
  END) * 100.0)/ COUNT (DISTINCT o.Order_ID) as Return_ 
  from Orders_ o left join Returns_ r on o.Order_ID = r.Order_ID


--33.Which product is returned the most?

  select o.Product_ID , COUNT(*) as Returned_
  from Returns_ r join Orders_ o on r.Order_ID = o.Order_ID
  where r.Returned = 'Yes'
  Group By o.Product_ID 
  Order By Returned_ desc


--34.Which category has the highest return rate?

select o.Category, (COUNT(DISTINCT 
CASE 
    WHEN r.Returned = 'YES' THEN r.Order_ID 
END) * 100.0) / COUNT(DISTINCT o.Order_ID) as Return_Rate
from Orders_ o left join Returns_ r on o.Order_ID = r.Order_ID
Group By o.Category
Order By Return_Rate desc

--35.Which region has the most returns?

select o.City , COUNT(r.Order_ID) as Total_Returns
from Orders_ o left join Returns_ r on o.Order_ID = r.Order_ID
Where Returned = 'YES'
Group By o.City
Order By Total_Returns desc

--36.Find customers who returned more than 1 orders.

 select o.Customer_Name , COUNT(Distinct r.Order_ID) as Count_of_OrderID 
 from Orders_ o join Returns_ r on o.Order_ID = r.Order_ID
 Group By o.Customer_Name
 Having COUNT(Distinct r.Order_ID) > 1

--37.What is the total loss due to returned orders?
     
  select 
  SUM (CASE
      WHEN o.Profit < 0 THEN o.Profit
      ELSE 0
  END) as Total_Loss_Due_to_Return
  from Orders_ o join Returns_ r on o.Order_ID = r.Order_ID 
  Where r.Returned = 'YES'

--38.Compare sales vs returned sales by category.

select o.Category , SUM(o.Sales * o.Quantity) as Total_Sales , 
SUM(
CASE
    WHEN r.Returned = 'YES' THEN (o.Sales * o.Quantity) ELSE 0 
END) as Returned_Revenue ,
Count(r.Returned) as count_of_return
from orders_ o Left Join  Returns_ r on o.Order_ID = r.Order_ID 
Group By o.Category


--39.Which month had the highest number of returns?

select DATENAME(MONTH , o.Order_Date) as Month_ , DATENAME(YEAR , o.Order_Date) as Year_ , Count(r.Returned) as Count_of_Returned
from Orders_ o join Returns_ r on o.Order_ID = r.Order_ID 
WHERE r.Returned = 'YES'
Group By  DATENAME(MONTH , o.Order_Date) , DATENAME(YEAR , o.Order_Date)
Order By Count_of_Returned desc


--40.Are returned orders more common in a particular segment?

select o.Segment , Count(o.Order_ID) as Count_of_Order_ID , Count(r.Returned) as Count_of_returned,
(CAST(Count(r.Returned) as Float) / Count(o.Order_ID)) * 100 as Returne_Percentage 
from Orders_ o Left Join Returns_ r on o.Order_ID = r.Order_ID 
Group By o.Segment 


--Section 5: Advanced SQL (Window Functions)


--41.Rank products by sales within each region.

select Product_ID , Region ,SUM(Sales * Quantity) as Total_Sales,
RANK() over (Partition By Region Order By SUM(Sales * Quantity) Desc) as Total_Sales 
from Orders_ 
Group By Product_ID, Region 

--42.Find the top 3 customers in each region.

with cte as (
select Customer_ID, Region, SUM(Sales * Quantity) as Total_Sales,
Dense_Rank() over(Partition By Region Order By SUM(Sales * Quantity) Desc) as Rank_
from Orders_
Group By Customer_ID , Region)
select Customer_ID, Region, Total_Sales from cte
Where Rank_ <= 3
Order By Region, Rank_

--43.Calculate running total of sales by month.

select DATEPART(MONTH, Order_Date) as Month_, DATEPART(YEAR, Order_Date) as Year_ ,
SUM(SUM(Sales * Quantity)) Over(Order By DATEPART(MONTH, Order_Date), DATEPART(YEAR, Order_Date)) as Running_Total
from Orders_
Group By DATEPART(MONTH, Order_Date) , DATEPART(YEAR, Order_Date) 
Order By Month_ , Year_

--44.Calculate cumulative profit year-wise.

select YEAR(Order_Date) as Year_ , SUM(Profit) Over (Partition By YEAR(Order_Date)) as Yearly_Profit,
SUM(Profit) over (Order By YEAR(Order_Date)) as Cumulative_Profit
from Orders_
  
--45.Assign row numbers to orders within each customer based on order date.

select Order_Date, Customer_ID,
Row_Number() Over(Partition By Customer_ID Order By Order_ID) as Row_Num
from Orders_

--46.Find the highest sales order per month.

with cte as (
select Order_ID , MONTH(Order_Date) as Month_ , Sales * Quantity as Order_Sales,
ROW_Number() Over(Partition By MONTH(Order_Date) Order By Sales * Quantity Desc) as Running_
from Orders_) 
select * from cte 
where Running_ = 1


--47.Find the lowest profit order in each category.

   
select Customer_ID , Category , Profit ,
Row_Number() over(Partition By Category Order By Profit Asc) as Running_
from Orders_

--48.Compare each product’s sales to the category average.

select Product_ID , Category , Sales * Quantity as Product_Sales,
AVG(Sales * Quantity) Over (Partition By Category) as Avg_Sales_Of_Category,
Sales * Quantity - AVG(Sales * Quantity) Over(Partition By Category) as Difference_from_Average
from Orders_


--49.Identify customers whose sales are above overall average sales.

select Customer_ID , AVG(Sales * Quantity) as AVG_Sales
from Orders_
Group By Customer_ID 
Having AVG(Sales * Quantity) > (Select AVG(Sales * Quantity) from Orders_)


--50.Find the percentage contribution of each category to total sales.

select Category, SUM(Sales * Quantity) as Category_Sales,
SUM(SUM(Sales * Quantity)) Over() as Total_Sales,
(SUM(Sales * Quantity) * 100.0) / SUM(SUM(Sales * Quantity)) Over() as Percentage_Contribution
from Orders_
Group By Category
Order By Percentage_Contribution
