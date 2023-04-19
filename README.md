## Introduction:

Enterprise Database Management is an essential course for anyone interested in understanding the complexities of managing large databases. Under the guidance of <b>Professor James Markulic</b>, we explored a <b>baseball-related database</b> that covered a wide range of topics, from basic to advanced. The course consisted of nine different topics, including creating tables, SQL queries, creating functions, triggers, and more, along with an extra project.

Throughout the course, we were required to load the baseball database and work on various SQL queries and functions using <b>Microsoft SQL Server Management Studio</b>. To help others practice using this tool, I have organized all the questions in separate folders with my answers. The repository is a great resource for anyone interested in learning and improving their SQL manipulation skills.

In summary, this project not only taught me the ins and outs of managing a database but also allowed me to hone my SQL skills. I hope that this resource will be helpful to others in their quest to master the intricacies of enterprise database management.

--------------

## 00. Load the Baseball Dataset | [Tutorial](https://github.com/ChiaLinz/Baseball-DataBse-Management-System/blob/0e56956278276fc47135353923534c3b6b35b0aa/00.%20Install/00.%20Creating%20the%20Baseball%20Database%20Using%20Scripts.pdf)

The first step in this project is to load the [baseball dataset](https://github.com/ChiaLinz/Baseball-DataBse-Management-System/blob/0e56956278276fc47135353923534c3b6b35b0aa/00.%20Install/Baseball.zip). This dataset contains information about various baseball players and teams, including their statistics, demographics, and other relevant information. Loading this dataset is a crucial step in analyzing and manipulating the data using SQL queries and functions.

To load the dataset, we will be using Microsoft SQL Server Management Studio, which is a powerful tool for managing databases. This tool provides a user-friendly interface for loading and manipulating large datasets, making it ideal for this project.

Once the dataset is loaded, we can start exploring the data and working on various SQL queries and functions to extract meaningful insights. This step is critical for anyone interested in enterprise database management as it lays the foundation for further analysis and manipulation of large datasets.

To better understand the Baseball database, you can refer to the [Baseball Database Documentation](https://github.com/ChiaLinz/Baseball-DataBase-Management/blob/375f85c0a777904e4c4ed65e4dfff2d9bb2183c7/00.%20Install/Baseball%20Database%20Documentation.pdf) which provides information on the various columns, tables, attributes, and their descriptions. This document helps to understand the structure of the database and the meaning of each field in the database. 


--------------

## 01. [Create the Park Table](https://github.com/ChiaLinz/Baseball-DataBase-Management/blob/e0469940be11461536ab8378385bca809f7dce35/01.%20Create%20the%20Park%20Table/01.%20Create%20the%20Park%20Table.pdf)

In this step, we load the park dataset containing information about baseball parks in the United States and create a table in our database to store this data, enabling more efficient querying and manipulation of information, while also providing a foundation for managing large datasets.

--------------

## 02. SQL Question &nbsp; [Part 1](https://github.com/ChiaLinz/Baseball-DataBase-Management/blob/e0469940be11461536ab8378385bca809f7dce35/02.%20SQL%20Question%20Part%201/02.%20SQL%20Question%20Part%201.pdf) &nbsp;&nbsp;|&nbsp;&nbsp; [Part 2](https://github.com/ChiaLinz/Baseball-DataBase-Management/blob/e0469940be11461536ab8378385bca809f7dce35/03.%20SQL%20Question%20Part%202/03.%20SQL%20Question%20Part%202.pdf)&nbsp;&nbsp;|&nbsp;&nbsp; [Part 3](https://github.com/ChiaLinz/Baseball-DataBase-Management/blob/e0469940be11461536ab8378385bca809f7dce35/07.%20SQL%20Question%20Part%203/07.%20SQL%20Question%20Part%203.pdf)

To learn the technology needed to answer these SQL questions, one should have a basic understanding of SQL syntax and concepts such as SELECT, FROM, WHERE, and JOIN statements, aggregate functions like COUNT, SUM, AVG, and MAX, and scalar subqueries.

Additionally, one should be familiar with the following tables:

| Pitching table
| Teams table|
| Batting table
| People table
| CollegePlaying table
| HallofFame table
| Salaries table
| Appearances table |

Furthermore, one should know how to calculate the Earned Run Average (ERA) and Batting Average (BA), format results using the FORMAT statement, concatenate columns using the CONCAT function, use the NULLIF function, and sort results using the ORDER BY clause. Finally, one should be able to use scalar subqueries in the SELECT statement and the IN clause in the WHERE statement to filter results based on certain conditions.

--------------

## 03. Create &nbsp;[View](https://github.com/ChiaLinz/Baseball-DataBase-Management/blob/e0469940be11461536ab8378385bca809f7dce35/04.%20Revised%20View/04.%20Revised%20View.pdf) &nbsp;&nbsp;|&nbsp;&nbsp;[Function](https://github.com/ChiaLinz/Baseball-DataBase-Management/blob/e0469940be11461536ab8378385bca809f7dce35/05.%20Create%20Function/05.%20Create%20Function.pdf)&nbsp;&nbsp;|&nbsp;&nbsp;[Trigger](https://github.com/ChiaLinz/Baseball-DataBase-Management/blob/e0469940be11461536ab8378385bca809f7dce35/08.%20Create%20Trigger/08.%20Create%20Trigger.pdf)

In this section involves creating a view, a function, and a trigger in SQL. The view, named NJITID_Player_History, is created using SQL queries that retrieve data from multiple tables, perform calculations, and group and filter data as needed. The function is created using SQL code to perform a specific task and can be called from SQL queries. The trigger is created using SQL DDL statements to automatically update specific columns in the PEOPLE table whenever a row is inserted, updated or deleted from the FIELDING table. It uses basic math functions and the INSERTED and DELETED tables to update the columns.

--------------

## 04. [ODBC connection](https://github.com/ChiaLinz/Baseball-DataBase-Management/blob/e0469940be11461536ab8378385bca809f7dce35/06.%20ODBC%20connection/06.%20ODBC%20connection.pdf)

To use Excel to load the results of the view created in Question 4 Revised, an ODBC connection needs to be established between Excel and the database. ODBC is an open standard application programming interface (API) that allows programs to access data in a database management system (DBMS) using SQL as a standard for accessing data. Once the ODBC connection is established, data can be imported from the view into Excel using the SQL query as the data source. The imported data can be manipulated, analyzed, and visualized using Excel's tools and features.

--------------

## 05. [Transaction Processing](https://github.com/ChiaLinz/Baseball-DataBase-Management/blob/e0469940be11461536ab8378385bca809f7dce35/09.%20Transaction%20Processing/09.%20Transaction%20Processing.pdf)

This section is related to transaction processing and cursor processing in a database. The task is to create a script that adds two columns to a table, creates an update cursor, updates the columns based on the cursor, selects a system variable, turns off update counters, writes log information for every 1,000 records updated, and finally deallocates the cursor. The script should also include a query to select specific columns from the updated table. Running the script twice and analyzing the results is also required. The data being updated is related to baseball statistics, specifically the Equivalent Average metric.

--------------

## 06. [Extra Project](https://github.com/ChiaLinz/Baseball-DataBase-Management/blob/e0469940be11461536ab8378385bca809f7dce35/10.%20Extra%20Project/10.%20Extra%20Project.pdf)

As the dataset is quite large, it exceeds the size limit for uploading to GitHub. Therefore, to access the necessary files such as Temperature.txt, GunCrimes.csv, and AQS_Sites.txt, please download them from the [Google Drive link](https://drive.google.com/file/d/1gWc3XuDgcVZEDx-AQeJ98DFY-Anm3KuD/view?usp=sharing). Once downloaded, the data should be loaded into a SQL Server for further manipulation as required for the project.


This extra project consists of three sections that use different technologies:

&nbsp;&nbsp; The first section involves using **temperature data** to make advance queries in SQL. This section involves using SQL ranking statements, windowing within ranking functions, and datepart functions.

&nbsp;&nbsp; The second section involves using **geospatial data** and stored procedures in SQL. This section also involves creating a front-end interface to display the data.

&nbsp;&nbsp; The third section involves using **GunCrime dataset** to create and populate a geography column and rank by shooting events. This section involves importing data into the database, updating stored procedures, and creating Cartesian products to filter data.

--------------

## End of the article

Thank you for reading my article on Enterprise Database Management. If you want to improve your SQL manipulation skills or learn more about the Baseball-related database used in this project, you can access all the questions and answers in separate folders on my GitHub repository at https://github.com/ChiaLinz/Baseball-DataBase-Management.

I have also shared other interesting projects on [my GitHub repository](https://github.com/ChiaLinz) and [my personal website](https://jeffrey-hsieh-portfolio.vercel.app/). Please feel free to visit and contact me for any questions or feedback. Thank you again for your time, and I hope this resource will be helpful in your journey to master enterprise database management.
