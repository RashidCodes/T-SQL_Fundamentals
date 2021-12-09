# SQL

SQL is botn an ANSI and ISO standard language based on the relational model, designed for querying and managing data in an RDBMS.

Unlike many programming languages which implement the *imperative* programming paradigm, SQL is a declarative programming language -- SQL requires you specify what you want and not how to get it. The RDBMS will figure out the mechanics required to process your request.

<br/>

## Categories of statements

The several categories of statements in SQL, including:

- DML: Data Manipulation Language
- DDL: Data Definition Language
- DCL: Data Control Language


DDL is associated with object definitions and includes statements like *CREATE*, *ALTER*, and *DROP*. DML allows you to **query** and **modify** data and includes statements like *SELECT*, *INSERT*, *UPDATE*, *DELETE*, *TRUNCATE*, and *MERGE*. Lastly, DCL is associated with permissions and includes statements such as *GRANT* and *REVOKE*.

Althoug T-SQL is based on SQL, it also provides some **proprietary** extensions.


<br/>

# Set Theory

<blockquote>*By a "set" we mean any collection M into a whole of definite, distinct objects m (which are called the "elements" of M) of our perception or of our thought. -- Joseph W. Dauben and Georg Cantor (Princeton University Press, 1990) </blockquote>

## Explaining the theory

Your focus should be on the collection of objects as opposed to the individual objects that make up the collection. So when you write T-SQL queries against a set of employees, you should think of the set of employees rather than the employees themselves.


The work *distinct* means that every element of a set must be unique. Tables implement this by using **key** constraints. Without a key, it's impossible to uniquely identify rows, and therefore the table will not qualify as a set but it'll qualify as a ***multiset*** or ***bag***.

The phrase *our perception 9or of our thought* implies that the definition of a set is subjective. For example in a field of vegetables, one person might focus on tomatoes, another might focus on carrots. Therefore you have a lot of freedom in defining sets. When you design a data model for your database, the design process should carefully consider the **subjective** needs of the application to determine adequate definitions for the entities involved.

### Notice that Cantor's definition does not mention Order

Cantors definition does not make any mention of order among the set elements. The order is not important. A query against a table can returns table rows in any order unless you explicitly request that the data be sorted in a specific way, perhaps for presentation purposes.


<br/>

# Predicate Logic

A predicate can be loosely defined as a property or an expression taht either holds or doesn't hold -- in other words, is either true or false. The relational model relies on predicates to maintain the *logical integrity* of the data and define its structure. For example, a predicate used to enforce integrity is a constraint defined in a table called *Employees* that allows only employees with salary greater than zero to be stored in the table. The predicate is "salary greater than zero".


<br/>

# The relational Model
The relationlal model is a semantic model for *data management and manipulation* and is based on set theory and predicate logic. It was created by **Dr. Edgar F. Codd**, and later explained and developed by Hugh Darwen, Chris Date, etc.
 
The goal of the relational model is to enable consistent *representation of data* with **minimal** or **no redundancy** and without sacrificing completeness, and to define data integrity (enforcement of data consistency) as part of the model.

An RDBMS is supposed to implement the relational model and provide the means to store, manage, enforce the integrity of, and query data. The relational model invlves concetpts such as propositions, predicates, relations, tuples, attributes, and more.

<br/>

# Propositions, Predicates, and Relations

The common belief that the term relational stems from relationships between tables is incorrect. "Relational" actually pertains to the mathematical term *relation*. In set theory, *relation* is a representation of a set. In the relational model, a relation is a set of related information, with the counterpart in SQL being a table - although not the exact counterpart.

<blockquote>A relation should represent a single set. </blockquote>

When you design a data model for a database, you represent all data with relations (tables). You start by identifying propostions that you'll need to represent in the database. For example, Employee "Rashid was born on February 2, 2000, and works in the Accounts Department" is a proposition. If this proposition is true, it will manifest itself as a row in a table of Employees. A false proposition will simply not manifest itself. This presumption is known as the *close world assumption (CWA)*.

The next steo is to formalize the propositions. This is done by taking out the actual data and defining the structure -- for example by  createing predicates out of propositions. You can think of predicates as ***parametrized propositions***.


<br/> 

# Missing Values
Should predicates be restricted to two-valued logic? In a two-valued logic, a predicate is either true or false. The use of the two-valued predicate logic follows a mathematical law called the *law of excluded middle*. 
Some say that there's room for three valued (or even four-valued) predicate logic, taking into accoutn cases where values are missing. A predicate involving a missing value neither yields a true or a false. Support for NULL marks and three-valued predicate logic in SQL is the source of a great deal of confusion and complexity, though one can argue that missing values are part of reality. In addition, the alternative - using only two-valued predicate -- is no less problematic.


<br/>

# Constraints
Data integrity is achieved through rules called constraints that are defined in the data model and enforced by the RDBMS. A candidate key is a key defined on one or more attributes that prevents more than one occurrence of the same tuple (row in SQL) in a relation. Typically, you arbitrarily choose one of the candidate keys as the primary key, and use that as the preferred way to identify a row. All other candidate keys are known as *alternate* keys.

Foreign keys are used to enforce **referential integrity**. It is defined on **one or more** attributes of a relation and references a candidate key in another (or possibly the same relation).

 
<br/>


# Normalization
In a normalized database, you avoid anomalies during data modification and keep redundancy to a minimum without sacrificing completeness.

## 1NF
Attributes of a relation should be atomic (unique). Atomicity of attributes is subjective in the same way that the definition of a set is subjective. For example, should an employee name in an Employee relation be expressed with one attribute *(fullname)*, two *(firstname and lastname)*, or three *(firstname, middlename, and lastname)*? **The answer depends on the application**.


<br/>

## 2NF
The second normal form involves two rules. One rule is that the data must meet the first normal form. The other rule addresses the relationship between the non-key and candidate key attributes.

<blockquote>If you need to obtain any non-key attributes value, you need to provide the values of all attributes of a candidate key from the sample tuple.</blockquote>


Let's take a look at the figure below.

<img src="Data model before applying 2NF.png" />

Figure 1-1: Data model before applying 2NF

<br/>

The second normal form is violated because there are non-key attributes that depend on only part of the candidate key. For instance, you can find the *orderdate* of an order, as well as *customerid* and *companyname*, based on the *orderid* alone. 

To conform to the second normal form, you would need to split your original relation into two relations: *Order* and *OrderDetails* (as shown in Figure 1-2).

<img src="Data model after applying 2NF and before 3NF.png" />

Figure 1-2: Data model after applying 2NF and before 3NF

<br/>

## 3NF

The third normal form has two rules. The data must meet the second normal form. **Also, all non-attributes must be dependent on candidate keys non-transitively.** Informally, this rule means that all non-key attributes must be mutually independent. In other words, one non-key attribute cannot be dependent on another non-key attribute.


The *Orders* and *OrderDetails* relations described previously now conform to the second normal form. Remember that the *Orders* relation at this point contains the attributes *orderid, orderdate, customerid*, and *companyname*, with the primary key defined in *orderid*.

Both *customerid* and *companyname* depend on the whole primark key -- *orderid*. For example, you need the entire primary key to find the *customerid* representing the customer who placed the order. Similarly, you need the whole primary key to find the company name of the customer who placed the order. However, *customerid* and *companyname* are also dependent on each other. To meet the third normal form, you need to add a *Customers* relation as shown in Figure 3 below.

<img src="Data model after applying 2NF and before 3NF.png" />

Figure 1-3: Data model after applying 3NF

<br/>

### Summary of 2NF and 3NF
<blockquote>Every non-key attribute is dependent on the key, the whole key, and nothing but the key -- so help me Codd.</blockquote>



