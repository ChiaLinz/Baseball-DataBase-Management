--  Assignment 11 
--  Chapter 5 Trigger Assignment

--  1.	Create and populate a column called  UCID_Total_G_Played (where UCID needs to be your UCID) and a column called UCID_Career_Range_Factor in the PEOPLE table. Next populate both columns with the appropriate aggregate functions for each player. Total _G_Played is simply the sum of all the G columns for a player in the FIELDING table. Career_Range_Factoris calculated using the following formula: Career_Range_Factor (RF) = 9*sum(P+A)/(sum(InnOuts)/3). Your SQL will need to adjust the columns and results for any difficulties caused by the column data types. The performance factor indicates if a player helps others on his team play better (RF > 1) or takes away from their performance (RF < 1). The 3rd step is to write a trigger that updates the both of the columns you created in the PEOPLE table whenever there is a row inserted, updated or deleted from the FIELDING table. The trigger name must start with your UCID and the DDL that creates the trigger must also check to see if the trigger exists before creating it.
--  The trigger must use basic math functions (+, -) to adjust UCID_Total_G_Played.  You¡¦ll need to use the INSERTED and DELETED tables to get the values to add or subtract. You can use the appropriate aggregate functions and the FIELDING table to adjust/recalculate the UCID_Career_Range_Factor column correctly. 
--  Your answer must also include the queries necessary to verify your trigger works correctly. This would typically include 3 sets of queries. One each for Insert, Delete and Update commands. Each set would have the following pattern. The firsts query would select the columns from the PEOPLE and FIELDING tables. The 2nd query would perform the insert, update or delete function on the FIELDING table. The 3rd query would select the columns from the PEOPLE and FIELDING  tables to show that your trigger correctly updated the values changed in the 2nd query. The 3 sets needed would be separate queries for insert, update and delete . 
--  The last part of your submission needs to be the DDL to disable the trigger.
--  The trigger will be 80% of the grade and the queries to test your trigger will be 20% of the grade. 


Use Summer_2022_BaseBall;
GO

--Create and populate a column called  UCID_Total_G_Played (where UCID needs to be your UCID) and a column called UCID_Career_Range_Factor in the PEOPLE tabl
USE Summer_2022_BaseBall;
IF not exists 
	(SELECT *
	 FROM INFORMATION_SCHEMA.COLUMNS
	 WHERE TABLE_NAME = 'People' and COLUMN_NAME = 'ch35_Total_G_Played')
BEGIN
 ALTER TABLE People
 ADD ch35_Total_G_Played INTEGER;
END;
GO

IF not exists 
	(SELECT *
	 FROM INFORMATION_SCHEMA.COLUMNS
	 WHERE TABLE_NAME = 'People' and COLUMN_NAME = 'ch35_Career_Range_Factor')
BEGIN
 ALTER TABLE People
 ADD ch35_Career_Range_Factor INTEGER;
END;
GO

SELECT * FROM People



--Updating Total _G_Played
UPDATE People
 SET ch35_Total_G_Played = F.G
 FROM (SELECT playerID,	sum(G) AS G
	   FROM Fielding
	   GROUP BY playerID) AS F, People P
 where F.playerID = P.playerID
GO

--Updating Career_Range_Factoris 

ALTER TABLE Fielding
  ALTER COLUMN InnOuts float;

UPDATE People
SET ch35_Career_Range_Factor = F.RF
 FROM (SELECT playerID,CASE WHEN sum(cast(InnOuts as float))/3 = 0 THEN 0 When sum(cast(InnOuts as float))/3 is null THEN 0 ELSE CAST(9*sum(cast(DP as float)+cast(A as float))*1.0 /(sum(cast(InnOuts as float))/3)as Float) END as RF
           FROM Fielding
           GROUP BY playerID) AS F, People P
		   WHERE F.playerID = P.playerID
GO

-- Deleting trigger if exists
IF EXISTS (
	SELECT *
	FROM sys.objects
	WHERE [type] = 'TR' AND [name] = 'ch35_Career_Range_Factor'
	 )
 DROP TRIGGER ch35_Career_Range_Factor;
GO


-- Creating new trigger
CREATE TRIGGER ch35_CRF
ON FIELDING AFTER INSERT, UPDATE, DELETE
AS
BEGIN
IF EXISTS(SELECT * FROM inserted) and EXISTS (SELECT * FROM deleted)
BEGIN
 UPDATE People
SET ch35_Career_Range_Factor = (A.RF)
FROM (SELECT F.playerid, 9*sum(F.PO + F.A + I.PO + I.A - D.PO - D.A) / (sum(F.InnOuts + I.InnOuts - D.InnOuts)/3) as RF
FROM Fielding F, Inserted I, Deleted D
WHERE F.playerid = I.playerID and 
	  F.playerid = D.playerID
GROUP BY F.playerid) A
WHERE People.playerid = A.playerid 


UPDATE People
SET ch35_Total_G_Played = (ch35_Total_G_Played + A.New_G - A.del_G)
FROM (SELECT F.playerid, sum(I.G) AS New_G, sum(D.G) AS del_G
FROM Fielding F, Inserted I, Deleted D
WHERE F.playerid = I.playerID and 
	  F.playerid = D.playerID
GROUP BY F.playerid) A
WHERE people.playerid = A.playerid
END


IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted)
BEGIN
UPDATE People
SET ch35_Total_G_Played = (ch35_Total_G_Played + I.G)
FROM inserted I
WHERE People.playerid = I.playerID;
UPDATE People

SET ch35_Career_Range_Factor = (A.RF)
FROM (SELECT F.playerid, 9*sum(F.PO + F.A + I.PO + I.A ) / (sum(F.InnOuts + I.InnOuts)/3) as RF
FROM Fielding F, Inserted I
WHERE F.playerid = I.playerID 
GROUP BY F.playerid) A
WHERE People.playerid = A.playerid 
END

IF NOT EXISTS(SELECT * FROM inserted) and EXISTS (SELECT * FROM deleted)
BEGIN
UPDATE People
SET ch35_Total_G_Played = (ch35_Total_G_Played - D.G)
FROM Deleted D
WHERE People.playerid = D.playerID
UPDATE People
SET ch35_Career_Range_Factor = (A.RF)
FROM (SELECT F.playerid, 9*sum(F.PO + F.A - D.PO - D.A) / (sum(F.InnOuts - D.InnOuts)/3) as RF
FROM Fielding F, Deleted D
WHERE F.playerid = D.playerID
GROUP BY F.playerid) A
WHERE People.playerid = A.playerid 
END
END
Go



-- Tests on delete
SELECT playerid, ch35_Total_G_Played 
FROM People 
WHERE playerid ='aardsda01'

SELECT * 
FROM FIELDING
WHERE playerid ='aardsda01' and yearid = 2004

DELETE FROM FIELDING WHERE playerid ='aardsda01' and yearid = 2004

SELECT playerid, ch35_Total_G_Played 
FROM People 
WHERE playerid ='aardsda01'


-- Tests on insert
SELECT playerid, ch35_Total_G_Played 
FROM People 
WHERE playerid ='aardsda01'

INSERT INTO FIELDING VALUES ('aardsda01',1871,1,'TRO','NA','SS',1,1,24,1,3,2,0,null,null,null,null,null)

SELECT playerid, ch35_Total_G_Played
FROM People 
WHERE playerid ='aardsda01'


-- Tests on update
SELECT playerid, ch35_Total_G_Played, ch35_Career_Range_Factor 
FROM People
WHERE playerid ='aardsda01'
SELECT * FROM FIELDING WHERE playerid ='aardsda01' and yearid = 1871

UPDATE FIELDING
SET G = 1000
WHERE playerid ='aardsda01' and yearid = 2008
SELECT playerid, ch35_Total_G_Played, ch35_Career_Range_Factor FROM People WHERE
playerid = 'aardsda01';


-- Disable the trigger
ALTER Table FIELDING DISABLE Trigger ch35_CRF ;