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

It is strongly recommended to adopt the practice of terminating all statements with a semi-colon. Not only will doing this improve the readability of your code, but in some cases it can save you some grief. (When a semicolon is required and *not* specified, the error message SQL Server produces is not always very clear.)


<br/>


## Defining data integrity

The benefits of the relational model is that data integrity is an integral part of it.

<blockquote> Data integrity enforced as part of the model -- namely, as part of the table definitions -- is considered as <b>declarative data integrity</b>. Data integrity enforced with code - such as with stored procedures or triggers -- is considered <b>procedural data integrity</b></blockquote>


This section highlights declarative constraints namely:

 - Primary Key constraints
 - Unique Constraints
 - Foreign Key constraints
 - Check constraints
 - Default constraints 


## Primary  Key Constraints

A primary key constraints enforces uniqueness of rows and also disallows *NULL* marks in the constraint attributes. **An attempt to define a primary key constraint on a column taht allows *NULL* marks will be rejected by the RDBMS.** Each table can only have one primary key.

```sql
ALTER TABLE dbo.Employees
  ADD CONSTRAINT PK_Employees
  PRIMARY KEY(empid);

```

To enforce uniqueness of the logical primary key constraint, SQL Server will create a unique index behind the scenes. **Indexes (not necessarily unique ones) are also used to speed up queries by avoiding unnecessary full table scans (simialar to indexes in books).**


<br/>


## Unique Constraints

Unique constraints enforces the uniquess of rows, allowing you to implement the concept of *alternate keys* from the relational model in your database. Unlike with primary keys, you can define multiple unique constraints within the same table. Also, a unique constraint is not restricted to columns defined as *NOT NULL*. According to standard SQL, a column with a unique constraint is supposed to allow multiple *NULL* marks (as if two *NULL* marks were different from each other). However, SQL Server's implementation rejects duplicate *NULL* marks (as if two *NULL* marks were equal to each other).

```sql 
ALTER TABLE dbo.Employees
  ADD CONSTRAINT UNQ_Employees_ssn
  UNIQUE(ssn)
```

As with a primary key constraint, SQL Server will create a **unique index** behind the scenes as the physical mechanism to enforce the logical unique constraint.


<br/>


## Foreign Key Constraints

A foreign key enforces **referential integrity**. This constraint is defined on one or more attributes in what's called the *referencing* table and points to the candidate key (primary key or unique constraint) attributes in what's called the *referenced* table.

<blockquote> The referencing and referenced tables can be one and the same </blockquote>.

The purpose of the foreign key to **RESTRICT** values allowed in the foreign key column to those that exists in the referenced columns.

```sql
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL
   DROP TABLE dbo.Orders


CREATE TABLE dbo.Orders (
  orderid INT NOT NULL,
  empid INT NOT NULL,
  custid VARCHAR(10) NOT NULL,
  orderts DATETIME2 NOT NULL, 
  qty INT NOT NULL
  CONSTRAINT PK_Orders
     PRIMARY KEY(orderid)
);

```

Suppose you want to restrict the values in ```empid``` column in the *Orders* table to the values that exist in the ```empid``` column in the *Employees* table, you can define a foreign key in the *Orders* table as follows:

```sql
ALTER TABLE dbo.Orders
  ADD CONSTRAINT FK_Orders_Employees
  FOREIGN KEY (empid)
  REFERENCES dbo.Employees(empid)
```
<br/>

<blockquote>Note that <i>NULL</i> marks are allowed in the foreign key columns even if there are no NULL marks in the referenced candidate key columns.</blockquote>

The example above is a basic definition of a foreign key that enforced a referential action called *no action*. No action means that attempts to delete rows from the referenced table or update the referenced candidate key attributes will be rejected if related rows exist in the referencing table. For examle, if you try to delete an employee rwow from the *Employee* table when there are related orders in the *Orders* table, the RDBMS will reject such an attempt and produce an error.


You can define the foreign key with actions that will compensate for such attempts (to delete rows from the referenced table or update the referenced candidate key attributes when related rows exist in the referencing table). You can define options *ON DELETE* and *ON UPDATE* with actions such as *CASCADE, SET DEFAULT,* and *SET NULL* as part of the foreign key definition.

<br/>

### CASCADE
Cascade means that the operation will be *cascaded* to related rows. For example, *ON DELETE CASCADE* means that when you delete a row from the referenced table, the RDBMS will delete the related rows from the referencing table.


### SET DEFAULT and SET NULL
*SET DEFAULT and SET NULL* mean that the compensating action will set the foreign key attributes of the related rows to the column's default value or *NULL*, respectively.


<br/>

## Check Constraints
A check constraint allows you to define a predicaet that a row must meet to be entered into the table or to be modified. For example, the following check constraint ensures that the salary column in the *Employees* table will support only positive values.

```sql
ALTER TABLE dbo.Employees
  ADD CONSTRAINT CHK_Employees_salary
  CHECK(salary > 0.00)
```

An attempt to insert or update a row with a nonpositive salary value will be rejected by the RDBMS. Note that a check constraint rejects an attempt to insert or update a row when the predicate evaluates to *FALSE*. The modification will only be accepted when the predicate evaluates to either *TRUE* or *UNKNOWN*.

When adding check and foreign key constraints, you can specify an option called *WITH NOCHECK* taht tells the RDBMS that you want it to bypass constraint checking for existing data. This is considered bad practice because you cannot be sure that your data is **consistent**. You can also disable or enable existing check and foreign key constraints.


<br/>


## Default Constraint
A default constraint is associated with a particular attribute. It is an expression that is used as the default value when an explicit value is not specified for the attribute when you insert a row. The following code defiens a default constraint for the *orderts* attribute.

```sql
ALTER TABLE dbo.Orders
  ADD CONSTRAINT DFT_Orders_ordersts
  DEFAULT(SYSDATETIME()) FOR orderts;
```

The default expression invokes the *SYSDATETIME* function, which returns the current date and time value. After this default expression is defined, whenever you insert a row in the *Orderts* table and do not explicitly specify a value in the *orderts* attribute, SQL Server will set the attribute value to *SYSDATETIME*. 

