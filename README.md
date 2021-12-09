# The Data Life Cycle

This section describes the different environments in which data can reside and the characteristics of both the data and the environment at each stage of the data life cycle. The figure below shows the lifecycle.

<img src="The data lifecycle.png" />

Figure 1: The data lifecycle

<br/>

## Online Transactioanl Processing

The focus of an OLTP system is data entry and not reporting -- transactions mainly insert, update, and delete data. The relational model is targed **primarily at OLTP systems**, where a normalized model provides both good performance for data entry and data consistency.

However, an OLTP environment is not suitable for reporting purposes because a normalized model usually involves many tables with complex relationships.

<br/>

## Data Warehouses

A *data warehouse (DW)* is an environment designed for data retrieval and reporting purposes. The data model of a data warehouse is designed and optimized mainly to support data **retrieval needs**. 

The simplest data warehouse design is called a *star schema*. It includes several **dimension** tables and a **fact** table. 

<blockquote>*Each dimension table represents a subject by which you want to analyze the data*.</blockquote>


For example, in a system that deals with orders and sales, you will probably want to analyze data by customers, products, employees, etc. In a star schema, each dimension is implemented as a single table with redundant data. For example, a product dimension could be implemented as a single *ProductDim* table instaed of three normalized tables: *Products*, *ProductSubCategories*, and *ProductCategories*.

**If you normalize a dimension table, which results in multiple tables representing that dimension, you get what's known as a snowflake dimension**.

The fact table holds the **facts** and **measures** such as *quantity* and value for each relevant combination of dimension keys. 

<blockquote>Note that the data in the DW is typically preaggregated to a certain level of granularity (such as day)</blockquote>

SQL Server provides a tool called Microsoft SQL Server Integration Services (SSIS) to handle ETL needs. Often the ETL process will involve the use of data staging area (DSA) between the OLTP and the DW.

<br/>


## The Business Intelligence Semantic Model

This is Microsoft's latest model for supporting the entire BI stack of applications. The idea is to provide **rich, flexible, efficient**, and **scalable analytical** andreporting capabilities.

The deployment of the model can be in:

- Analysis Services server
- PowerPivot

Analysis Services server is targed at BI professionals and IT, whereas PowerPivot is targeted at business users. With Analysis Services, you can use either a **multidimensional data model* or a **tabular (relational) one*. 

With PowerPivot, you use a **tabular data model***. 





















