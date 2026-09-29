-- PTE Academic Test Case Study 
-- You are required to build a data warehouse for this PTE Academic Test system. 
    -- The  data warehouse must be able to answer at least the following questions: 

-- How many students received a Competent grade in their overall score?
-- How many students took the test in 2017? 
-- How many Korean citizen students took test? 
-- How many students took the test in Australia?  
-- How many Chinese students received a Proficient Grade in the Listening part in 2017? 

-- explore the data in the operational database
select * from ptetest.test_venue;
select * from ptetest.test;
select * from ptetest.test_supervisor;
select * from ptetest.supervisor;
select * from ptetest.test_result;
select * from ptetest.student;
select * from ptetest.country;


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

-- first try w/o test_component
-- since we have manually created gradeDIM because the operational database/system does not hae grade information
-- we have to first create a tempFact

-- drop table tempfact;
-- create table tempfact as 
-- select countryCode, 
--     citizenship, 
--     year, 
--     grade,
--     listeningscore, 
--     readingscore, 
--     speakingscore, 
--     writingscore, 
--     overallscore, 
--     listeninggrade, 
--     readinggrade,
--     speakinggrade, 
--     writinggrade

-- the above is what happens if we do not have the test_component determinant dimension 
-- thus we need to create an additional dimension for test_component
-- so that the fact table is not crowded with a bunch of attributes????


-- create dimension testComponentDIM
drop table testComponentDIM;
create table testComponentDIM
(
    testComponent varchar2(20)
);

insert into testComponentDIM values ('Listening');
insert into testComponentDIM values ('Reading');
insert into testComponentDIM values ('Speaking');
insert into testComponentDIM values ('Writing');
insert into testComponentDIM values ('Overall');

select * from testComponentDIM; -- this is a determinant dimension
-- Determinant Dimension: A dimension which Key Attribute must be used in each instance of querying to ensure meaningful output

-- Try Again: Since testComponentDIM and gradeDIM is manually created without accessing the operational database
    -- it is required that we create a temporary fact first 

drop table tempfact;
create table tempfact as
select v.countrycode as VenueCountryCode,
    s.citizenship as CitizenshipCountryCode, 
    to_char(t.testdate, 'YYYY') as year, -- from fact table information
    listeningscore, -- to obtain grade
    r.readingscore, 
    r.speakingscore, 
    r.writingscore,
    r.overallscore,
    r.registrationid
from ptetest.test_venue v, -- this is an inner join
    ptetest.student s,
    ptetest.test t,
    ptetest.test_result r
where v.venueid = t.venueid and 
    r.registrationid = s.registrationid and 
    t.testno = r.testno;
select * from ptetest.test_result; -- there is 11 records and all the records have a score 
-- QUESTION:  I understand that inner join causes certain records to dissapear because of the values not being in the other tables in the operational database 
-- in what instance would that affect this creation of tempfact 
select * from ptetest.student; -- there is 8 students 
-- however some of the student retake tests 
-- so the record could show that the number of students taking a test within a year to be mor than 8 students (due to retakes)
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
-- tempfact finalised gradde for each test component

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


-- create the final fact table
drop table finalfact;
create table finalfact as 
select 
    venuecountrycode, 
    citizenshipcountrycode,
    year,
    grade, 
    testcomponent, 
    total_students_overall as total_students 
from OVERALLFACT
union 
    select * from listeningfact
union 
    select * from readingfact
union 
    select * from writingfact
union 
    select * from speakingfact;

select * from finalfact;

-- Task A: The report 
-- How many students received a Competent grade in their overall score? 
select * from gradedim;
select * from finalfact;

select f.grade, g.description, f.testcomponent, sum(f.total_students) as number_of_students
from finalfact f, gradedim g
where 
    f.grade = g.grade and
    f.testcomponent = 'Overall' and 
    g.description = 'Competent'
group by f.grade, f.testcomponent, g.description; -- 3 students   

-- my solution also gives the same result 
-- is this correct? however from my understanding of determinant dimension, the determinant dimension must be joined and queried
-- alongside the other components, however wouldnt that be more iinefficient as compared to not joining 3 tables but just 2???

-- solution: 
-- SELECT g.grade, g.description as grade_description, t.testcomponent,  SUM(f.total_students) as number_of_students 
-- FROM FinalFact f, TestComponentDim t, GradeDim g 
-- WHERE f.grade = g.grade 
-- AND f.testcomponent = t.testcomponent 
-- AND g.description = 'Competent' 
-- AND t.testcomponent = 'Overall' 
-- GROUP BY g.grade, g.description, t.testcomponent; 


-- how many students took the test in 2017 has
select * from finalfact;
select * from ptetest.test_result; -- there is only 11 students 
-- each student has each of the testcomponent 
select * from citizenshipdim;
select * from testcomponentdim;

select year, testcomponent, sum(total_students) as number_of_students
from finalfact 
where testcomponent = 'Overall' and year = '2017'
group by year, testcomponent; -- this gives the correct answer 
-- QUESTION:  although i understand that the testcomponentdim is a determinant dimension, thus 
-- when retrieving information from the fact without the information of the determinant dimension causes the query to be uninsightful 
-- however in this case without the join to the determinant dimension we are still able to obtain the correct result 
-- QUESTION:  SO WHY DO WE NEED TO join the testcomponentdim, wouldnt that make the query inefficient, and slow

-- in this case if testcomponent is not queried as one of the main select components,
    -- it would produce a false result
        -- below: 
select year, sum(total_students) as number_of_students
from finalfact 
where testcomponent = 'Overall' and year = '2017'
group by year, testcomponent;  -- is this true? in this case without testcomponent attribute we still get meaningful result 
-- as in at year 2017 there is number of students 
-- because in the where clause, we specified only for 'overall' component 
-- QUESTION:  this is weird because we purposefully included the condition that to obtain number of students at 2017 
    -- from understanding that in the operatioal database there is only 11 records of student 
    -- and understanding if we were not to include the condition specifially for a test_component, the obtained result would be false
-- Does this mean that thus testcomponent is a determinant attribute, despite it not being used as part of the select statement but only in the where clause (condition)
-- because without testcomponent attribute the result is false?
-- Does this then mean that a determinant dimension/attribute means that without the use of that attribute when querying (either as a condition or select statement) 
-- the result could be either false / unmeaningful?


-- How many Korean citizen students took test? 
select * from finalfact;
select * from citizenshipdim;
select * 
from ptetest.test_result t, ptetest.STUDENT s, ptetest.country c
where t.registrationid = s.registrationid and 
    c.countrycode = s.citizenship and 
    c.countryname = 'Korea'; -- from this query we know that registrationid is the same for both students
-- and that the student with registrationid = 891186588 retook the test

select c.countryname, f.testcomponent, sum(f.total_students) as number_of_students
from finalfact f, citizenshipdim c 
where f.citizenshipcountrycode = c.citizenship and 
    c.countryname = 'Korea' and 
    f.testcomponent = 'Overall'
group by  c.countryname, f.testcomponent; 
-- this shows that 2 korean students took the test, testcomponent = 'Overall'
-- QUESTION: I have use testcomponent in the query thus showing again, it is a determinant attribute?

select c.countryname, sum(f.total_students) as number_of_students
from finalfact f, citizenshipdim c 
where f.citizenshipcountrycode = c.citizenship and 
    c.countryname = 'Korea'
group by  c.countryname, f.testcomponent; -- this shows for each component 2 korean student took the test
-- QUESTION:  Why 2 not 1, is it because the main business question encompassing the analysis is based on
    -- the test??? like as long as it is a Korean Student and it is a different test despite the same person 
    -- you should report it as 2 korean students ?

-- the fact table does not allow us to find out whether it is the same person or not 
-- it only reports whether the student taking the test if of what citizenship, where the test takes place (venue), the grade of the student, when the test takes place 
-- the main analysis questions: 
    -- How many students received a Competent grade in their overall score?
    -- How many students took the test in 2017? 
    -- How many Korean citizen students took test? 
    -- How many students took the test in Australia?  
    -- How many Chinese students received a Proficient Grade in the Listening part in 2017? 
-- Based on the above: 
    -- comptent grade based on score (gradedim)
    -- year (how many students took the test in year 2017)
    -- citizen of the students (how many korean citizen took test)
    -- venue of test being taken (how many students took the test in australia)
    -- chinese student (citizenship), proficientgrade (grade), listening part (testcomponent)

-- from the above we found out we need to create dimensions: gradedim, yeardim, citizenshipdim, testvenuedim, testcomponentdim

-- QUESTION:  How did we figure out that testcomponentdim is a determinant dimension??
    -- determinant dimension definition: the testcomponent must be used in every query to ensure meaningful output
    -- in this case if testcomponentdim is not a determinant dimension would the output not be meaningful?
    -- yes it wont be meaningful as seen in the above query if we remove the testcompoent attribute, we would have 
        -- 5 records composing countryname and number_of_students, but what do we get out of it 
        -- we just know that korea has 2 students because of something that seperates it into 5 different records 


-- How many students took the test in Australia -- the venue of the test is in Australia 
select * from finalfact;
select * from countryvenuedim;
select f.venuecountrycode, v.countryname, sum(total_students) as number_of_students
from finalfact f, countryvenuedim v 
where f.venuecountrycode = v.countrycode and 
    upper(v.countryname) = upper('Australia') -- QUESTION: do we need to use upper all the time? the solutions doesnt use upper
group by f.venuecountrycode, v.countryname; -- Meaning: this does not work, because it shows that number of student that took the exam in australia is 40 
-- in fact this output is skewed because for each instance of test taken by a particular registrationid, it includes all test components, (business case), student MUST take all testcomponents

select f.venuecountrycode, v.countryname, sum(total_students) as number_of_students
from finalfact f, countryvenuedim v 
where f.venuecountrycode = v.countrycode and 
    upper(v.countryname) = upper('Australia') -- QUESTION: do we need to use upper all the time? the solutions doesnt use upper
group by f.venuecountrycode, v.countryname; 

-- CORRECTION: 
select f.venuecountrycode, v.countryname, f.testcomponent, sum(total_students) as number_of_students
from finalfact f, countryvenuedim v 
where f.venuecountrycode = v.countrycode and 
    upper(v.countryname) = upper('Australia') and 
    upper(f.testcomponent) = upper('Overall')
group by f.venuecountrycode, v.countryname, f.testcomponent; -- QUESTION: based on the solutions again, why do we need to join testcomponentdim??? is this a format or must ? for determinant dimension although the results can be obtained without the testcomponentdim?

-- for each testcomponent there is 8 australian students taking the test
-- QUESTION: what does the Overall Component mean? 


-- How many Chinese students received a Proficient Grade in the Listening part in 2017?
select * from finalfact;
select * from gradedim;
select f.citizenshipcountrycode, c.countryname, f.grade, g.description, f.testcomponent, f.year, sum(f.total_students) as number_of_students
from finalfact f, gradedim g, citizenshipdim c
where f.citizenshipcountrycode = c.citizenship and 
    f.grade = g.grade and 
    c.countryname = 'China' and
    g.description = 'Proficient' and
    f.testcomponent = 'Listening' and
    f.year = '2017'
group by f.citizenshipcountrycode, c.countryname, f.grade, g.description, f.testcomponent, f.year; 


-- how many japanese students received a competent grade in 2017 
select * from finalfact;

select f.citizenshipcountrycode, c.countryname, f.grade, g.description, f.testcomponent, f.year, sum(f.total_students) as number_of_students
from finalfact f, gradedim g, citizenshipdim c
where f.citizenshipcountrycode = c.citizenship and 
    f.grade = g.grade and 
    c.countryname = 'Japan' and
    g.description = 'Competent' and
    f.year = '2017'
group by f.citizenshipcountrycode, c.countryname, f.grade, g.description, f.testcomponent, f.year; -- this also shos number of students taking the testcomponent for listening is 2 



