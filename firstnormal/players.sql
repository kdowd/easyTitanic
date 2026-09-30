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
-- DROP TABLE IF EXISTS players;
-- DROP TABLE IF EXISTS teams;


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