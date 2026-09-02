-- Create table SUBJECT2 and insert the above 5 records.
drop table subject2;
Create Table SUBJECT2 (
UCode Varchar2(10) NOT NULL,
UTitle Varchar2(20) NOT NULL,
UCredit Number(2),
PRIMARY KEY (Ucode)
);
Insert Into SUBJECT2 Values ('IT001', 'Database', 5);
Insert Into SUBJECT2 Values ('IT002', 'Java', 5);
Insert Into SUBJECT2 Values ('IT003', 'SAP', 10);
Insert Into SUBJECT2 Values ('IT004', 'Network', 5);
Insert Into SUBJECT2 Values ('IT005', 'ASP.NET', 5);

-- student2 table
select * from subject2;

drop table student2;
create table student2 as 
select * from DTANIAR.student2;

select * from student2;

-- describe table student2 
desc student2;

-- display all records from student2 
select * from student2;

-- insert missing records to table student2
insert into student2 values ('10008', 'Miller', 'Larry', 'M', '22-Jul-73', 211);
Insert Into STUDENT2 Values ('10009', 'Smith', 'Leonard', 'M', to_date('26-05-1985', 'DD-MM-YYYY'), 211);
Insert Into STUDENT2 Values ('10010', 'Brown', 'Menson', 'M', to_date('12-07-1983', 'DD-MM-YYYY'), 112);

-- import tables offering2 and enrollment2 from dtaniar
drop table offering2;
create table offering2 as 
select * from DTANIAR.offering2;

drop table enrollment2;
create table enrollment2 as
select * from dtaniar.ENROLLMENT2;

select * from offering2;

select * from enrollment2;

-- How many students enrolled in the Database unit offered in Main campus (CHECKED -- CORRECT)
select f.ocampus, f.ucode, u.utitle, count(s.SID) as number_of_students
from OFFERING2 f, enrollment2 e, student2 s, subject2 u
where f.OID = e.OID
and e.SID = s.SID 
and f.ucode = u.ucode
and upper(ocampus) = upper('Main')
and upper(utitle) = upper('Database')
group by f.ocampus, f.ucode, u.utitle;

-- What is the total score of students taking the Database unit in Main campus? (CHECKED -- CORRECT)
select * from enrollment2;
select f.ocampus, f.ucode, u.utitle, sum(e.score) as total_score
from ENROLLMENT2 e, offering2 f, subject2 u
where f.OID = e.OID
and f.Ucode = u.Ucode
and upper(f.ocampus) = upper('Main')
and upper(u.utitle) = upper('Database')
group by f.ocampus, f.ucode, u.utitle;

-- How many students enrolled in the Java unit offered in Semester 2, 2009? (CHECKED -- CORRECT)
select * from offering2;

select f.osem, f.oyear, u.utitle, count(s.SID) as number_of_students
from offering2 f, subject2 u, student2 s, enrollment2 e
where f.OID = e.OID
and e.SID = s.SID
and f.Ucode = u.Ucode
and f.osem = 2
and f.oyear = 2009
and upper(u.utitle) like '%JAVA%'
group by f.osem, f.oyear, u.utitle;

desc offering2;


-- What is the total score of students taking the Java unit in Semester 2, 2009? (CHECKED--CORRECT)
select f.osem, f.oyear, u.utitle, sum(e.score) as total_score 
from offering2 f, subject2 u, enrollment2 e 
where f.ucode = u.ucode 
and f.OID = e.OID 
and upper(u.utitle) like '%JAVA%'
and f.osem = 2
and f.oyear = 2009
group by f.osem, f.oyear, u.utitle;


-- How many students received HD in the SAP unit offered in Semester 1, 2009? (CHECKED--CORRECT, can show empty records or 0)
select * from subject2;

select count(e.sid) as number_of_students
from offering2 f, enrollment2 e, subject2 u 
where f.OID = e.OID 
and f.ucode = u.ucode 
and upper(e.grade) = upper('HD')
and upper(u.utitle) like '%SAP%';

-- IMPLEMENTING STAR SCHEMA
drop table campus_dim;
create table campus_dim as 
select distinct ocampus from offering2;

select * from campus_dim;

drop table grade_dim;
create table grade_dim as 
select distinct grade from enrollment2;

select * from grade_dim;

drop table subject_dim;
create table subject_dim as 
select * from subject2;

select * from SUBJECT_DIM;

drop table sem_year_dim;
create table sem_year_dim as 
select distinct oyear||osem as sem_id, osem, oyear
from offering2;

select * from sem_year_dim;

drop table student_enrollment_fact;
create table student_enrollment_fact as 
select f.ocampus, e.grade, u.ucode, f.oyear||f.osem as sem_id, count(s.SID) as number_of_student, sum(e.score) as total_score
from offering2 f, enrollment2 e, subject2 u, student2 s
where f.OID = e.OID
and f.ucode = u.ucode
and e.SID = s.SID
group by f.ocampus, e.grade, u.ucode, f.oyear||f.osem;

select * from student_enrollment_fact;

-- Use the star schema that you have created, 
-- display the average score of each unit (show unit name) offered in 2009. 

select sef.ucode, u.utitle, sum(sef.total_score)/sum(sef.number_of_student) as avg_score
from student_enrollment_fact sef, subject2 u
where sef.ucode = u.ucode
group by  sef.ucode, u.utitle;


-- Use the star schema that you have created, 
-- display the average score of each unit offered in main campus. 

select sef.ucode, u.utitle, sum(sef.total_score)/sum(sef.number_of_student) as avg_score
from student_enrollment_fact sef, subject2 u
where sef.ucode = u.ucode
and upper(sef.ocampus) like '%MAIN%'
group by sef.ucode, u.utitle;


-- Use the star schema that you have created, 
-- display the average score of the Database unit with the grade N

select u.utitle, sef.grade, sum(sef.total_score)/sum(sef.number_of_student) as avg_score
from student_enrollment_fact sef, subject2 u
where sef.ucode = u.ucode
and upper(u.utitle) = upper('Database')
and upper(grade) = upper('N')
group by u.utitle, sef.grade;


