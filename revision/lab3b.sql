-- Pat A: explore data 
-- Explore the content of all tables in the operational database.
select * from dw.pilot;
select * from dw.customer;
select * from dw.charter;
select * from dw.employee;
select * from dw.aircraft;
select * from dw.model;

-- Did you identify any issues related to the 
-- tables in the operational database during your exploration?


select distinct char_copilot from dw.charter;

select * from dw.charter 
where char_pilot = char_copilot;


select * from dw.charter
where char_pilot is null; 


-- check for duplicates
select c.cus_lname,c.cus_fname, count(*) 
from dw.customer c
group by c.cus_lname,c.cus_fname
having count(*) > 1;

select c.char_trip, count(*) from dw.charter c
group by c.char_trip
having count(*) > 1;

select e.emp_num, count(*) from dw.employee e
group by e.emp_num
having count(*) > 1;

select p.emp_num, count(*) from dw.pilot p
group by p.emp_num
having count(*) > 1;

select a.ac_number, count(*) from dw.aircraft a
group by a.ac_number
having count(*) > 1;

select m.mod_code, count(*) from dw.model m
group by m.mod_code
having count(*) > 1;


select * from dw.charter 
where char_trip = 10268; -- this suggests that the input data is not clean however it does not 
-- influence the calculations in the fact table in data warehourse so we can ignore this for now


-- Part B: 
-- Create model dimension
select * from dw.model;
drop table model_dim;
create table model_dim as 
select * from dw.model;

select * from model_dim;


-- Create Pilot Dimension 
select * from dw.pilot;
drop table pilot_dim;
create table pilot_dim as 
select * from dw.pilot;

select * from pilot_dim;

-- Create Time Dimension
select * from dw.charter;

drop table time_dim;
create table time_dim as 
select distinct to_char(char_date, 'YYYYMM') as time_id,
to_char(char_date, 'Month') as time_month,
to_char(char_date,'YYYY') as time_year
from dw.charter;

select * from time_dim;
select * from dw.model;
-- create charter fact 
drop table charter_fact;
create table charter_fact as 
select m.mod_code, c.char_pilot, to_char(c.char_date, 'YYYYMM') as time_id,
sum(c.char_hours_flown) as tot_char_hours, 
sum(c.char_fuel_gallons) as tot_fuel,
sum(c.char_distance* m.mod_chg_mile) as revenue 
from dw.model m, dw.charter c, dw.aircraft a
where m.mod_code = a.mod_code
and a.ac_number = c.ac_number
group by m.mod_code, c.char_pilot, to_char(c.char_date, 'YYYYMM');


select * from charter_fact;

-- After creating the charter_fact, does the char_fact_flown 
-- accurately reflect the total hours flown by each pilot?

-- After creating the charter_fact, the char_fact_flown field may not 
-- fully reflect the total hours flown by each pilot. This is because 
-- the current star schema only includes hours flown when the pilot is 
-- in the primary pilot role, and does not account for hours when the 
-- pilot is acting as a co-pilot. To accurately reflect the total hours 
-- flown for each pilot, an additional star schema or modification to 
-- the existing schema may be necessary to include hours flown as a co-pilot.