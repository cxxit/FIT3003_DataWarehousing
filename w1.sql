-- PART A. Managing Tables
-- Question 1
select * from TAB;

-- Question 2: Type in the following SQL statement
-- add delete table statement 
drop table lecturer cascade constraints purge;

CREATE TABLE LECTURER
(StaffNO 			NUMBER(6) 		NOT NULL, 
 Title				VARCHAR2(3),
 FName 				VARCHAR2(30),
 LName				VARCHAR2(30),
 StreetAddress		VARCHAR2(70), 
 Suburb				VARCHAR2(40), 
 City				VARCHAR2(40), 
 PostCode			VARCHAR2(4), 
 Country			VARCHAR2(30),
 LecturerLevel		CHAR(2), 
 BankNO				CHAR(20),
 BankName			VARCHAR2(40),
 Salary				NUMBER(8,2), 
 WorkLoad			NUMBER(2,1) 	NOT NULL, 
 ResearchArea			VARCHAR2(40),
 PRIMARY KEY(StaffNo));

 -- Question 3: 
select * from TAB;

 -- Question 4
insert into lecturer (
    staffno,
    title,
    fname,
    lname,
    streetaddress,
    suburb,
    city,
    postcode,
    country,
    lecturerlevel,
    bankno,
    bankname,
    salary,
    workload,
    researcharea
) values
    ( 1000,
      'Dr',
      'David',
      'Taniar',
      '3 Robinson Av',
      'Kew',
      'Melbourne',
      '3080',
      'Australia',
      '5',
      '1000567237',
      'CommBank',
      89000.00,
      2.0,
      'O-R DB' );
insert into lecturer (
    staffno,
    title,
    fname,
    lname,
    streetaddress,
    suburb,
    city,
    postcode,
    country,
    lecturerlevel,
    bankno,
    bankname,
    salary,
    workload,
    researcharea
) values
    ( 2000,
      'Ms',
      'Julie',
      'Main',
      '6 Algorithm Av',
      'Montmorency',
      'Melbourne',
      '3089',
      'Australia',
      '5',
      '1000123456',
      'CommBank',
      89000.00,
      2.0,
      'CBR' );

insert into lecturer values
    ( 3000,
      'Mr',
      'Daniel',
      'Wright',
      '22 Crystal Cres',
      'Alphington',
      'Melbourne',
      '3790',
      'Australia',
      '5',
      '1000654321',
      'CommBank',
      89000.00,
      2.0,
      'DB' );

insert into lecturer (
    staffno,
    title,
    fname,
    lname,
    streetaddress,
    suburb,
    postcode,
    country,
    researcharea,
    workload
) values
    ( 4000,
      'Mr',
      'RaiHong',
      'Lam',
      '12 Oracle Dr',
      'Fitzroy',
      '3424',
      'Australia',
      'Data Mining',
      1 );

-- Question 5 
select * from lecturer;

-- Question 6
drop table student cascade constraints purge;
CREATE TABLE STUDENT
(StudentNO			NUMBER(6)	NOT NULL, 
 DOB				DATE, 
 FName 			    VARCHAR2(30),
 LName			    VARCHAR2(30),
 -- city spelt CiTTy
 CiTTy			    VARCHAR2(40),
 PostCode			VARCHAR2(4), 
 Country			VARCHAR2(30),
 FeePaid			NUMBER(8,2), 
 LastFeeDate		DATE,
 PRIMARY KEY(StudentNo));

 -- Question 6b
 insert into student (
    studentno,
    dob,
    fname,
    lname,
    citty,
    postcode,
    country,
    feepaid,
    lastfeedate
 ) values (
    30001,
    TO_DATE('12-MAR-2001', 'DD-MON-YYYY'),
    'John',
    'Smith',
    'Melbourne',
    '3000',
    'Australia',
    10000.00,
    TO_DATE('12-MAR-2024', 'DD-MON-YYYY')
 );

 insert into student (
    studentno,
    dob,
    fname,
    lname,
    citty,
    postcode,
    country,
    feepaid,
    lastfeedate
 ) values (
    30002,
    TO_DATE('12-MAR-2001', 'DD-MON-YYYY'),
    'Jenny',
    'Smith',
    'Melbourne',
    '3000',
    'Australia',
    10000.00,
    TO_DATE('12-MAR-2024', 'DD-MON-YYYY')
 );

  insert into student (
    studentno,
    dob,
    fname,
    lname,
    citty,
    postcode,
    country,
    feepaid,
    lastfeedate
 ) values (
    30003,
    TO_DATE('12-MAR-2001', 'DD-MON-YYYY'),
    'Minnie',
    'Mouse',
    'Melbourne',
    '3000',
    'Australia',
    10000.00,
    TO_DATE('12-MAR-2024', 'DD-MON-YYYY')
 );

  insert into student (
    studentno,
    dob,
    fname,
    lname,
    citty,
    postcode,
    country,
    feepaid,
    lastfeedate
 ) values (
    30004,
    TO_DATE('12-MAR-2001', 'DD-MON-YYYY'),
    'Mickey',
    'Mouse',
    'Melbourne',
    '3000',
    'Australia',
    10000.00,
    TO_DATE('12-MAR-2024', 'DD-MON-YYYY')
 );


  insert into student (
    studentno,
    dob,
    fname,
    lname,
    citty,
    postcode,
    country,
    feepaid,
    lastfeedate
 ) values (
    30005,
    TO_DATE('12-MAR-2001', 'DD-MON-YYYY'),
    'Hello',
    'Kitty',
    'Melbourne',
    '3000',
    'Australia',
    10000.00,
    TO_DATE('12-MAR-2024', 'DD-MON-YYYY')
 );

-- Question 7
ALTER TABLE STUDENT ADD 
(StreetAddress		VARCHAR2(70), 
 Suburb				VARCHAR2(40));

-- Question 8
desc student;

-- Question 9
ALTER TABLE STUDENT
DROP(CiTTy);

-- Question 10
ALTER TABLE STUDENT
ADD (City	CHAR(40));

-- Question 11 
ALTER TABLE STUDENT
MODIFY (City	VARCHAR2(40));

-- ALTERNATIVE to 9,10,11
-- this is best because you don't lose the data
alter table student rename column citty to city;

-- Question 12 
UPDATE STUDENT
SET StreetAddress = '12 New St'
WHERE StudentNo = 30001;

-- Question 13
ALTER TABLE STUDENT
ADD (PhoneNo    VARCHAR2(20));

ALTER TABLE STUDENT
DROP(suburb);

-- Question 14 
commit;

-- Question 15
-- DONE


-- Question 16

-- ADD LAB_SIGNUP Table
DROP TABLE LAB_SIGNUP CASCADE CONSTRAINTS PURGE;
Create Table LAB_SIGNUP 
As Select * 
From dtaniar.LAB_SIGNUP;

-- ADD LAB Table
DROP TABLE LAB CASCADE CONSTRAINTS PURGE;
Create Table LAB 
As Select * 
From dtaniar.LAB;

-- ADD TUTOR Table
DROP TABLE TUTOR CASCADE CONSTRAINTS PURGE;
Create Table TUTOR
As Select *
From dtaniar.TUTOR;

-- ADD SUBJECT Table
DROP TABLE SUBJECT CASCADE CONSTRAINTS PURGE;
Create Table SUBJECT
As Select * 
From dtaniar.SUBJECT;

-- ADD LECTURE Table
DROP TABLE LECTURE CASCADE CONSTRAINTS PURGE;
Create Table LECTURE
As Select *
From dtaniar.LECTURE;

-- ADD StUDENT_ENROLMENT Table
DROP TABLE STUDENT_ENROLMENT CASCADE CONSTRAINTS PURGE;
Create Table STUDENT_ENROLMENT
As Select *
From dtaniar.STUDENT_ENROLMENT;


-- Write an SQL statement to list all the lecturers and their lecture schedules
select * from lecturer;
select * from lecture;

select staffno, fname || ' ' || lname as lecturer_name, subjectcode, lectday, lecttime, venue
from lecturer
join lecture 
using (staffno);

-- Are there any lecturers who are not teaching?
select * 
from lecturer lr
join lecture l
on lr.staffno = l.staffno 
where l.staffno not in (select staffno from lecturer);

-- List all the subjects offered in the first semester.
select * 
from subject 
where semester = 1;

-- List all the students by first-name, last-name, date-of-birth, and fee-paid details, who are born after 1990 and before 1995.
select fname, lname, dob, feepaid
from student 
where dob > to_date(1990, 'YYYY') and dob < to_date(1995, 'YYYY');

-- List all the students enrolled in the database subject. (Note: database = CSE21DB, CSE31DB, CSE41FDB)
select distinct studentNo, FName, LName
from student s 
natural join student_enrolment se
where upper(subjectcode) in ('CSE21DB', 'CSE31DB', 'CSE41FDB')
order by studentNo;

-- List the students who are tutors.
select tutorNo, studentNo, fname, lname 
from tutor 
left join student 
using (studentno);

-- Select the lecturer(s) whose research area is ‘Network Management’.
select * 
from lecturer
where upper(researcharea) = upper('Network Management');

-- Calculate the average salary of a lecturer.
select avg(salary) as "average salary"
from lecturer;

-- Calculate the minimum and maximum salary of the lecturers.
select min(salary) as "minimum salary", max(salary) as "maximum salary"
from lecturer;

-- List the number of tutors by each subject and semester.
select subjectcode, semester,count(tutorNo) as "number of tutors"
from tutor
left join lab
using (tutorno)
left join subject
using (subjectcode)
group by subjectcode, semester;

-- List the total number of students in each lab, for each subject, with the tutor’s name.


-- Calculate the cost of running all the database labs per week. (Hint: lab duration * tutors’ SALARYPERHOUR)



