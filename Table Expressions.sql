USE BikeStores 
GO

/* Table expressions

A table expression is a named query expression that represents a valid relational table. Microsoft SQL Server supports 4 types of tables
 - derived tables
 - Common table expressions
 - Views
 - Inline table-valued functions 

 DERIVED TABLES
 --------------
 Derived tables are defined in the FROM clause of an outer query. Their scope of existence is the outer query. As soon as the outer query,
 is finished, the derived table is gone.

 */

 SELECT * 
 FROM (SELECT O.order_id, O.list_price
       FROM sales.order_items AS O) AS Orders;


/* REQUIREMENTS TO BE A VALID TABLE EXPRESSION 

1. Order is not guaranteed: A table expression is supposed to represent a relational table, and the rows in a relational table have no guaranteed order. For this reason, standard 
SQL DISALLOWS an ORDER BY clause in queries that are used to define table expressions, unless the ORDER BY serves another purpose besides presentation. An example for such an exception
is whe the qeury uses the OFFSET-FETCH filter. In the context of a query with the TOP or OFFSET-FETCH filter, the ORDER BY clause serves as part of the specification of the filter.

If you use a query with TOP or OFFSET-FETCH and ORDER BY to define a table expression, ORDER BY is only guaranteed to server the filtering-related purpose and not the usual presentation
purpose.

If the outer query against the table expression does not have a presentation ORDER BY, the output is not guaranteed to be returned in any particular order.


2. All columns must have names

3. All column names must be unique: you can use column aliasing to achieve this

All three requirements have to do with the fact that the table expression is supposed to represent a relation.
*/

--============-==============-================-================-================-=================-==============
/* COMMON TABLE EXPRESSIONS
The inner query defining the CTE must folow all requirements mentioned earlier to be valid to define a table expression. 
As with derived tables, as soon as the outer query finishes, the CTE goes out of scope.

The WITH clause is used to T-SQL for several different purposes. To avoid ambiguity, when the WITH clause is used to define a CTE, the preceding statement in the same batch -- if one 
exists-- must be terminated with a semicolon. In fact terminate all your statements with a semicolon.
*/

WITH NewYorkCust AS 
(
      SELECT customer_id, first_name 
      FROM sales.customers 
      WHERE city = N'New York'
)
select * from NewYorkCust; -- <outer query is required>


/* Column Aliasing with CTE's */
WITH C AS 
(
      SELECT YEAR(order_date) AS orderyear, customer_id 
      FROM sales.orders
)
SELECT orderyear, COUNT(DISTINCT customer_id) AS numcusts 
FROM C 
GROUP BY orderyear;


-- External form 
WITH C(orderyear, customer_id) AS 
(
      SELECT YEAR(order_date) AS orderyear, customer_id
      FROM sales.orders 
)
SELECT orderyear, COUNT(DISTINCT customer_id) AS numcusts 
FROM C 
GROUP BY orderyear;


-- DEFINING Multiple CTEs
WITH C1 AS 
(
      SELECT YEAR(order_date) AS orderyear, customer_id 
      FROM sales.orders
),
C2 AS 
(
      SELECT orderyear, COUNT(DISTINCT customer_id) AS numcusts
      FROM C1 
      GROUP BY orderyear
)
SELECT orderyear, numcusts 
FROM C2 
WHERE numcusts > 70


/* Multiple References in CTE's 
The fact that a CTE is defined first and then quries has another advantage: As far as the FROM clause of the outer query is concerned,
the CTE already exists; therefore you can refer to multiple instances of the same CTE. 

*/

WITH YearlyCount AS 
(
      SELECT YEAR(order_date) AS orderyear,
        COUNT(DISTINCT customer_id) AS numcusts 
      FROM sales.orders 
      GROUP BY YEAR(order_date)
)
SELECT Cur.orderyear, 
  Cur.numcusts AS curnumcusts, Prv.numcusts AS prvnumcusts,
  Cur.numcusts - Prv.numcusts AS growth 
FROM YearlyCount AS Cur 
  LEFT OUTER JOIN YearlyCount AS Prv 
    ON Cur.orderyear = Prv.orderyear + 1



/* RECURSIVE CTE's
A recursive CTE is defined by at least two queries (more are possible) -- at least one query known as the anchor member and at least
one query known as the recursive member.
 */
select * from sales.staffs;

WITH StaffCTE AS 
(
      SELECT staff_id, first_name, last_name, phone
      FROM sales.staffs 
      WHERE staff_id = 1

      UNION ALL 

      SELECT C.staff_id, C.first_name, C.last_name, C.phone
      FROM StaffCTE as  P 
        JOIN sales.staffs AS C 
          ON P.staff_id = C.manager_id
)
SELECT staff_id, first_name, last_name
FROM StaffCTE;


/* VIEWS
Views are a reusable type of table expressions. In most other respects, views are treated like derived tables and CTE's For example, when
querying a view or an inline TVF, SQL Server expands the definition of the table expression and queries the underlying objects directly,
as with derived tables and CTE's. 

Because a view is an object in the database, you can control access to the view with permissions just as you can with other objects
than can be queried (those permissions include SELECT, INSERT, UPDATE, and DELETE permissions)

Note that the general recommendation to avoid using SELECT * has specific relevance inthe context of views. The columns are enumerated in the
compiled form of the view, and new table columns will not be automatically added to the view (If you alter the definition of the table to
add new columns, those new columns will not be added to the view.)

You can refresh the view's meta data by using the stored procedure sp_refreshview or sp_refeshsqlmodule, but to avoid confusion, the best 
practice is to explicitly list the column names that you need in the definition of the view.
*/
IF OBJECT_ID('sales.NewYorkCusts', 'U') IS NOT NULL 
  DROP VIEW sales.NewYorkCusts;
GO

CREATE VIEW sales.NewYorkCusts 
AS

SELECT 
  customer_id, first_name, last_name, phone 
FROM sales.customers 
WHERE city = N'New York'
GO

-- Query the view
SELECT * 
FROM sales.NewYorkCusts


/* VIEWS and the ORDER BY Clause

The query that you use to define a view must meet all requirements mentioned earlier with respect to table expressions in the context of
derived tables. 
- The view should not guarantee any order to the rows
- All columns must have names 
- All column names must be unique 

An attempt to create an ordered view is absurd because it violates fundamental properties of a relation as defined by the relational model. 
If you need to return rows from a view sorted for presentation purposes, YOU SHOULDN'T TRY TO MAKE A VIEW SOMETHING IT SHOULDN'T BE! Instead,
you should specify a presentation ORDER BY clause in the outer query against the view.

*/
IF OBJECT_ID('sales.TestView', 'U') IS NOT NULL 
   DROP VIEW sales.TestView
GO

CREATE VIEW sales.TestView 
AS 

SELECT 
   customer_id, first_name, last_name, phone 
FROM sales.customers 
ORDER BY customer_id -- We get an error
GO


/* Because T-SQL allows an ORDER BY clause in a view when TOP or OFFSET-FETCH is also specified, some people think that they can create
"ordered views". One of the ways to achieve this is by using TOP (100) PERCENT
*/

ALTER VIEW sales.NewYorkCusts
AS 

SELECT TOP (100) PERCENT 
  customer_id, first_name, last_name, phone 
FROM sales.customers 
ORDER BY first_name 
GO


/* Even though the code is technically valid, and the view is created, you should be aware that because the query is used to define a table
expression, the ORDER BY clause here is only guaranteed to serve the logical filtering purpose for the TOP option.

IF YOU QUERY THE VIEW AND DON'T SPECIFY AN ORDER BY CLAUSE IN THE OUTER QUERY, presentation order is NOT guaranteed.
*/


SELECT customer_id, first_name, last_name, phone 
FROM sales.NewYorkCusts -- We can see that the resultset was NOT sorted by first_name 
GO

/* In SQL Server 2012, there's a new to try to get a "sorted view", by using the OFFSET clause with 0 ROWS, and without a FETCH clause */
ALTER VIEW sales.NewYorkCusts 
AS 

SELECT TOP(100) PERCENT 
  customer_id, first_name, last_name, phone 
FROM sales.customers 
ORDER BY first_name 
GO


/* VIEW OPTIONS 

ENCRYPTION
The ENCRYPTION option indicates that SQL Server will internally store the text with the definition of the object in an obfuscated format. The
obfuscated text is not directly visible to users through any of the catalog objects - only to privileged users through special means
*/
IF OBJECT_ID('sales.NewYorkCusts') IS NOT NULL 
  DROP VIEW sales.NewYorkCusts;
GO

CREATE VIEW sales.NewYorkCusts 
AS

SELECT 
  customer_id, first_name, last_name, phone 
FROM sales.customers 
WHERE city = N'New York'
GO
 

-- Get the definition of the view 
SELECT OBJECT_DEFINITION(OBJECT_ID('sales.NewYorkCusts')) -- The text definition of the view is available because the view was created without the 
-- ENCRYPTION option 
GO


-- Let's alter the view by setting the ENCRYPTION OPTION 
ALTER VIEW sales.NewYorkCusts WITH ENCRYPTION 
AS

SELECT
  customer_id, first_name, last_name, phone 
FROM sales.customers 
WHERE city = N'New York'
GO

SELECT OBJECT_DEFINITION(OBJECT_ID('sales.NewYorkCusts')) -- This now returns NULL 
GO

-- You can also use the sp_helptext Stored procedure to get object definitions 
EXEC sp_helptext 'sales.NewYorkCusts'
GO

/* SCHEMABINDING option 
The SCHEMABINDING option is available to views and UDFs; it binds the schema of referenced objects and columns to the schema
of the referencing object. It indicates that referenced objects cannot be dropped and that referenced columns cannot be dropped or altered!

-- To support the SCHEMABINDING option, the object definition must meet a couple of technical requirements 
1. The query is not allowed to use * in the SELECT clause; instead, you have to explicitly list column names 
2. You must use schema-qualified two-part names when referring to objects

Both requirements are actually good practices in general.
*/

ALTER VIEW sales.NewYorkCusts WITH SCHEMABINDING 
AS

SELECT
  customer_id, first_name, last_name, phone 
FROM sales.customers 
WHERE city = N'New York'
GO

ALTER TABLE sales.customers DROP COLUMN first_name -- Error
GO

/* CHECK option 
The purpose of CHECK OPTION is to prevent modifications through the view that conflict with the view's filter -- assuming that one exists in
the query defining the view.

The query defining the view NewYorkCusts filters customers whose city attribute is equal to N'New York'. The view is currently defined
without the CHECK OPTION. This means that you can currently insert rows through the view with customers from cities other than New York, and
you can update existing customers through the view, changing their city to one other than New York.
*/

ALTER VIEW sales.NewYorkCusts 
AS

SELECT
  customer_id, first_name, last_name, phone, 
  email, street, city, "state", zip_code
FROM sales.customers 
WHERE city = N'New York'
GO

-- Insert data into the Customers table using the sales.NewYorkCusts View */

INSERT INTO sales.NewYorkCusts (
      first_name, last_name, phone, email, street, city, "state", zip_code)
VALUES (
      N'rashid', N'Mohammed', N'(505)-888-999', 'rashid@email.com', N'West Street', N'Accra', N'Greater-Accra', N'4350')

/*The row was inserted through the view into the Customers table. However, because the view filters only customers from the United States,
if you query the view looking for the new customer, you get an empty set back */

SELECT * 
FROM sales.NewYorkCusts 
WHERE first_name = N'rashid' -- empty set

-- Even though the the new customer was actually added
SELECT * FROM sales.customers 
WHERE first_name = N'rashid'
GO

/* If you want to prevent modifications that conflict with the view's filter, add WITH CHECK OPTION at the end of the query defining the view */
ALTER VIEW sales.NewYorkCusts WITH SCHEMABINDING
AS

SELECT
  customer_id, first_name, last_name, phone, 
  email, street, city, "state", zip_code
FROM sales.customers 
WHERE city = N'New York'
WITH CHECK OPTION;
GO

-- Now this does not work because the new customer is not from New York
INSERT INTO sales.NewYorkCusts (
      first_name, last_name, phone, email, street, city, "state", zip_code)
VALUES (
      N'Maria', N'Mohammed', N'(505)-888-999', 'maria@email.com', N'West Street', N'Accra', N'Greater-Accra', N'4350')

-- But this does
INSERT INTO sales.NewYorkCusts (
      first_name, last_name, phone, email, street, city, "state", zip_code)
VALUES (
      N'Maria', N'Mohammed', N'(505)-888-999', 'maria@email.com', N'West Street', N'New York', N'Greater-Accra', N'4350')

-- non empty
SELECT * 
FROM sales.NewYorkCusts 
WHERE first_name = N'Maria' -- empty set


-- Clean up
DELETE FROM sales.customers 
WHERE customer_id IN (1447, 1448)



/* Inline Table-Valued functions 
These are table expressions that support input parameters. In all respects except for the support for input parameters, inline TVFs are similar
to views. For this reason, I like to think of inline TVFs as parameterized views, even though they are not called this formally.

*/

IF OBJECT_ID('dbo.GetCustOrders') IS NOT NULL  
   DROP FUNCTION dbo.GetCustOrders
GO
CREATE FUNCTION dbo.GetCustOrders 
  (@cust_id AS INT) RETURNS TABLE 
AS
RETURN
  SELECT order_id, customer_id, order_status,
    order_date, required_date, shipped_date, 
    store_id, staff_id
  FROM sales.orders 
  WHERE customer_id = @cust_id

GO

-- Query a TVF using normal DML statements, the same way you query other tables
SELECT order_id, customer_id, order_date, shipped_date 
FROM dbo.GetCustOrders(2) as G


/* As with other tables, you can refer to an inline TVF as part of a join. */

SELECT C.first_name, C.last_name, C.city, T.order_date, T.shipped_date
FROM dbo.GetCustOrders(2) AS T 
  JOIN sales.customers as C 
    ON T.customer_id = C.customer_id 

-- Clean up
IF OBJECT_ID('dbo.GetCustOrders') IS NOT NULL
  DROP FUNCTION dbo.GetCustOrders




/* The Apply Operator 
There are two supported types of APPLY operators namely:
 - CROSS APPLY
 - OUTER APPLY 

 Note that APPLY isn't standard; the standard counterpart is called LATERAL, but the standard form wasn't implemented in SQL Server. The 
 APPLY operator operates on two input tables, the second of which can be a table expression; Let's refer to them as "left" and "right" 
 tables. The right table is usually a derived table or an inline TVF.

 CROSS APPLY OPERATOR
 The cross apply operator implements one logical query processing phase - it applies the right table expression to each row from the 
 left table and produces a result table with the unified result sets.
 */

 SELECT C.customer_id, A.order_id, A.order_date 
 FROM sales.customers AS C 
   CROSS APPLY
      (SELECT TOP (3) order_id, staff_id, order_date, shipped_date 
       FROM sales.orders AS  O 
       WHERE O.customer_id = C.customer_id 
       ORDER BY order_date DESC, order_id DESC) AS A 


-- You can also use the OFFSET-FETCH filter instead of TOP 
SELECT C.customer_id, A.order_id, A.order_date 
FROM sales.customers AS C 
  CROSS APPLY 
    (SELECT order_id, staff_id, order_date, shipped_date
    FROM sales.orders AS  O
    WHERE O.customer_id = C.customer_id 
    ORDER BY order_date DESC, order_id DESC
    OFFSET 0 ROWS FETCH FIRST 3 ROWS ONLY) AS A


/* If the right table expression returns an empty set, the CROSS APPLY operator does not return the corresponding left row.
*/
SELECT P.product_id 
FROM production.products AS P
WHERE P.product_id  NOT IN 
  (SELECT DISTINCT O.product_id 
  FROM sales.order_items AS O)


SELECT P.product_id 
FROM production.products AS P 
WHERE NOT EXISTS (
      SELECT O.product_id 
      FROM sales.order_items AS O 
      WHERE O.product_id = P.product_id)



GO


-- Find the top 3 most recent orders for each customer
IF OBJECT_ID('sales.joinOrdersAndItems') IS NOT NULL 
   DROP VIEW sales.joinOrdersAndItems
GO

CREATE VIEW sales.joinOrdersAndItems 
AS 

SELECT O.order_id, O.customer_id, OI.product_id, P.product_name, O.order_date, OI.list_price
FROM sales.orders AS O
  JOIN sales.order_items as OI
    ON O.order_id = OI.order_id 
  JOIN production.products AS P
    ON OI.product_id = P.product_id 

GO

SELECT C.customer_id, C.first_name, A.orderid, A.orderdate
FROM sales.customers AS C
  CROSS APPLY 
    (SELECT TOP (3) order_id AS orderid,
            order_date AS orderdate 
    FROM sales.joinOrdersAndItems AS OI
    WHERE OI.customer_id = C.customer_id
    ORDER BY orderdate DESC, orderid DESC) AS A

-- Clean up
IF OBJECT_ID('sales.joinOrderAndItems') IS NOT NULL 
   DROP VIEW sales.joinOrdersAndItems


/* THE OUTER APPLY OPERATOR
If the right table expression returns an empty set, the CROSS APPLY operator does not return the corresponding left row. If you want to return rows from the left table
for which the right table expression returns an empty set, use the OUTER APPLY operator instead of CROSS APPLY. 

The OUTER APPLY operator adds a second logical phase that identifies rows from the left side for which the right table expression returns an empty set, and it adds those rows
to the result table as outer rows with NULL marks in the right side's attributes as placeholders. In a sense, this phase is similar to the phase that adds outer rows in a 
left outer join.
*/
SELECT C.customer_id, C.first_name, A.orderid, A.orderdate
FROM sales.customers AS C
  OUTER APPLY 
    (SELECT TOP (3) order_id AS orderid,
            order_date AS orderdate 
    FROM sales.joinOrdersAndItems AS OI
    WHERE OI.customer_id = C.customer_id -- Rows on the left for which the right table is empty are returned.
    ORDER BY orderdate DESC, orderid DESC) AS A
WHERE orderid IS NULL
GO


/* For encapsulation purposes, let's make the right table an inline TVF 
The function accepts as inputs a customer ID (@custid) and a number (@n), and returns the @n most recent orders for customer @custid
*/

IF OBJECT_ID('dbo.TopOrders') IS NOT NULL
   DROP FUNCTION dbo.TopOrders;
GO

CREATE FUNCTION dbo.TopOrders
  (@custid AS INT, @n AS INT)
  RETURNS TABLE 

AS
RETURN 
  SELECT TOP (@n) customer_id AS custid, 
     order_id AS orderid, 
     order_date AS orderdate 
  FROM sales.joinOrdersAndItems AS OI 
  WHERE OI.customer_id = @custid 
  ORDER BY orderdate DESC, orderid DESC;
GO

-- We can now substitute the use of the derived table from the previous examples with the new function 
SELECT C.customer_id, C.first_name, A.orderid, A.orderdate
FROM sales.customers AS C
  OUTER APPLY dbo.TopOrders(C.customer_id, 3) AS A
WHERE orderid IS NULL
GO