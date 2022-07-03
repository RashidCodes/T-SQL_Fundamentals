-- create dbo.test_table and populate it
if object_id('dbo.test_table') is not null  
    drop table dbo.test_table;
go 

create table dbo.test_table (
    ident int identity(1,1),
    name binary(32)
);
go


set nocount on;
declare @count as int  = 0;

-- random numbers can be generated twice (remove duplicates subsequently)
while @count <= 10
begin 
    declare @somevar as binary(32) = hashbytes('SHA', cast(rand() as varchar(100)));
    insert into dbo.test_table values (@somevar);

    set @count = @count + 1;
end
go


-- remove the duplicates if there are any
-- looks like we had a few duplicates
drop table if exists #test_table;
go 

set nocount on;
with a as (
    select *,
        row_number() over (partition by name order by name) row_num
    from dbo.test_table 
) 
select *
into #test_table 
from a 
where row_num < 2;



-- drop the table and recreate it
if object_id('dbo.test_table') is not null  
    drop table dbo.test_table;

create table dbo.test_table (
    ident int identity(1,1),
    name binary(32)
);

insert into dbo.test_table (name) 
    select [name]
    from #test_table;




drop table if exists #results;
go 

with a as (
    select  
        t1.ident as t9ident,
        t1.name as t1name,
        t2.name as t2name,
        t3.name as t3name, -- this is where performance degrades
        t4.name as t4name,
        t5.name as t5name,
        t6.name as t6name,
        t7.name as t7name,
        t8.name as t8name,
        t9.name as t9name
    from dbo.test_table t1 
    cross apply dbo.test_table t2 
    cross apply dbo.test_table t3 
    cross apply dbo.test_table t4 
    cross apply dbo.test_table t5
    cross apply dbo.test_table t6 
    cross apply dbo.test_table t7 
    cross apply dbo.test_table t8 
    cross apply dbo.test_table t9 -- add more cross apply operators to expand 
    cross apply dbo.test_table t10
    where t1.ident > t2.ident
        and t2.ident > t3.ident 
        and t3.ident > t4.ident
        and t4.ident > t5.ident 
        and t5.ident > t6.ident 
        and t6.ident > t7.ident
        and t7.ident > t8.ident 
        and t8.ident > t9.ident
        and t9.ident > t10.ident
),

b as (
    select *,
        row_number() over (partition by t9ident order by t9ident) as row_num
    from a
)

select * 
into #results
from b 
where row_num < 2;
go 

select count(*) 'Number of records' 
from #results;
go 

select top 10 * 
from #results;
