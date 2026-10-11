select * from dtaniar.author5;

-- go to sales table
-- number of book sold: quantity from salesdetails, and book
-- star rating can only be found using stars, and month



-- Your tasks:
-- Create a dimension table called TimeDim.
drop table timedim; 
create table timedim as 
select distinct to_char(salesdate, 'yyyymm') as timeid, 
to_char(salesdate,'mm') as month, 
to_char(salesdate,'yyyy') as year
from dtaniar.sales5;

select * from timedim; -- 28 rows

-- Create a dimension table called StoreDim.
drop table storedim;
create table storedim as 
select * from dtaniar.STORE5;

select * from storedim;

-- Create a dimension table called CategoryDim.
drop table categorydim;
create table categorydim as 
select * from dtaniar.CATEGORY5;

select * from categorydim;

-- Create a dimension table called StarRatingDim. This table will have 6 records (0 for 'Unknown', 1 for 'Poor', 2 for 'Not Good', 3 for 'Average', 4 for 'Good', 5 for 'Excellent')
drop table StarRatingDim;
create table StarRatingDim 
(
    starid number(1),
    stardescription varchar2(20)
);
select * from STARRATINGDIM;

-- which books has never been reviewed
SELECT title, ISBN
 FROM dtaniar.book5
 WHERE isbn
 NOT IN (SELECT DISTINCT isbn FROM dtaniar.review5);

insert into STARRATINGDIM values(0,'Unknown');

insert into STARRATINGDIM values(1,'Poor');

insert into STARRATINGDIM values(2,'Not Good');

insert into STARRATINGDIM values(3,'Average');

insert into STARRATINGDIM values(4,'Good');

insert into STARRATINGDIM values(5,'Excellent');



-- Create a fact table called ReviewFact.
create table reviewfact as 
select categoryid, stars as starid,
count(*) as num_of_reviews
from dtaniar.review5 natural join dtaniar.book5
group by categoryid, stars;

select * from reviewfact
order by categoryid, starid;

-- Create a tempfact table called TempBookWithStar. (NOTE: Books without review should be included in the result, and it should get a ZERO in the Star).
drop table TempBookWithStar;
create table TempBookWithStar as 
select 
    b.isbn, 
    b.categoryid,
    nvl(r.stars,0) as Stars
from dtaniar.book5 b, dtaniar.review5 r
where b.isbn = r.isbn(+);

select * from TEMPBOOKWITHSTAR
order by isbn; --127 rows


-- Create a tempfact table called TempBookWithAvgStar. (NOTE: Calculate the average of stars by each book and each category using TempBookWithStar. The average of stars should be an integer either 0 or 1,2,3,4,5).
drop table TempBookWithAvgStar;
create table TempBookWithAvgStar as 
select isbn, categoryid, round(avg(stars),0) as avg_stars
from tempbookwithstar
group by isbn, categoryid;

select * from TEMPBOOKWITHAVGSTAR;

-- Create the final fact table called BookSalesFact. (NOTE: starid in the fact table is the average of stars).
drop table booksalesfact;
create table booksalesfact as
select categoryid, to_char(salesdate,'yyyymm') as timeid,
    storeid, avg_stars as star_id,
    sum(quantity) as num_of_books, 
    sum(totalprice) as total_sales
from dtaniar.sales5 natural join dtaniar.SALESDETAILS5 natural join TEMPBOOKWITHAVGSTAR
group by categoryid, to_char(salesdate,'yyyymm'),
    storeid, avg_stars;

select * from booksalesfact; -- 33 rows


-- What are the total sales for each bookstore in a month?
select storeid, sum(total_sales) as total_sales
from booksalesfact
group by storeid
order by storeid;

-- What is the number of books sold for each category?
select categoryid, sum(num_of_books) as num_of_books 
from booksalesfact
group by categoryid
order by categoryid;

-- What is the book category with the highest number of books sold?
SELECT categoryid,
      categorydescription,
      SUM(num_of_books) AS total_books_sold
 FROM booksalesfact
NATURAL JOIN categorydim
GROUP BY categoryid,
         categorydescription
ORDER BY total_books_sold desc
Fetch first 1 rows only;



SELECT *
FROM (
SELECT  categoryid,
        categorydescription,
        SUM(num_of_books) AS total_books_sold
 FROM booksalesfact
NATURAL JOIN categorydim
GROUP BY categoryid,
         categorydescription
ORDER BY TOTAL_BOOKS_SOLD DESC)
WHERE ROWNUM = 1;



-- What is the number of reviews for each category?
select r.categoryid, c.categorydescription, sum(r.num_of_reviews) as num_of_reviews
from reviewfact r , CATEGORYDIM c
where r.categoryid = c.categoryid
group by r.categoryid, c.categorydescription
order by categoryid;

select categoryid, categorydescription ,sum(num_of_reviews) as total_reviews
from reviewfact natural join categorydim
group by categoryid, categorydescription
order by categoryid;

-- How many 5-star reviews for each category?
SELECT categoryid,
      categorydescription,
      SUM(num_of_reviews) AS num_of_reviews
 FROM reviewfact
NATURAL JOIN categorydim
WHERE starid = 5
GROUP BY categoryid,
         categorydescription
ORDER BY categoryid;
