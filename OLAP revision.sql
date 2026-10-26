-- Explore the data warhouse
select * from dw.charter_fact;
select * from dw.model;
select * from dw.pilot;
select * from dw.time;



-- A. Aggregate exercises using CUBE and ROLLUP
select time_id as period, 
        c.emp_num as pilot,
        mod_code as model, 
        sum(tot_fuel)
from dw.charter_fact c, dw.pilot p 
where c.emp_num = p.emp_num 
and time_id like '19951%'
and mod_code = 'C-90A'
and p.pil_license = 'COM'
group by time_id, c.emp_num, mod_code 
order by time_id;

-- Question 2 : CUBE 
select time_id as period, 
        c.emp_num as pilot,
        mod_code as model, 
        sum(tot_fuel)
from dw.charter_fact c, dw.pilot p 
where c.emp_num = p.emp_num 
and time_id like '19951%'
and mod_code = 'C-90A'
and p.pil_license = 'COM'
group by cube(time_id, c.emp_num, mod_code)  
order by time_id;

select time_id as period, 
        c.emp_num as pilot,
        mod_code as model, 
        sum(tot_fuel)
from dw.charter_fact c, dw.pilot p 
where c.emp_num = p.emp_num 
and time_id like '19951%'
and mod_code = 'C-90A'
and p.pil_license = 'COM'
group by rollup(time_id, c.emp_num, mod_code)  
order by time_id;

-- Question 3 : CUBE with GROUPING 
select time_id as period, 
        c.emp_num as pilot,
        mod_code as model, 
        sum(tot_fuel),
        grouping(time_id) as periodgroup, 
        grouping(c.emp_num) as pilotgroup,
        grouping(mod_code) as modelgroup
from dw.charter_fact c, dw.pilot p 
where c.emp_num = p.emp_num 
and time_id like '19951%'
and mod_code = 'C-90A'
and p.pil_license = 'COM'
group by cube(time_id, c.emp_num, mod_code)  
order by time_id;


-- Question 4 : CUBE with GROUPING with DECODE 
select 
        decode(grouping(time_id),1,'All Periods', time_id) as period, 
        decode(grouping(c.emp_num), 1, 'All Pilots', c.emp_num) as Pilot,
        decode(grouping(mod_code),1,'All Models', mod_code) as Model,
        sum(tot_fuel)
from dw.charter_fact c, dw.pilot p 
where c.emp_num = p.emp_num 
and time_id like '19951%'
and mod_code = 'C-90A'
and p.pil_license = 'COM'
group by cube(time_id, c.emp_num, mod_code)  
order by time_id;


-- Question 5 : Partial CUBE 
select 
        decode(grouping(time_id),1,'All Periods', time_id) as period, 
        decode(grouping(c.emp_num), 1, 'All Pilots', c.emp_num) as Pilot,
        decode(grouping(mod_code),1,'All Models', mod_code) as Model,
        sum(tot_fuel)
from dw.charter_fact c, dw.pilot p 
where c.emp_num = p.emp_num 
and time_id like '19951%'
and mod_code = 'C-90A'
and p.pil_license = 'COM'
group by cube(time_id, c.emp_num), mod_code   
order by time_id;


-- Question 6 : ROLLUP and DECODE 
select 
        decode(grouping(time_id),1,'All Periods', time_id) as period, 
        decode(grouping(c.emp_num), 1, 'All Pilots', c.emp_num) as Pilot,
        decode(grouping(mod_code),1,'All Models', mod_code) as Model,
        sum(tot_fuel)
from dw.charter_fact c, dw.pilot p 
where c.emp_num = p.emp_num 
and time_id like '19951%'
and mod_code = 'C-90A'
and p.pil_license = 'COM'
group by rollup(time_id, c.emp_num, mod_code)   
order by time_id;

-- Question 8 : Partial RollUp 
select 
        decode(grouping(time_id),1,'All Periods', time_id) as period, 
        decode(grouping(c.emp_num), 1, 'All Pilots', c.emp_num) as Pilot,
        decode(grouping(mod_code),1,'All Models', mod_code) as Model,
        sum(tot_fuel)
from dw.charter_fact c, dw.pilot p 
where c.emp_num = p.emp_num 
and time_id like '19951%'
and mod_code = 'C-90A'
and p.pil_license = 'COM'
group by rollup(time_id, c.emp_num), mod_code   
order by time_id;


-- B. ROW_NUMBER(), DENSE_RANK(), RANK(), and PERCENT_RANK() : Analysis Questions
SELECT time_year, time_month,  
RANK() OVER (ORDER BY time_year, time_month) AS time_rank  FROM dw.time; 

-- Question 2 : ROW_NUMBER() 
select mod_code, 
        time_id,
        sum(tot_char_hours),
        row_number() over (order by sum(tot_char_hours)) as row_num 
from dw.charter_fact
where time_id like '1996%'
group by mod_code, time_id;

-- Question 3 : DENSE_RANK() 
select 
    mod_code, 
    time_id, 
    sum(tot_char_hours),
    dense_rank() over (order by sum(tot_char_hours)) as dense_rank 
from dw.charter_fact
where time_id like '1996%'
group by mod_code, time_id;

-- Question 4 : RANK() 
select 
    mod_code, 
    time_id, 
    sum(tot_char_hours),
    rank() over (order by sum(tot_char_hours)) as rank 
from dw.charter_fact 
where time_id like '1996%'
group by mod_code, time_id;


-- Question 5 : PERCENT_RANK() 
select time_id, total, percent_rank 
from (
select 
    time_id,
    sum(revenue) as total,
    percent_rank() over (order by sum(revenue)) as percent_rank
from dw.charter_fact 
group by time_id) 
where percent_rank >= 0.9 
order by percent_rank desc;

-- C. Cumulative and Moving Aggregate Questions 
-- Question 1 : NO PARTITION 
select 
    time_id,
    sum(revenue), 
    to_char(sum(sum(revenue)) over (order by time_id rows unbounded preceding), '9,999,999.99') as cumulative_rev 
from dw.charter_fact 
where time_id like '1995%'
group by time_id;

-- Question 2 : 
select 
    time_id, 
    sum(revenue), 
    to_char(avg(sum(revenue)) over (order by time_id rows 2 preceding), '9,999,999.99') as moving_3_months_avg
from dw.charter_fact 
where time_id like '1995%'
group by time_id;

-- Question 4 : CUMULATIVE FUEL & CUMULATIVE FUEL MODEL (TOT_FUEL)
select 
    t.time_year, 
    f.mod_code,
    sum(f.tot_fuel) as total, 
    to_char(sum(sum(f.tot_fuel)) over (partition by t.time_year order by t.time_year rows unbounded preceding), '9,999,999.99') as cum_fuel_year, 
    to_char(sum(sum(f.tot_fuel)) over (partition by f.mod_code order by f.mod_code rows unbounded preceding), '9,999,999.99') as cum_fuel_mod
from dw.charter_fact f, dw.time t
where f.time_id = t.time_id 
group by t.time_year, f.mod_code 
order by t.time_year;
