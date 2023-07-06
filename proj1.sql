-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear 
  FROM people
  WHERE weight > 300;
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear 
  FROM people
  WHERE namefirst LIKE '% %'
  ORDER BY namefirst ASC, namelast ASC;
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) as avgheight, count(*)
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear ASC;
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) as avgheight, count(*)
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear ASC;
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, halloffame.playerID, yearid
  FROM halloffame
  INNER JOIN people
  ON halloffame.playerID = people.playerID
  WHERE inducted = 'Y'
  ORDER BY yearid DESC, people.playerID ASC;
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, people.playerID, schools.schoolID, yearid
  FROM people
  INNER JOIN collegeplaying
  ON people.playerID = collegeplaying.playerID
  INNER JOIN schools
  ON collegeplaying.schoolID = schools.schoolID 
  INNER JOIN halloffame
  ON collegeplaying.playerID = halloffame.playerID
  WHERE inducted = 'Y' AND schoolState = 'CA'
  ORDER BY yearid DESC, schools.schoolID ASC, halloffame.playerID ASC;
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT people.playerID, namefirst, namelast, collegeplaying.schoolID
  FROM people
  LEFT OUTER JOIN collegeplaying
  ON people.playerID = collegeplaying.playerID
  INNER JOIN halloffame
  ON people.playerID = halloffame.playerID
  WHERE inducted = 'Y'
  ORDER BY halloffame.playerID DESC, collegeplaying.schoolID ASC;
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT batting.playerID, namefirst, namelast, yearID, ((CAST((H - H2B - H3B - HR) + (2 * H2B) + (3 * H3B) + (4 * HR) as float))
   / CAST(AB as float)) as slg
  FROM batting
  INNER JOIN people
  ON batting.playerID = people.playerID
  WHERE AB > 50
  ORDER BY slg DESC, yearID ASC, batting.playerID ASC
  LIMIT 10;
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT batting.playerID, namefirst, namelast,
  CAST(SUM((H - H2B - H3B - HR) + (2 * H2B) + (3 * H3B) + (4 * HR)) as float) / CAST(SUM(AB) as float) as lslg
  FROM batting
  INNER JOIN people
  ON batting.playerID = people.playerID
  GROUP BY batting.playerID
  HAVING SUM(AB) > 50
  ORDER BY lslg DESC, batting.playerID ASC
  LIMIT 10;
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT namefirst, namelast,
  CAST(SUM((H - H2B - H3B - HR) + (2 * H2B) + (3 * H3B) + (4 * HR)) as float) / CAST(SUM(AB) as float) as lslg
  FROM batting
  INNER JOIN people
  ON batting.playerID = people.playerID
  GROUP BY batting.playerID
  HAVING  SUM(AB) > 50 AND
  CAST(SUM((H - H2B - H3B - HR) + (2 * H2B) + (3 * H3B) + (4 * HR)) as float) / CAST(SUM(AB) as float) > 
    (
      SELECT CAST(SUM((H - H2B - H3B - HR) + (2 * H2B) + (3 * H3B) + (4 * HR)) as float) / CAST(SUM(AB) as float)
      FROM batting
      WHERE batting.playerID = 'mayswi01'
    )
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearID, MIN(salary), MAX(salary), AVG(salary)
  FROM salaries
  GROUP BY yearID
  ORDER BY yearID ASC
;


-- Helper table for 4ii
DROP TABLE IF EXISTS binids;
CREATE TABLE binids(binid);
INSERT INTO binids VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9);

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  SELECT binids.binid, MIN(salary), MAX(salary), count
  FROM salaries, binids
  GROUP BY (
  -- Honestly this one was too hard for me. :)
  )
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT S.yearID,
  MIN(S.salary) - (SELECT MIN(F.salary) FROM salaries F WHERE F.yearID = S.yearID -1),
  max(S.salary) - (SELECT max(F.salary) FROM salaries F WHERE F.yearID = S.yearID -1),
  avg(S.salary) - (SELECT avg(F.salary) FROM salaries F WHERE F.yearID = S.yearID -1)
  FROM salaries as S
  GROUP BY S.yearID
  ORDER BY S.yearID
  LIMIT -1
  OFFSET 1
;
-- Another solution
-- CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
-- AS
--   SELECT S.yearID,
--   MIN(S.salary) - (SELECT MIN(F.salary) FROM salaries F WHERE F.yearID = S.yearID -1),
--   max(S.salary) - (SELECT max(F.salary) FROM salaries F WHERE F.yearID = S.yearID -1),
--   avg(S.salary) - (SELECT avg(F.salary) FROM salaries F WHERE F.yearID = S.yearID -1)
--   FROM salaries as S
--     WHERE S.yearID <> (
--     SELECT F.yearID
--     FROM salaries F
--     ORDER BY F.yearID ASC
--     LIMIT 1
--   )
--   GROUP BY S.yearID
--   ORDER BY S.yearID
-- ;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT S.playerID, P.namefirst, P.namelast, S.salary, S.yearID
  FROM salaries S
  INNER JOIN people P
  ON S.playerID = P.playerID
  WHERE (S.yearID = 2001 OR S.yearID = 2000) AND S.salary >=(
    SELECT MAX(F.salary)
    FROM salaries F
    WHERE F.yearID = S.yearID
  )
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT A.teamID, MAX(S.salary) - MIN(S.salary)
  FROM allstarfull A
  INNER JOIN salaries S
  ON  A.playerID = S.playerID AND A.yearid = S.yearid
  WHERE A.yearID = 2016
  GROUP BY A.teamID
;


