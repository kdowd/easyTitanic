-- ============================================================
--  players.sql  —  teaching data for "First and Second Normal Form"
-- ============================================================
--  Load with:
--      psql -U postgres -d firstnormal -f players.sql
--  (first:  CREATE DATABASE firstnormal;)
--
--  The SAME facts, stored several ways — one per stage of the lesson:
--
--    players_flat   stage 0 — unnormalised. No key at all, a player's
--                             name crammed into one column, and the
--                             club's name, city and stadium typed
--                             again on every player row.
--    clubs_bad      the 1NF atomicity demo — each club's players
--                   listed inside ONE cell. Not queryable.
--    players_1nf    stage 1 — 1NF. One fact per cell (the name is now
--                             first_name + last_name) and every row
--                             has a primary key.
--    players_2nf    stage 2 — 2NF. The player's own facts only. The
--    + teams                  club facts have moved to teams, once each.
--
--  players_1nf and players_2nf hold identical information. That is the
--  point: 2NF stores each fact once, and a JOIN puts it back together.
--
--  SAFE TO RE-RUN. It drops and recreates everything, so if you break
--  something while experimenting, just run it again.
-- ============================================================


-- ------------------------------------------------------------
-- Reset (so the file can be run again and again)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS players_2nf;
DROP TABLE IF EXISTS players_1nf;
DROP TABLE IF EXISTS players_flat;
DROP TABLE IF EXISTS teams;
DROP TABLE IF EXISTS clubs_bad;


-- ============================================================
-- STAGE 0 — THE "BEFORE": one flat table
-- ============================================================
-- Two things to notice:
--
--   1. There is no PRIMARY KEY. Nothing stops the same player
--      being inserted twice.
--   2. team_name, city and stadium are stored AGAIN on every
--      player row. Four players at Real Madrid means the words
--      'Real Madrid', 'Madrid' and 'Santiago Bernabéu' are typed
--      four separate times.

CREATE TABLE players_flat (
  player_id   INT,
  player_name VARCHAR(60),
  position    VARCHAR(20),
  team_name   VARCHAR(60),
  city        VARCHAR(60),
  stadium     VARCHAR(80)
);

INSERT INTO players_flat (player_id, player_name, position, team_name, city, stadium) VALUES
  (1,  'Thibaut Courtois',   'Goalkeeper', 'Real Madrid',       'Madrid',        'Santiago Bernabéu'),
  (2,  'Éder Militão',       'Defender',   'Real Madrid',       'Madrid',        'Santiago Bernabéu'),
  (3,  'Jude Bellingham',    'Midfielder', 'Real Madrid',       'Madrid',        'Santiago Bernabéu'),
  (4,  'Vinícius Júnior',    'Forward',    'Real Madrid',       'Madrid',        'Santiago Bernabéu'),

  (5,  'Marc-André ter Stegen', 'Goalkeeper', 'FC Barcelona',   'Barcelona',     'Camp Nou'),
  (6,  'Ronald Araújo',      'Defender',   'FC Barcelona',      'Barcelona',     'Camp Nou'),
  (7,  'Pedri',              'Midfielder', 'FC Barcelona',      'Barcelona',     'Camp Nou'),
  (8,  'Anthony Gordon', 'Forward',    'FC Barcelona',      'Barcelona',     'Camp Nou'),

  (9,  'Jan Oblak',          'Goalkeeper', 'Atlético de Madrid','Madrid',        'Metropolitano'),
  (10, 'José María Giménez', 'Defender',   'Atlético de Madrid','Madrid',        'Metropolitano'),
  (11, 'Koke',               'Midfielder', 'Atlético de Madrid','Madrid',        'Metropolitano'),
  (12, 'Antoine Griezmann',  'Forward',    'Atlético de Madrid','Madrid',        'Metropolitano'),

  (13, 'Unai Simón',         'Goalkeeper', 'Athletic Club',     'Bilbao',        'San Mamés'),
  (14, 'Óscar de Marcos',    'Defender',   'Athletic Club',     'Bilbao',        'San Mamés'),
  (15, 'Oihan Sancet',       'Midfielder', 'Athletic Club',     'Bilbao',        'San Mamés'),
  (16, 'Iñaki Williams',     'Forward',    'Athletic Club',     'Bilbao',        'San Mamés'),

  (17, 'Ørjan Nyland',       'Goalkeeper', 'Sevilla FC',        'Sevilla',       'Ramón Sánchez-Pizjuán'),
  (18, 'Loïc Badé',          'Defender',   'Sevilla FC',        'Sevilla',       'Ramón Sánchez-Pizjuán'),
  (19, 'Nemanja Gudelj',     'Midfielder', 'Sevilla FC',        'Sevilla',       'Ramón Sánchez-Pizjuán'),
  (20, 'Dodi Lukébakio',     'Forward',    'Sevilla FC',        'Sevilla',       'Ramón Sánchez-Pizjuán'),

  (21, 'Álex Remiro',        'Goalkeeper', 'Real Sociedad',     'San Sebastián', 'Reale Arena'),
  (22, 'Igor Zubeldia',      'Defender',   'Real Sociedad',     'San Sebastián', 'Reale Arena'),
  (23, 'Brais Méndez',       'Midfielder', 'Real Sociedad',     'San Sebastián', 'Reale Arena'),
  (24, 'Mikel Oyarzabal',    'Forward',    'Real Sociedad',     'San Sebastián', 'Reale Arena');


-- ============================================================
-- THE 1NF ATOMICITY DEMO — clubs_bad
-- ============================================================
-- Look at the players column. Each cell holds a LIST of four
-- names, separated by commas. Four facts crammed into one box.
--
-- Six rows. Twenty-four players. But try to ask "how many
-- goalkeepers?" or "who is the oldest?" — you cannot. The facts
-- are not stored as values, they are buried inside sentences.
--
-- The 1NF fix is to give every player their own row. That is
-- exactly what players_flat already does.

CREATE TABLE clubs_bad (
  club_name VARCHAR(60),
  players   VARCHAR(300)
);

INSERT INTO clubs_bad (club_name, players) VALUES
  ('Real Madrid',        'Thibaut Courtois, Éder Militão, Jude Bellingham, Vinícius Júnior'),
  ('FC Barcelona',       'Marc-André ter Stegen, Ronald Araújo, Pedri, Anthony Gordon'),
  ('Atlético de Madrid', 'Jan Oblak, José María Giménez, Koke, Antoine Griezmann'),
  ('Athletic Club',      'Unai Simón, Óscar de Marcos, Oihan Sancet, Iñaki Williams'),
  ('Sevilla FC',         'Ørjan Nyland, Loïc Badé, Nemanja Gudelj, Dodi Lukébakio'),
  ('Real Sociedad',      'Álex Remiro, Igor Zubeldia, Brais Méndez, Mikel Oyarzabal');


-- ============================================================
-- STAGE 1 — FIRST NORMAL FORM
-- ============================================================
-- Two fixes, both from the same rule — one fact per cell:
--
--   1. player_name held two facts. Split it into first_name
--      and last_name, so you can sort by surname or search by
--      first name.
--   2. players_flat had no key. Declare player_id as PRIMARY KEY.
--
-- Note players 7 and 11: Pedri and Koke go by one name only.
-- There is no surname to store, so last_name is NULL. That is
-- allowed — NULL means "no value", and it is the honest way to
-- record it. (The class will meet NULL again in the Titanic quiz.)

CREATE TABLE players_1nf (
  player_id   INT PRIMARY KEY,
  first_name  VARCHAR(40),
  last_name   VARCHAR(40),
  position    VARCHAR(20),
  team_name   VARCHAR(60),
  city        VARCHAR(60),
  stadium     VARCHAR(80)
);

INSERT INTO players_1nf (player_id, first_name, last_name, position, team_name, city, stadium) VALUES
  (1,  'Thibaut',     'Courtois',   'Goalkeeper', 'Real Madrid',       'Madrid',        'Santiago Bernabéu'),
  (2,  'Éder',        'Militão',    'Defender',   'Real Madrid',       'Madrid',        'Santiago Bernabéu'),
  (3,  'Jude',        'Bellingham', 'Midfielder', 'Real Madrid',       'Madrid',        'Santiago Bernabéu'),
  (4,  'Vinícius',    'Júnior',     'Forward',    'Real Madrid',       'Madrid',        'Santiago Bernabéu'),

  (5,  'Marc-André',  'ter Stegen', 'Goalkeeper', 'FC Barcelona',      'Barcelona',     'Camp Nou'),
  (6,  'Ronald',      'Araújo',     'Defender',   'FC Barcelona',      'Barcelona',     'Camp Nou'),
  (7,  'Pedri',        NULL,        'Midfielder', 'FC Barcelona',      'Barcelona',     'Camp Nou'),
  (8,  'Anthony',     'Gordon',     'Forward',    'FC Barcelona',      'Barcelona',     'Camp Nou'),

  (9,  'Jan',         'Oblak',      'Goalkeeper', 'Atlético de Madrid','Madrid',        'Metropolitano'),
  (10, 'José María',  'Giménez',    'Defender',   'Atlético de Madrid','Madrid',        'Metropolitano'),
  (11, 'Koke',         NULL,        'Midfielder', 'Atlético de Madrid','Madrid',        'Metropolitano'),
  (12, 'Antoine',     'Griezmann',  'Forward',    'Atlético de Madrid','Madrid',        'Metropolitano'),

  (13, 'Unai',        'Simón',      'Goalkeeper', 'Athletic Club',     'Bilbao',        'San Mamés'),
  (14, 'Óscar',       'de Marcos',  'Defender',   'Athletic Club',     'Bilbao',        'San Mamés'),
  (15, 'Oihan',       'Sancet',     'Midfielder', 'Athletic Club',     'Bilbao',        'San Mamés'),
  (16, 'Iñaki',       'Williams',   'Forward',    'Athletic Club',     'Bilbao',        'San Mamés'),

  (17, 'Ørjan',       'Nyland',     'Goalkeeper', 'Sevilla FC',        'Sevilla',       'Ramón Sánchez-Pizjuán'),
  (18, 'Loïc',        'Badé',       'Defender',   'Sevilla FC',        'Sevilla',       'Ramón Sánchez-Pizjuán'),
  (19, 'Nemanja',     'Gudelj',     'Midfielder', 'Sevilla FC',        'Sevilla',       'Ramón Sánchez-Pizjuán'),
  (20, 'Dodi',        'Lukébakio',  'Forward',    'Sevilla FC',        'Sevilla',       'Ramón Sánchez-Pizjuán'),

  (21, 'Álex',        'Remiro',     'Goalkeeper', 'Real Sociedad',     'San Sebastián', 'Reale Arena'),
  (22, 'Igor',        'Zubeldia',   'Defender',   'Real Sociedad',     'San Sebastián', 'Reale Arena'),
  (23, 'Brais',       'Méndez',     'Midfielder', 'Real Sociedad',     'San Sebastián', 'Reale Arena'),
  (24, 'Mikel',       'Oyarzabal',  'Forward',    'Real Sociedad',     'San Sebastián', 'Reale Arena');


-- ============================================================
-- STAGE 2 — SECOND NORMAL FORM
-- ============================================================
-- Which columns describe the PLAYER, and which describe the CLUB?
--
--   player_id / first_name / last_name / position  ->  the player
--   team_name / city / stadium                     ->  the club
--
-- Those last three always move together and never on their own, so
-- they belong to a table about clubs. SELECT DISTINCT pulls out the
-- six clubs that are hiding in the 24 repeated rows.

CREATE TABLE teams (
  team_name VARCHAR(60) PRIMARY KEY,
  city      VARCHAR(60),
  stadium   VARCHAR(80)
);

INSERT INTO teams (team_name, city, stadium)
SELECT DISTINCT team_name, city, stadium
FROM players_1nf;

-- Now the player table keeps only the player's own facts, plus a
-- reference to the club row. team_name is a FOREIGN KEY: the database
-- will refuse a player whose club does not exist in teams.

CREATE TABLE players_2nf (
  player_id   INT PRIMARY KEY,
  first_name  VARCHAR(40),
  last_name   VARCHAR(40),
  position    VARCHAR(20),
  team_name   VARCHAR(60) REFERENCES teams(team_name)
);

INSERT INTO players_2nf (player_id, first_name, last_name, position, team_name)
SELECT player_id, first_name, last_name, position, team_name
FROM players_1nf;
