USE BikeStores
GO

SELECT *
FROM production.brands

SELECT TOP 10 YEAR(shipped_date) shipYear
FROM sales.orders

SELECT *
FROM sales.customers

SELECT TOP 0.1 PERCENT * 
FROM sales.order_items

SELECT order_id, COUNT(product_id) as numOfProducts, SUM(list_price) sumOfListPrice
FROM sales.order_items
WHERE order_id = 3
GROUP BY order_id
HAVING COUNT(product_id) > 1
ORDER BY numOfProducts;

-- Standard delimiting
SELECT DISTINCT("product_id")
FROM sales.order_items;

-- SQL Server delimiting
SELECT DISTINCT([product_id])
FROM sales.order_items

-- THE GROUP BY: This means that the GROUP BY phase produces a group for each uniuq combination of employee ID
SELECT 
  order_id,
  COUNT(product_id) as numOfProducts, 
  SUM(list_price) sumOfListPrice
FROM sales.order_items
GROUP BY order_id
HAVING COUNT(product_id) > 4 AND SUM(list_price) > 12000
ORDER BY order_id ASC;


-- THE HAVING CLAUSE
-- Having is used to filter groups as opposed to the WHERE clause which filters rows

select distinct product_id, order_id
from sales.order_items

select list_price 
from sales.order_items

--=====================
-- OFFSET-FETCH FILTER
--=====================
-- Note that a query that uses OFFSET-FETCH must have an ORDER BY clause.
-- This clause supports skipping capabilities
-- The OFFSET: You can indicate how many rows to skip
-- THE FETCH: You can indicate how many rows to filter after the skipped rows
SELECT 
  customer_id,
  first_name,
  last_name,
  email
FROM sales.customers
ORDER BY first_name
OFFSET 50 ROWS FETCH NEXT 25 ROWS ONLY;

SELECT
  customer_id,
  first_name,
  last_name,
  email 
FROM sales.customers
ORDER BY first_name
OFFSET 0 ROWS FETCH FIRST 1 ROW ONLY



/* 
=================================
A QUICK LOOK AT WINDOW FUNCTIONS
=================================
A window function is a function that, for each row in the underlying query, operates on a window (set) of rows and computes a scalar (single) result value.
The window of rows is defined by using an OVER clause. The OVER clause can restrict the rows in the window by using the PARTITION BY subclause, and it can define ordering
for the calculation if necessary by using the ORDER BY subclause (not to be confused with the query's presentation ORDER BY clause) 

The ROW_NUMBER function assigns unique, sequential, incrementing integers to the rows in the result within the respective partition, based on the indicated ordering.

*/

SELECT order_id, item_id, list_price,
  ROW_NUMBER() OVER(PARTITION BY order_id
                      ORDER BY list_price) AS rownum 
FROM sales.order_items
ORDER BY order_id, list_price


/* 
=========================
PREDICATES AND OPERATORS
=========================
Predicates are logical expressions that evaluate to TRUE, FALSE, or UNKNOWN
*/

-- IN operator
SELECT 
  order_id,
  item_id,
  quantity,
  list_price 
FROM sales.order_items
WHERE order_id IN (1, 2, 3)


-- BETWEEN operator
SELECT 
  order_id,
  item_id,
  quantity,
  list_price
FROM sales.order_items
WHERE order_id BETWEEN 1 AND 5


-- LIKE operator
SELECT
  customer_id,
  first_name,
  last_name,
  email
FROM sales.customers
WHERE last_name LIKE N'D%'

-- Using parentheses to force precedence with logical operators
SELECT order_id, item_id, quantity, list_price
FROM sales.order_items
WHERE 
    (item_id = 1 AND order_id IN (1, 3, 5))
    OR
    (item_id = 2 AND order_id IN (2, 4, 6))


/*
=================
CASE Expressions
=================
Note that CASE is an expression NOT a statement; that is, it doesn't let you control flow of activity or do something based on conditional logic. Instead
the value it returns is based on conditional logic.
*/

/* Unless the set of categories is very small and static, your best design choice is probably to maintain the product categories in a table, and join that table
with the staffs table. 
*/

-- Simple Case form
SELECT staff_id, first_name, last_name, 
  CASE store_id
     WHEN 1 THEN 'Big Store'
     WHEN 2 THEN 'Medium Store'
     WHEN 3 THEN 'Small Store'
     ELSE 'Unknown Category'
  END AS storeCategory
FROM sales.staffs 


-- SEARCHED Case Form
SELECT order_id, item_id, list_price,
  CASE
     WHEN list_price <= 500 THEN 'Medium Price'
     WHEN (list_price > 500) AND (list_price <= 1000) THEN 'High Price'
     ELSE 'Unknown Price Category'
  END AS priceCategory
FROM sales.order_items 
WHERE order_id IN (1, 2, 3, 4)
ORDER BY order_id
OFFSET 0 ROWS FETCH FIRST 10 ROWS ONLY 


-- Using the CASE Clause in the WHERE Clause
-- SQL guarantees the processing order of the WHEN clauses in the CASE expression
SELECT col1, col2
FROM dbo.T1
WHERE
  CASE 
     WHEN col1 = 0 THEN 'no'
     WHEN col2/col1 > 2 THEN 'yes'
     ELSE 'no'
    END = 'yes'

-- You can use a mathematical workaround to avoid this division altogether
SELECT col1, col2 
FROM dbo.T1
WHERE (col1 > 0 AND col2 > 2*col1)
  OR (col 1 < 0 AND col2 < 2*col1)


/* 
============================
WORKING WITH CHARACTER DATA
============================
*/

/*
========= 
Collation
=========
Collation is a property of character data that encapsulates several aspects, including language support, sort ordre, case sensitivity, acent sensitivity, and more. */

-- Use this query to get the supported collation and their descriptions
SELECT name, description
FROM sys.fn_helpcollations()
WHERE name like 'Latin%'

-- Convert the collation of an expression by using the COLLATE clause: Case insensitive matching
SELECT customer_id, first_name, last_name
FROM sales.customers
WHERE last_name = N'burks'

-- Case sensistive matching
SELECT customer_id, first_name, last_name
FROM sales.customers
WHERE last_name COLLATE Latin1_General_CS_AS = N'burk'


/* 
========================
OPERATORS AND FUNCTIONS
======================== */
SELECT CHARINDEX(' ', 'Itzik Ben-Gan')
SELECT PATINDEX('%[0-9]%', 'abcd123efgh')

-- Replace all occurrences of string1 in string with substring2
-- You can also use the REPLACE function to count the number of occurrences of a character using the code below
SELECT LEN('1-a 2-b') - LEN(REPLACE('1-a 2-b', '-', ''))


SELECT REPLICATE('rashid ', 3)

-- The STUFF function
-- The STUFF function allows you to remove a substring from a string and isnert a new substring instead.
SELECT STUFF('xyz', 2, 1, 'abc')

-- The FORMAT function
-- The FORMAT function allows you to format an input value as a character string based on a Microsoft .NET format string and an optional culture
SELECT FORMAT(1759, '00000000')


/*
==================
The LIKE Predicate
==================
LIKE allows you to check whether a character string matches a specified pattern. Note that often you can use function such as SUBSTRING and lEFT instead of 
the lIKE predicate to represent the same meaning. But the LIKE predicate tends to get optimized better - especially when the pattern starts with a known prefix
*/
SELECT customer_id, first_name, last_name
FROM sales.customers 
WHERE last_name LIKE N'D%'

-- The _ (Underscore) wildcard
SELECT customer_id, first_name, last_name
FROM sales.customers
WHERE last_name LIKE N'_e%'

-- The [<List of Characters>] Wildcard
SELECT customer_id, last_name 
FROM sales.customers 
WHERE last_name LIKE N'[AB]%'

-- Character range and opposites
-- Square brackets with a caret sign (^) followed by a character list or range (such as [^A-E]) represent a single character that is NOT in specified character list or range.
SELECT customer_id, last_name
FROM sales.customers 
WHERE last_name LIKE N'[^A-Y]%'

-- Match underscores in the last name
SELECT customer_id, last_name
FROM sales.customers
WHERE last_name LIKE N'%!_%'


/* 
===========================
WORKING WITH DATA AND TIME
===========================
It is important to note that some character string formats of date and time literals are language dependent, meaning that when you convert them to a date and time data type,
SQL server might interpret the value differently based on the language setting in effect in the session.
You can overwrite the default language in yoursession by using the SET LANGUAGE command, but this is generally not recommended because some aspects of the code 
might rely on the user's default language.
*/

/* Language dependent formats*/
SET LANGUAGE British;
SELECT CAST('02/12/2007' AS DATETIME)

SET LANGUAGE us_english;
SELECT CAST('02/12/2007' AS DATETIME)


/* Language neutral formats */
SET LANGUAGE British;
SELECT CAST('20070212' AS DATETIME);

SET LANGUAGE us_english;
SELECT CAST('20070212' AS DATETIME);

/* If you insist on using a language dependent format */
-- CONVERT using a specific style
SELECT CONVERT(DATETIME, '02/12/2007', 101) -- MM/DD/YY
SELECT CONVERT(DATETIME, '02/12/2007', 103) -- DD/MM/YY

-- You can also use the PARSE function
SELECT PARSE('02/12/2012' AS DATETIME USING 'en-US')
SELECT PARSE('02/12/2012' AS DATETIME USING 'en-GB')

SELECT * 
FROM sales.orders
WHERE order_date = '20160101'

-- If the time component is stored with non-midnight values
SELECT *
FROM sales.orders 
WHERE order_date >= '20160101'
   AND order_date < '20160102'


/* FILTERING DATE RANGES
To have the potential to use an index efficiently, you need to revise the predicate so that there there is no manipulation on the filtered column
*/

-- Inefficient
SELECT order_id, order_status, order_date
FROM sales.orders
WHERE YEAR(order_date) = 2016; -- manipulation in the filtered column

/* Similarly, instead of using functiosn to filter orders placed in a particular month like this*/

SELECT order_id, customer_id 
FROM sales.orders
WHERE YEAR(order_date) = 2016 AND MONTH(order_date) = 2

-- use a range filter instead (MUCH BETTER)
SELECT order_id, customer_id, order_date
FROM sales.orders
WHERE order_date >= '20160201' AND order_date < '20160301'


/* DATE AND TIME FUNCTIONS
The following niladic (parameterless) functions return the current date and time values in the system where the SQL Server Instance resides */

SELECT 
   GETDATE() AS [GETDATE],
   CURRENT_TIMESTAMP AS [CURRENT_TIMESTAMP],
   GETUTCDATE() AS [GETUTCDATE],
   SYSDATETIME() AS [SYSDATETIME],
   SYSUTCDATETIME() AS [SYSUTCDATETIME],
   SYSDATETIMEOFFSET() AS [SYSDATETIMEOFFSET];

-- You can get the current date and time separately as follows
SELECT 
   CAST(GETDATE() AS DATE) AS [current_date],
   CAST(GETDATE() AS TIME) AS [current_time]

-- Convert the current date and time value to CHAR(8) by using 112 - ('YYYYMMDD')
SELECT CONVERT(CHAR(8), CURRENT_TIMESTAMP, 112)

-- Zero out the time and keep the date only
SELECT CAST(CONVERT(CHAR(8), CURRENT_TIMESTAMP, 112) AS DATETIME)

-- Zero out the date and keep the time only: Culture = 114 (hh:mm:ss.nnn)
SELECT CAST(CONVERT(CHAR(12), CURRENT_TIMESTAMP, 114) AS DATETIME)

-- The SWITCHOFFSET function
-- The SWITCHOFFSET function adjusts an ipnut DATETIMEOFFSET value to a specified time zone.
SELECT SWITCHOFFSET(SYSDATETIMEOFFSET(), '+10:00')

-- The TODATETIMEOFFSET Function: Create a datetimeoffset value which can be used with switchoffset
SELECT TODATETIMEOFFSET(GETDATE(), '+00:00')
SELECT SWITCHOFFSET(TODATETIMEOFFSET(GETDATE(), '+00:00'), '+10:00')


-- The DATEADD function
-- Algorithm: Set the time component of the current system date and time value to midnight
SELECT 
  DATEADD(
    day, 
    DATEDIFF(day, '20010101', CURRENT_TIMESTAMP), '20010101')


-- Algorithm: Get the first day of the month
SELECT
    DATEADD(
        month,
        DATEDIFF(
            month, '20010101', CURRENT_TIMESTAMP
        ),
        '20010101'
    )

-- Get the last day of the current month
SELECT
    DATEADD(
        MONTH,
        DATEDIFF(
            MONTH, '19991231', CURRENT_TIMESTAMP
        ),
        '19991231'
    )

-- The DATEPART, YEAR, MONTH, and DAY functions
-- The DATEPART function returns an integer representing a requested part of a date and time value 
SELECT DATEPART(MONTH, CURRENT_TIMESTAMP)
SELECT  
  YEAR(CURRENT_TIMESTAMP) AS [Year], 
  MONTH(CURRENT_TIMESTAMP) AS [Month],
  DAY(CURRENT_TIMESTAMP) AS [Day]


-- DATENAME function
SELECT DATENAME(MONTH, CURRENT_TIMESTAMP)

-- ISDATE function
-- Check if a character string is convertible to a date and time datatype
SELECT ISDATE('20020101')
SELECT ISDATE('RASHID')

-- The FROMPARTS functions
-- Used to construct the date and time from integer inputs
SELECT 
  DATEFROMPARTS(2012, 02, 12),
  DATETIME2FROMPARTS(2012, 02, 12, 13, 30, 5, 1, 7),
  DATETIMEOFFSETFROMPARTS(2012, 02, 12, 13, 30, 5, 1, -8, 0, 7)

-- The EOMONTH function
-- It accepts an input date and time value and returns the respective end-of-month date, at midnight, as a DATE data type.
SELECT EOMONTH(SYSDATETIME())

-- You can add days to the end of the month
SELECT EOMONTH(SYSDATETIME(), 5)

SELECT order_id, order_date
FROM sales.orders
WHERE order_date = EOMONTH(order_date)


-- Querying Metadata
/* SQL Server provides tools for getting information about the metadata of objects, such as
 - Information about tables
 - Informations about columns

These tools include catalog views, information schema views, and system stored procedures and functions.


CATALOG VIEWS
---------------
*/
-- List the tables in the database along with their schema names
SELECT SCHEMA_NAME(schema_id) AS table_schema_name, name AS table_name
FROM sys.tables

-- Get information about columns in a table
SELECT
  name AS column_name,
  TYPE_NAME(system_type_id) AS column_type,
  max_length,
  collation_name,
  is_nullable
FROM sys.columns 
WHERE object_id = OBJECT_ID(N'sales.order_items')




/* INFORMATION SCHEMA VIEW
An information schema view is a set of views that resides in a schema called INFORMATION_SCHEMA and provides metadata information in a standard manner. That is,
the views are defined in the SQL Standard, so naturally they don't cover aspects specific to SQL Server */

-- List the user tables in the current database along with their schema names
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = N'BASE TABLE'


-- Get the most available information about columns in the sales.orders table
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = N'sales'
  AND TABLE_NAME = N'orders'



/* System Stored procedures and functions 
System stored procedures and functions internaly query the system catalog and give you back more "digested" metadata information. */
EXEC sys.sp_tables

/* The sp_help procedure accepts an object name as input and returns multiple result sets with general information about the object, and also informatin about columns,
indexes, constraints, and more.*/
EXEC sys.sp_help 
  @objname = N'sales.orders'

-- The sp_columns procedure returns information about columns in an object
EXEC sys.sp_columns 
   @table_name = N'orders',
   @table_owner = N'sales'

-- Get the information about constraints in an object
EXEC sys.sp_helpconstraint 
  @objname = N'sales.orders'


/* One set of functions returns information about properties of entites such as the SQL Server instance, database, object, column, and so on*/
-- Return the product level of the current instance
SELECT 
  SERVERPROPERTY('ProductLevel')


-- Return the requested property of the specified database name, in this case, the Collation
SELECT 
    DATABASEPROPERTYEX(N'BikeStores', 'Collation')

/*
 OBJECTPROPERTY
----------------
The OBJECTPROPERTY function returns the requested property of the specified object name.
Check if the order's table has primary key */
SELECT
    OBJECTPROPERTY(OBJECT_ID(N'Sales.Orders'), 'TableHasPrimaryKey')


/*
COLUMNPROPERTY
---------------
The COLUMNPROPERTY function returns the requested property of a specified column.

Check whether the order_id column in the orders table is nullable
*/
SELECT
    COLUMNPROPERTY(OBJECT_ID(N'sales.orders'), N'order_id', 'AllowsNull')
