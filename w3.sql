-- Explore the data
select * from dw.major;
select count(*) from dw.major; -- 172 rows 

select * from dw.uselog;
-- the question doesnt want the date and time instead it wants the semester


-- semester dimensions uses uselog table log datae and log time

-- create the 4 dimensions based on the googledoc lab-uselog
--first create the dimensions
--create semester dimension

drop table semesterDIM;
create table semesterDIM
(SemID      varchar2(10),
 Sem_Desc   varchar2(20),
 begin_date date,
 end_date   date);

-- create time dimension (note do not use time as a
-- table name, it is a reserved keyword)

drop table labtimeDIM;
create table labtimeDIM
(TimeID     number,
Time_Desc   varchar2(15),
begin_time  date,
end_time    date);

-- create major and class dimensions

drop table majorDIM;
create table majorDIM as
select * from dw.major;

drop table classDIM;
create table classDIM as
select * from dw.class;


-- populate semester dimension 
-- (the begin and end date can be changed)

insert into semesterDIM values ('S1', 'Semester1', to_date('01-JAN', 'DD-MON'), to_date('15-JUL', 'DD-MON'));

insert into semesterDIM values ('S2', 'Semester2', to_date('16-JUL', 'DD-MON'), to_date('31-DEC', 'DD-MON'));

select * from semesterDIM;
--populate labtime dimension
insert into labtimeDIM values(1, 'morning', to_date('06:01', 'HH24:MI'), to_date('12:00', 'HH24:MI'));

insert into labtimeDIM values(2, 'afternoon', to_date('12:01', 'HH24:MI'), to_date('18:00', 'HH24:MI'));

insert into labtimeDIM values(3, 'night', to_date('18:01', 'HH24:MI'), to_date('06:00', 'HH24:MI'));

select timeid, time_desc, to_char(begin_time, 'HH24:MI'), to_char(end_time, 'HH24:MI') 
from labtimeDIM;

select * from labtimedim;
-- secondly, create a temp table to extract from uselog table
-- create a temp fact table 

drop table tempfact_uselog;
create table tempfact_uselog as
select U.log_date , U.log_time,
U.student_ID, S.class_id, S.major_code
from dw.uselog U, dw.student S
where U.student_id = S.student_id;


SELECT TO_CHAR(log_date, 'dd-mm-yyyy') AS log_date,
        TO_CHAR(log_time, 'HH24:MI') AS log_time, student_id, class_id, major_Code
FROM tempfact_uselog;


-- add a column in the tempfact table to store timeid
-- (cannot directly do this in the tempfact table because
-- log_time was of DATE type and timeid is of NUMBER type).
alter table tempfact_uselog
add (timeid number);

select * from tempfact_uselog;

update tempfact_uselog
set timeid = 1
where  to_char(log_time, 'HH24:MI') >= '06:01'
and to_char(log_time, 'HH24:MI') <='12:00';

update tempfact_uselog
set timeid = 2
where  to_char(log_time, 'HH24:MI') >= '12:01'
and to_char(log_time, 'HH24:MI') <='18:00';

-- note that we use OR in the last update statement to
-- include the time between 18:01 and 06:00.

update tempfact_uselog
set timeid = 3
where to_char(log_time, 'HH24:MI') >= '18:01'
or to_char(log_time, 'HH24:MI') <='06:00';

-- alternatively, you may want to update timeid=3 
-- for all other records where the time_id is still empty
-- update tempfact_uselog
-- set timeid = 3
-- where timeid is NULL;

-- add a column in the tempfact_uselog table to store semid
-- (cannot directly do this in the test table because
-- log_date was of DATE type and semid is of VARCHAR type.)

alter table tempfact_uselog
add (semid varchar2(10));

-- populate the new attribute semid by summarizing
-- the date(log_date)

update tempfact_uselog
set semid = 'S1'
where to_char(log_date, 'MMDD') >= '0101'
and to_char(log_date, 'MMDD') <= '0715';

update tempfact_uselog
set semid = 'S2'
where to_char(log_date, 'MMDD') >= '0716'
and to_char(log_date, 'MMDD') <= '1231';

select * from tempfact_uselog;

-- Now, create the fact table,
-- make sure to include the TOTAL aggregate.
-- This is an aggregate table of the earlier tempfact table.

create table fact_uselog as
select t.semid, t.timeid, t.class_id,
t.major_code, count(t.student_id) as total_usage
from tempfact_uselog t
group by t.semid, t.timeid, t.class_id, t.major_code;


select * from fact_uselog;


-- number of records in 'tempfact_uselog'
select count(*) from tempfact_uselog; -- 170610


-- number of records in 'fact_uselog;
select count(*) from FACT_USELOG; -- 1363


-- why the discrepancies between them ???
-- because for fact_uselog we group by for each similar semid, timeid, major_code, and class_id
-- they are aggregated by the 4 dimensions and you calculate the fact measures 

-- Question 10
-- Compare the number of records between ‘tempfact_uselog’ and ‘dw.uselog’. 
-- Why is the number of rows different between these 2 tables?

-- for tempfact_uselog no. of rows
select count(*) from TEMPFACT_USELOG; --170610
-- for uselog no. of rows
select count(*) from dw.uselog; -- 108267


select * from tempfact_uselog
order by student_id, log_date, log_time; -- this shows there is duplicated values in tempfact_uselog

select * from dw.USELOG
order by student_id, log_date, log_time; -- there is duplication in this table

select * from dw.student
order by student_id; -- there is also duplication here 

-- Question 12 
-- content dw.uselog from operational database
Select log_date, 
to_char(log_time, 'HH24:MI') as log_time,
student_ID, act
From dw.uselog
order by student_id, log_date, log_time; -- barely any redundant, only a few

-- content from data warehousing
Select log_date,
to_char(log_time, 'HH24:MI') as log_time,
student_ID
From tempfact_uselog; -- there is duplicated values

select * from tempfact_uselog; -- a lot of redundancy 
-- this is caused by the student table because for each student_id there is duplicated records


select count(*) from (
    select student_ID, count(*)
    from dw.student
    group by student_id); -- 23663
-- this suggests that there is too many redundant records
-- the student table is corrupted with many redundant records


-- Clean up the data
-- the use of distinct removes whole records which are duplicates
create table tempfact_uselog2 as
select distinct U.log_date , U.log_time,
U.student_ID, S.class_id, S.major_code
from dw.uselog U, dw.student S
where U.student_id = S.student_id;

select count(*) from tempfact_uselog2; --108261
select count(*) from dw.uselog; -- 108267
-- What happened to that missing 6 records 

select log_date, log_time, student_id, act, count(*)
from dw.uselog
group by log_date, log_time, student_id, act
having count(*) > 1; -- this shows there is duplication in uselog table

select * from tempfact_uselog2;

alter table tempfact_uselog2
add (timeid number);

update tempfact_uselog2
set timeid = 1
where  to_char(log_time, 'HH24:MI') >= '06:01'
and to_char(log_time, 'HH24:MI') <='12:00'; -- 39921 rows added


update tempfact_uselog2
set timeid = 2
where  to_char(log_time, 'HH24:MI') >= '12:01'
and to_char(log_time, 'HH24:MI') <='18:00'; -- 48261 rows added 

update tempfact_uselog2
set timeid = 3
where to_char(log_time, 'HH24:MI') >= '18:01'
or to_char(log_time, 'HH24:MI') <='06:00'; -- 20079 rows added 


alter table tempfact_uselog2
add (semid varchar2(10));

update tempfact_uselog2
set semid = 'S1'
where to_char(log_date, 'MMDD') >= '0101'
and to_char(log_date, 'MMDD') <= '0715'; -- 57621 rows added 

update tempfact_uselog2
set semid = 'S2'
where to_char(log_date, 'MMDD') >= '0716'
and to_char(log_date, 'MMDD') <= '1231'; -- 50649 rows added 


create table fact_uselog2 as
select t.semid, t.timeid, t.class_id,
t.major_code, count(t.student_id) as total_usage
from tempfact_uselog2 t
group by t.semid, t.timeid, t.class_id, t.major_code;


SELECT * FROM fact_uselog2
ORDER BY class_id, major_Code;


SELECT * FROM fact_uselog
ORDER BY class_id, major_Code;

-- tips for assignment 2 
-- you will be given tables 
-- and you will have to check for redundant and dirty data 
-- and makes sense with it



-- LAB 3B (ROBCOR)
-- why is there two entity with the exact same attributes 

----------------ROBCOR Case Study ---------------------
SELECT * FROM dw.charter;
-- for every charter there must be a pilot, but copilot is optional
SELECT * FROM dw.pilot;
SELECT * FROM dw.employee;
SELECT * FROM dw.aircraft;
SELECT * FROM dw.model;
SELECT * FROM dw.customer;
SELECT * FROM dw.pilot_1; -- ghost table, does not exists

DESCRIBE dw.charter;
DESCRIBE dw.pilot;

-- QUESTION 2 
-- Yes we see that table pilot1 does not exists

-- QUESTION 3
-- charter table has relationship with the pilot1 table

-- Are there any rows in the CHARTER table that contains invalid pilot's or co-pilot's number?
SELECT *
FROM dw.charter
WHERE char_pilot NOT IN (SELECT emp_num FROM dw.pilot)
OR char_copilot NOT IN (SELECT emp_num FROM dw.pilot); -- none of it 
-- that means all the pilot and copilot are valid employees, with valid emp_num

-- QUESTION 5
-- are there mistakes where pilot and copilot are the same person 
select * 
from dw.charter 
where char_pilot = char_copilot; -- None, that means there is no error regarding invalid pilot and copilot instances in a charter 

SELECT *
FROM dw.charter
WHERE char_copilot IS NULL; -- there are about 300 records of which copilot is null

SELECT *
FROM dw.charter
WHERE char_pilot IS NULL; -- no pilot in a charter is null thus the charter would be valid 
-- since if it is a small short flight one pilot would be enough 

-- QUESTION 6 
select * from dw.charter;
select char_trip, count(*)
from dw.charter
group by char_trip
having count(*) > 1;

select * 
from dw.charter
where char_trip = 10268; -- will this affect making the data warehouse ? 

select * from dw.customer;
select cus_lname, cus_fname, count(*)
from dw.customer
group by cus_lname, cus_fname
having count(*)>1; -- check if there is any customer have the same name
-- but not ideal because it is possible which cus_lname, and cus_fname is the same 
-- in the case where pk is missing, we use the whole record to check if the whole record is duplicated 


-- QUESTION 7
-- beside redundant records what other dirty records can wew check for 
-- Duplication problems
-- Relationship problems
-- Inconsistent values 
-- Incorrect values 
-- The null value problems
select * from dw.charter;
-- check for invalid values 
select * from dw.charter
where char_distance <= 0 
or char_fuel_gallons <= 0;


-- Part B: Data Cleaning and Star Schema implementation 
--First create the dimensions
create table time_dim As
select Distinct to_char(char_date, 'YYYYMM') as Time_ID,
                to_char(char_date, 'Month') as Time_Month,
                to_char(char_date, 'YYYY') as Time_Year
from dw.Charter;

create table model_dim as
select * from dw.model;

create table pilot_dim as
select * from dw.pilot;

--Second, create the Charter_fact (the fact table) table
create table charter_fact as
select C.Char_Pilot as EMP_Num,
       M.Mod_Code,
       to_char(C.Char_Date, 'YYYYMM') as Time_ID,
       sum(C.Char_Hours_Flown) as Tot_Char_Hours, 
       sum(C.Char_Fuel_Gallons) as Tot_Fuel,
       sum(C.Char_Distance * M.Mod_chg_mile) as Revenue
from   dw.Charter C, dw.Model M, dw.Aircraft A
where  C.AC_Number=A.AC_Number and A.Mod_Code=M.Mod_Code
group by C.Char_Pilot, M.Mod_Code, to_char(C.Char_Date, 'YYYYMM');

select count(*) from charter_fact; -- 480 rows 

-- After creating the charter_fact, does the charter_fact table 
-- accurately reflect the total hours flown by each pilot?
select * from charter_fact
order by emp_num;


SELECT emp_num, SUM(tot_char_hours) as Total_hours
FROM CHARTER_FACT
where emp_num = 101
GROUP BY emp_num; -- 672.7 hours


select sum(char_hours_flown) as  Total_hours
from dw.charter 
where char_pilot = 101
or char_copilot = 101; -- total hours 1053.2


-- WHY IS IT MORE?
-- it shows that we only count the pilot total hours not the copilot total hours 
-- we did not include when he/she is assign as copilot
-- ideally for this its best to have two seperate data warehouse, one for pilot and one for copilot 
















