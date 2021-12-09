# SQL Server Architecture

## SQL Server Instances

A SQL Server Instance, as illustrated in Figure 1-5, is an installation of a SQL server database engine or service. You can install multiple instances of an on-premises SQL Server on the same computer. Each instance is completely independent of the others in terms of security, the data that it managers, and in all other aspects.

<img src="SQL Server Instances.png" />

<blockquote>At the logical level, two different instances residing on the same computer have no more in comon that two instances residing on two separate computers.</blockquote>

<br/>

## Why you might install serveral instances

### Save on support costs

For example, to be able to test functionality of features in reponse to support calls or reproduce errors that users encounter in the production environment, the support department needs local installations of SQL Server tha mimic the user's production environment in terms of version, edition, and service pack of SQL Server. If an organization has multiple user environments, the support department needs multiple installations of SQL Server. Rather than having multiple computers, each hosting a different installation of SQL Server, that must be supported separately, the support department can have one computer with multiple installed instances. 
This can also be achieved using multiple virtual machines.


<br>

### Data Segregation

Providers of database service sometimes need to guarantee their customers complete security separation of their dat from other customer's data.



