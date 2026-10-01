-- Explore the Book Sales Case Study 
select * from dtaniar.author5;
select * from dtaniar.book5;
select * from dtaniar.titleauthor5;
select * from dtaniar.category5;
select * from dtaniar.publisher5;
select * from dtaniar.review5;
select * from dtaniar.store5;
select * from dtaniar.sales5;
select * from dtaniar.salesdetails5;

-- You are required to design a small data warehouse for analysis purposes. 
-- The analysis is needed for identifying at least the following questions:

-- What are the total sales for each bookstore in a month? (bookstore dim), (month/time dim)
-- What is the number of books sold for each category? (category dim)
-- What is the book category that has the highest total sales? (book category dim)
-- What is the number of reviews for each category? (category dim)
-- How many 5-star reviews for each category? (5-starreview dim), (category dim)

-- QUESTION: why is it the multifact starratingdim is connected to the booksales 
    -- when the questions does not require us to know for each starrating how many books is sold or the total sales for each starring?

-- Fact Measure: 
    -- Total Sales
    -- number of books sold
    -- number of reviews


-- create dimension timedim
drop table timedim;
create table timedim as 
select distinct 
    to_char(salesdate, 'yyyymm') as timeid, 
    to_char(salesdate, 'mm') as month, 
    to_char(salesdate, 'yyyy') as year
from dtaniar.sales5;

select * from timedim;


-- create dimension table storedim 
drop table storedim;
create table storedim as 
select * 
from dtaniar.store5;

select * from storedim;

-- create dimension categorydim
drop table categorydim;
create table categorydim as 
select * 
from dtaniar.category5;

select * from categorydim;

-- create dimension starratingdim
select * from dtaniar.review5; -- book reviews star rating is in numbers from range 1-5
drop table starratingdim;
create table starratingdim 
(
    starid number(1),
    stardescription varchar2(15)
);

insert into starratingdim values (0, 'Unknown');
insert into starratingdim values (1, 'Poor');
insert into starratingdim values (2, 'Not Good');
insert into starratingdim values (3, 'Average');
insert into starratingdim values (4, 'Good');
insert into starratingdim values (5, 'Excellent');

select * from starratingdim;


-- create fact table reviewfact
drop table reviewfact;
create table reviewfact as
select 
    b.categoryid,
    r.stars as starid, 
    count(*) as num_of_review
from dtaniar.book5 b, dtaniar.review5 r
where b.isbn = r.isbn 
group by b.categoryid, r.stars;

select * from reviewfact;


-- createtempfavt table called tempbokwithstar
drop table tempbookwithstar;
create table tempbookwithstar as 
select b.isbn, b.categoryid, nvl(r.stars, 0) as star 
from dtaniar.book5 b, dtaniar.review5 r 
where b.isbn = r.isbn (+);

select * from tempbookwithstar; -- for each isbn there is multiple star reviews , because many customer can buy the same book with the same isbn

select * 
from TempBookWithStar 
where ISBN='0316465186';

-- create tempfactwithavgstar
drop table tempbookwithavgstar;
create table tempbookwithavgstar 
as select isbn, categoryid, round(avg(star)) as avg_star -- QUESTION: why is it that we can use avg() aggregate function here
from tempbookwithstar
group by isbn, categoryid;

select * from tempbookwithavgstar;

-- create teh final fact table called booksalesfact
-- nnote star id in the fact table is average of star
drop table booksalesfact;
create table booksalesfact as 
select 
    t.categoryid,
    to_char(s.salesdate, 'YYYYMM') as timeid,
    s.storeid, 
    t.avg_star as starid, 
    sum(sd.quantity) as num_of_books, 
    sum(sd.totalprice) as total_sales
from tempbookwithavgstar t, dtaniar.sales5 s, dtaniar.salesdetails5 sd 
where t.isbn = sd.isbn and sd.salesid = s.salesid
group by 
    t.categoryid,
    to_char(s.salesdate, 'YYYYMM'),
    s.storeid, 
    t.avg_star;

select * from booksalesfact;

-- QUESTION: why do we need starid here because the business question doesnt state that there is analysis required between the starid and numofbooks and totalsales???

-- what are the total sales for each bookstore in a month 
select * from dtaniar.store5;
select * from dtaniar.sales5;
select s.storeid, t.year, t.month, sum(bsf.total_sales) as total_sales
from booksalesfact bsf, timedim t, storedim s
where bsf.storeid = s.storeid and bsf.timeid = t.timeid
group by s.storeid, t.month, t.year -- would the total_sales obtained be wrong if you aggregate using month, that would mean the sales obtained from different years of the same month would be aggregated too no?
order by s.storeid, t.month, t.year;

-- if t.year is added then the number of records is 54

-- what is the number of books sold for each category
select * from booksalesfact;
select * from categorydim;
select c.categoryid, c.categorydescription, sum(f.num_of_books) as num_of_books_sold
from booksalesfact f, categorydim c 
where c.categoryid = f.categoryid
group by c.categoryid, c.categorydescription
order by c.categoryid, c.categorydescription;


-- what is the book category with the highest number of books sold
select * from booksalesfact;
select categoryid, categorydescription, num_of_books_sold
from (
    select c.categoryid, c.categorydescription, sum(f.num_of_books) as num_of_books_sold
    from booksalesfact f, categorydim c 
    where c.categoryid = f.categoryid
    group by c.categoryid, c.categorydescription
    order by c.categoryid, c.categorydescription
)
where num_of_books_sold = (
    select max(num_of_books_sold)
    from (
        select c.categoryid, c.categorydescription, sum(f.num_of_books) as num_of_books_sold
        from booksalesfact f, categorydim c 
        where c.categoryid = f.categoryid
        group by c.categoryid, c.categorydescription
        order by c.categoryid, c.categorydescription
    )
); -- slower

select * from (
  select 
    c.CATEGORYID, 
    c.CATEGORYDESCRIPTION, 
    sum(f.num_of_books) as total_num_books
  from booksalesfact f, categorydim c
  where f.categoryid = c.categoryid
  group by c.CATEGORYID, c.CATEGORYDESCRIPTION
  order by total_num_books desc)
where rownum =1;

-- what is the number of reviews for each category 
select * from reviewfact;

select c.categoryid, c.categorydescription, sum(r.num_of_review) as total_num_of_review
from reviewfact r, categorydim c
where r.categoryid = c.categoryid
group by c.categoryid, c.categorydescription
order by c.categoryid, c.categorydescription;


-- how many 5-star reviews for each category
select * from reviewfact;

select c.categoryid, c.categorydescription, s.starid, s.stardescription, sum(r.num_of_review) as total_num_of_review
from reviewfact r, categorydim c, starratingdim s
where r.categoryid = c.categoryid and 
    s.starid = r.starid and 
    r.starid = 5
group by c.categoryid, c.categorydescription, s.starid, s.stardescription
order by c.categoryid, c.categorydescription, s.starid, s.stardescription;