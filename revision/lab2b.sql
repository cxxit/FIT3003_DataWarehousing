-- PART 1: The International College Case Study --
-- Explore the Dataset 
select * from opdb.student; -- 5 records/students 
select * from opdb.campus; -- 2 campus 
select * from opdb.course; -- 4 courses
select * from opdb.agent; -- 2 agents 
select * from opdb.enrolment; -- 8 enrolments
select * from opdb.payment; -- 10 payments made 

-- CREATING STAR SCHEMA -- 
drop table AgentDim;
drop table CountryDim;
drop table CourseDim;
drop table YearDim;
drop table CollegeFact;


-- Agent Dimension
create table AgentDim as
select * from opdb.Agent;

select * from AgentDim;

--Country Dimension
create table CountryDim as 
select distinct Country
from opdb.Student;

select * from CountryDim;

--Course Dimension
create table CourseDim as
select CourseCode, CourseName, Duration, CourseLevel
from opdb.Course;

select * from CourseDim;

--Year Dimension
create table YearDim as
select distinct EnrolmentYear
from opdb.Enrolment;

select * from YearDim;

--Fact Table
create table CollegeFact as
select
  S.Country,
  E.AgentNo,
  E.CourseCode,
  E.EnrolmentYear,
  count(p.PaymentNo) as Number_of_payments,
  sum(P.Amount) as Total_Income
from opdb.Student S, opdb.Enrolment E, opdb.Payment P
where E.EnrolmentNo = P.EnrolmentNo
  and E.StudentID = S.StudentID
group by
  S.Country,
  E.AgentNo,
  E.CourseCode,
  E.EnrolmentYear;
  
select * from CollegeFact;


-- The College now requires a data warehouse for analysis purposes. 
-- The analysis is needed for identifying at least the following questions:

-- What is the total income coming from Australia?
select country, sum(total_income) as total_income
from COLLEGEFACT
where upper(country) = upper('Australia')
group by country; -- 239800

-- What is the total income for each course?
select * from collegefact
order by coursecode;
select * from coursedim;

select coursecode, coursename, sum(total_income) as total_income
from COLLEGEFACT
join coursedim
using (coursecode)
group by coursecode, coursename
order by coursecode; -- CHECKED

-- SOLUTION -- 
select f.coursecode,c.courseName,sum(Total_income) as total_income
from CollegeFact f join courseDIM c on f.coursecode = c.coursecode
group by f.coursecode,c.courseName; -- CHECKED

-- What is the total income for the Master of Data Science course(C6003) in 2019?
select * from collegefact;

select coursecode, coursename,enrolmentyear, sum(total_income) as total_income
from COLLEGEFACT
join COURSEDIM
using (coursecode)
where upper(coursename) = upper('Master of Data Science') and enrolmentyear = 2019
group by coursecode, coursename, enrolmentyear;

-- SOLUTION --
select EnrolmentYear, CourseCode, sum(Total_Income) as Total_Income
from CollegeFact
where EnrolmentYear = 2019 and
	CourseCode = 'C6003'
group by EnrolmentYear, CourseCode;

-- What is the total income from New Star Agent?
select * from collegefact;
select distinct agentno, agentname
from CollegeFact
join AGENTDIM
using (agentno);

select agentno, agentname, sum(total_income) as total_income
from collegefact 
join agentdim 
using (agentno)
where upper(agentname) = upper('New Star Agent')
group by agentno, agentname;

-- SOLUTION -- 
select A.AgentName, sum(Total_income) as Total_Income
from AgentDim A, CollegeFact C
where A.AgentNo = C.AgentNo and
	A.AgentName = 'New Star Agent'
group by A.AgentName;

-- ADDITIONAL QUERIES 
-- How many students come from certain countries 
select * from collegefact;
select * from studentdim;


-- PART 2: THE SALES CASE STUDY (QUARTER) 
-- explore the sales operational system database 

select * from opdb.branch;
select * from opdb.sales;
select * from opdb.product;
select * from opdb.category;

-- the manager would like to analyse total sales so a star schema is created 
-- drop tables
drop table timeDim; 
drop table prodCategoryDim; 
drop table branchDim; 

-- create dimensions 
create table prodCategoryDim as 
select * from opdb.category;

select * from PRODCATEGORYDIM;

create table branchDim as 
select * from opdb.branch;

select * from BRANCHDIM;

-- Create Time Dimensions 
-- create Quarter attribute as ()
-- 12/4 = 3
create table timeDim 
(
  Quarter number(1), 
  Description varchar2(20)
);

insert into timeDim values (1,'Jan-Mar');
insert into timeDim values (2,'Apr-Jun');
insert into timeDim values (3,'Jul-Sep');
insert into timeDim values (4,'Oct-Dec');

select * from timeDim;

-- create a temp sales fact then only a sales fact because the information of Quarter is not in the operational database 
-- we need to derive what quarter the sales is made based on the SalesDate attribute in SALES
-- why not use the CategoryDim table but use the operational database Category table
drop table tempSalesFact;

create table tempSalesFact as 
select S.SalesDate, B.BranchID, C.CategoryID, S.TotalPrice
from opdb.Sales S, opdb.Branch B, opdb.Product P, opdb.Category C
where S.BranchID = B.BranchID
and S.ProductNo = P.ProductNo
and P.CategoryID = C.CategoryID;

select * from TEMPSALESFACT;

alter table tempSalesFact
add (Quarter number(1));

update TEMPSALESFACT
set Quarter = 1
where to_char(SalesDate, 'MM') >='01' 
and to_char(SalesDate, 'MM') <= '03';

update TempSalesFact 
set Quarter = 2 
where to_char(SalesDate, 'MM') >= '04'
and to_char(SalesDate, 'MM') <= '06';

update TempSalesFact 
set Quarter = 3
where to_char(SalesDate, 'MM') >= '07'
and to_char(SalesDate, 'MM') <= '09';

update TempSalesFact 
set Quarter = 4
where to_char(SalesDate, 'MM') >= '10'
and to_char(SalesDate, 'MM') <= '12';


-- now create the SalesFact 
drop table salesfact;

create table salesfact as
select T.Quarter, T.BranchID, T.CategoryID, sum(T.TotalPrice) as Total_Sales 
from TempSalesFact T
group by T.Quarter, T.BranchID, T.CategoryID;

select * from salesfact
order by quarter, branchid, 
categoryid;

-- Show the total sales in different quarter (CHECKED-CORRECT)
select quarter, sum(total_sales) as Total_Sales
from salesfact 
group by quarter;

-- Show the total sales for different branches and product categories. (CHECKED-CORRECT)
select branchid, categoryid, sum(total_sales) as total_sales
from salesfact
group by branchid, categoryid;

-- Show the total sales of Kitchen supplies in Quarter 1 (CHECKED-CORRECT)
select quarter, categoryID, categoryDesc, sum(total_sales) as total_sales
from salesfact 
join PRODCATEGORYDIM
using (categoryID)
where upper(categoryDesc) = upper('Kitchen supplies') and Quarter = 1
group by quarter, categoryID, categoryDesc;

-- Part 3: The Sales Case Study (Month)
-- Create a star schema for the Sales data.
-- Analyse Total Sales 
-- create star schema using TimeDim (Month), BranchDim and ProdVategoryDim

drop table branchDim;
create table branchDim as 
select * from opdb.Branch;

select * from branchdim;

drop table prodCategoryDim;
create table prodCategoryDim as 
select * from opdb.category;

select * from PRODCATEGORYDIM;


drop table timedim;
-- create table timedim
-- (
--   MM number(2),
--   Month varchar2(20)
-- );

-- select * from timedim;

-- insert into timedim values(1, 'January');
-- insert into timedim values(2, 'February');
-- insert into timedim values(3, 'March');
-- insert into timedim values(4, 'April');
-- insert into timedim values(5, 'May');
-- insert into timedim values(6, 'June');
-- insert into timedim values(7, 'July');
-- insert into timedim values(8, 'August');
-- insert into timedim values(9, 'September');
-- insert into timedim values(10, 'October');
-- insert into timedim values(11, 'November');
-- insert into timedim values(12, 'December');

create table timedim as 
select distinct 
  to_char(salesdate, 'MM') as MM, 
  to_char(salesdate, 'Month') as Month_desc
from opdb.Sales;
select * from timedim;

-- dont need to create tempfact for sales fact because the dates in timedim are obtained through the operational database 
drop table salesfact;
create table salesfact as 
select to_char(S.SalesDate, 'Month') as Month, B.BranchID, P.CategoryID, sum(S.TotalPrice) as Total_Sales
from opdb.Sales S, opdb.Branch B, opdb.Product P
where S.BranchID = B.BranchID 
and S.ProductNo = P.ProductNo
group by to_char(S.SalesDate, 'Month'), B.BranchID, P.CategoryID;


select * from salesfact;


-- Show the total sales by different months. (CHECKED -- CORRECT)
select month, sum(total_sales) as total_sales
from salesfact
group by month;

-- Show the total sales by different branches and product categories. (CHECKED -- CORRECT)
select * from branchdim;
select * from prodcategorydim;

select b.branchid, b.address, pc.categoryid, pc.categorydesc, sum(s.total_sales) as total_sales
from SALESFACT s, branchdim b, PRODCATEGORYDIM pc
where b.branchid = s.branchid and pc.categoryid = s.categoryid
group by b.branchid, b.address, pc.categoryid, pc.categorydesc;
