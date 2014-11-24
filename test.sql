/*
Напишите запрос, выводящий из таблицы список ID сотрудников с нумерацией по дате рождения и с сортировкой по зарплате от большей к меньшей.
 */
CREATE TABLE #T1
(
	[user_id]     INT,
	birthday      DATETIME,
	salary        MONEY
);
GO
INSERT INTO #T1
  (
    [user_id],
    birthday,
    salary
  )
VALUES
  (1,'1981-03-02',1200.00),
(2, '1983-09-12', 1100.00),
(3, '1981-03-02', 1500.00),
(4, '1986-09-16', 3800.00)
GO
;
WITH T
     AS
     (
         SELECT ROW_NUMBER() OVER(ORDER BY t.salary) AS number,
                t.[user_id]
         FROM   #T1 t
     )
SELECT t.number,
       t.[user_id]
FROM   T t
 GO
DROP TABLE #T1
GO
---------------------------------------------------------------------
/*
Напишите наиболее быстрый по времени выполнения запрос вывода всех сотрудников,
работавших в компании в определённый период времени. 
*/
CREATE TABLE #T1
(
	[user_id]      INT,
	date_start     DATETIME,
	date_end       DATETIME
)
GO
INSERT INTO #T1
(
	[user_id],
	date_start,
	date_end
)
VALUES (1,'2008-05-05','2012-10-10'),
(2,'2003-12-15','2005-01-15'),
(3,'2008-05-05','2012-10-10'),
(4,'2012-03-07','2014-09-12')
GO
DECLARE @date_start DATETIME = '2008-05-05',
        @date_end DATETIME   = '2012-10-10'
        
SELECT t.[user_id]
FROM   #T1 t
WHERE  t.date_start >= @date_start
       AND t.date_end <= @date_end     
GO
DROP TABLE #T1
GO 
/*
Напишите запрос, показывающий все отличия таблицы @tt от таблицы @t.
Есть уточнения по заданию, написал запрос в разрезе комбинаций перебора значений.
*/
DECLARE @t      TABLE(x INT NOT NULL, y INT)
DECLARE @tt     TABLE(x INT NOT NULL, y INT)
insert into @t values(1, 3)
insert into @t values(2, 2)
insert into @t values(3, NULL)
insert into @t values(5, NULL)
insert into @tt values(1, 3)
insert into @tt values(3, NULL)
insert into @tt values(4, 3)

SELECT t.* 
FROM @tt t
FULL JOIN @t t2
ON t2.x != t.x AND t2.y != t.y 
GO
/*
Необходимо написать запрос, выводящий три поля: день, максимальная температура за день, час, 
в который максимальная температура была достигнута.
Запрос должен выводить, например, такую выборку:

dt t h
2006-07-06 25 12:00
2006-07-07 22 14:00

*/
CREATE TABLE #T
(
	dt     DATETIME,
	t      FLOAT
);
GO 
INSERT INTO #T
(
	dt,
	t
)
VALUES ('2005-01-02 12:00', 21),
('2005-01-03 12:00', 21),
('2005-01-03 14:00', 24),
('2005-01-04 15:00', 21),
('2005-01-04 10:00', 19),
('2005-01-06 11:00', 21),
('2005-01-06 12:00', 22),
('2005-01-06 13:00', 23)
GO
;WITH T
      AS
      (
          SELECT CAST(t.dt AS DATE) AS dt,
                 t.t,
                 CONVERT(CHAR(5), t.dt, 108) AS h
          FROM   #T t
      ), res
      AS 
      (
          SELECT ROW_NUMBER() OVER(PARTITION BY t.dt ORDER BY t.h DESC) AS rn,
                 t.dt,
                 MAX(t.t) OVER(PARTITION BY t.dt ORDER BY t.h DESC) AS t,
                 t.h
          FROM   T t
      )
 SELECT r.dt,
        r.t,
        r.h
 FROM   res r
 WHERE  r.rn = 1
GO
DROP TABLE #T
GO
/*
Как сократить время выполнения запроса «select b, sum(d) from T group by b»?
*/
CREATE TABLE #T
(
	A     INT NOT NULL PRIMARY KEY,
	b     INT,
	c     INT,
	d     FLOAT
);
GO 
INSERT INTO #T
(
	A,
	b,
	c,
	d
)
VALUES (1,2,2,3),
(2,50,7,8),
(3,4,3,12),
(4,20,5,12),
(5,2,2,3)
GO
--Максимально ускорить данный запрос можно создав индексирование представлеие, с индексом по полям выборки
--Второй вариант колоночный индекс по полю d
SELECT b,
       SUM(d) AS d
FROM   #T
GROUP BY
       b
GO
DROP TABLE #T

