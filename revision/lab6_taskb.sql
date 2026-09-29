-- Task B: Q1. Star Schema – Pivoted Fact Table Version
-- QUESTION: What is a pivoted fact table and when is it used 
    -- it is used when determinant attributes/dimension is present 
    -- and instead of using a determinant dimension, we choose 
        -- to use a pivoted fact measure, whereby the determinant attribute is within the 
            -- fact measure
            -- forcing users of the data warehouse to also take into consideration the determinant 
            -- component within their analysis

-- QUESTION: When is this pivoted table better used compared to the determinant dimension (star schema) version (is this case dependent?)
    -- the normal determinant dimension star schema version would require more join statemenst when querying (complex querying)
        -- inefficient join statements when querying
        -- smaller storage usage due to inner join used (removes....)
    -- the pivoted fact table would redue the storage usage and join statements when querying (advantage)
    -- creating the star schema (pivoted fact table) is more complex , uses more storage (as it is a cartesion product, outer join, records with no )

-- create dimensions 
-- create countryVenueDIM
    -- do not need address, venueID, or name of Venue just ocuntry 
    -- because the analysis/ business question only encompasses analysis between country and grade and test component
drop table countryVenueDIM; 
create table countryVenueDIM as 
select distinct v.countrycode, c.countryname, v.testprice 
from ptetest.test_venue v, ptetest.country c
where v.countrycode = c.countrycode;

select * from COUNTRYVENUEDIM;

-- create citizenshipDIM
    -- from student, as student has a citizenship from a particular country
    -- this dimensions shows a student from (some) country
    -- only need countrycode, countryname, and citizenship  
    -- in the ptetest.student table citizenship is the countrycode, citizenship attribute is a FK
    -- does not need to include student name registrationID and whatnot, since we do not require further analysis, and listing of which student took what test and got what score and grade
drop table citizenshipDIM;
create table citizenshipDIM as 
select distinct s.citizenship, c.countryname
from ptetest.student s, ptetest.country c
where s.citizenship = c.countrycode;

select * from CITIZENSHIPDIM; -- this dimension includes the student who are registered in the pte academic test system citizenship
-- thus country where the pte academic test venus are in the country but no student took test from that country before is also true 
-- but in the dimension we only include the country which student has registered, since our analysis is particularly on student who has registered (the number of them)
    -- based on either their citizenship, where they took the test, which year they took the test, the grade they have gotten for a particular test (eg. listnening)

-- can be obtained from operational database, create yearDIM
drop table YearDIM;
create table YearDIM as 
select distinct to_char(testdate, 'YYYY') as year
from ptetest.test;

select * from YEARDIM; -- only one record at year 2017, correct since when exploring the ptetest.test table
-- we know then the registere test are only at year 2017

-- create dimension gradeDIM
-- after exploring the operational system for pte acaddemic test system, notably table ptetest.test_result which has the test score
-- there is no 'proficient'/'competent' grade stated
-- and none of this data from the rest of the system, thus we know that we need to create this dimension manually
-- given is that we have 5 types of grade 
drop table gradeDIM;
create table gradeDIM 
(
    grade varchar2(3),
    description varchar2(20),
    minscore number,
    maxscore number
);

insert into gradeDIM values ('4.5','Functional',30,35);
insert into gradeDIM values ('5','Vocational',36,49);
insert into gradeDIM values ('6','Competent',50,64);
insert into gradeDIM values ('7','Proficient',65,78);
insert into gradeDIM values ('8-9','Superior',79,90);

select * from GRADEDIM;


-- in pivoted fact table star schema there is no determinant dimension testcomponentdim

-- Step 1: create the dimensions 
select * from countryVenueDIM;
select * from gradedim;
select * from citizenshipdim; 
select * from yeardim;

-- Create the Temp Fact Table 
-- WHY? because, there is a dimension in the star schema which does not use records that come from the operational database, 
    -- but manually inserted data

drop table tempfact;
create table tempfact as
select v.countrycode as VenueCountryCode,
    s.citizenship as CitizenshipCountryCode, 
    to_char(t.testdate, 'YYYY') as year, -- from fact table information
    r.listeningscore, -- to obtain grade
    r.readingscore, 
    r.writingscore, 
    r.speakingscore,
    r.overallscore,
    r.registrationid
from ptetest.test_venue v, -- this is an inner join
    ptetest.student s,
    ptetest.test t,
    ptetest.test_result r
where v.venueid = t.venueid and 
    r.registrationid = s.registrationid and 
    t.testno = r.testno;

select * from tempfact;

alter table tempfact
add (GradeOverall varchar2 (3),
    GradeListening varchar2(3),
    GradeReading varchar2(3),
    GradeWriting varchar2(3),
    GradeSpeaking varchar2(3));

update tempfact 
set GradeOverall = (
    case
    when overallScore >=30 and OverallScore <= 35 then '4.5' 
    when overallScore >= 36 and OverallScore <= 49 then '5'
    when overallScore >= 50 and OverallScore <= 64 then '6'
    when overallScore >= 65 and overallScore <= 78 then '7'
    when overallScore >= 79 and overallScore <= 90 then '8-9'
    end
);

update tempfact 
set GradeListening = (
    case
    when listeningScore >=30 and listeningScore <= 35 then '4.5' 
    when listeningScore >= 36 and listeningScore <= 49 then '5'
    when listeningScore >= 50 and listeningScore <= 64 then '6'
    when listeningScore >= 65 and listeningScore <= 78 then '7'
    when listeningScore >= 79 and listeningScore <= 90 then '8-9'
    end
);

update tempfact 
set GradeReading = (
    case
    when readingScore >=30 and readingScore <= 35 then '4.5' 
    when readingScore >= 36 and readingScore <= 49 then '5'
    when readingScore >= 50 and readingScore <= 64 then '6'
    when readingScore >= 65 and readingScore <= 78 then '7'
    when readingScore >= 79 and readingScore <= 90 then '8-9'
    end
);

update tempfact 
set GradeWriting = (
    case
    when writingScore >=30 and writingScore <= 35 then '4.5' 
    when writingScore >= 36 and writingScore <= 49 then '5'
    when writingScore >= 50 and writingScore <= 64 then '6'
    when writingScore >= 65 and writingScore <= 78 then '7'
    when writingScore >= 79 and writingScore <= 90 then '8-9'
    end
);

update tempfact 
set GradeSpeaking = (
    case
    when speakingScore >=30 and speakingScore <= 35 then '4.5' 
    when speakingScore >= 36 and speakingScore <= 49 then '5'
    when speakingScore >= 50 and speakingScore <= 64 then '6'
    when speakingScore >= 65 and speakingScore <= 78 then '7'
    when speakingScore >= 79 and speakingScore <= 90 then '8-9'
    end
);

select * from tempfact;


-- Step 3: create temporary fact table for each test component 
drop table overallfact;
create table OverallFact as 
select 
    venuecountrycode, 
    citizenshipcountrycode, 
    year, 
    gradeoverall as grade,
    'Overall' as TestComponent, 
    count(registrationid) as total_students_overall
from tempfact
group by 
    venuecountrycode, 
    citizenshipcountrycode, 
    year, 
    gradeoverall,
    'Overall';

select * from overallfact;

drop table listeningfact;
create table listeningfact as 
select 
    venuecountrycode, 
    citizenshipcountrycode,
    year,
    gradelistening as grade,
    'Listening' as TestComponent,
    count(registrationid) as total_students_listening
from tempfact
group by 
    venuecountrycode, 
    citizenshipcountrycode,
    year,
    gradelistening,
    'Listening';
select * from listeningfact;

drop table readingfact;
create table readingfact as 
select 
    venuecountrycode, 
    citizenshipcountrycode,
    year,
    gradereading as grade,
    'Reading' as TestComponent,
    count(registrationid) as total_students_reading
from tempfact
group by 
    venuecountrycode, 
    citizenshipcountrycode,
    year,
    gradereading,
    'Reading';

select * from readingFact;

select * from writingfact;
drop table writingfact;
create table writingfact as 
select 
    venuecountrycode, 
    citizenshipcountrycode,
    year,
    gradewriting as grade,
    'Writing' as TestComponent,
    count(registrationid) as total_students_writing
from tempfact
group by 
    venuecountrycode, 
    citizenshipcountrycode,
    year,
    gradewriting,
    'Writing';

select * from writingfact;

select * from speakingfact;
drop table speakingfact;
create table speakingfact as 
select 
    venuecountrycode, 
    citizenshipcountrycode,
    year,
    gradespeaking as grade,
    'Speaking' as TestComponent,
    count(registrationid) as total_students_speaking
from tempfact
group by 
    venuecountrycode, 
    citizenshipcountrycode,
    year,
    gradespeaking,
    'Speaking';


select * from overallfact;
select * from readingfact;
select * from listeningfact;
select * from writingfact;
select * from speakingfact;


select * from countryvenuedim;
-- step 4: create a cartesian product of all dimensions in order to get all possible combinations of the dimensions
drop table AllDimensions; -- this is an inner join 
create table AllDimensions as 
select 
    v.countrycode,
    c.citizenship,
    y.year,
    g.grade
from countryvenuedim v, 
    citizenshipdim c, 
    yeardim y, 
    gradedim g;

select * from alldimensions;

-- temporary fact table for each test component 
-- using outer join operation between alldimensions table and each temporary fact from before 
select * from overallfact;
drop table overallfactnew;
create table overallfactnew as 
select 
    a.countrycode,
    a.citizenship, 
    a.year, 
    a.grade, 
    nvl(o.total_students_overall, 0) as total_students_overall
from alldimensions a, overallfact o 
where a.countrycode = o.venuecountrycode (+) and -- left outer join
    a.citizenship = o.citizenshipcountrycode (+) and 
    a.year = o.year (+) and 
    a.grade = o.grade (+);

select * from overallfactnew;

drop table listeningfactnew;
create table listeningfactnew as 
select 
    a.countrycode,
    a.citizenship, 
    a.year, 
    a.grade, 
    nvl(o.total_students_listening, 0) as total_students_listening
from alldimensions a, listeningfact o 
where a.countrycode = o.venuecountrycode (+) and -- left outer join
    a.citizenship = o.citizenshipcountrycode (+) and 
    a.year = o.year (+) and 
    a.grade = o.grade (+);

select * from listeningfactnew;



drop table readingfactnew;
create table readingfactnew as 
select 
    a.countrycode,
    a.citizenship, 
    a.year, 
    a.grade, 
    nvl(o.total_students_reading, 0) as total_students_reading
from alldimensions a, readingfact o 
where a.countrycode = o.venuecountrycode (+) and -- left outer join
    a.citizenship = o.citizenshipcountrycode (+) and 
    a.year = o.year (+) and 
    a.grade = o.grade (+);

select * from readingfactnew;


drop table writingfactnew;
create table writingfactnew as 
select 
    a.countrycode,
    a.citizenship, 
    a.year, 
    a.grade, 
    nvl(o.total_students_writing, 0) as total_students_writing
from alldimensions a, writingfact o 
where a.countrycode = o.venuecountrycode (+) and -- left outer join
    a.citizenship = o.citizenshipcountrycode (+) and 
    a.year = o.year (+) and 
    a.grade = o.grade (+);

select * from writingfactnew;


drop table speakingfactnew;
create table speakingfactnew as 
select 
    a.countrycode,
    a.citizenship, 
    a.year, 
    a.grade, 
    nvl(o.total_students_speaking, 0) as total_students_speaking
from alldimensions a, speakingfact o 
where a.countrycode = o.venuecountrycode (+) and -- left outer join
    a.citizenship = o.citizenshipcountrycode (+) and 
    a.year = o.year (+) and 
    a.grade = o.grade (+);

select * from speakingfactnew;

-- create the final fact table
drop table finalfact2; 
create table finalfact2 as 
select
    o.countrycode,
    o.citizenship,
    o.year, 
    o.grade,
    o.total_students_overall, 
    l.total_students_listening, 
    r.total_students_reading, 
    w.total_students_writing,
    s.total_students_speaking
from 
    overallfactnew o, 
    listeningfactnew l,
    readingfactnew r, 
    writingfactnew w, 
    speakingfactnew s 
where O.CountryCode = L.CountryCode 
and L.CountryCode = R.CountryCode 
and R.CountryCode = W.CountryCode 
and W.CountryCode = S.CountryCode 
and O.Citizenship = L.Citizenship 
and L.Citizenship = R.Citizenship 
and R.Citizenship = W.Citizenship 
and W.Citizenship = S.Citizenship 
and O.Year = L.Year 
and L.Year = R.Year 
and R.Year = W.Year 
and W.Year = S.Year 
and O.Grade = L.Grade 
and L.Grade = R.Grade 
and R.Grade = W.Grade 
and W.Grade = S.Grade; 

select * from finalfact2; -- 60 records 

-- remove unnecessary data weher all total students for each fact measure is 0 
delete from FinalFact2 
where Total_Students_Overall = 0 
and Total_Students_Listening = 0 
and Total_Students_Reading = 0 
and Total_Students_Writing = 0 
and Total_Students_Speaking = 0; 

select * from finalfact2; -- 11 records, similar to the actual number of test takers which is 11 

select * from ptetest.test_result; -- 11 records 

-- Task B: Reports 

-- How many students received a competent grade in their overall score 
select f.grade, g.description, sum(f.total_students_overall) as number_of_students
from finalfact2 f, gradedim g
where f.grade = g.grade and 
    g.description = 'Competent'
group by f.grade, g.description; -- 3 students 
-- Comparatively: to taska where determinant dimension is used, there is same amount of join however one less condition


-- How many students took the test in 2017
select * from finalfact2;

select f.year, 
    sum(f.total_students_overall),
    sum(f.total_students_listening),
    sum(f.total_students_reading),
    sum(f.total_students_writing),
    sum(f.total_students_speaking)
from finalfact2 f
where f.year = '2017'
group by f.year;
-- QUESTION: Why does the solution require me to join with the yeardim, when the year can just be obtained in the fact table?

-- How many Korean citizen students took the test 
select * from finalfact2;
select f.citizenship, 
    c.countryname,
    sum(f.total_students_overall),
    sum(f.total_students_listening),
    sum(f.total_students_reading),
    sum(f.total_students_writing),
    sum(f.total_students_speaking)
from finalfact2 f, citizenshipdim c
where f.citizenship = c.citizenship and 
    c.countryname = 'Korea'
group by f.citizenship, c.countryname;


-- How many students took the test in Australia 
select * from finalfact2;

select 
    f.countrycode, 
    v.countryname, 
    sum(f.total_students_overall),
    sum(f.total_students_listening),
    sum(f.total_students_reading),
    sum(f.total_students_writing),
    sum(f.total_students_speaking)
from finalfact2 f, countryvenuedim v 
where f.countrycode = v.countrycode and 
    v.countryname = 'Australia'
group by f.countrycode, v.countryname;

-- how many chinese students received a proficient grade in the listening part in 2017
select * from finalfact2;

select 
    f.citizenship, 
    c.countryname, 
    f.grade, 
    g.description, 
    f.year,
    sum(f.total_students_listening)
from finalfact2 f, citizenshipdim c, gradedim g
where f.citizenship = c.citizenship and 
    f.grade = g.grade and 
    f.year = '2017' and 
    g.description = 'Proficient' and 
    c.countryname = 'China'
group by f.citizenship , 
    c.countryname, 
    f.grade, 
    g.description, 
    f.year;

-- how many japanese students received a competent grade in 2017 
select * from finalfact2;

select 
    f.citizenship, 
    c.countryname, 
    f.grade, 
    g.description, 
    f.year,
    sum(f.total_students_overall),
    sum(f.total_students_listening),
    sum(f.total_students_reading),
    sum(f.total_students_writing),
    sum(f.total_students_speaking)
from finalfact2 f, citizenshipdim c, gradedim g
where f.citizenship = c.citizenship and 
    f.grade = g.grade and 
    f.year = '2017' and 
    g.description = 'Competent' and 
    c.countryname = 'Japan'
group by f.citizenship , 
    c.countryname, 
    f.grade, 
    g.description, 
    f.year;

-- why does this query show an extra student in the listening part 
-- QUESTION: does this mean that the number of student 