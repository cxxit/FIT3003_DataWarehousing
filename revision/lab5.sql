--CUSTOMER 
create table CUSTOMER as 
select CUSTOMERID as CUSTOMER_ID, name as CUSTOMER_NAME, ADDRESS,  SUBURB, POSTCODE, STATE 
from DTANIAR.CUSTOMER4; 
alter table CUSTOMER add constraint CUSTOMER_PK primary key  ( CUSTOMER_ID ) ; 
--BOOK 
create table BOOK 
 ( 
 BOOK_ID varchar2(20) not null , 
 BOOK_TITLE varchar2(200), 
 AUTHOR varchar2(200) 
 ) ; 

alter table BOOK add constraint BOOK_PK primary key ( BOOK_ID ); 

insert into BOOK values('C1', 'CSIRO Diet', 'CSIRO Team'); insert into BOOK values('H6', 'Harry Potter 6', 'Rowling'); insert into BOOK values('DV', 'Da Vinci Code', 'Dan Brown'); 
--BOOK PRICE HISTORY 
create table BOOK_PRICE_HISTORY 
 ( 
 BOOK_ID varchar2(20) not null , 
 START_DATE varchar2(10) null , 
 END_DATE varchar2(10) not null , 
 PRICE number, 
 REMARKS varchar2(100) 
 ) ; 

alter table BOOK_PRICE_HISTORY add constraint BOOK_PRICE_HISTORY_PK  primary key ( BOOK_ID, START_DATE, END_DATE ) ; 

alter table BOOK_PRICE_HISTORY add constraint BOOK_PRICE_HISTORY_BOOK_FK  foreign key ( BOOK_ID ) references BOOK ( BOOK_ID ) ; 

insert into BOOK_PRICE_HISTORY values('C1', 'Jan2007', 'Jul2007', 45.95,  'Full Price');  
insert into BOOK_PRICE_HISTORY values('C1', 'Aug2007', 'Oct2007', 36.75,  '20% Discount');  
insert into BOOK_PRICE_HISTORY values('C1', 'Nov2007', 'Jan2008', 23.00,  'Half Price'); 
insert into BOOK_PRICE_HISTORY values('C1', 'Feb2008', 'Now', 45.95,  'Full Price'); 
insert into BOOK_PRICE_HISTORY values('H6', 'Jan2007', 'Mar2007', 21.95,  'Launching'); 
insert into BOOK_PRICE_HISTORY values('H6', 'Apr2007', 'Feb2008', 30.95,  'Full Price'); 
insert into BOOK_PRICE_HISTORY values('H6', 'Jan2008', 'Now', 10.00,  'End of Product Sale');
insert into BOOK_PRICE_HISTORY values('DV', 'Jan2007', 'Now', 27.95,  'Full Price'); 

--BRANCH 
create table BRANCH 
 ( 
 BRANCH_ID varchar2(100) not null , 
 BRANCH_ADDRESS varchar2(200) 
 ) ; 

alter table BRANCH add constraint BRANCH_PK primary key ( BRANCH_ID ) ; 

insert into BRANCH values('City', 'VIC3622'); 
insert into BRANCH values('Chadstone', 'Chadstone VIC3234'); insert into BRANCH values('Camberwell', 'Camberwell VIC2451'); 
--TRANSACTION 
create table BOOK_TRANSACTION 
 ( 
 TRANSACTION_ID number not null , 
 BRANCH_ID varchar2 (100) not null , 
 CUSTOMER_ID varchar2 (20) not null , 
 BOOK_ID varchar2 (20) not null , 
 TRANSACTION_DATE date , 
 QUANTITY number 
 ) ; 

alter table BOOK_TRANSACTION add constraint BOOK_TRANSACTION_PK primary  key ( TRANSACTION_ID ) ; 
alter table BOOK_TRANSACTION add constraint TRANSACTION_BOOK_FK foreign  key ( BOOK_ID ) references BOOK ( BOOK_ID ) ; 
alter table BOOK_TRANSACTION add constraint TRANSACTION_BRANCH_FK  foreign key ( BRANCH_ID ) references BRANCH ( BRANCH_ID ) ; 

alter table BOOK_TRANSACTION add constraint TRANSACTION_CUSTOMER_FK  foreign key ( CUSTOMER_ID ) references CUSTOMER ( CUSTOMER_ID ) ; 

create sequence BOOK_TRANSACTION_TRANSACTION_I start with 1 ; 

create or replace trigger BOOK_TRANSACTION_TRANSACTION_I before  insert on BOOK_TRANSACTION for each row when (new.TRANSACTION_ID is  null)  
begin  
 :new.TRANSACTION_ID := BOOK_TRANSACTION_TRANSACTION_I.NEXTVAL; end; 
/ 

insert into BOOK_TRANSACTION values(null, 'City', 'Cus1', 'C1',  to_date('Mar 2008', 'Mon YYYY'), 2); 
insert into BOOK_TRANSACTION values(null, 'City', 'Cus2', 'C1',  to_date('Mar 2008', 'Mon YYYY'), 3); 
insert into BOOK_TRANSACTION values(null, 'City', 'Cus2', 'H6',  to_date('Mar 2008', 'Mon YYYY'), 10); 
insert into BOOK_TRANSACTION values(null, 'City', 'Cus3', 'H6',  to_date('Mar 2008', 'Mon YYYY'), 5); 
insert into BOOK_TRANSACTION values(null, 'City', 'Cus3', 'DV',  to_date('Mar 2008', 'Mon YYYY'), 10); 
insert into BOOK_TRANSACTION values(null, 'City', 'Cus4', 'DV',  to_date('Mar 2008', 'Mon YYYY'), 13);
insert into BOOK_TRANSACTION values(null, 'Chadstone', 'Cus4', 'C1',  to_date('Mar 2008', 'Mon YYYY'), 10); 
insert into BOOK_TRANSACTION values(null, 'Chadstone', 'Cus5', 'C1',  to_date('Mar 2008', 'Mon YYYY'), 5); 
insert into BOOK_TRANSACTION values(null, 'Chadstone', 'Cus4', 'H6',  to_date('Mar 2008', 'Mon YYYY'), 3); 
insert into BOOK_TRANSACTION values(null, 'Chadstone', 'Cus3', 'DV',  to_date('Mar 2008', 'Mon YYYY'), 2); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus3', 'C1',  to_date('Mar 2008', 'Mon YYYY'), 1); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus2', 'H6',  to_date('Mar 2008', 'Mon YYYY'), 1); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus1', 'DV',  to_date('Mar 2008', 'Mon YYYY'), 2); 
insert into BOOK_TRANSACTION values(null, 'City', 'Cus4', 'C1',  to_date('Dec 2007', 'Mon YYYY'), 10); 
insert into BOOK_TRANSACTION values(null, 'City', 'Cus3', 'C1',  to_date('Dec 2007', 'Mon YYYY'), 5); 
insert into BOOK_TRANSACTION values(null, 'City', 'Cus2', 'H6',  to_date('Dec 2007', 'Mon YYYY'), 5); 
insert into BOOK_TRANSACTION values(null, 'City', 'Cus2', 'H6',  to_date('Dec 2007', 'Mon YYYY'), 1); 
insert into BOOK_TRANSACTION values(null, 'City', 'Cus5', 'DV',  to_date('Dec 2007', 'Mon YYYY'), 6); 
insert into BOOK_TRANSACTION values(null, 'Chadstone', 'Cus4', 'C1',  to_date('Dec 2007', 'Mon YYYY'), 5); 
insert into BOOK_TRANSACTION values(null, 'Chadstone', 'Cus3', 'C1',  to_date('Dec 2007', 'Mon YYYY'), 5); 
insert into BOOK_TRANSACTION values(null, 'Chadstone', 'Cus2', 'H6',  to_date('Dec 2007', 'Mon YYYY'), 4); 
insert into BOOK_TRANSACTION values(null, 'Chadstone', 'Cus1', 'H6',  to_date('Dec 2007', 'Mon YYYY'), 4); 
insert into BOOK_TRANSACTION values(null, 'Chadstone', 'Cus4', 'DV',  to_date('Dec 2007', 'Mon YYYY'), 1); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus1', 'C1',  to_date('Dec 2007', 'Mon YYYY'), 9); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus3', 'C1',  to_date('Dec 2007', 'Mon YYYY'), 9); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus2', 'H6',  to_date('Dec 2007', 'Mon YYYY'), 3); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus1', 'DV',  to_date('Dec 2007', 'Mon YYYY'), 2); 
insert into BOOK_TRANSACTION values(null, 'Chadstone', 'Cus4', 'DV',  to_date('Dec 2007', 'Mon YYYY'), 1); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus1', 'C1',  to_date('Dec 2007', 'Mon YYYY'), 9); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus3', 'C1',  to_date('Dec 2007', 'Mon YYYY'), 9); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus2', 'H6',  to_date('Dec 2007', 'Mon YYYY'), 3); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus1', 'DV',  to_date('Dec 2007', 'Mon YYYY'), 2);
commit; 


-- explore data
select * from book_price_history;
select * from book;
select * from branch;
select * from book_transaction;
select * from customer;


-- solution model 1 -- no bridge dimension 
-- crete a dimension table called book_dim 
drop table book_dim;
create table book_dim as 
select distinct * from book;
select * from book_dim;

-- create dimension branch_dim
drop table branch_dim;
create table branch_dim as 
select distinct * from branch;

-- create dimension time_dim
drop table time_dim;
create table time_dim as
select distinct
    to_char(transaction_date, 'MonYYYY') as time_id,
    to_char(transaction_date,'YYYY') as year, 
    to_char(transaction_date, 'Mon') as month
from book_transaction;
select * from BOOK_TRANSACTION;

-- create the fact table book_sales_fact
drop table book_sales_fact;
-- create table book_sales_fact1 as
select to_char(bt.transaction_date, 'MonYYYY') as time_id,
    bt.book_id,
    bt.branch_id, 
    sum(bt.quantity) as number_of_books_sold 
from book_transaction bt
group by to_char(bt.transaction_date, 'MonYYYY'),
    bt.book_id,
    bt.branch_id
order by to_char(bt.transaction_date, 'MonYYYY'),
    bt.book_id,
    bt.branch_id; -- shouldnt i use this instead of the below one since it is faster

-- select to_char(T.TRANSACTION_DATE, 'MonYYYY') as TIME_ID,  BK.BOOK_ID, BR.BRANCH_ID, 
--  sum(T.QUANTITY) as NUMBER_OF_BOOKS_SOLD 
-- from BOOK_TRANSACTION T, BOOK BK, BRANCH BR 
-- where T.BRANCH_ID = BR.BRANCH_ID 
-- and T.BOOK_ID = BK.BOOK_ID 
-- group by to_char(T.TRANSACTION_DATE, 'MonYYYY'), BK.BOOK_ID,  BR.BRANCH_ID
-- order by to_char(T.TRANSACTION_DATE, 'MonYYYY'), BK.BOOK_ID,  BR.BRANCH_ID; 


select * from book_sales_fact1;

-- Solution Model 2 -- add a Temporal Bridge (Bridge Table)
-- create dimension book_price_dim
select * from book_price_history;
drop table book_price_dim;
create table book_price_dim as 
select distinct * from book_price_history;
select * from book_price_dim;



select F.TIME_ID as "Month", F.BRANCH_ID as "Branch", F.BOOK_ID  as "Book ID",  
 B.BOOK_TITLE as "Book Title", B.AUTHOR, BP.PRICE,   F.NUMBER_OF_BOOKS_SOLD as "No of Books Sold" 
from BOOK_SALES_FACT1 F, BOOK_PRICE_DIM BP, BOOK_DIM B where F.BOOK_ID = B.BOOK_ID 
and BP.BOOK_ID = B.BOOK_ID 
and to_date(F.TIME_ID, 'MonYYYY') >= to_date(BP.START_DATE,  'MonYYYY')  
and to_date(F.TIME_ID, 'MonYYYY') <= case BP.END_DATE when  'Now' then SYSDATE  
 else to_date(BP.END_DATE, 'MonYYYY') 
 end 
order by F.TIME_ID desc, F.BRANCH_ID desc, F.NUMBER_OF_BOOKS_SOLD  asc;

-- Book Sales Report 2
select * from book_sales_fact1;
select bsf.time_id, bsf.branch_id, bsf.book_id, b.book_title, b.author, bp.price, bsf.number_of_books_sold
from book_sales_fact1 bsf, book_price_dim bp, book_dim b
where bsf.book_id = b.book_id and bp.book_id = b.book_id
and to_date(bsf.time_id, 'MonYYYY') >= to_date(bp.start_date, 'MonYYYY')
and to_date(bsf.time_id, 'MonYYYY') <= case BP.END_DATE
                                            when 'Now' then SYSDATE
                                            else to_date(bp.end_date, 'MonYYYY')
                                            end
order by bsf.time_id desc, bsf.branch_id desc, bsf.number_of_books_sold asc;


-- Solution Model 3 - add a new Fact: Total Sales
-- create a new fact table: book_sales_fact2
drop table book_sales_fact2;
create table book_sales_fact2 as 
select * from book_sales_fact1;

-- add column total_sales (number) to books_sales_fact2
alter table book_sales_fact2
add total_sales number;

-- 
-- declare 
--     cursor price_cursor is select * from book_price_dim; 
--     valid_end_date date;
-- begin
--     for item in price_cursor loop 
--     if item.end_date = 'Now'  then 
--     valid_end_date := SYSDATE;
--     else 
--     valid_end_date := to_date(item.end_date, 'MonYYYY');
--     end if;
--     update book_sales_fact2 
--     set total_sales = 
--         number_of_books_sold * item.price
--         where book_id = item.book_id
--         and to_date(time_id, 'MonYYYY') >= to_date(item.start_date, 'MonYYYY') and 
--         to_date(time_id, 'MonYYYY') <= valid_end_date;
--     end loop;
-- end;


create table book_sales_fact2 as 
select to_char(t.transaction_date, 'MonYYYY') as time_id, 
bk.book_id, br.branch_id,
    sum(t.quantity) as number_of_books_sold, 
    sum(t.quantity * bp.price) as total_sales
from book_transaction t, book bk, branch br, book_price_history bp
where t.book_id = bk.book_id and bp.book_id = bk.book_id and t.branch_id = br.branch_id
and t.transaction_date >= to_date(bp.start_date, 'MonYYYY') and 
t.transaction_date <= case bp.end_date when 'Now' then sysdate
else to_date(bp.end_date, 'MonYYYY') end 
group by to_char(t.transaction_date, 'MonYYYY'), bk.book_id, br.branch_id;
select * from book_sales_fact2
order by time_id desc, branch_id desc;

-- create reports 
select * from book_sales_fact2;
select * from BOOK_PRICE_DIM;
select * from book_dim;
select * from branch_dim;
select * from time_dim;

select 
    f.time_id,
    f.branch_id,
    f.book_id,
    b.book_title,
    b.author,
    bp.price,
    f.number_of_books_sold
from book_sales_fact2 f, book_dim b, book_price_dim bp
where f.book_id = b.book_id and 
    b.book_id = bp.book_id and
    to_date(f.time_id, 'MonYYYY') >= to_date(bp.start_date, 'MonYYYY') and 
    to_date(f.time_id, 'MonYYYY') <= case 
            bp.end_date when 'Now' then sysdate
            else to_date(bp.end_date, 'MonYYYY') end;



