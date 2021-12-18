USE Bikestores
GO

/* 
Subqueries
SQL supports writing queries within queries, or nesting queries. The inner query acts in place of an expression that is based on constants
or variables and is evaluated at run time.

A subquery can either be self-contained or correlated. A self-container subquery has no dependency on the outer query that it belongs to,
whereas a correlated subquery does.

A subquery can be single-valued, multivalued, or table-valued. That is, a subquery can return a single value (a scalar value), multiple values,
or a whole table result.

Self-Contained Scalar Subquery Examples
*/

DECLARE @maxid AS INT = (SELECT MAX(order_id) FROM sales.orders)

SELECT order_id, order_date, customer_id, staff_id
FROM sales.orders
WHERE order_id = @maxid

------------ YOU CAN ALSO WRITE IT LIKE THIS --------------------
SELECT order_id, order_date, customer_id, staff_id
FROM sales.orders 
WHERE order_id = (SELECT MAX(order_id) FROM sales.orders)


/* This query fails because the equality operator expects single-valued expressions */
SELECT order_id 
FROM sales.orders 
WHERE customer_id = 
    (SELECT customer_id 
        FROM sales.customers 
        WHERE first_name LIKE N'B%')



/* Self-Contained Multivalued Subquery Examples
A multivalued subquery is a subquery that returns multiple values as a single column, regardless whether the subquery 
is self-contained. Some predicates, such as the IN predicate, operate on a multiple subquery.

Other predicates that operate on a multivalued subquery include SOME, ANY, AND ALL.

*/

SELECT order_id
FROM sales.orders 
WHERE customer_id IN 
    (SELECT customer_id 
     FROM sales.customers 
     WHERE first_name LIKE N'De%')


-- query orders that come from customers in New York
SELECT order_id
FROM sales.orders 
WHERE customer_id IN 
    (SELECT customer_id 
     FROM sales.customers AS C 
     WHERE C.city = N'New York')

/* As with many other predicates, you can negate the IN predicate with the NOT logical operator. 

For instance, find orders that do not come from customers in New York. You might want to specify a DISTINCT clause in the subquery to improve
performance but the database engine is way ahead of you. 

*/
SELECT order_id
FROM sales.orders 
WHERE customer_id NOT IN 
    (SELECT customer_id 
     FROM sales.customers AS C 
     WHERE C.city = N'New York')



-- INSERTING multiple data into a table using multivalued subqueries
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
CREATE TABLE dbo.Orders(order_id INT NOT NULL CONSTRAINT PK_Orders PRIMARY KEY);

-- Insert order_id's that are even numbers
INSERT INTO dbo.Orders 
    SELECT order_id 
    FROM sales.orders 
    WHERE order_id % 2 = 0;


/* TASK AT HAND

The task at hand is to return all individual order IDs that are missing between the minimum and maximum in the table.
*/

DECLARE @maxNumOfOrders AS INT = (SELECT MAX(order_id) FROM dbo.Orders)
DECLARE @minNumOfOrders AS INT = (SELECT MIN(order_id) FROM dbo.Orders)
 
-- Sequence of integers, starting with 0 with no gaps
select d4.digit * 1000 + d3.digit * 100 + d2.digit * 10 + d1.digit * 1 AS Nums
FROM dbo.Digits AS d1
    CROSS JOIN dbo.Digits AS d2
        CROSS JOIN dbo.Digits AS d3
            CROSS JOIN dbo.Digits AS D4

WHERE d4.digit * 1000 + d3.digit * 100 + d2.digit * 10 + d1.digit * 1 <= @maxNumOfOrders
    AND d4.digit * 1000 + d3.digit * 100 + d2.digit * 10 + d1.digit * 1 >= @minNumOfOrders
    AND d4.digit * 1000 + d3.digit * 100 + d2.digit * 10 + d1.digit * 1 NOT IN (SELECT order_id FROM dbo.Orders)
ORDER BY Nums

GO

-- You could have also used the BETWEEN clause 
DECLARE @maxNumOfOrders AS INT = (SELECT MAX(order_id) FROM dbo.Orders)
DECLARE @minNumOfOrders AS INT = (SELECT MIN(order_id) FROM dbo.Orders)
 
-- Sequence of integers, starting with 0 with no gaps
select d4.digit * 1000 + d3.digit * 100 + d2.digit * 10 + d1.digit * 1 AS Nums
FROM dbo.Digits AS d1
    CROSS JOIN dbo.Digits AS d2
        CROSS JOIN dbo.Digits AS d3
            CROSS JOIN dbo.Digits AS D4

WHERE d4.digit * 1000 + d3.digit * 100 + d2.digit * 10 + d1.digit * 1 BETWEEN @minNumOfOrders AND @maxNumOfOrders
    AND d4.digit * 1000 + d3.digit * 100 + d2.digit * 10 + d1.digit * 1 NOT IN (SELECT order_id FROM dbo.Orders)
ORDER BY Nums

-- Clean up
DROP TABLE dbo.Orders


/* Correlated Subqueries 

These are subqueries that refer to attributes from the table that appears in the outer query. This means that the subquery is dependent 
on the outer query and cannot be invoked independently. 

To better understand the concept of correlated subqueries, I find it useful to focus attention on a single row in the outer
table and understand the logical processing that takes place for that row.

For example, focus your attention on the order in the order in the sales.orders table with order_id 1.
With respect to the outer row, when the subquery is evaluated, the correlation or reference to O1.customer_id means 259.
After substituting the correlation with 1, you get the following

SELECT MAX(O2.order_id) 
FROM sales.orders AS O2 
WHERE O2.customer_id = 1

This query returns the order ID 1613. The outer row's order ID - 1 - is compared to with the inner one - 1613 - and because there's no 
match in this case, the outer row is filtered out.
*/

SELECT customer_id, order_id, order_date, staff_id 
FROM sales.orders AS O1 
WHERE order_id = 
    (SELECT MAX(O2.order_id)
     FROM sales.orders AS O2 
     WHERE O2.customer_id = O1.customer_id)


-- Feed a row from the outer query into the inner query, and it'll all make sense
SELECT order_id, item_id, list_price,
    CAST (100 * list_price / (SELECT SUM(O2.list_price)
                              FROM sales.order_items AS O2
                              WHERE O2.order_id = O1.order_id) 
                              AS numeric(5, 2))
FROM sales.order_items AS O1 
ORDER BY order_id, item_id



/* THE EXISTS Predicate 
The EXISTS predicate accepts a subquery as inputs and returns TRUE if the subquery returns any rows and FALSE otherwise.
*/

SELECT customer_id, first_name, email
FROM sales.customers AS C
WHERE city = N'New York'
 AND EXISTS (SELECT * 
             FROM sales.orders AS O
             WHERE O.customer_id = C.customer_id)


-- As always, you can negate predicates
SELECT customer_id, first_name, email
FROM sales.customers AS C
WHERE city = N'New York'
 AND NOT EXISTS (SELECT * 
             FROM sales.orders AS O
             WHERE O.customer_id = C.customer_id)


/* Beyond the fundamentals of Subqueries

Returning previous of next values */
-- Previous orders
SELECT order_id, order_date, staff_id,
    (SELECT MAX(O2.order_id)
     FROM sales.orders AS O2
     WHERE O2.order_id < O1.order_id) AS prevorderid
FROM sales.orders AS O1;

--- Next order
SELECT order_id, order_date, staff_id ,
    (SELECT MAX(O2.order_id)
    FROM sales.orders AS O2
    WHERE O2.order_id > O1.order_id) AS nextorderid
FROM sales.orders AS O1


/* Running Aggregates
*/



SELECT YEAR(order_date), ORDER_ITEMS.quantity, 
  (SELECT SUM(ORDER_ITEMS.list_price) 
  FROM ORDER_ITEMS
  WHERE O.order_date <= OI.order_date)
FROM (SELECT OI.order_id, OI.list_price, OI.quantity, O.order_date
     FROM sales.order_items AS OI
     JOIN sales.orders AS O
     ON OI.order_id = O.order_id) AS ORDER_ITEMS

select * from sales.order_items


-- table 1
SELECT OI.order_id, OI.list_price, OI.quantity, O.order_date 
FROM sales.order_items AS OI 
JOIN sales.orders AS  O 
ON OI.order_id = O.order_id





IF OBJECT_ID('dbo.OrderInfo', 'U') IS NOT NULL DROP TABLE dbo.OrderInfo;

CREATE TABLE dbo.OrderInfo (
    order_id INT NOT NULL,
    list_price NUMERIC(10, 2) NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL,
    order_date DATE
);


INSERT INTO dbo.OrderInfo (order_id, list_price, item_id, quantity, order_date)
    (SELECT DISTINCT OI.order_id, OI.list_price, OI.item_id, OI.quantity, O.order_date
     FROM sales.order_items AS OI
     JOIN sales.orders AS O
     ON OI.order_id = O.order_id)


SELECT YEAR(O1.order_date) AS [Year], 
    (SELECT SUM(O2.list_price)  
    FROM dbo.OrderInfo AS O2
    WHERE YEAR(O2.order_date) <= YEAR(O1.order_date)) AS runqty
FROM dbo.OrderInfo AS O1
ORDER BY [Year]

-- Clean Up: 
DROP TABLE dbo.OrderInfo


/* 
Dealing with misbehaving subqueries 
------------------------------------
This section introduces cases in which subqueries might behave counter to your expectations, and provide best practices that you can follow
to avoid logical bugs in your code taht are assocciated with those cases.

NULL TROUBLE
Remember that T-SQL uses three-valued logic. In this section, let's highlight problems that could arise with subqueries with NULL marks are 
involved and we don't take into consideration the three-valued logic
*/

-- Customers that have placed orders: Seemingly intuitive query
-- If a NULL mark is found in the subquery, the resultset of the query will be empty
SELECT customer_id, email 
FROM sales.customers 
WHERE customer_id IN (SELECT customer_id FROM sales.orders)


/* Substitution Errors in Subquery Column Names

Let's take a look at this harmless query: Assume that the shipper is also the store (shipper_id in sales.MyShippers = store_id in sales.orders
)

*/
IF OBJECT_ID('sales.MyShippers', 'U') IS NOT NULL
  DROP TABLE sales.MyShippers;

CREATE TABLE sales.MyShippers
(
    shipper_id INT NOT NULL,
    companyname NVARCHAR(20) NOT NULL,
    phone NVARCHAR(20) NOT NULL,
    CONSTRAINT PK_MyShippers PRIMARY KEY(shipper_id)  
)

INSERT INTO sales.MyShippers (shipper_id, companyname, phone)
  VALUES (1, N'Shipper GVSUA', N'(503) 555-0137'),
         (2, N'Shipper ETYNR', N'(503) 555-0136'),
         (3, N'Shipper ZHISN', N'(503) 555-0138')


/*

It turns out that the column name in the sales.orders table holding the shipper ID is not called shipper_id; it is called store_id. The column
The column in the sales.MyShippers table is called shipper_id. 

THE RESOLUTION OF NONPREFIXED COLUMN NAMES works in the context of a subquery from the current/inner scope outward. So, in this example, SQL Server first looks for the 
column shipper_id in the orders table. Such a column is not found there, so SQL Server looks for it in the outer table in the query sales.MyShipers. Because one is found,
it is the one used.

You can see that what was supposed to be a self-contained subquery unintentionally became a correlated subquery. Some might argue that this behaviour is a design flaw in 
standard SQL. However, it's not that the designers of this behaviour in the ANSI SQL committee thought that it would be difficult to detect the "error", rather, it's an 
intentional behaviour designed to allow you to refer to column names from the outer table without needing to prefix them with the table name, as long as those column names are
unambiguous (that is, as long as they appear only in one of the tables)
*/

SELECT shipper_id, companyname
FROM sales.MyShippers 
WHERE shipper_id IN 
      (SELECT shipper_id
       FROM sales.orders
       WHERE customer_id=43)


/* SOLUTION
In the short run, you can prefix column names in subqueries with the source table alias. This way the resolution process only looks for the column in the specified table,
and if no such column is there, you get a resolution error.
*/
SELECT shipper_id, companyname
FROM sales.MyShippers 
WHERE shipper_id IN 
    (SELECT O.shipper_id -- this returns an error
    FROM sales.orders AS O 
    WHERE customer_id = 43)


-- Now you can correct that error
SELECT shipper_id, companyname
FROM sales.MyShippers 
WHERE shipper_id IN 
    (SELECT O.store_id 
    FROM sales.orders AS O
    WHERE customer_id = 43)

-- Clean up
IF OBJECT_ID('sales.MyShippers', 'U') IS NOT NULL
  DROP TABLE sales.MyShippers