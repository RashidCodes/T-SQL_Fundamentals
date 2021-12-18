/* SET OPERATORS
 An interesting aspect of sets operators is that when its comparing rows, a set operator considers two NULLS as equal.

All three operators in Microsoft SQL Server support an implicit distinct version, but only the UNION operator supports the ALL version. In
terms of syntax, you cannot explicitly specify the DISTINCT clause. Instead, it is implied when you don't specify ALL explicitly.
*/

/* Because UNION ALL doesn't eliminate duplicates, the result is a multiset not a set */
SELECT last_name FROM sales.customers 
UNION ALL -- Non distinct union
SELECT last_name from sales.staffs

-- Result is not a multiset
SELECT last_name FROM sales.customers 
UNION -- Distinct union
SELECT last_name FROM sales.staffs 



/* The INTERSECT OPERATOR 
Looking for customers and staff that share the same last name
*/
SELECT last_name FROM sales.customers 
INTERSECT 
SELECT last_name FROM sales.staffs


/* The INTERSECT ALL multiset operator 

INTERSECT ALL is different from UNION ALL in that the former does not return all duplicates but only returns the number of duplicate rows,
matching the lower of the counts in both multisets.

Another way to look at it is that the INTERSECT ALL operator doesn't only care about the existence of a row in both sides - it also cares 
about the number of occurrences of the row in each side.

If there are x occurrences of a row R in the first multiset and y occurrences of R in the second, R appears minimum(x,y) times in the result
of the operator.

Case in point: Look for VARGAS
*/
SELECT 
  ROW_NUMBER() 
    OVER (PARTITION BY last_name
          ORDER BY (SELECT 0)) AS rownum,
  last_name
FROM sales.staffs 

INTERSECT

SELECT 
  ROW_NUMBER()
    OVER(PARTITION BY last_name 
         ORDER BY (SELECT 0)) AS rownum,
  last_name
FROM sales.customers
GO

/* Of course the INTERSECT operator is not supposed to return any row numbers; those are used to support the solution. If you don't
want to return those in the output, you can define a table expression such as CTE based on this query and select only the original 
attributes from the table expression */

WITH INTERSECT_ALL 
AS 
(
    SELECT 
    ROW_NUMBER() 
    OVER (PARTITION BY last_name
          ORDER BY (SELECT 0)) AS rownum,
    last_name
    FROM sales.staffs 

    INTERSECT

    SELECT 
    ROW_NUMBER()
        OVER(PARTITION BY last_name 
            ORDER BY (SELECT 0)) AS rownum,
    last_name
    FROM sales.customers
)
SELECT last_name
FROM INTERSECT_ALL



/* Except Distinct Set Operator 

Note that unlike the other two operators, EXCEPT is asymmetric; that is, with the other set operators, it doesn't matter which input 
query appears first and which second - with EXCEPT, it does.

*/
SELECT last_name FROM sales.customers 
EXCEPT 
SELECT last_name FROM sales.staffs

-- 

SELECT last_name FROM sales.staffs 
EXCEPT 
SELECT last_name FROM sales.customers

GO

/* EXCEPT ALL Multiset Operator

The EXCEPT  ALL operator is very similar to the EXCEPT operator, but it also takes into account the number of occurrences of each row.
Provided that a row R appears x times in the first multiset and y times in the second, and x > y, R will appear x-y times in 
Query1 EXCEPT ALL Query2.\

In other words, at the logical level, EXCEPT ALL returns only occurrences of a row from the first multiset that do not have a corresponding
occurrence in the second

*/


WITH EXCEPT_ALL 
AS 
(
    SELECT 
      ROW_NUMBER()
        OVER(PARTITION BY last_name
             ORDER BY (SELECT 0)) AS rownum,
      last_name
    FROM sales.staffs 

    EXCEPT 

    SELECT 
      ROW_NUMBER()
        OVER(PARTITION BY last_name
             ORDER BY (SELECT 0)) AS rownum,
      last_name 
    FROM sales.customers
)
SELECT last_name
FROM EXCEPT_ALL
GO

--==============--==============--============--

WITH EXCEPT_ALL 
AS 
(
    SELECT 
      ROW_NUMBER()
        OVER(PARTITION BY last_name
             ORDER BY (SELECT 0)) AS rownum,
      last_name 
    FROM sales.customers

    EXCEPT 

    SELECT 
      ROW_NUMBER()
        OVER(PARTITION BY last_name
             ORDER BY (SELECT 0)) AS rownum,
      last_name
    FROM sales.staffs 

)
SELECT last_name
FROM EXCEPT_ALL


/* PRECEDENCE 
SQL defines precedence among set operators. The INTERSECT operator precedes UNION and EXCEPT and UNION and EXCEPT are considered equal.
*/



/* CIRCUMVENTING UNSUPPORTED LOGICAL PHASES

The individual queries that are used as inputs to a set operator support all logical query processing phases (such as table operators, WHERE,
GROUP BY, and HAVING) except for ORDER BY. However, only the ORDER BY phase is allowed on the result of the operator. What if you need to apply
other logical phases besides ORDER BY to the result of the operator?

This is not supported directly as part of the query that applies the operator, but you can easily circumvent this restriction by using
table expressions.
*/

SELECT last_name, COUNT(*) AS numOfOccurrences
FROM (SELECT last_name FROM sales.staffs
      UNION ALL
      SELECT last_name FROM sales.customers) AS U
GROUP BY last_name
HAVING COUNT(*) > 3


/* The fact that you cannot specify ORDER BY with the individual queries involved in the set operator might also cause logical problems.
What if you need to restrict the number of rows in those queries with the TOP or OFFSET-FETCH option? Again, you can resolove this problem 
with table expressions

Recall that an ORDER BY clause is allowed in a query with TOP or OFFSET-FETCH, even when the query is used to define a table-expression. In
such a case, the ORDER BY clause serves only as part of the filtering specification and has no presentation meaning.*/

SELECT last_name, COUNT(*) AS numOfOccurrences
FROM 
    (SELECT T.last_name
    FROM (SELECT last_name
        FROM sales.customers 
        ORDER BY last_name -- Not for presentation purposes
        OFFSET 10 ROWS FETCH NEXT 50 ROWS ONLY) AS T


    UNION ALL 


    SELECT U.last_name
    FROM (SELECT last_name 
        FROM sales.staffs 
        ORDER BY last_name -- Not for presentation purposes
        OFFSET 10 ROWS FETCH NEXT 50 ROWS ONLY) AS U) AS AGG

GROUP BY last_name 
HAVING COUNT(*) > 3





