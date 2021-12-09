# Creating Tables and Defining Data integrity

## Create a table

```sql
USE TSQL2012;

-- Check if the table exists
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL
  DROP TABLE dbo.Employees;

CREATE TABLE dbo.Employees (
   empid INT NOT NULL,
   firstname VARCHAR(30) NOT NULL,
   lastname VARCHAR(30) NOT NULL,
   hiredate DATE NOT NULL,
   mgrid INT NULL,
   ssn VARCHAR(20) NOT NULL,
   salary MONEY NOT NULL
)
```

<br/>

Notice the use of the two-part name *dbo.Employees* for the table name, as recommended earlier. If you omit the schema name, SQL Server will assume the default schema associated with the database user running the code.


<br/>

## Coding Style
Use a style that you and your fellow developers are comfortable with. What ultimately matters most is the consistency, readability, and maintability of your code. Take advantage of whitespace to facilitate readability.

It is strongly recommended to adopt the practice of terminating all statements with a semi-colon. Not only will doing this improve the readability of your code, bu tin some cases it can save you some grief. (When a semicolon is required and *not* specified, the error message SQL Server produces is not always very clear.)


<br/>


# Defining data integrity

The benefits of the relational model is that data integrity is an integral part of it.

<blockquote> Data integrity enforced as part of the model -- namely, as prt of the table definitions -- is considered as <b>declarative data integrity</b>. Data integrity enforced with code - such as with stored procedures or triggers -- is considered <b>procedural data integrity</b></blockquote>















