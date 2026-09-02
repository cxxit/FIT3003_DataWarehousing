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



