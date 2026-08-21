Create Table Warehouse
(WarehouseID  Varchar2(10) Not Null,
 Location     Varchar2(10) Not Null,
 Primary Key (WarehouseID)
);

Create Table Truck
(TruckID        Varchar2(10) Not Null,
 VolCapacity    Number(5,2), 
 WeightCategory Varchar2(10),
 CostPerKm      Number(5,2),
 Primary Key (TruckID)
);

Create Table Trip 
(TripID   Varchar2(10) Not Null,
 TripDate Date,
 TotalKm  Number(5),
 TruckID  Varchar2(10),
 Primary Key (TripID),
 Foreign Key (TruckID) References Truck(TruckID)
);

Create Table TripFrom
(TripID      Varchar2(10) Not Null,
 WarehouseID Varchar2(10) Not Null,
 Primary Key (TripID, WarehouseID),
 Foreign Key (TripID) References Trip(TripID),
 Foreign Key (WarehouseID) References Warehouse(WarehouseID)
);

Create Table Store
(StoreID      Varchar2(10) Not Null,
 StoreName    Varchar2(20),
 StoreAddress Varchar2(20),
 Primary Key (StoreID)
);

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



-- TESTING --
select * from trip;
select * from destination;
select * from truck;
select * from warehouse;
select * from store;
select * from tripfrom;

-- Question 1 
Insert into Destination Values ('Trip3', 'M1');
Insert into Destination Values ('Trip3', 'M5');
Insert into Destination Values ('Trip3', 'M6');
select * from destination;

-- Question 2
-- Create a dimension table called TruckDim1.
drop table truckDIM1;
create table truckDIM1 as
select * from truck;
select * from truckDIM1;

-- Create a dimension table called TripSeason1. This table will have 4 records (Summer, Autumn, Winter, and Spring).
drop table tripseasonDIM1;
create table tripseasonDIM1
(seasonid varchar (15),
seasonperiod varchar2 (15));

INSERT INTO tripseasonDIM1 VALUES ('Summer','Dec-Feb');
INSERT INTO tripseasonDIM1 VALUES ('Autumn','Mar-May');
INSERT INTO tripseasonDIM1 VALUES ('Winter','Jun-Aug');
INSERT INTO tripseasonDIM1 VALUES ('Spring','Sep-Nov');


SELECT * FROM tripseasonDIM1;




-- Create a dimension table called TripDim1.
drop table tripDIM1;
create table tripDIM1 as 
select tripID, tripDate, totalKM 
from trip;
select * from tripDIM1;

-- Create a bridge table called BridgeTableDim1.
drop table bridgetableDIM1;
create table bridgetableDIM1 as 
select * from destination;
select * from BRIDGETABLEDIM1;

-- Create a dimension table called StoreDim1.
drop table storeDIM1;
create table storeDIM1 as 
select * from store;
select * from storeDIM1;

-- why do we not include the pk and fk 
-- these are passive data warehouse 
-- we pull from operational database 
-- snapshot of the database 
-- new records are added to operational database, not to our data warehouse 
-- these data warehouse we are creating are passive data warehouse 
-- we first need to check the consistency and inetegrity by cleaning the data only we can get a correct "snapshot" of the oeprational database as data warehosue

-- Create a tempfact (and perform the necessary alter and update), and then create the final fact table (called it TruckFact1).
-- we dont have season in operational database
-- as part of the procedure !!!????
drop table tempfact;
create table tempfact as 
select tripID, extract(Month from tripdate) as Month_, totalKM, truckID, costperKM
from TRIP
natural join truck;

alter table tempfact
add seasonID varchar2(15);

update TEMPFACT
set seasonID =
    CASE 
        WHEN month_ = 12 OR month_ <= 2 THEN 'Summer'
        WHEN month_ >= 3 AND month_ <= 5 THEN 'Autumn'
        WHEN month_ >= 6 AND month_ <= 8 THEN 'Winter'
        WHEN month_ >= 9 AND month_ <= 11 THEN 'Spring'
    END;

select * from tempfact;

-- Display (and observe) the contents of the fact table (TruckFact1).
create table truckFact1 as 
select tripID, truckID, seasonID, (totalkm * costperkm) as total_delivery_cost
from tempfact;

select * from truckFact1
order by tripid;


-- SOLUTION MODEL 2
drop table truckDIM2;
create table truckDIM2 as
select * from truck;
select * from truckDIM2;

-- Create a dimension table called TripSeason1. This table will have 4 records (Summer, Autumn, Winter, and Spring).
drop table tripseasonDIM2;
create table tripseasonDIM2
(seasonid varchar (15),
seasonperiod varchar2 (15));

INSERT INTO tripseasonDIM2 VALUES ('Summer','Dec-Feb');
INSERT INTO tripseasonDIM2 VALUES ('Autumn','Mar-May');
INSERT INTO tripseasonDIM2 VALUES ('Winter','Jun-Aug');
INSERT INTO tripseasonDIM2 VALUES ('Spring','Sep-Nov');


SELECT * FROM tripseasonDIM2;

drop table storeDIM2;
create table storeDIM2 as 
select * from store;
select * from storeDIM2;


drop table bridgetableDIM2;
create table bridgetableDIM2 as 
select * from destination;
select * from BRIDGETABLEDIM2;

select * from trip;
select * from destination;

select tripID, tripdate, totalkm, COUNT(storeID)
from destination 
natural join trip
group by tripID, tripdate, totalkm
order by tripID;


SELECT tripID, tripdate, totalkm, ROUND(1/COUNT(storeID),2) AS weightfactor
FROM destination NATURAL JOIN trip
GROUP BY tripID,tripdate, totalkm
ORDER BY TripID;


CREATE TABLE tripDIM2 AS
SELECT tripID, tripdate, totalkm, ROUND(1/COUNT(storeID),2) AS weightfactor
FROM destination NATURAL JOIN trip
GROUP BY tripID,tripdate, totalkm;
select * from tripDIM2;



-- what is the total delivery cost for each store?
select storeid,
       storename,
       sum(weightfactor * total_delivery_cost) as total_cost
  from truckfact1
natural join tripdim2
natural join bridgetabledim2
natural join storedim2
 group by storeid,
          storename
order by storeId;


-- SOLUTION MODEL 3
-- Like with TripDim2, before creating table TripDim3, we would like to experiment with a few Select statements to find out what is the best way to create table TripDim3.

-- Do a select statement to display TripID, TripDate, TotalKm, and WeightFactor.
select tripID, tripdate, totalkm, 1/COUNT(*) as weightfactor 
from trip natural join DESTINATION
group by tripId, tripdate, totalkm;

-- Now do a select statement to display TripID, TripDate, TotalKm, WeightFactor, and StoreGroupList. The StoreGroupList column is implemented by the ListAGG function.

-- The ListAGG function has the following format:
-- LISTAGG (attr1, '_') Within Group (Order By attr1) As columnname

-- Attr1 is the store id, and the '_' is to indicate that the store ids are concatenated with the '_' symbol (e.g. M1_M2_M3_M4_M8). If we want to have the stores listed in a descending order (e.g. M8_M4_M3_M2_M1), then we use Within Group (Order By attr1 Desc).
select tripID, tripdate, totalkm, 1/COUNT(*) as weightfactor, 
    listagg(storeId,'_') within group (order by storeID) as StoreGroupList
from trip natural join destination
group by tripId, tripdate, totalkm; 

-- You can now create table TripDim3 by using the above select statement.
drop table TripDim3;
create table TripDim3 as 
select tripID, tripdate, totalkm, 1/COUNT(*) as weightfactor, 
    listagg(storeId,'_') within group (order by storeID) as StoreGroupList
from trip natural join destination

group by tripId, tripdate, totalkm; 

select * from tripdim3;



select * 
from tripDIM3, STOREDIM2
where StoreGroupList like '%' || StoreID || '%';


