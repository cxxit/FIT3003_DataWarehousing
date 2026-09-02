-- discover the uselof 3a database
select * from dw.uselog;
select * from dw.student;
select * from dw.major;
select * from dw.class;

-- create the star schema 
-- create dimensions
drop table semesterDim;
create table semesterDim 
(
    SemID varchar2(10),
    sem_desc varchar2(20),
    begin_date date,
    end_date date
);
select * from semesterdim;

drop table labtimedim;
create table labtimedim 
(
    timeid number, 
    time_desc varchar2(15),
    begin_time date, 
    end_time date
);

drop table majordim;
create table majordim as 
select * from dw.major;

drop table classdim;
create table classdim as 
select * from dw.class;

select * from classdim;

-- populate semester dimension 
insert into semesterdim values ('S1','Semester1', to_date('01-JAN','DD-MON'), to_date('15-JUL','DD-MON'));
insert into semesterdim values ('S2', 'Semester2', to_date('16-JUL', 'DD-MON'), to_date('31-DEC','DD-MON'));
select * from semesterdim;

-- populate labtime dimension 
select * from labtimedim;
insert into labtimedim values (1, 'morning', to_date('06:01','HH24:MI'), to_date('12:00','HH24:MI'));
insert into labtimedim values (2, 'afternoon', to_date('12:01','HH24:MI'), to_date('18:00','HH24:MI'));
insert into labtimedim values (3, 'night', to_date('18:01','HH24:MI'), to_date('06:00', 'HH24:MI'));

-- create tempfact 
-- WHY? 

select * from dw.uselog;
drop table tempfact_uselog;
create table tempfact_uselog as 
select u.log_date, u.log_time,s.student_id, s.class_id, s.major_code
from dw.uselog u, dw.student s
where u.student_id = s.student_id;

select * from tempfact_uselog;

alter table tempfact_uselog
add (semid varchar2(10));

alter table tempfact_uselog 
add (timeid number);

select * from labtimedim;
update TEMPFACT_USELOG
set timeid = 1
where to_char(log_time, 'HH24:MI') >= '06:01'
and to_char(log_time, 'HH24:MI') <= '12:00';

update TEMPFACT_USELOG
set timeid = 2
where to_char(log_time, 'HH24:MI') >= '12:01'
and to_char(log_time, 'HH24:MI') <= '18:00';


update TEMPFACT_USELOG
set timeid = 3
where to_char(log_time, 'HH24:MI') >= '18:01'
or to_char(log_time, 'HH24:MI') <= '06:00';

-- select * from tempfact_uselog 
-- where timeid is null;

select * from SEMESTERDIM;
select * from tempfact_uselog;
update TEMPFACT_USELOG
set semid = 'S1'
where to_char(log_date, 'MMDD') >= '0101'
and to_char(log_date, 'MMDD') <= '0715';

update tempfact_uselog 
set semid = 'S2'
where to_char(log_date, 'MMDD') >= '0716'
and to_char(log_date, 'MMDD') <= '1231';

-- select * from TEMPFACT_USELOG where semid is null;


--- CREATE FACT TABLE 
-- create fact_uselog 
drop table fact_uselog;
create table fact_uselog as 
select semid, timeid, class_id, major_code, count(student_id) as total_usage
from TEMPFACT_USELOG
group by semid, timeid, class_id, major_code;

select * from fact_uselog;

-- PART B: Data Exploration 
-- How many rows in ‘dw.student’?  (CHECKED--CORRECT)
select count(*) as number_of_rows 
from dw.student;

-- What does ‘dw.student’ look like? Write a SQL query 
-- to retrieve and review all columns and rows. (CHECKED--CORRECT)
select * from dw.student;

-- How many rows in ‘dw.uselog’? (CHECKED--CORRECT)
select count(*) as number_of_rows 
from dw.uselog;

-- What does ‘dw.uselog’ look like?  (CHECKED--CORRECT)
select * from dw.uselog;
select to_char(log_date, 'DD-MON-YYYY') as log_date, to_char(log_time, 'HH24:MI') as log_time, student_id, act
from dw.uselog;

-- How many rows in ‘dw.major’?  (CHECKED--CORRECT)
select count(*) as number_of_rows 
from dw.major;


-- What does ‘dw.major’ look like?  (CHECKED--CORRECT)
select * from dw.major;


-- How many rows in ‘dw.class’?  (CHECKED--CORRECT)
select count(*) as number_of_rows 
from dw.class;


-- What does ‘dw.class’ look like?
select * from dw.class;

-- We've explored all the tables in the data warehouse earlier. 
-- Does anything seem wrong?
select count(*) from fact_uselog;

select count(*) from tempfact_uselog;

-- fact_uselog is the aggregated version of tempfact_uselog
-- aggregate function count(nstudent_id) ised om fact_uselog groups all student_id columns which are 
-- the same together
-- thus, reducing the number of rows

-- fact_uselog would serve as a fact table, where the aggregated data is stored and used for analysis 


-- the relationship between dw.student and dw.uselog is one to many 
-- each student has at least one instance of logging in or many instances 

select log_date, to_char(log_time,'HH24:MI') as log_time, student_id, class_id, major_code, semid, timeid 
from tempfact_uselog;
select * from dw.uselog;
-- given that temfact uselog has an instance of uselog record for each student each time they are logged in 
-- shouldnt that mean the number of rows in uselog = number of rows in tempfact_uselog

-- NUMBER OF ROWS IN TEMPFACT_USELOG 
select count(*) number_of_rows
from tempfact_uselog; -- 170610 


-- NUMBER OF ROWS IN USELOG 
select count(*) number_of_rows 
from dw.uselog; -- 108267 

-- the number of records does not match, that means there may be issues with the data 
-- code use to create the tempfact_uselog:

-- create table tempfact_uselog as
-- select U.log_date , U.log_time,
-- U.student_ID, S.class_id, S.major_code
-- from dw.uselog U, dw.student S
-- where U.student_id = S.student_id;


-- tempfact_uselog uses both the table uselog and student
-- so let's check both of those table
select * from dw.student
order by student_id;

select student_id,count(student_id) number_repeated
from dw.student 
group by student_id
order by student_id;

-- from this code we can see that there is duplication of the student record in dw.student_id when there shouldnt be 
-- as student_id should represent the primary key 
-- and that each student only should have one student_id 
-- duplication could have cause what happened in tempfact_uselog 
-- there is dirty data originating from the dw.student table

select * from dw.uselog;
-- check for duplication of data in dw.uselog? 
select log_date, to_char(log_time,'HH24:MI'), student_id, act, count(*)
from dw.uselog
group by log_date, to_char(log_time,'HH24:MI'), student_id, act
having count(*) >1;

-- and this suggests that dw.uselog also has duplicated data 
select * from dw.uselog 
where student_id not in (
    select student_id from dw.student
); -- none 
-- thus all student recorded in uselog table is in the student table

select * from dw.student;
-- check if there is illegal class_id, and major_code in the student table 

select * from dw.student 
where class_id not in ( 
    select class_id from dw.class
); -- none 

select count(*) as count 
from (
select * from dw.student 
where major_code not in (
    select major_code from dw.major
)); -- 122 majors in student table is not listed in the major table
select * 
from dw.uselog, dw.student
where dw.uselog.student_id = dw.student.student_id
and dw.student.major_code NOT IN 
   (select major_code from dw.major);








