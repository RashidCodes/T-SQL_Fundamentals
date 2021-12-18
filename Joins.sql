USE BikeStores
GO

/*
----- ------
TABLE JOINS
------------
Logical query processing describes a generic series of logical steps that for any specified query produces the correct result, whereas physical query
processing is the way the query is processed by the RDBMS engine in practice.

The database engine does not ahve to follow logicalquery processing phases literally, as long as it can guarantee tha tthe result that 
it produces is the same as that dictated by logical query processing.

CROSS JOINS (ANSI SQL-92 Syntax)
A cross join implements only one logical query processing phase - a Cartesian product. This phase operates on the two tables
provided as inputs to the join and produces a Cartesian product of the two.
------------
*/

SELECT C.customer_id, O.order_id
FROM sales.customers AS C 
  CROSS JOIN sales.order_items as O


SELECT count(*)
FROM sales.customers AS C
  CROSS JOIN production.products as P


-- SELF Cross Joins
SELECT * 
FROM sales.staffs

SELECT 
  E1.staff_id, E1.first_name, E1.last_name,
  E2.staff_id, E2.first_name, E2.last_name
FROM sales.staffs AS E1 
  CROSS JOIN sales.staffs AS E2


-- Algorithm: Producing numbers
IF OBJECT_ID('dbo.Digits', 'U') IS NOT NULL DROP TABLE dbo.Digits;
CREATE TABLE dbo.Digits(digit INT NOT NULL PRIMARY KEY);

-- INSERT the numbers
INSERT INTO dbo.Digits
   VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9);

-- one way to generate counting numbers
SELECT D4.digit * 1000 + D3.digit * 100 + D2.digit * 10 + D1.digit + 1 AS n
FROM dbo.Digits AS D1 
  CROSS JOIN dbo.Digits AS D2 
  CROSS JOIN dbo.Digits AS D3
  CROSS JOIN dbo.Digits AS D4
ORDER BY n

SELECT 
  D3.digit * 100 AS D3, 
  D2.digit * 10 AS D2, 
  D1.digit * 1 AS D1, 
  D3.digit * 100 + D2.digit * 10 + D1.digit + 1 AS Total
FROM dbo.Digits AS D1 
  CROSS JOIN dbo.Digits AS D2 
  CROSS JOIN dbo.Digits AS D3
ORDER BY Total


/* INNER JOINS (ANSI SQL 92 SYNTAX
The more formal way to think of a join based on relational algebra is that first, the join performs a Cartesian product of the two tables,
, and then filters rows based on the predicate O.product_id = P.product_id

As mentioned earlier, that's just the logical way that the join is processed; in practice, physical processing of the query by the database
engine can be different.
*/
-- Inner join between order_items and products

SELECT O.order_id, O.quantity, O.list_price, O.product_id, P.product_name
FROM sales.order_items AS O
  JOIN production.products AS P 
    ON O.product_id = P.product_id


/* COMPOSITE JOINS 
This is a join based on a predicate that involves more than one attribute from each side. */

-- cross sales.orders and production.products
SELECT ORDER_ITEMS.order_id, SALES_ORDERS.product_id, ORDER_ITEMS.quantity, ORDER_ITEMS.discount
FROM (
    SELECT O.order_id, O.order_status, O.order_date, P.product_id, P.product_name
    FROM sales.orders AS O 
        CROSS JOIN production.products AS P
) AS SALES_ORDERS
    INNER JOIN sales.order_items AS ORDER_ITEMS
      ON SALES_ORDERS.product_id = ORDER_ITEMS.product_id
        AND SALES_ORDERS.order_id = ORDER_ITEMS.order_id
ORDER BY SALES_ORDERS.order_id
OFFSET 0 ROWS FETCH FIRST 10 ROWS ONLY


/* Non-equi joins 
When a join condition involves only an equality operator, the join is said to be an equi join. When a join condition involves any operator
besides equality, the join is said to be a non-equi join.

The query below joins two instances of the sales.staff table to produce unique pairs of employees. Using an inner join with a join condition
that says taht the key in the left side must be smaller than the ky in the right side eliminates two inapplicable cases. 

1. Self pairs are eliminated because both sides are equal
2. With mirrored pairs, only one of the two cases qualifies because, of the two cases, only one will have a left key that is smaller
than the right key.
*/

SELECT 
  E1.staff_id, E1.first_name, E1.last_name,
  E2.staff_id, E2.first_name, E2.last_name
FROM sales.staffs AS E1
  INNER JOIN sales.staffs AS E2
    ON E1.staff_id < E2.staff_id

/* MULTI JOIN QUERIES
In general, when more than one table operator appears in the FROM clause, the table operators are logically processed from left to right.  So,
if there are multiple joins in the FROM clause, the first join operates on two base tables, but all otehr joins get the result of the preceding 
join as their left input */

SELECT 
  C.customer_id, C.first_name, C.last_name,
  O.order_id, O.order_status, OI.product_id,
  OI.list_price
FROM sales.orders AS O 
  JOIN sales.order_items OI
    ON O.order_id = OI.order_id 
  JOIN sales.customers AS C 
    ON O.customer_id = C.customer_id



/* OUTER JOINS
Outer joins apply the two logical procesing phases taht inner joins apply (Cartesian product and the ON filter), plus a third phase
called Adding Outer Rows that is unique to this type of join. In an outer join, you mark a table as "preserved" by using the keywords 
LEFT OUTER JOIN, RIGHT OUTER JOIN, or FULL OUTER JOIN. The OUTER keyword is optional.

Using the LEFT keyword means that the rows in the left table are preserved. Using the RIGHT keyword means that the rows in the RIGHT table
are preserved. Lastly, using the FULL keyword means that the rows in both the left and righ tables are preserved.

The third logical query processing phase of an outer join identifies the rows from the preserved table that did not find matches in the 
other table, based on the ON predicate. This phaes adds those rows to the result table produced by the first two phases of the join, and uses
the NULL marks as placeholders for attributes from the nonpreserved side of the join in those outer rows.

A good way to understand outer joins is through an example.

The following query joins the Customers and Orders tables based on a match between the customer's customer ID and ther order's customer ID,
to return customers and their orders. Here, the Customers table is the preserved table, and ther Orders table is the non-preserved table
 */

-- Find customers that have not placed any orders
SELECT C.customer_id, C.first_name, C.last_name, O.order_id 
FROM sales.customers AS C
  LEFT OUTER JOIN sales.orders AS O 
    ON C.customer_id = O.customer_id



-- find products that are not part of any order
SELECT P.product_id, P.product_name, P.list_price, O.order_id 
FROM production.products AS P 
  LEFT OUTER JOIN sales.order_items AS O 
    ON O.product_id = P.product_id
WHERE O.product_id IS NULL



/*

======= 
PROBLEM
=======
We want to get orders on each day since January 1, 2006 through to December 31, 2008.

*/

-- Generate dates in a specific range: Code will be replicated 
SELECT DATEADD(DAY, rownum-1, '20060101') AS orderdate
FROM (
    -- Create an auxilliary table of numbers ( my inefficient way )
    SELECT 
        ROW_NUMBER() OVER(PARTITION BY D5.digit ORDER BY D5.digit) AS rownum
    FROM dbo.Digits AS D1 
    CROSS JOIN dbo.Digits AS D2
    CROSS JOIN dbo.Digits AS D3 
    CROSS JOIN dbo.Digits AS D4
    CROSS JOIN dbo.Digits AS D5
    WHERE D5.digit = 0 AND D5.digit < 1100
) AS Nums
WHERE rownum <= DATEDIFF(DAY, '20060101', '20081231') + 1 
ORDER BY orderdate


-- Perform an outer join with the generated dates and the Orders table
SELECT 
    DATEADD(DAY, Nums.rownum - 1, '20160101') AS orderdate, 
    O.order_id, 
    O.customer_id, 
    O.staff_id
FROM (
    -- Create an auxilliary table of numbers: Replicated code from above
    SELECT 
        ROW_NUMBER() 
            OVER(PARTITION BY D5.digit ORDER BY D5.digit) AS rownum
    FROM dbo.Digits AS D1 
    CROSS JOIN dbo.Digits AS D2
    CROSS JOIN dbo.Digits AS D3 
    CROSS JOIN dbo.Digits AS D4
    CROSS JOIN dbo.Digits AS D5
    WHERE D5.digit = 0 AND D5.digit <= 1096
) AS Nums
    LEFT OUTER JOIN sales.orders AS O 
    ON DATEADD(DAY, Nums.rownum-1, '20160101') = O.order_date
WHERE 
  rownum <= DATEDIFF(DAY, '20160101', '20181231') + 1 
ORDER BY orderdate


/* 

When you need to revise code involving outer joins to look for logical bugs, one of the things you should examine is the WHERE clause.
If the predicate in the WHERE clause refers to an attribute from the nonpreserved side of the join using an expression in the form
<attribute> <operator> <value>, it's usually an indication of a bug.

This is because attributes from the nonpreserved side of the join are NULL marks in outer rows, and an expression in the form 
NULL <operator> <value> yields UNKNOWN (unless it's the IS NULL operator explicitly looking for NULL marks).

Be careful with the attributes in the nonpreserved table!

The code below only produces the inner rows and neglects all outer rows because rows that have a NULL order_date will be filtered out. This 
effectively makes this code an INNER join.

*/

-- Revise the predicate
SELECT C.customer_id, C.first_name, C.last_name, O.order_date
FROM sales.customers AS C 
  LEFT JOIN sales.orders AS O 
    ON C.customer_id = o.customer_id 
WHERE O.order_date  >= '20160101'


/*
*=======*========*========*======*======
Using Outer Joins in a Multi-Join Query
*=======*========*========*======*======

Remember than outer rows have nULL marks in the attributes from the nonpreserved side of the join, and comparing a NULL with anything yields
UNKNOWN. UNKNOWN will be filtered out by the ON filter. In other words, such a predicate would nullify the outer join, and logically it would
be as if you specified an inner join.
*/

-- The goal is to find all customers that don't have any orders. We want to see the NULL values
SELECT C.customer_id, O.order_id, OD.product_id, OD.list_price 
FROM 
  sales.customers AS C 
  LEFT OUTER JOIN sales.orders as O 
    ON C.customer_id = O.customer_id 
  JOIN sales.order_items AS OD 
    ON O.order_id = OD.order_id -- predicate contains the outer join, this is not good



-- One way to solve this problem would be to use a left join with the OD table
SELECT C.customer_id, O.order_id, OD.product_id, OD.list_price 
FROM 
  sales.customers AS C 
  LEFT OUTER JOIN sales.orders as O
    ON C.customer_id = O.customer_id
  LEFT OUTER JOIN sales.order_items AS OD 
    ON O.order_id = OD.order_id


-- WE can also join the orders and order_items tables before joining to the sales.customers table 
SELECT O.order_id, C.customer_id, C.first_name
FROM 
  sales.orders as O 
  JOIN sales.order_items AS OD 
    ON O.order_id = OD.order_id 
  RIGHT OUTER JOIN sales.customers AS C 
    ON O.customer_id = C.customer_id


-- You can also turn the inner join between sales.orders and sales.order_items to a logical phase
SELECT * 
FROM sales.customers AS C
LEFT JOIN 
    (
        -- Independent logical phase
       sales.orders AS O
        JOIN sales.order_items AS OI 
            ON O.order_id =  OI.order_id
    )
ON C.customer_id = O.customer_id




/* Using the COUNT aggregate with outer joins
When you group the result of an outer join and use the COUNT(*) aggregate, the aggregate takes into consideration both inner
rows and outer rows, because it counts rows regardless of their contents. Usually, you're not supposed to take outer rows into consideration 
for the purposes of counting.

The COUNT(*) aggregate function cannot detect whether a row really represents an order. To fix the problem, you should use COUNT(<column>)
instead of COUNT(*), and provide a column from the NONPRESERVED side of the join. 
This way the COUNT() aggregate ignores outer rows because they have a NULL in that column.

 */

-- find products that are not part of any order
SELECT 
    P.product_id, 
    P.product_name, 
    COUNT(O.product_id) AS pricecount -- the NULL aggregate does not count NULL values
FROM production.products AS P 
  LEFT OUTER JOIN sales.order_items AS O 
    ON O.product_id = P.product_id
WHERE O.product_id IS NULL    
GROUP BY P.product_id, P.product_name



