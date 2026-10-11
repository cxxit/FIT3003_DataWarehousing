SELECT * FROM dw.charter_fact; -- there is some aggregation, not level-0
SELECT * FROM dw.time;
SELECT * FROM dw.pilot;
SELECT * FROM dw.model;


-- A. Aggregate exercises using CUBE and ROLLUP 
-- The OLAP queries you need to implement are the following: 
-- 1. What is the total fuel used from Oct to Dec 1995 by commercial pilots and 
-- airplane model C-90A. Sort the results by the month. How many rows of records do you get? 
select f.time_id as period,
 f.emp_num as pilot,
 f.mod_code as model,
 sum(f.tot_fuel)
from dw.charter_fact f, dw.pilot p
where f.emp_num = p.emp_num
and upper(p.pil_license) = 'COM' 
and f.time_ID like '19951_'
and upper(mod_code) = 'C-90A'
group by f.time_id, f.emp_num,
 f.mod_code
order by f.time_id;


-- 2. Using cube, what is the total fuel used from Oct to Dec 1995 by commercial pilots and airplane model C-90A. Sort the results by the month. How many rows of records do you get? 
select f.time_id as period,
 f.emp_num as pilot,
 f.mod_code as model,
 sum(f.tot_fuel)
from dw.charter_fact f, dw.pilot p
where f.emp_num = p.emp_num
and upper(p.pil_license) = 'COM' 
and f.time_ID like '19951_'
and upper(mod_code) = 'C-90A'
-- group by cube(f.time_id, f.emp_num, f.mod_code)
group by cube(f.time_id, f.mod_code, f.emp_num)
order by f.time_id;

-- QUESTION: roll up????

-- 3. Redo question A.2 using Grouping. Notes that “1” and “0” in the TIME, PILOT,  and MODEL indicate that they are aggregate values and real values respectively.  
select f.time_id as period,
 f.emp_num as pilot,
 f.mod_code as model,
 sum(f.tot_fuel),
 grouping(time_id) as periodgroup, -- QUESTION: why not use f.timeid
 grouping(f.emp_num) as pilotgroup,
 grouping(f.mod_code) as model
from dw.charter_fact f, dw.pilot p
where f.emp_num = p.emp_num
and upper(p.pil_license) = 'COM' 
and f.time_ID like '19951_'
and upper(mod_code) = 'C-90A'
group by cube(f.time_id, f.mod_code, f.emp_num)
order by f.time_id;

-- 4. As like question A.3 above, but instead of using “0” and “1”, it displays “All  Periods”, “All Pilots” and “All Models” instead. (Hints: Use DECODE).  
select decode(grouping(f.time_id),1,'All Periods', time_id) as period,
 decode(grouping(f.emp_num),1,'All Pilots', f.emp_num)  as pilot,
 decode(grouping(f.mod_code),1,'All Models', f.mod_code) as model,
 sum(f.tot_fuel),
 grouping(time_id) as periodgroup, -- QUESTION: why not use f.timeid
 grouping(f.emp_num) as pilotgroup,
 grouping(f.mod_code) as model
from dw.charter_fact f, dw.pilot p
where f.emp_num = p.emp_num
and upper(p.pil_license) = 'COM' 
and f.time_ID like '19951_'
and upper(mod_code) = 'C-90A'
group by cube(f.time_id, f.emp_num, f.mod_code)
order by f.time_id;

-- DECODE: change the value of a particular item

-- 5. Following the results in question A.4, since there is only one aircraft model in the  query results (e.g. C-90A), it seems that the “All Models” are redundant. Now, we  want to remove them from the report, as there is no point displaying “All Models”  when there is only one model (Hints: Use Partial CUBE).  
select decode(grouping(f.time_id),1,'All Periods', time_id) as period,
 decode(grouping(f.emp_num),1,'All Pilots', f.emp_num)  as pilot,
 decode(grouping(f.mod_code),1,'All Models', f.mod_code) as model,
 sum(f.tot_fuel),
 grouping(time_id) as periodgroup, -- QUESTION: why not use f.timeid
 grouping(f.emp_num) as pilotgroup,
 grouping(f.mod_code) as model
from dw.charter_fact f, dw.pilot p
where f.emp_num = p.emp_num
and upper(p.pil_license) = 'COM' 
and f.time_ID like '19951_'
and upper(mod_code) = 'C-90A'
group by cube(f.time_id, f.emp_num), f.mod_code
order by f.time_id;

-- 6. Using rollup with decode, what is the total fuel used from Oct to Dec 1995 by  commercial pilots and airplane model C-90A. Sort the results by the month. How  many rows of records do you get? 
-- Grouping sets / combinations for GROUP BY cube (time_id, F.mod_code, F.emp_num)
-- (time_id, F.mod_code, F.emp_num)
-- (time_id, F.mod_code)
-- (time_id, F.emp_num)
-- (F.mod_code, F.emp_num)
-- (time_id)
-- (F.mod_code)
-- (F.emp_num)
-- () → GRANT TOTAL

select decode(grouping(f.time_id),1,'All Periods', time_id) as period,
 decode(grouping(f.emp_num),1,'All Pilots', f.emp_num)  as pilot,
 decode(grouping(f.mod_code),1,'All Models', f.mod_code) as model,
 sum(f.tot_fuel),
 grouping(time_id) as periodgroup, -- QUESTION: why not use f.timeid
 grouping(f.emp_num) as pilotgroup,
 grouping(f.mod_code) as model
from dw.charter_fact f, dw.pilot p
where f.emp_num = p.emp_num
and upper(p.pil_license) = 'COM' 
and f.time_ID like '19951_'
and upper(mod_code) = 'C-90A'
group by rollup (f.time_id, f.emp_num), f.mod_code
order by f.time_id;

select decode(grouping(f.time_id),1,'All Periods', time_id) as period,
 decode(grouping(f.emp_num),1,'All Pilots', f.emp_num)  as pilot,
 decode(grouping(f.mod_code),1,'All Models', f.mod_code) as model,
 sum(f.tot_fuel),
 grouping(time_id) as periodgroup, -- QUESTION: why not use f.timeid
 grouping(f.emp_num) as pilotgroup,
 grouping(f.mod_code) as model
from dw.charter_fact f, dw.pilot p
where f.emp_num = p.emp_num
and upper(p.pil_license) = 'COM' 
and f.time_ID like '19951_'
and upper(mod_code) = 'C-90A'
group by rollup(f.time_id, f.emp_num, f.mod_code)
order by f.time_id;
-- 7. Compare the results in A.2 and A.6. What is the difference? 
-- 8. Modify C.6 to use Partial Roll up (exclude “All Models” from the rollup). 
select decode(grouping(f.time_id),1,'All Periods', time_id) as period,
 decode(grouping(f.emp_num),1,'All Pilots', f.emp_num)  as pilot,
 decode(grouping(f.mod_code),1,'All Models', f.mod_code) as model,
 sum(f.tot_fuel),
 grouping(time_id) as periodgroup, -- QUESTION: why not use f.timeid
 grouping(f.emp_num) as pilotgroup,
 grouping(f.mod_code) as model
from dw.charter_fact f, dw.pilot p
where f.emp_num = p.emp_num
and upper(p.pil_license) = 'COM' 
and f.time_ID like '19951_'
and upper(mod_code) = 'C-90A'
group by rollup(f.time_id, f.emp_num), f.mod_code
order by f.time_id;

-- B. ROW_NUMBER(), DENSE_RANK(), RANK(), and PERCENT_RANK()  Analysis Questions 

-- 1. The rank function displays the rank of a record. 
-- Its usage is as follow. To find the  rank of the records in the time table is as follow: 

SELECT time_year, time_month,  
RANK() OVER (ORDER BY time_year, time_month) AS time_rank 
FROM dw.time; 

-- 2. Display the row number of total charter hours used by each 
-- aircraft model in year  1996 (Hints: Use ROW_NUMBER() Over) 
-- The results should look like as  follows. 

SELECT mod_code, time_id, sum(tot_char_hours), 
row_number()  over (order by sum(tot_char_hours)) as row_num
FROM dw.charter_fact
where time_id like '1996%'
group by mod_code, time_id; -- 36 rows selected 

-- 3. Display the ranking of total charter hours used by each aircraft model 
-- in year  1996(Hints: Use Dense_Rank() Over) The results should look like as  follows. 
select mod_code, time_id, sum(tot_char_hours),
dense_rank() over(order by sum(tot_char_hours))
from dw.charter_fact 
where time_id like '1996%'
group by mod_code, time_id;

-- 4.  Display the ranking of total charter hours used by each aircraft model 
-- in year  1996 (Hints: Use Rank() Over) The results should look like as follows. 
select mod_code, time_id, sum(tot_char_hours),
rank() over(order by sum(tot_char_hours))
from dw.charter_fact 
where time_id like '1996%'
group by mod_code, time_id;
-- if company doesnt want gap between then dense rank 
-- else if want gap between use rank

-- Using the Percent_Rank() function (nested within a sub query), 
-- display the  time periods which had revenue in the top 10% of the months.  
select * from dw.charter_fact;

select * 
from (
select time_id, sum(revenue),
percent_rank() over (order by sum(revenue)) as percent_rank
from dw.charter_fact 
group by time_id)
where percent_rank >= 0.9
order by percent_rank desc;


select time_id, sum(revenue),
percent_rank() over (order by sum(revenue)) as percent_rank
from dw.charter_fact 
group by time_id;

-- C. Cumulative and Moving Aggregate Questions
-- 1. Use the cumulative aggregate to show the following results. 
-- We only need to  show 1995 revenues (Hints: Since we only display 1995 data, 
-- there is no  PARTITION)

select time_id, sum(revenue),
to_char(sum(sum(revenue)) over (order by time_id rows unbounded preceding),
        '999,999,999.99') as cumulative_rev
from dw.CHARTER_FACT
where time_id like '1995%'
group by time_id; -- at the last column at record row 12, is the total revenue of the year 1995
-- as it cumulates the revenue of each month

-- QUESTION:
-- rows unbounded preceding: cumulative
-- rows to preceding

-- 2. Redo question C.1 above, instead of using cumulative aggregate, 
-- use moving  aggregate to show the following results moving aggregate of 3 monthly. 
-- (Hints:  Use ROWS 2 PRECEDING). 

select time_id, sum(revenue),
to_char(round(avg(sum(revenue))) over (order by time_id rows 2 preceding),
        '999,999,999.99') as moving_3_months_avg
from dw.CHARTER_FACT
where time_id like '1995%'
group by time_id; 

SELECT time_id,
      SUM(revenue),
      round(
          AVG(sum(revenue))
          OVER(
               ORDER BY time_id
              ROWS 2 PRECEDING
          ),
          2
      ) AS moving_3_months_avg
 FROM dw.charter_fact f
 JOIN dw.pilot p
ON f.emp_num = p.emp_num
  AND time_id LIKE '1995%'
GROUP BY time_id;

SELECT Time_ID, sum(revenue),
       to_char(avg(sum(revenue)) OVER (order BY time_id Rows 2 PRECEDING), '999,999,999.99') AS Moving_3_month_avg
FROM dw.CHARTER_FACT
WHERE time_id LIKE '1995%'
GROUP BY time_id;


-- 3. Compare the result of C.1 and C.2, 
-- investigate the difference betweencumulative  aggregate and moving aggregate. 

-- 4. Display the cumulative total fuel used based on the year, 
-- and another cumulative  total used for each airplane model.

select * from dw.time;
select * from dw.charter_fact;

select t.time_year, f.mod_code, sum(f.tot_fuel) as total,
to_char(sum(sum(f.tot_fuel)) over (partition by time_id order by mod_code rows unbounded preceding),
        '999,999,999.99') as cumulative_fuel_year,
to_char(sum(sum(revf.tot_fuel)) over (partition by mod_code order by mod_code rows unbounded preceding),
        '999,999,999.99') as cumulative_rev
from dw.charter_fact f, dw.time t
where f.time_id = t.time_id
group by t.time_year, f.mod_code
order by t.time_year, f.mod_code;

