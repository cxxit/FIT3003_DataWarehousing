-- Task A: 
DROP TABLE countryVenueDIM;


CREATE TABLE countryVenueDIM AS
SELECT DISTINCT CountryCode, CountryName, TestPrice
FROM ptetest.test_venue NATURAL JOIN ptetest.country;


SELECT * FROM countryVenueDIM;

-- For the Citizenship Dimension, it is also a join between Student and Country tables from the operational database
-- to get the Citizenship (which is the Country Code), and Country Name.
DROP TABLE citizenshipDIM;
CREATE TABLE citizenshipDIM AS
SELECT DISTINCT CountryCode, CountryName
FROM ptetest.student JOIN ptetest.country ON citizenship = countrycode;


SELECT * FROM citizenshipDIM;




-- For the Year Dimension, it is basically an extraction from the Test Date attribute in the Test table.
DROP TABLE YearDIM;


CREATE TABLE YearDIM AS
SELECT DISTINCT TO_CHAR(TestDate, 'yyyy') AS Year
FROM ptetest.test;


SELECT * FROM YearDIM;



-- GradeDIM
DROP TABLE gradeDIM;
CREATE TABLE gradeDIM (
    grade       VARCHAR2(3),
    description VARCHAR2(20),
    minscore    NUMBER,
    maxscore    NUMBER    
);


INSERT INTO gradeDIM VALUES ('4.5', 'Functional', 30, 35);
INSERT INTO gradeDIM VALUES ('5', 'Vocational', 36, 49);
INSERT INTO gradeDIM VALUES ('6', 'Competent', 50, 64);
INSERT INTO gradeDIM VALUES ('7', 'Proficient', 65, 78);
INSERT INTO gradeDIM VALUES ('8-9', 'Superior', 79, 90);


SELECT * FROM gradeDIM;

-- TestComponentDIM
DROP TABLE testComponentDIM;


CREATE TABLE testComponentDIM(
    TestComponent VARCHAR2(20)
);


INSERT INTO testComponentDIM VALUES ('Listening');
INSERT INTO testComponentDIM VALUES ('Reading');
INSERT INTO testComponentDIM VALUES ('Writing');
INSERT INTO testComponentDIM VALUES ('Speaking'); 
INSERT INTO testComponentDIM VALUES ('Overall');


SELECT * FROM testComponentDIM;


DROP TABLE tempfact;


CREATE TABLE tempfact AS
    SELECT TV.CountryCode, S.Citizenship, TO_CHAR(TestDate, 'yyyy') AS Year, ListeningScore, ReadingScore, WritingScore, SpeakingScore, OverallScore, R.registrationID
FROM ptetest.test_venue TV JOIN ptetest.test T ON TV.venueID = T.venueID
JOIN ptetest.test_result R ON R.testNo = T.testNo
JOIN ptetest.student S ON R.registrationID = S.registrationID;








ALTER TABLE tempfact
ADD (   GradeOverall VARCHAR2(3),
        GradeListening VARCHAR2(3),
        GradeReading VARCHAR2(3),
        GradeWriting VARCHAR2(3),
        GradeSpeaking VARCHAR2(3)
);


UPDATE tempfact
SET GradeOverall =
(Case
    WHEN OverallScore BETWEEN 30 AND 35 THEN '4.5'
    WHEN OverallScore BETWEEN 36 AND 49 THEN '5'
    WHEN OverallScore BETWEEN 50 AND 64 THEN '6'
    WHEN OverallScore BETWEEN 65 AND 78 THEN '7'
    WHEN OverallScore BETWEEN 79 AND 90 THEN '8-9'
END);


update tempfact
set GradeListening = (
case
    when listeningScore between 30 and 35 then '4.5'
    when listeningScore between 36 and 49 then '5'
    when listeningScore between 50 and 64 then '6'
    when listeningScore between 65 and 78 then '7'
    when listeningScore between 79 and 90 then '8-9'
end
);


UPDATE TEMPFACT
SET GRADEREADING =
(
    CASE
        WHEN READINGSCORE BETWEEN 30 AND 35 THEN '4.5'
        WHEN READINGSCORE BETWEEN 36 AND 49 THEN '5'
        WHEN READINGSCORE BETWEEN 50 AND 64 THEN '6'
        WHEN READINGSCORE BETWEEN 65 AND 78 THEN '7'
        WHEN READINGSCORE BETWEEN 79 AND 90 THEN '8-9'
    END
);


UPDATE TEMPFACT
SET GRADEWRITING =
(
    CASE
        WHEN WRITINGSCORE BETWEEN 30 AND 35 THEN '4.5'
        WHEN WRITINGSCORE BETWEEN 36 AND 49 THEN '5'
        WHEN WRITINGSCORE BETWEEN 50 AND 64 THEN '6'
        WHEN WRITINGSCORE BETWEEN 65 AND 78 THEN '7'
        WHEN WRITINGSCORE BETWEEN 79 AND 90 THEN '8-9'
    END
);


UPDATE TEMPFACT
SET 
GRADESPEAKING =
(
    CASE	
        WHEN SPEAKINGSCORE BETWEEN 30 AND 35 THEN '4.5'
        WHEN SPEAKINGSCORE BETWEEN 36 AND 49 THEN '5'
        WHEN SPEAKINGSCORE BETWEEN 50 AND 64 THEN '6'
        WHEN SPEAKINGSCORE BETWEEN 65 AND 78 THEN '7'
        WHEN SPEAKINGSCORE BETWEEN 79 AND 90 THEN '8-9'
    END
);


/* Temporary fact for each test component */
CREATE TABLE OverallFact AS	
SELECT countrycode, citizenship, year, GradeOverall as Grade, 'Overall' AS TestComponent,
        COUNT(RegistrationID) AS Total_Students_Overall
FROM TEMPFACT
GROUP BY countrycode, citizenship, year, GradeOverall, 'Overall';


SELECT * FROM OverallFACT;


DROP TABLE ListeningFACT;
CREATE TABLE ListeningFact AS
SELECT countrycode, citizenship, year, GradeListening as Grade, 'Listening' AS TestComponent,
        COUNT(RegistrationID) AS Total_Students_Overall
FROM TEMPFACT
GROUP BY countrycode, citizenship, year, GradeListening, 'Listening';


SELECT * FROM ListeningFACT;


CREATE TABLE ReadingFact AS
SELECT CountryCode, Citizenship, Year, GradeReading as Grade, 'Reading' AS TestComponent,
COUNT(RegistrationID) AS TOTAL_STUDENTS_OVERALL
FROM TEMPFACT
GROUP BY CountryCode, Citizenship, Year, GradeReading, 'Reading';


SELECT * FROM ReadingFact;


-- DROP TABLE WRITINGFACT;
CREATE TABLE WRITINGFACT
    AS
        SELECT COUNTRYCODE,
               CITIZENSHIP,
               YEAR,
               GRADEWRITING AS GRADE,
               'Writing' AS TESTCOMPONENT,
               COUNT(REGISTRATIONID) AS TOTAL_STUDENTS_OVERALL
          FROM TEMPFACT
         GROUP BY COUNTRYCODE,CITIZENSHIP, YEAR, GRADEWRITING,'Writing';




SELECT * FROM WRITINGFACT;


-- DROP TABLE SPEAKINGFACT;


CREATE TABLE SPEAKINGFACT
    AS
        SELECT COUNTRYCODE,
               CITIZENSHIP,
               YEAR,
               GRADESPEAKING AS GRADE,
               'Speaking' AS TESTCOMPONENT,
               COUNT(REGISTRATIONID) AS TOTAL_STUDENTS_OVERALL
          FROM TEMPFACT
         GROUP BY COUNTRYCODE,
                  CITIZENSHIP,
                  YEAR,
                  GRADESPEAKING,
                  'Speaking';


SELECT * FROM SPEAKINGFACT;

/* Create the final fact table by union-ing the temporary component fact tables */ 
CREATE TABLE FinalFACT AS
SELECT COUNTRYCODE, CITIZENSHIP, YEAR, Grade, TestComponent,  Total_Students_Overall AS Total_Students
FROM OVERALLFACT
UNION
SELECT * FROM ListeningFact
UNION
SELECT * FROM ReadingFact
UNION
SELECT * FROM WritingFact
UNION
SELECT * FROM SpeakingFact;

select * from finalfact;

-- How many students received a Competent grade in their overall score? 
select sum(total_students), f.grade, f.TestComponent
from finalfact f join gradedim g on f.grade = g.grade
where testcomponent = 'Overall' and g.description = 'Competent'
group by f.grade, f.TestComponent;

select sum(total_students) as total_students from finalfact
where to_char(year) = '2017';

select sum(total_students) as total_students
from finalfact
where to_char(year) = '2017'
and upper(testcomponent) = upper('Overall');

-- how many korean students took test 
select * from finalfact; 
select * from citizenshipdim;

select c.countryname, f.citizenship, sum(f.total_students)
from finalfact f
join CITIZENSHIPDIM c
on c.countrycode = f.citizenship
where upper(c.countryname) = upper('Korea')
and upper(f.testcomponent) = upper('Overall')
group by c.countryname, f.citizenship;

-- How many students took the test in Australia? (2 students)
select * from finalfact;

SELECT SUM(total_students) AS total_students
  FROM finalfact f
  JOIN countryvenuedim c
ON f.countrycode = c.countrycode
 WHERE upper(c.countryname) = upper('Australia')
   AND upper(f.testcomponent) = upper('Overall');



-- Task B: 
-- hat is a pivoted fact table

DROP TABLE AllDimensions;
create table AllDimensions as
select CO.CountryCode, CI.CountryCode AS Citizenship, Y.Year, G.Grade
from CountryVenueDim CO, CitizenshipDim CI, YearDim Y, GradeDim G;


SELECT * FROM AllDimensions;

-- why is it 60 rows
-- countryvenuedim = 2 
-- citizenshipdim = 6 
-- year = 1
-- grades = 5
-- 6*2*1*5 = 60 rows 

create table OverallFactNew as
select
  A.CountryCode, A.Citizenship, A.Year, A.Grade,
  nvl(O.Total_Students_Overall, 0) as Total_Students_Overall
from AllDimensions A, OverallFact O
where A.CountryCode = O.CountryCode(+)
and A.Citizenship = O.Citizenship(+)
and A.Year = O.Year(+) -- left outer join
and A.Grade = O.Grade(+);


SELECT * FROM OverallFactNew;


DROP TABLE ListeningFactNew;
create table ListeningFactNew as
select
  A.CountryCode, A.Citizenship, A.Year, A.Grade,
  nvl(O.Total_Students_Overall, 0) as Total_Students_Listening
from AllDimensions A, ListeningFact O
where A.CountryCode = O.CountryCode(+)
and A.Citizenship = O.Citizenship(+)
and A.Year = O.Year(+)
and A.Grade = O.Grade(+);







DROP TABLE WritingFactNew;
create table WritingFactNew as
select
  A.CountryCode, A.Citizenship, A.Year, A.Grade,
  nvl(O.Total_Students_Overall, 0) as Total_Students_Writing
from AllDimensions A, WritingFact O
where A.CountryCode = O.CountryCode(+)
and A.Citizenship = O.Citizenship(+)
and A.Year = O.Year(+)
and A.Grade = O.Grade(+);





DROP TABLE ReadingFactNew;
create table ReadingFactNew as
select
  A.CountryCode, A.Citizenship, A.Year, A.Grade,
  nvl(O.Total_Students_Overall, 0) as Total_Students_Reading
from AllDimensions A, ReadingFact O
where A.CountryCode = O.CountryCode(+)
and A.Citizenship = O.Citizenship(+)
and A.Year = O.Year(+)
and A.Grade = O.Grade(+);





DROP TABLE SpeakingFactNew;
create table SpeakingFactNew as
select
  A.CountryCode, A.Citizenship, A.Year, A.Grade,
  nvl(O.Total_Students_Overall, 0) as Total_Students_Speaking
from AllDimensions A, SpeakingFact O
where A.CountryCode = O.CountryCode(+)
and A.Citizenship = O.Citizenship(+)
and A.Year = O.Year(+)
and A.Grade = O.Grade(+);


SELECT * FROM ListeningFactNew;
SELECT * FROM WritingFactNew;
SELECT * FROM ReadingFactNew;
SELECT * FROM SpeakingFactNew;


-- fact consolidation
create table FinalFact2 as select
  O.CountryCode, O.Citizenship, O.Year, O.Grade,
  O.Total_Students_Overall, L.Total_Students_Listening,
  R.Total_Students_Reading, W.Total_Students_Writing,
  S.Total_Students_Speaking
from
  OverallFactNew O, ListeningFactNew L, ReadingFactNew R, WritingFactNew W, SpeakingFactNew S
where O.CountryCode = L.CountryCode and L.CountryCode = R.CountryCode
  and R.CountryCode = W.CountryCode and W.CountryCode = S.CountryCode
  and O.Citizenship = L.Citizenship and L.Citizenship = R.Citizenship
  and R.Citizenship = W.Citizenship and W.Citizenship = S.Citizenship
  and O.Year = L.Year and L.Year = R.Year and R.Year = W.Year and W.Year = S.Year
  and O.Grade = L.Grade and L.Grade = R.Grade and R.Grade = W.Grade and W.Grade = S.Grade;


select * from finalfact2;


-- why one uses union but the other usess join for the final fact???

-- remove rows where there is zero for all 5 fact measure 
delete from FinalFact2
where total_students_overall = 0 
and total_students_listening = 0
and total_students_reading = 0
and total_students_writing = 0
and total_students_speaking = 0;

-- Write the SQL statements to produce the following reports: 
-- How many students received a Competent grade in their overall score? 
select * from gradedim;
select * from finalfact2;

select g.description, sum(f.total_students_overall)
from finalfact2 f
join gradedim g
on g.grade = f.grade
where upper(g.description) = upper('Competent')
group by g.description;


select f.grade, g.description, sum(total_students_overall)
from finalfact2 f join gradedim g on f.grade = g.grade
where g.description = 'Competent'
group by f.grade, g.description;


-- How many students took the test in 2017? 
select * from finalfact2;
select sum(total_students_overall)
from finalfact2
where year = 2017;

-- How many Korean citizen students took test? 
select f.citizenship, sum(f.total_students_overall)
from finalfact2 f
join citizenshipdim c
on c.countrycode = f.citizenship
where upper(c.countryname) = upper('Korea')
group by f.citizenship;


SELECT countryname,
        SUM(total_students_overall) AS total_students_overall,
        sum(total_students_listening) as total_students_listening,
        sum(total_students_reading) as total_students_reading,
        sum(total_students_writing) as total_students_writing,
        sum(total_students_speaking) as total_students_speaking
 FROM finalfact2 f JOIN citizenshipdim c on c.countrycode = f.citizenship
WHERE upper(countryname) = upper('Korea')
GROUP BY countryname;


-- How many students took the test in Australia? (8 students)
select f2.countrycode, sum(total_students_overall)
from finalfact2 f2 join countryvenuedim gd on f2.countrycode = gd.countrycode
where upper(countryname) = upper('Australia')
group by f2.countrycode;

-- How many Chinese students received a Proficient Grade in the  Listening part in 2017? 
select citizenship,
       description as grade,
       year,
       sum(total_students_listening) as total_students_listening
  from finalfact2 f
  join gradedim g
on f.grade = g.grade
  join citizenshipdim c
on f.citizenship = c.countrycode
 where upper(c.countryname) = upper('China')
   and upper(description) = upper('Proficient')
   and year = '2017'
 group by citizenship,
          description,
          year;

-- How many Japanese students received a Competent Grade in 2017? 
SELECT citizenship,
      description AS grade,
      year,
      SUM(total_students_overall) AS total_students_overall,
        sum(total_students_listening) as total_students_listening,
        sum(total_students_reading) as total_students_reading,
        sum(total_students_writing) as total_students_writing,
        sum(total_students_speaking) as total_students_speaking
 FROM finalfact2 f
 JOIN gradedim g
ON f.grade = g.grade
 JOIN citizenshipdim c
ON f.citizenship = c.countrycode
WHERE upper(c.countryname) = upper('Japan')
  AND upper(description) = upper('Competent')
  AND year = '2017'
GROUP BY citizenship,
         description,
         year;


-- Based on both Task A and Task B, compare the star schema with 
-- Determinant  Dimension vs. star schema with Pivoted Fact Table. 

