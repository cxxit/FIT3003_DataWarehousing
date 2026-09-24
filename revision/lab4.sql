-- A Truck Delivery Case Study 
-- ER Diagram of Truck Delivery System 

-- Warehouse (WarehouseID, Location)
-- Trip (TripID, Date, TotalKm, TruckID)
-- TripFrom (TripID, WarehouseID)
-- Truck (TruckID, VolCapacity, WeightCategory, CostPerKm)
-- Store (StoreID, StoreName, Address)
-- Destination (TripID, StoreID)

-- Create operational database using given SQL statements

drop table Warehouse cascade constraints;
Create Table Warehouse
(WarehouseID  Varchar2(10) Not Null,
 Location     Varchar2(10) Not Null,
 Primary Key (WarehouseID)
);
drop table Truck cascade constraints;
Create Table Truck
(TruckID        Varchar2(10) Not Null,
 VolCapacity    Number(5,2), 
 WeightCategory Varchar2(10),
 CostPerKm      Number(5,2),
 Primary Key (TruckID)
);
drop table Trip cascade constraints;
Create Table Trip 
(TripID   Varchar2(10) Not Null,
 TripDate Date,
 TotalKm  Number(5),
 TruckID  Varchar2(10),
 Primary Key (TripID),
 Foreign Key (TruckID) References Truck(TruckID)
);
drop table TripFrom cascade constraints;
Create Table TripFrom
(TripID      Varchar2(10) Not Null,
 WarehouseID Varchar2(10) Not Null,
 Primary Key (TripID, WarehouseID),
 Foreign Key (TripID) References Trip(TripID),
 Foreign Key (WarehouseID) References Warehouse(WarehouseID)
);
drop table Store cascade constraints;
Create Table Store
(StoreID      Varchar2(10) Not Null,
 StoreName    Varchar2(20),
 StoreAddress Varchar2(20),
 Primary Key (StoreID)
);
drop table Destination cascade constraints;
Create Table Destination
(TripID       Varchar2(10) Not Null,
 StoreID      Varchar2(10) Not Null,
 Primary Key (TripID, StoreID),
 Foreign Key (TripID) References Trip(TripID),
 Foreign Key (StoreID) References Store(StoreID)
);

--Insert Records to Operational Database
Insert Into Warehouse Values ('W1','Warehouse1');
Insert Into Warehouse Values ('W2','Warehouse2');
Insert Into Warehouse Values ('W3','Warehouse3');
Insert Into Warehouse Values ('W4','Warehouse4');
Insert Into Warehouse Values ('W5','Warehouse5');

Insert Into Truck Values ('Truck1', 250, 'Medium', 1.2);
Insert Into Truck Values ('Truck2', 300, 'Medium', 1.5);
Insert Into Truck Values ('Truck3', 100, 'Small',  0.8);
Insert Into Truck Values ('Truck4', 550, 'Large',  2.3);
Insert Into Truck Values ('Truck5', 650, 'Large',  2.5);

Insert Into Trip Values ('Trip1', to_date('14-Apr-2013', 'DD-MON-YYYY'), 370, 'Truck1');
Insert Into Trip Values ('Trip2', to_date('14-Apr-2013', 'DD-MON-YYYY'), 570, 'Truck2');
Insert Into Trip Values ('Trip3', to_date('14-Apr-2013', 'DD-MON-YYYY'), 250, 'Truck3');
Insert Into Trip Values ('Trip4', to_date('15-Jul-2013', 'DD-MON-YYYY'), 450, 'Truck1');
Insert Into Trip Values ('Trip5', to_date('15-Jul-2013', 'DD-MON-YYYY'), 175, 'Truck2');

Insert Into TripFrom Values ('Trip1', 'W1');
Insert Into TripFrom Values ('Trip1', 'W4');
Insert Into TripFrom Values ('Trip1', 'W5');
Insert Into TripFrom Values ('Trip2', 'W1');
Insert Into TripFrom Values ('Trip2', 'W2');
Insert Into TripFrom Values ('Trip3', 'W1');
Insert Into TripFrom Values ('Trip3', 'W5');
Insert Into TripFrom Values ('Trip4', 'W1');
Insert Into TripFrom Values ('Trip5', 'W4');
Insert Into TripFrom Values ('Trip5', 'W5');

Insert Into Store Values ('M1', 'Myer City', 'Melbourne');
Insert Into Store Values ('M2', 'Myer Chaddy', 'Chadstone');
Insert Into Store Values ('M3', 'Myer HiPoint', 'High Point');
Insert Into Store Values ('M4', 'Myer West', 'Doncaster');
Insert Into Store Values ('M5', 'Myer North', 'Northland');
Insert Into Store Values ('M6', 'Myer South', 'Southland');
Insert Into Store Values ('M7', 'Myer East', 'Eastland');
Insert Into Store Values ('M8', 'Myer Knox', 'Knox');

Insert Into Destination Values ('Trip1', 'M1');
Insert Into Destination Values ('Trip1', 'M2');
Insert Into Destination Values ('Trip1', 'M4');
Insert Into Destination Values ('Trip1', 'M3');
Insert Into Destination Values ('Trip1', 'M8');
Insert Into Destination Values ('Trip2', 'M4');
Insert Into Destination Values ('Trip2', 'M1');
Insert Into Destination Values ('Trip2', 'M2');

-- Check Tables 

select * from WAREHOUSE;
select * from store;
select * from destination;
select * from TRIPFROM;
select * from trip;
select * from truck;

-- Question 1: 
-- Insert records into the Destination table for trips 3, 4, and 5. You can add any store for each trip, for example:
Insert into Destination Values ('Trip3', 'M1');
Insert into Destination Values ('Trip3', 'M5');
Insert into Destination Values ('Trip3', 'M6');

Insert into Destination Values ('Trip4', 'M3');
Insert into Destination Values ('Trip4', 'M4');
Insert into Destination Values ('Trip4', 'M5');

Insert into Destination Values ('Trip5', 'M2');
Insert into Destination Values ('Trip5', 'M4');
Insert into Destination Values ('Trip5', 'M8');

-- Solution Model 1 -- using a Bridge Table
-- fact measure: Total Delivery Cost

-- a. Create a dimension table called TruckDim1
drop table truckdim1;
create table truckdim1 as 
select distinct * from truck; -- if i know that the values in truck is distinct given that truckid is the primary key 
-- why when creating the dimension i need to use distinct again?

select * from truck;
-- b. Create a dimension table called TripSeason1. This table will have 4 records 
    -- (Summer, Autumn, Winter, and Spring).
drop table tripseasondim1;
create table tripseasondim1
(
    sesonid varchar2 (15),
    seasonperiod varchar2 (15)
);

insert into tripseasondim1 values ('Summer', 'Dec-Feb');
insert into tripseasondim1 values ('Autumn', 'Mar-May');
insert into tripseasondim1 values ('Winter', 'Jun-Aug');
insert into tripseasondim1 values ('Spring', 'Sep-Nov');

select * from tripseasondim1;
select * from trip;

-- c. Create a dimension table called TripDim1.
drop table tripdim1;
create table tripdim1 as 
select tripid, tripdate, totalkm 
from trip;

select * from tripdim1;

-- d. Create a bridge table called BridgeTableDim1.
select * from destination;
drop table BridgeTableDim1;
create table BridgeTableDim1 as
select * from destination;

select * from BRIDGETABLEDIM1;

-- e. Create a dimension table called StoreDim1.
select * from store;
drop table storedim1;
create table storedim1 as 
select * from store;

select * from storedim1;

-- f. Create a tempfact (and perform the necessary alter and update), 
    -- and then create the final fact table (called it TruckFact1).
drop table tempfact1;
create table tempfact1 as 
select tr.truckid, t.tripid, extract(month from t.tripdate) as month_,
t.totalkm, tr.costperkm
from trip t 
join truck tr 
on t.TRUCKID = tr.TRUCKID;

select * from tempfact1;

alter table tempfact1 
add seasonid varchar2 (15); 

update TEMPFACT1
set seasonid = case 
    when month_ = 12 or month_ <= 2 then 'Summer'
    when month_ >= 3 and month_ <= 5 then 'Autumn'
    when month_ >= 6 and month_ <= 8 then 'Winter'
    when month_ >= 9 and month_ <= 11 then 'Spring'
end;

select * from tempfact1;

drop table truckfact1;
create table truckfact1 as 
select truckid, tripid, seasonid, sum(totalkm * costperkm) as total_delivery_cost
from tempfact1
group by truckid, tripid, seasonid;

select * from truckfact1;


-- test if weight factor is not used we cannot obtain the estimate of total delivery cost per store
-- drill down ????


-- Solution Model 2 -- add a Weight attribute in the Bridge 
-- Create a dimension table called TruckDim2

drop table truckdim2;
create table truckdim2 as 
select distinct * from truck;

-- b. create dimension tripseason2
drop table tripseasondim2;
create table tripseasondim2 
(
    seasonid varchar2 (15),
    seasonperiod varchar2 (15)
);

insert into tripseasondim2 values ('Summer', 'Dec-Feb');
insert into tripseasondim2 values ('Autumn', 'Mar-May');
insert into tripseasondim2 values ('Winter', 'Jun-Aug');
insert into tripseasondim2 values ('Spring', 'Sep-Nov');

-- c. create dimention storedim2
drop table storedim2;
create table storedim2 as 
select * from store;

-- create a bridge taable bridgetabledim2
drop table bridgetabledim2;
create table bridgetabledim2 as 
select * from destination;


-- create tripdim2
select * from trip;
select * from destination;
drop table tripdim2;
create table tripdim2 as (
select t.tripid, t.tripdate, t.totalkm, 1/count(*) as weight_factor
from trip t
join destination d 
on t.tripid = d.tripid
group by t.tripid, t.tripdate, t.totalkm);

select * from tripdim2;

-- create a tempfact2
drop table tempfact2;
create table tempfact2 as 
select tr.truckid, t.tripid, extract(month from t.tripdate) as month_,
t.totalkm, tr.costperkm
from trip t
join truck tr
on t.truckid = tr.truckid;

alter table tempfact2 
add seasonid varchar2(15);

update tempfact2 
set seasonid = case 
    when month_ = 12 and month_ <= 2 then 'Summer'
    when month_ >= 3 and month_ <= 5 then 'Autumn' 
    when month_ >=6 and month_ <= 8 then 'Winter'
    when month_ >= 9 and month_ <= 11 then 'Spring'
end;
select * from tempfact2;


drop table truckfact2;
create table truckfact2 as 
select truckid, tripid, seasonid, sum(totalkm * costperkm) as total_delivery_cost
from tempfact2
group by truckid, tripid, seasonid;

select * from truckfact2;

-- Business Question: What is the total delivery cost for each store ? 
select s.storeid, s.storename, sum(tf.total_delivery_cost) 
from storedim2 s, BRIDGETABLEDIM2 b, truckfact1 tf
where s.storeid = b.storeid and tf.tripid = b.tripid
group by s.storeid, s.storename
order by s.storeid, s.storename;

select t.tripid, t.tripdate, s.storeid, s.storename
from tripdim1 t , bridgetabledim1 bt, storedim1 s
where t.tripid = bt.tripid and s.storeid = bt.storeid
order by t.tripid, t.tripdate, s.storeid, s.storename; -- shows that each trip has many stores 

--  from this can we get the total delivery cost for each store?
-- no we cant because the operational database itself doesnt show relationship bteween the totalkm to a single store
    -- but instead the totalkm per trip which consist of not only a single store


-- Thus the choice to split the total km equally using weight is a smart choice 
    -- so we can get an estimate given that we assume the totalkm to go to each store in a trip is the same 
    -- we obtain the percentage of the delivery cost to go to a store 
-- choice to place weightfactor in TripDIM and not BridgTable is so that we can reduce the number of joins
Select S.StoreId, S.StoreName,
  sum(Total_delivery_Cost * Weight_Factor) as "Total Cost for Store"
from
  TruckFact2 F, TripDim2 T,
  StoreDim2 S, BridgeTableDim2 B
where F.TripId = T.TripId
and   T.TripId = B.TripId
and   B.StoreId = S.StoreId
group by S.StoreId, S.StoreName
order by S.StoreId, S.StoreName;

-- Solution Model 3 -- A ListAGG version 
drop table truckdim3;
create table truckdim3 as 
select distinct * from truck;

drop table tripseasondim3;
create table tripseasondim3 (
    seasonid varchar2(15),
    seasonperiod varchar2(15)
);

insert into tripseasondim3 values ('Summer', 'Dec-Feb');
insert into tripseasondim3 values ('Autumn', 'Mar-May');
insert into tripseasondim3 values ('Winter', 'Jun-Aug');
insert into tripseasondim3 values ('Spring', 'Sep-Nov');

drop table storedim3;
create table storedim3 as 
select * from store;

drop table bridgetabledim3;
create table bridgetabledim3 as 
select * from destination;

drop table tripdim3;
create table tripdim3 as 
select t.tripid, t.tripdate, t.totalkm, 1/count(*) as weight_factor, 
listagg(storeid,'_') within Group (order by storeid) as storegrouplist
from trip t
join destination d
on t.tripid = d.tripid
group by t.tripid, t.tripdate, t.totalkm;

select * from tripdim3;

-- f. create tempfact
drop table tempfact3;
create table tempfact3 as 
select tr.truckid, t.tripid, extract(month from t.tripdate) as month_, 
t.totalkm, tr.costperkm 
from trip t
join truck tr
on t.truckid = tr.truckid;

-- alter tempfact3 to include seasonid 
alter table tempfact3
add seasonid varchar2(15);

update tempfact3
set seasonid = case 
    when month_ = 12 and month_ <= 2 then 'Summer'
    when month_ >= 3 and month_ <= 5 then 'Autumn' 
    when month_ >=6 and month_ <= 8 then 'Winter'
    when month_ >= 9 and month_ <= 11 then 'Spring'
end;
select * from tempfact3;


-- create final fact truckfact3
drop table truckfact3;
create table truckfact3 as 
select truckid, tripid, seasonid, sum(totalkm*costperkm) as total_delivery_cost
from tempfact3
group by truckid, tripid, seasonid;

select * from truckfact3;






