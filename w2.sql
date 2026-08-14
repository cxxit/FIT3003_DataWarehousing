-- The College now requires a data warehouse for analysis purposes. The analysis is needed for identifying at least the following questions:
-- What is the total income coming from certain countries? (totalincome - fact, countries - dimensions)
-- What is the total income for certain postgraduate courses in a certain year? (totalincome - fact, postgraduatecourses, year - dimensions)
-- What is the total income as a result of each agent? (totalincome - fact, agent - dimensions)
-- How many payments are generated each year? (number_of_payments - fact, year - dimensions)
-- Dimensions: CountryDIM (STUDENT), YearDIM (PAYMENT), CourseDIM (COURSE), AgentDIM (AGENT)
-- Fact: CollegeFACT - Country, AgentNo, CourseCode, EnrolmentYear; Number_of_Payments, Total_income


-- STAR SCHEMA

/*
  drop table AgentDim;
  drop table CountryDim;
  drop table CourseDim;
  drop table YearDim;
  drop table CollegeFact;
*/

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

--Fact Table (!! I dont understand why do we take the required information for the FACT from the original table and not from the dimensions)
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


-- TASK A
select sum(total_income) as total_income_aus
from CollegeFact
where upper(Country) = upper('Australia');


-- TASK B 
--  !! NUMERIC has to be right-aligned
select coursecode, coursename, lpad(sum(total_income), length('total_income')) as total_income
from CollegeFact 
natural join COURSEDIM
group by coursecode, coursename
order by coursecode;

-- TASK C
select coursecode, coursename, sum(total_income) as total_income
from CollegeFact 
natural join COURSEDIM
where upper(coursename) = upper('Master of Data Science') and enrolmentyear = 2019
group by coursecode, coursename;


-- Task D
-- select * from opdb.agent;
-- select * from collegefact;
-- select * from agentdim;

select agentname, sum(total_income) as total_income
from collegefact 
natural join agentdim
where upper(agentname) = upper('New Star Agent')
group by agentname;

-- select agentno, sum(total_income)
-- from COLLEGEFACT
-- where agentno=1
-- group by agentno;


-- PART 2: The Sales Case Study (Quarter)
select * from opdb.branch;
select * from opdb.product;
select * from opdb.sales;
select * from opdb.category;


-- STAR SCHEMA 2

/*
  drop table ProdCategoryDim;
  drop table BranchDim;
  drop table TimeDim;
  drop table TempFact;
  drop table SalesFact;
*/

-- Prodcategory Dimension
create table ProdCategoryDim as
select * from opdb.Category;

select * from ProdCategoryDim;

-- Branch Dimension
create table BranchDim as
select * from opdb.Branch;

select * from BranchDim;

--Time Dimension
create table TimeDim
(
  Quarter number(1),
  Description varchar2(20)
);

insert into TimeDim values (1, 'Jan-Mar');
insert into TimeDim values (2, 'Apr-Jun');
insert into TimeDim values (3, 'Jul-Sep');
insert into TimeDim values (4, 'Oct-Dec');

select * from TimeDim;

-- TempFact Table
create table TempFact as
select S.SalesDate, B.BranchID, C.CategoryID, S.TotalPrice
from opdb.Branch B, opdb.Sales S, opdb.Product P, opdb.Category C
where B.BranchID = S.BranchID
and S.ProductNo = P.ProductNo
and P.CategoryID = C.CategoryID;

alter table TempFact
add (Quarter number(1));

update TempFact
set Quarter = 1
where to_char(SalesDate, 'MM') >= '01'
and to_char(SalesDate, 'MM') <= '03';

update TempFact
set Quarter = 2
where to_char(SalesDate, 'MM') >= '04'
and to_char(SalesDate, 'MM') <= '06';

update TempFact
set Quarter = 3
where to_char(SalesDate, 'MM') >= '07'
and to_char(SalesDate, 'MM') <= '09';

update TempFact
set Quarter = 4
where Quarter is null;

select * from TempFact;

-- SalesFact Table
create table SalesFact as
select Quarter, BranchID, CategoryID,
sum(TotalPrice) as Total_Sales
from TempFact
group by Quarter, BranchID, CategoryID;

select * from SalesFact;


-- TASK A2
select quarter, description, sum(total_sales) as total_sales
from salesfact
natural join timedim
group by quarter, description;


-- TASK B2
select branchid, address, categoryid, categorydesc, lpad(sum(total_sales), length('total_sales')) as total_sales
from salesfact
natural join PRODCATEGORYDIM
natural join BRANCHDIM
group by branchid, address, categoryid, categorydesc;


-- TASK C2
select quarter, categorydesc, lpad(sum(total_sales), length('total_sales')) as total_sales
from SALESFACT
natural join PRODCATEGORYDIM
where quarter = 1 and upper(categorydesc) = upper('Kitchen supplies')
group by quarter, categorydesc;


-- TASK 3: The Sales Case Study (Month)
select * from opdb.branch;
select * from opdb.product;
select * from opdb.sales;
select * from opdb.category;


-- STAR SCHEMA 3
-- The manager would like to analyse Total Sales from 
-- various point of views, including Time (month), 
-- Branch, and Product Category

--Time Dimension
drop table TimeDim2;
create table TimeDim2
as select distinct to_char(salesdate, 'Month') as Month
from opdb.Sales;

select * from TimeDim2;


create table SalesFact2 as 
select to_char(SalesDate, 'Month') as Month, branchid, categoryid,
sum(totalprice) as total_sales
from opdb.Sales 
natural join opdb.PRODUCT
group by to_char(SalesDate, 'Month'), BranchID, CategoryID;

select * from SalesFact2;

-- TASK 3
-- TASK A3
select month, sum(total_sales) as total_sales
from salesfact2
group by month;

-- TASK B3
select branchid, address, categoryid, categorydesc, sum(total_sales)
from SALESFACT2
natural join BRANCHDIM
natural join PRODCATEGORYDIM
group by branchid, address, categoryid, categorydesc;


-- LAB 2A --
create table subject2
(
    UCode CHAR(5) NOT NULL PRIMARY KEY,
    UTitle VARCHAR2(20) NOT NULL,
    UCredit NUMBER(2) NOT NULL
);
select * from subject2;
insert into subject2 values('IT001', 'Database', 5);
insert into subject2 values('IT002', 'Java', 5);
insert into subject2 values('IT003', 'SAP', 10);
insert into subject2 values('IT004', 'Network', 5);
insert into subject2 values('IT005', 'ASP.net', 5);

drop table studdent2;
create table student2
as select * from dtaniar.student2;

desc student2;























