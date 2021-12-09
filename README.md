# Databases

You can think of a database as a container of objcts such as tables, views, stored procedures, and other objects. When you install an on-premises flavor of SQL Server, the setup program creates several system databases that hold system data and server internal purposes. You can create your own databases that will hold application data after the installation.

The system databases that the setup program create includes *master*, *Resource*, *model*, *tempdb*, and *msdb*.

<br/>

## The Physical layer of a database

If you're using SQL Databaes, your only concern is taht logical layer. You do not deal with the physical layout of the database data and log files, *tempdb*, and so on. But if you're using on-premises SQL Server, you are responsible for the physical layer as well. The figure below shows a diagram of the physical database layout.

<img src="Database layout.png" />

The database is made up of **data files** and **transaction log files**. When you create a database, you can define varous properties for each file, including the file name, location, initial size, maximum size, and an autogrowth increment. Each database must have at least one data file and at least one log file. 

<br/>

### The data files
The data files hold object data

<br/>

## The log files
The log files hold information that SQL Server needs to maintian transactions.


## Filegroups

Data files are organized in logical groups called **filegroups**. A filegroup is the target for creating an object, such as a table or index. The object data will be spreads across the files that belong to target filegroup. **Filegroups are your way of controlling the physical locatiosn of your objects.**
A database can have at least one file group called *PRIMARY*, and can optionally have other use filegroups as well. 


<br/>

### The ```PRIMARY``` Filegroup

The *PRIMARY* filegroup contains the primary data file (which has an ```.mdf``` extension) for the database, and the database's sytem catalog. You can optionally add secondary data files (whihc have the ```.ndf``` extension) to PRIMARY. User filegroups only contain secondary data file (which have an ```.ndf``` extension) to *PRIMARY*. User filegroups contain only secondary data files. You can decide which filegroup is marked as the default filegroup. Objects are created in the default filegroup when the object creation statement does not explicitly specify a differnt target group.








