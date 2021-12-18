/* WINDOW FUNCTIONS 

A window function is a function that, for each row, computes scalar result value based on a calculation against a subquery of the rows from the 
underlying subquery.

The subset of rows is known as a window and is based on a window descriptor that relates to the current row.

*/

USE BikeStores 
GO

-- Using a window aggregate function to compute the running total value
SELECT customer_id, order_id, order_date, list_price,
  SUM(list_price) OVER(PARTITION BY customer_id, order_id 
                       ORDER BY order_date
                       ROWS BETWEEN UNBOUNDED PRECEDING  
                                AND CURRENT ROW) AS runprice
FROM sales.joinOrdersAndItems

-- Trying to understand the UNBOUNDED PRECEDING and CURRENT ROW keywords: Notice the difference
SELECT customer_id, order_id, order_date, list_price,
  SUM(list_price) OVER(PARTITION BY customer_id, order_id 
                       ORDER BY order_date) AS runprice
FROM sales.joinOrdersAndItems

/* RANKING WINDOW FUNCTIONS

Ranking window functions allow you to rank each row in respect to others in several different ways. SQL Server supports four ranking functions:
- ROW_NUMBER
- RANK 
- DENSE_RANK 
- NTILE 

*/

SELECT order_id, customer_id, list_price,
  ROW_NUMBER() OVER(ORDER BY list_price) AS rownum,
  RANK() OVER(ORDER BY list_price) AS rank,
  DENSE_RANK() OVER(ORDER BY list_price) AS dense_rank, 
  NTILE(100) OVER(ORDER BY list_price) AS ntile 
FROM sales.joinOrdersAndItems
ORDER BY list_price 

/* The functions 

ROW_NUMBER
-----------
This function assigns incrementing sequential integers to the rows in the result set of a query, based on logical order that is specified in the ORDER BY 
subclause of the OVER clause. In the sample query, the logical order is based on the list_price column; therefore, you can see in the output that when the 
value increases, the row number increases as well. However, even when the ordering value doesn't increase, the row number still must increase. Therefore, if the 
ROW_NUMBER function's ORDER BY list is non-unique, as in the preceding example, the query is NONDETERMINISTIC, i.e. more than one correct result is possible.
If you want to make a row number calculation deterministic, you need to add elements to the ORDER BY list to make it unique; meaning that the list of elements
in the ORDER BY clause would uniquely identify rows. For example, you can add the order_id column as a tiebreaker to the ORDER BY list to make the row number 
calculation deterministic.

RANK AND DENSE RANK
--------------------
If you want to treat ties int he ordering values the same way, you will probably want to use the RANK or DENSE_RANK function instead. Both are similar to the 
ROW_NUMBER function, but they produce the same ranking value in all rows that have the same logical ordering value. The differnce between RANK and DENSE_RANK 
is that RANK indicates how many rows have a lower value, whereas DENSE_RANK indicates how many distinct ordering values are lower. For example, in the sample
query, a rank of 8 indicates 7 rows with lower values. A dense rank of 8 indicates 7 distinct lower values.

NTILE 
-----
The NTILE function allows you to associate the rows in the result with tiles (equally sized groups of rows) by assigning a tile number to each row. You 
specify the number of tiles you are after as input to the function, and in the OVER clause, you specify the logical ordering. The sample query has 4,722 rows
and the request was for 10 tiles; therefore, the tile size is 4722/10 = 472.2. Logical ordering is based on the list_price column. This means that the 472 
rows with the lowerst list_prices are assigned the number 1, the next 472 with tile number 2, and so on.
If the number of rows doesn't divide evenly by the number of tiles, an extra row is aded to each of the first tiles from the remainder. 

Case in point: The extra 2 rows are added to first and second tiles, thus, the tile 1 and tile 2 will have a total of 473 rows.

*/


/* RANKING AND WINDOWING 

Ranking functions support window partition clauses. Remember that window partition restricts the window to only those rows that share the same values 
in the partitioning attributes as in the current row.
*/

SELECT order_id, customer_id, list_price, 
  ROW_NUMBER() OVER(PARTITION BY order_id, customer_id 
                    ORDER BY list_price) AS rownum
FROM sales.joinOrdersAndItems 
ORDER BY order_id, customer_id, list_price 

/* As you can see in the output, the row numbers are calculated indenpendently for each order item, as though the calculation were reset for each customer. 
Remember that window ordering has nothing to do with presentation ordering and does not change the nature of the result from being relational.
*/

--==================--====================--==================--

/* OFFSET WINDOW FUNCTIONS 

Offset window functions allow you to return an element from a row that is at a certain offset from the current row or from the beginning or end of a window 
frame. SQL Server 2012 supports four offset functions namely: 
- LAG and LEAD
- FIRST_VALUE and LAST_VALUE


The LAG and LEAD functions support window partition and window order clauses. There's no relevance to window framing here. These functions allow you to 
obtain an element from a row that is at a certain offset from the current row within the partition, based on the indicated ordering. 

The LAG function looks before the current row, and the LEAD function looks ahead. The first argument to the functions (which is mandatory) is the element
you want to return; the second argument (optional) is the offset (1 if not specified); the third argument (optional) is the default value to return 
in case there is no row at the requested offset (NULL if not specified).

The FIRST_VALUE and LAST_VALUE functions allow you to return an element from the first and last rows in the window frame, respectively.
*/

-- LAG AND LEAD in action
SELECT customer_id, order_id, list_price,
  LAG(list_price)  OVER(PARTITION BY customer_id, order_id
                       ORDER BY order_date, customer_id, order_id) AS prevval, 
  LEAD(list_price) OVER(PARTITION BY customer_id, order_id
                       ORDER BY order_date, customer_id, order_id) AS nextval 
FROM sales.joinOrdersAndItems


-- FIRST_VALUE and LAST_VALUE in action 
-- Think of UNBOUNDED PRECEDING and UNBOUNDED FOLLOWING as the start and end of the window
SELECT customer_id, order_id, list_price, order_date,
   FIRST_VALUE(list_price) OVER(PARTITION BY customer_id, order_id
                                ORDER BY order_date, customer_id, order_id
                                ROWS BETWEEN UNBOUNDED PRECEDING 
                                     AND CURRENT ROW) AS firstval,
   LAST_VALUE(list_price) OVER(PARTITION BY customer_id, order_id 
                               ORDER BY order_date, customer_id, order_id
                               ROWS BETWEEN UNBOUNDED PRECEDING 
                                     AND UNBOUNDED FOLLOWING) AS lastval
FROM sales.joinOrdersAndItems
ORDER BY customer_id, order_date, order_id
                

SELECT customer_id, order_id, list_price,
   FIRST_VALUE(list_price) OVER(PARTITION BY customer_id, order_id
                                ORDER BY order_date, customer_id, order_id) AS firstval,
   LAST_VALUE(list_price) OVER(PARTITION BY customer_id, order_id 
                               ORDER BY order_date, customer_id, order_id) AS lastval
FROM sales.joinOrdersAndItems
ORDER BY customer_id, order_date, order_id



/* AGGREGATE WINDOW FUNCTIONS

Prior to SQL Server 2012, window aggregate functions supported only a window partition clause. In SQL Server 2012, they also support window order
and frame clauses, advancing their usefulness dramatically.

Recall that using an OVER clause with an empty parenthesis exploses a window of all rows from the underlying query's result set to the function. So
SUM(list_price) OVER() returns the grand total of all values. If you do add a window partition clause, you expose a restricted window to the function,
with only those rows from the underlying query's result set that share the same values in the partitioning elements as in the current row.

As mentioned, one of the great advantages of window functions is that by enabling you to return detail elements and aggregate them in the same row,
they also enable you to write expressions that mix details and aggregates.
*/

SELECT order_id, customer_id, list_price,
  SUM(list_price) OVER() AS totalvalue,
  SUM(list_price) OVER(PARTITION BY order_id, customer_id) AS orderItemPrice,
  (list_price / SUM(list_price) OVER(PARTITION BY order_id, customer_id) * 100) AS pricePercentage
FROM sales.joinOrdersAndItems


/* 

SQL Server supports other delimiteres for the ROWS window frame unit. You can indicate an offset back from the current row
as well as an offset forward. For example, to capture all rows from two rows before the current row and through one row ahead,
you would use ROWS BETWEEN 2 PRECEDING AND 1 FOLLOWING 

*/
SELECT order_id, customer_id, list_price, order_date,
  SUM(list_price) OVER(PARTITION BY order_id, customer_id 
                       ORDER BY order_id, customer_id, order_date
                       ROWS BETWEEN 2 PRECEDING AND 1 FOLLOWING ) AS someWeirdPrice 
FROM sales.joinOrdersAndItems 




/* Pivoting Data 

Pivoting data involves rotating data from a state of rows to a state of columns, possibly aggregating values along the way.

*/

IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL
   DROP TABLE dbo.Orders;


CREATE TABLE dbo.Orders 
(
    orderid INT NOT NULL,
    orderdate DATE NOT NULL,
    empid INT NOT NULL,
    custid VARCHAR(5) NOT NULL,
    qty INT NOT NULL,
    CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);


INSERT INTO dbo.Orders (orderid, orderdate, empid, custid, qty)
VALUES 
    (30001, '20070802', 3, 'A', 10),
    (10001, '20071224', 2, 'A', 12),
    (10005, '20071224', 1, 'B', 20),
    (40001, '20080109', 2, 'A', 40),
    (10006, '20080118', 1, 'C', 14),
    (20001, '20080212', 2, 'B', 12),
    (40005, '20090212', 3, 'A', 10),
    (20002, '20090216', 1, 'C', 20),
    (30003, '20090418', 2, 'B', 15),
    (30004, '20070418', 3, 'C', 22),
    (30007, '20090907', 3, 'D', 30);

SELECT * FROM dbo.Orders


/* Consider a request to produce a report with the total order quantity for each employee and customer */
SELECT empid, custid, SUM(qty) AS sumqty 
FROM dbo.Orders 
GROUP BY empid, custid

/* But suppose that you have a requirement to produce the output in the form shown in table 7-1 */


/* Every pivoting request involves three logical phases, each with associated elements:

1. A grouping phase with an associated grouping or on rows element
2. A spreading phase with an associated spreading or on cols element
3. An aggregation phase with an associated aggregation element and aggregation function

*/


/* PIVOTING IN STANDARD SQL */
SELECT empid,
  SUM(CASE WHEN custid='A' THEN qty END) AS A,
  SUM(CASE WHEN custid='B' THEN qty END) AS B,
  SUM(CASE WHEN custid='C' THEN qty END) AS C,
  SUM(CASE WHEN custid='D' THEN qty END) AS D 
FROM dbo.Orders 
GROUP BY empid 


/* PIVOTING IN TRANSACT SQL 

Syntax
SELECT ...
FROM <source_table_or_table_expression>
  PIVOT(<agg_func>(<aggregation_element>)
    FOR <spreading_element>
      IN (<list_of_target_columns)) AS <result_table_alias>)
...;

In the parenthesis of the PIVOT operator, you specify the aggregate function (SUM, in this example), aggregation element(qty), spreading element(custid), 
and the list of target column names (A, B, C, D). Following the parenthesis of the PIVOT operator, you specify an alias for the result table.

It is important to note that with the PIVOT operator, you do not explicitly specify the grouping elements, removing teh need for GROUP BY in the query. The 
PIVOT operator figures out the grouping elements implicitly as all attributes from the source table (or table expression) that were not specified 
as either the spreading element or the aggregation element. 

You must ensure that the source table for the PIVOT operator has no attributes besides the grouping, spreading, and aggregation elements, so that after
specifying the spreading and aggregation elements, the only attributes left are those you intend as grouping elements. You achieve this by not applying the PIVOT
operator to the original table directly (Orders in this case), but instead to a table expression that includes only the attributes representing the pivoting
elements and no others.

*/

SELECT empid, A, B, C, D 
FROM (SELECT empid, custid, qty 
      FROM dbo.Orders) AS D 
    PIVOT(SUM(qty) FOR custid IN (A, B, C, D)) AS P


/* UNPIVOTING

Unpivoting is a technique to rotate data froma a state of columns to a state of rows. Usually it involves querying a pivoted state of data, producing 
from each source row multiple result rows, each with a different source column value. In other words, each source row of the pivoted table becomes
potentially many rows, one row for each of the specified source column values.

*/

IF OBJECT_ID('dbo.EmpCustOrders', 'U') IS NOT NULL 
   DROP TABLE dbo.EmpCustOrDers;

CREATE TABLE dbo.EmpCustOrders 
(
    empid INT NOT NULL
      CONSTRAINT PK_EmpCustOrders PRIMARY KEY,
    A VARCHAR(5) NULL,
    B VARCHAR(5) NULL,
    C VARCHAR(5) NULL,
    D VARCHAR(5) NULL
);

INSERT INTO dbo.EmpCustOrders(empid, A, B, C, D)
  SELECT empid, A, B, C, D 
  FROM (SELECT empid, custid, qty
        FROM dbo.Orders) AS D 
    PIVOT(SUM(qty) FOR custid IN (A, B, C, D)) AS P;

SELECT * FROM dbo.EmpCustOrders


-- Perform a Cartesian product
SELECT * FROM dbo.EmpCustOrders 
CROSS JOIN (VALUES('A'), ('B'), ('C'), ('D')) AS Custs(custid);

-- Add the aggregated column 
SELECT empid, custid,
  CASE custid 
    WHEN 'A' THEN A
    WHEN 'B' THEN B
    WHEN 'C' THEN C
    WHEN 'D' THEN D 
  END AS qty 
FROM dbo.EmpCustOrders 
  CROSS JOIN (VALUES ('A'), ('B'), ('C'), ('D')) AS Custs(custid)


-- Eliminate the irrelevant intersections 
SELECT * 
FROM (
    SELECT empid, custid,
    CASE custid 
        WHEN 'A' THEN A
        WHEN 'B' THEN B
        WHEN 'C' THEN C
        WHEN 'D' THEN D 
    END AS qty 
    FROM dbo.EmpCustOrders 
    CROSS JOIN (VALUES ('A'), ('B'), ('C'), ('D')) AS Custs(custid)) AS D
WHERE qty IS NOT NULL



/* UNPIVOTING WITH NATIVE T-SQL 

SELECT ...
FROM <source_table_or_table_expression>
  UNPIVOT(<target_col_to_hold_source_column_values>
    FOR <target_col_to_hold_source_col_names> IN (<list_of_source_columns>)) AS
<result_table_alias>
...;

*/

SELECT empid, custid, qty
FROM dbo.EmpCustOrders 
  UNPIVOT(qty FOR custid IN (A, B, C, D)) AS U;



/* GROUPING SETS 

A grouping set is simply a set of attributes by which you group.

THE GROUPING SETS SUBCLAUSE
---------------------------
This is a powerful subclause that is used mainly for reporting and data warehousing. By using this subclause, you can define multiple grouping sets in the 
same query */

SELECT empid, custid, SUM(qty) AS sumqty 
FROM dbo.Orders 
GROUP BY 
  GROUPING SETS 
  (
      (empid, custid),
      (empid),
      (custid),
      ()
  )


/* The CUBE subclause 
The CUBE subclause of the GROUP BY clause provides an abbreviated way to define multiple grouping sets. In the parenthesis of the CUBE subclause,
you provide a list of members separated by commans, and you get all possible grouping sets that can be defined based on the input members.

for example, CUBE(a, b, c) -> GROUPING SETS((a, b, c), (a, b), (a, c), (b, c), (a), (b), (c), ()). In set theory, the set of all subsets of elements 
that can be produced from a particular set is called the POWER SET. You can think of the CUBE subclause as producing the power set of grouping sets 
that can be formed from the given set of elements

*/

SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders 
GROUP BY CUBE(empid, custid)


/* The ROLLUP Subclause 
Quite similar to the CUBE subclause but it produces a subset of the powerset instead of the whole powerset. It does by assuming a hierarcy among the 
input members and produces all grouping sets that make sense considering the hierarchy. 

For example, suposed that you want to reutnr total quantities for all grouping sets taht can be defined based on the time hierarchy order year > order month >
order day. You can use GROUPING SETS subclause and explicitly list all four possible grouping sets.

GROUPING SETS (
    (YEAR(orderdate), MONTH(orderdate), DAY(orderdate)),
    (YEAR(orderdate), MONTH(orderdate)),
    (YEAR(orderdate)),
    ()
)
*/

SELECT 
  YEAR(orderdate) AS orderyear, 
  MONTH(orderdate) AS ordermonth,
  DAY(orderdate) AS orderday,
  SUM(qty) AS sumqty 
FROM dbo.Orders 
GROUP BY ROLLUP(YEAR(orderdate), MONTH(orderdate), DAY(orderdate))


/* 
THE GROUPING AND GROUPING_ID FUNCTION 
--------------------------------------
When you have a single query that defines multiple grouping sets, you might need to be able to associate result rows and grouping sets--that is, to 
identify for each result row the grouping set it is associated with. As long as grouping elements are defined as NOT NULL, this is easy.

For example, consider the following query

*/

SELECT empid, custid, SUM(qty) AS sumqty 
FROM dbo.Orders 
GROUP BY CUBE(empid, custid)

/* Because both the empid and custid columns were defined in the dbo.Orders table as NOT NULL, a NULL in those columns can only represent a placeholder, 
indicating that the column did not participate in the current grouping set. So for example, all rows in which empid is not NULL and custid is not NULL are 
associated with the grouping set (empid, custid). All rows in which empid is not NULL and custid is NULL are associated with the grouping set (empid), and
so on.

However, if a grouping column is defined as allowing NULL marks in the table, you cannot tell for sure whether a NULL in the result set originated from the 
data or is a placeholder for a nonparticipating  member in a grouping set.

One way to determine grouping set association in a deterministic manner, even when grouping columns allow NULL marks, is to use the GROUPING function. This
function accepts a name of a column and returns 0 if it is a member of the current grouping set and 1 otherwise.

*/

SELECT 
  GROUPING(empid) AS grpemp,
  GROUPING(custid) AS grpcust,
  empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders 
GROUP BY CUBE(empid, custid)


/* Now you don't need to rely on the NULL marks anymore to figure out the association between result rows and grouping sets. For example, all rows in which 
grpemp is 0 and grpcust is 0 are associated with the grouping set (empid, custid). All rows i which grpemp is 0 and grpcust is 1 are associated with the 
grouping set (empid), and so on.

You can also checkout the GROUPING_ID function. The grouping sets are represented by integers.

*/

SELECT 
  GROUPING_ID(empid, custid) AS groupingset,
  empid, custid, SUM(qty) AS sumqty 
FROM dbo.Orders 
GROUP BY CUBE(empid, custid)