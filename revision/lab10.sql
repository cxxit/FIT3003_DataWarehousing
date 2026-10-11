-- insert into GlucoseAlbumin (Glucose, Albumin) values (70.3, 2.0)-- Create GlucoseAlbumin table
Create TABLE GlucoseAlbumin
    (
    Glucose NUMERIC(18,6) NOT NULL,
    Albumin NUMERIC(18,6) NOT NULL
    );

select * from glucosealbumin;

-- Insert the data
insert into GlucoseAlbumin (Glucose, Albumin) values (70.3, 2.0);
insert into GlucoseAlbumin (Glucose, Albumin) values (162.2, 3.5);
insert into GlucoseAlbumin (Glucose, Albumin) values (93.7, 2.9);
insert into GlucoseAlbumin (Glucose, Albumin) values (68.5, 2.6);
insert into GlucoseAlbumin (Glucose, Albumin) values (155.0, 3.0);
insert into GlucoseAlbumin (Glucose, Albumin) values (121.0, 4.5);
insert into GlucoseAlbumin (Glucose, Albumin) values (198.0, 2.2);
insert into GlucoseAlbumin (Glucose, Albumin) values (99.1, 4.1);
insert into GlucoseAlbumin (Glucose, Albumin) values (180.2, 5.0);
insert into GlucoseAlbumin (Glucose, Albumin) values (169.0, 3.4);
insert into GlucoseAlbumin (Glucose, Albumin) values (64.9, 2.6);
insert into GlucoseAlbumin (Glucose, Albumin) values (72.1, 3.9);
insert into GlucoseAlbumin (Glucose, Albumin) values (155.0, 4.6);
insert into GlucoseAlbumin (Glucose, Albumin) values (218.0, 3.8);
insert into GlucoseAlbumin (Glucose, Albumin) values (146.0, 4.5);
insert into GlucoseAlbumin (Glucose, Albumin) values (91.9, 2.6);
insert into GlucoseAlbumin (Glucose, Albumin) values (200.0, 4.6);

-- Calculate the slope
select 
sum((Glucose - x_bar) * (Albumin - y_bar)) /
sum((Glucose - x_bar) * (Glucose - x_bar)) as slope, x_bar, y_bar
from (
select Glucose, avg(Glucose) over () as x_bar, Albumin, avg(Albumin) over () as y_bar
from GlucoseAlbumin)
group by x_bar, y_bar;

select Glucose, avg(Glucose) over () as x_bar, 
Albumin, 
avg(Albumin) over () as y_bar
from GlucoseAlbumin 
group by Glucose, Albumin;

-- Create Age WBC table
Create TABLE Age_WBC
    (
    Age NUMERIC(3,0) NOT NULL,
    WBC NUMERIC(18,6) NOT NULL
    );

select * from age_wbc;

-- Insert the data
insert into Age_WBC (Age, WBC) values (74,27);
insert into Age_WBC (Age, WBC) values (56.3, 8.6);
insert into Age_WBC (Age, WBC) values (55.9, 8.5);
insert into Age_WBC (Age, WBC) values (80.4, 9.2);
insert into Age_WBC (Age, WBC) values (56.8, 7.8);
insert into Age_WBC (Age, WBC) values (29.8, 18.2);
insert into Age_WBC (Age, WBC) values (19.1, 12.2);
insert into Age_WBC (Age, WBC) values (32.7, 19);
insert into Age_WBC (Age, WBC) values (28.3, 37.3);
insert into Age_WBC (Age, WBC) values  (73.8, 41.5);
insert into Age_WBC (Age, WBC) values  (62.7, 30.2);
insert into Age_WBC (Age, WBC) values (25.7, 16.6);
insert into Age_WBC (Age, WBC) values (66, 17.6);
insert into Age_WBC (Age, WBC) values  (64.9, 16);
insert into Age_WBC (Age, WBC) values  (37.2, 16.1);
insert into Age_WBC (Age, WBC) values  (94.6, 4.7);
insert into Age_WBC (Age, WBC) values  (39.7, 8.4);
insert into Age_WBC (Age, WBC) values  (29.9, 9.7);
insert into Age_WBC (Age, WBC) values  (48, 5.4);
insert into Age_WBC (Age, WBC) values  (42, 24.4);
insert into Age_WBC (Age, WBC) values  (71.5, 19.5);
insert into Age_WBC (Age, WBC) values  (47.4, 18.3);
insert into Age_WBC (Age, WBC) values  (24.9, 17.7);
insert into Age_WBC (Age, WBC) values  (50.8, 6);
insert into Age_WBC (Age, WBC) values  (45.3, 20.9);
insert into Age_WBC (Age, WBC) values  (76.7, 2.5);
insert into Age_WBC (Age, WBC) values  (55.7, 12.1);
insert into Age_WBC (Age, WBC) values  (86.8, 7.3);
insert into Age_WBC (Age, WBC) values  (83.5, 8.4);
insert into Age_WBC (Age, WBC) values  (84.4, 18);
insert into Age_WBC (Age, WBC) values  (18.7, 26);
insert into Age_WBC (Age, WBC) values  (85, 9.6);
insert into Age_WBC (Age, WBC) values  (57.3, 9.8);
insert into Age_WBC (Age, WBC) values  (80.6, 6.9);
insert into Age_WBC (Age, WBC) values  (65.8, 23.2);
insert into Age_WBC (Age, WBC) values  (67.9, 14.8);
insert into Age_WBC (Age, WBC) values  (84.9, 9.2);
insert into Age_WBC (Age, WBC) values (67.1, 6.8);
insert into Age_WBC (Age, WBC) values  (51.1, 21.9);
insert into Age_WBC (Age, WBC) values  (88.6, 8.4);
insert into Age_WBC (Age, WBC) values  (29.8, 10);
insert into Age_WBC (Age, WBC) values  (65, 14.9);
insert into Age_WBC (Age, WBC) values  (74, 11);
insert into Age_WBC (Age, WBC) values  (78.9, 16.7);
insert into Age_WBC (Age, WBC) values  (53.4, 6);
insert into Age_WBC (Age, WBC) values  (86, 6.5);
insert into Age_WBC (Age, WBC) values  (71.8, 14.5);
insert into Age_WBC (Age, WBC) values (54.7, 12.3);
insert into Age_WBC (Age, WBC) values (90.9, 21.9);


-- Calculate the slope and intercept
select slope, 
       y_bar_max - x_bar_max * slope as intercept 
from (
    select sum((Age - x_bar) * (WBC - y_bar)) / sum((Age - x_bar) * (Age - x_bar)) as slope,
           max(x_bar) as x_bar_max,
           max(y_bar) as y_bar_max    
    from (
        select Age, avg(Age) over () as x_bar,
               WBC, avg(WBC) over () as y_bar
        from Age_WBC group by Age, WBC) s);
