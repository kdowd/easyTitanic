-- ============================================================
--  laliga.sql  —  teaching data for "Why JOINs exist"
-- ============================================================
--  Load with:
--      psql -U postgres -d laliga -f laliga.sql
--  (first:  CREATE DATABASE laliga;)
--
--  This file creates BOTH states of the lesson side by side:
--
--    players_flat        one big table, team details repeated on every row
--    teams + players     the same facts split into two tables
--
--  The two states hold identical information. That is the point:
--  the split version stores each fact once, and a JOIN puts it
--  back together when you need it.
--
--  SAFE TO RE-RUN. It drops and recreates everything, so if you
--  break something while experimenting, just run it again.
-- ============================================================


-- ------------------------------------------------------------
-- Reset (so the file can be run again and again)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS players_flat;
DROP TABLE IF EXISTS players;
DROP TABLE IF EXISTS teams;


-- ============================================================
-- PART 1 — THE "BEFORE": one flat table
-- ============================================================
-- Notice that team_name, city and stadium are stored AGAIN on
-- every player row. Four players at Real Madrid means the words
-- 'Real Madrid', 'Madrid' and 'Santiago Bernabéu' are typed four
-- separate times.

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
-- PART 2 — THE "AFTER": the same facts in two tables
-- ============================================================
-- Each club is stored exactly ONCE. The players table no longer
-- repeats the club name, the city or the stadium. Instead each
-- player carries a team_id — a pointer to their row in teams.
--
--          teams.team_id  <---->  players.team_id
--
-- That matching pair of columns is the "join key". It is the
-- whole trick.

CREATE TABLE teams (
  team_id   INT PRIMARY KEY,
  team_name VARCHAR(60),
  city      VARCHAR(60),
  stadium   VARCHAR(80)
);

INSERT INTO teams (team_id, team_name, city, stadium) VALUES
  (1, 'Real Madrid',        'Madrid',        'Santiago Bernabéu'),
  (2, 'FC Barcelona',       'Barcelona',     'Camp Nou'),
  (3, 'Atlético de Madrid', 'Madrid',        'Metropolitano'),
  (4, 'Athletic Club',      'Bilbao',        'San Mamés'),
  (5, 'Sevilla FC',         'Sevilla',       'Ramón Sánchez-Pizjuán'),
  (6, 'Real Sociedad',      'San Sebastián', 'Reale Arena');

CREATE TABLE players (
  player_id   INT PRIMARY KEY,
  player_name VARCHAR(60),
  position    VARCHAR(20),
  team_id     INT REFERENCES teams(team_id)
);

INSERT INTO players (player_id, player_name, position, team_id) VALUES
  (1,  'Thibaut Courtois',      'Goalkeeper', 1),
  (2,  'Éder Militão',          'Defender',   1),
  (3,  'Jude Bellingham',       'Midfielder', 1),
  (4,  'Vinícius Júnior',       'Forward',    1),

  (5,  'Marc-André ter Stegen', 'Goalkeeper', 2),
  (6,  'Ronald Araújo',         'Defender',   2),
  (7,  'Pedri',                 'Midfielder', 2),
  (8,  'Robert Lewandowski',    'Forward',    2),

  (9,  'Jan Oblak',             'Goalkeeper', 3),
  (10, 'José María Giménez',    'Defender',   3),
  (11, 'Koke',                  'Midfielder', 3),
  (12, 'Antoine Griezmann',     'Forward',    3),

  (13, 'Unai Simón',            'Goalkeeper', 4),
  (14, 'Óscar de Marcos',       'Defender',   4),
  (15, 'Oihan Sancet',          'Midfielder', 4),
  (16, 'Iñaki Williams',        'Forward',    4),

  (17, 'Ørjan Nyland',          'Goalkeeper', 5),
  (18, 'Loïc Badé',             'Defender',   5),
  (19, 'Nemanja Gudelj',        'Midfielder', 5),
  (20, 'Dodi Lukébakio',        'Forward',    5),

  (21, 'Álex Remiro',           'Goalkeeper', 6),
  (22, 'Igor Zubeldia',         'Defender',   6),
  (23, 'Brais Méndez',          'Midfielder', 6),
  (24, 'Mikel Oyarzabal',       'Forward',    6);


-- ============================================================
-- Quick check that both states agree
-- ============================================================
-- Both of these should print 24:
--   SELECT COUNT(*) FROM players_flat;
--   SELECT COUNT(*) FROM players;
-- And this should print 6:
--   SELECT COUNT(*) FROM teams;
