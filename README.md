# Schemas

As illustrated below, a database contains schemas, and schemas contain objects. You can think of a schema as a container of objects such a tables, views, stored procedures, and others.

<img src="Schemas.png" />

<br/>

## Schemas and Security
You can control permissions at the schema level. For example, you can grant a user ```SELECT``` permissions on a schema, allowing the user to query data from all object in that schema.

<br/>

## Schemas as namespaces
The schema is also a **namespace** -- it is used as a prefix to the object name. For example, supposed you have a table named *Orders* in a schema named *Sales*. The **schema-qualified** object name (also known as the ***two-part object name***) is ***Sales.Orders***.

If you omit the schema name when referring to an object, SQL server will a apply a process to resolve the schema name, such as checking whether the object exists in the user's default schema, and if it doesn't checking whether it exists in the *dbo* schema.

<blockquote> Microsoft recommends that when you refer to objects in your code you always use the two-part object names </blockquote>

There are some relatively insignificant costs involved in resolving the object name whe you don't specify it explicitly. But as insignificant as this extra cost might be, why pay it?








