-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

-- If a database named 'tournament' already exists, it will drop it
DROP DATABASE IF EXISTS tournament;
-- Creates a new database named 'tournament'
CREATE DATABASE TOURNAMENT;
-- Above statements make sure the database is created everytime this sql file
-- is executed


-- Connects to tournament db
\c tournament;

-- Creates a new table named PLAYER if it does not exist already
CREATE TABLE IF NOT EXISTS PLAYER (
  -- ID stores player id which is an integer. SERIAL data type defines the
  -- behavior of auto generation of values in this column using a
  -- sequence and trigger. This column acts as PRIMARY KEY
  ID SERIAL PRIMARY KEY,

  -- NAME stores the names of the players. It cannot take NULL for a name i.e.
  -- A player must have a name
  NAME VARCHAR(30) NOT NULL
);

-- Creates a new table named MATCH it it does not exist already
CREATE TABLE IF NOT EXISTS MATCH (
  -- ID column stores unique ID for every match. SERIAL data type is used for
  -- auto generation of integer values in this column
  ID SERIAL PRIMARY KEY,

  -- WINNER stores player id of winner of the match. It has a foreign key
  -- constraint which references PLAYER table's PRIMARY KEY (ID column). This
  -- ensures the players must be present in PLAYER table to play a match
  WINNER INTEGER REFERENCES PLAYER,

  -- LOSER stores player id of loser of the match. It has a foreign key
  -- constraint which references PLAYER table's PRIMARY KEY (ID column).
  LOSER INTEGER REFERENCES PLAYER,

  -- If a match has resulted into draw, this column has a boolean value of TRUE
  -- otherwise it is FALSE
  DRAW BOOLEAN
);


-- This creates a view in named MATCHES_PLAYED which returns player id,
-- player name and the number of matches that player has played
CREATE OR REPLACE VIEW MATCHES_PLAYED AS
-- COALESCE is PostgreSQL function which replaces any null empty/NULL values
-- with whatever passed in second argument which in our case is 0.
SELECT P.ID AS ID, P.NAME AS PLAYER, COALESCE(COUNT(M.ID),0) AS MATCHES
-- A LEFT JOIN is applied on the PLAYER and MATCH tables to check whoever has
-- played any matches irrespective of the result of the match.
FROM PLAYER P LEFT JOIN MATCH M ON P.ID = M.WINNER OR P.ID=M.LOSER
-- GROUP BY statement is used to aggregate the results based on player name
-- and id
GROUP BY P.NAME, P.ID
-- Sorts the results in descending order of number of matches played
ORDER BY COUNT(*) DESC;



-- Creates a view named PLAYER_WINS which returns the id, name and number of
-- matches won by players
CREATE OR REPLACE VIEW PLAYER_WINS AS
SELECT P.ID AS ID, P.NAME AS PLAYER, COALESCE(COUNT(M.WINNER),0) AS WINS
-- LEFT JOIN on PLAYER and MATCH tables to check if a match has not resulted in
-- a draw, then which player's id is present in WINNER column. This is same
-- like the MATCHES_PLAYED view but with a filter on number of times a player id
-- appears in WINNER column when DRAW column has the value of FALSE
FROM PLAYER P LEFT JOIN MATCH M ON P.ID = M.WINNER AND M.DRAW is FALSE
GROUP BY P.NAME, P.ID
-- Sorts the results in descending order of the number of wins
ORDER BY COUNT(*) DESC;



-- Creates a view named TIES which assigns TIE_POINTS to players who have tied
-- matches. Every player is given 0.5 point for each tied match. Returns
-- player id, name, tie points.
CREATE OR REPLACE VIEW TIES AS
-- It reads the results of sub query which gets the number of drawn matches
-- for each player and returns player id, name and calculated tie points
SELECT S.ID AS ID, S.NAME AS PLAYER,
-- Number of drawn matches are counted for each player and multiplied by 0.5
-- for tie points
COUNT(S.NAME)*0.5 AS TIE_POINTS
FROM (
  -- Returns player id and name of players who have played matches and results
  -- were a draw. In case of draw, winner and loser columns have the IDs of
  -- both players but they are not interpreted as actual winner or loser of the
  -- match because the DRAW has a value of TRUE.
  SELECT P.ID, P.NAME
  FROM PLAYER P, MATCH M
  WHERE (P.ID = M.WINNER OR P.ID = M.LOSER) AND M.DRAW = TRUE
) S
GROUP BY S.NAME, S.ID
-- Sorted on the descending number of points for drawn matches for player.
ORDER BY COUNT (S.NAME) DESC;


-- Creates a view that has columns for player id, name, wins and matches.
-- It adds up the number of wins with tie points if there is any draw match
-- for a player
CREATE OR REPLACE VIEW STANDING AS
SELECT MP.ID AS ID, MP.PLAYER AS PLAYER,
COALESCE(P.WINS,0) AS WINS, MP.MATCHES AS MATCHES
FROM MATCHES_PLAYED MP
-- Applies a LEFT JOIN on MATCHES_PLAYED and Win points table from Subquery
LEFT JOIN (
  -- Gets the players and the win points by adding the tie points
  -- to number of wins from PLAYER_WINS view.
  SELECT PW.ID AS ID, PW.PLAYER AS PLAYER,
  COALESCE(PW.WINS + COALESCE(T.TIE_POINTS,0),0) AS WINS
  FROM PLAYER_WINS PW
  -- LEFT JOIN on the PLAYER_WINS view and TIES VIEW to selct only the players
  -- for standings
  LEFT JOIN TIES T
  ON PW.ID = T.ID
) P

ON MP.ID=P.ID;
