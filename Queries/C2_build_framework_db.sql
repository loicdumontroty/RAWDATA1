DROP SCHEMA IF EXISTS movie CASCADE; -- Check if Movie Schema already exists
DROP SCHEMA IF EXISTS "user" CASCADE; -- Check if User Schema already exists

CREATE SCHEMA movie; -- Create movie table
CREATE SCHEMA "user"; -- Create user table

-- Adding MOVIE Framework

CREATE TABLE movie.titleBasics (
  titleId CHAR(10) UNIQUE NOT NULL PRIMARY KEY,
  titleType VARCHAR(20),
  primaryTitle TEXT,
  originalTitle TEXT,
  isAdult BOOL,
  startYear CHAR(4),
  endYear CHAR(4),
  runtimeMinutes INT4,
  genres VARCHAR(256)
);

CREATE  TABLE movie.omdb_data (
  titleId CHAR(10) UNIQUE NOT NULL PRIMARY KEY,
  poster VARCHAR(256),
  awards TEXT,
  plot TEXT,
	FOREIGN KEY(titleId)
  REFERENCES movie.titleBasics
);

CREATE TABLE movie.titleEpisode (
  titleId CHAR(10) UNIQUE NOT NULL PRIMARY KEY,
  parentTId CHAR(10),
  seasonNumber INT4,
  episodeNumber INT4,
	FOREIGN KEY(titleId)
	REFERENCES movie.titleBasics
);

CREATE TABLE movie.titleCrew (
  titleId CHAR(10) UNIQUE NOT NULL PRIMARY KEY,
  directors TEXT,
  writers TEXT,
	FOREIGN KEY(titleId)
	REFERENCES movie.titleBasics
);

CREATE TABLE movie.nameBasics (
  nameId VARCHAR(256) UNIQUE NOT NULL PRIMARY KEY,
  primaryName VARCHAR(256),
  birthYear CHAR(4),
  deathYear CHAR(4),
  primaryProfession VARCHAR(256),
  knownForTitles TEXT
);

CREATE TABLE movie.titlePrincipals (
  titleId CHAR(10) NOT NULL,
  ordering INT4,
  nameId CHAR(10),
  category VARCHAR(50),
  job TEXT,
  characters TEXT,
	PRIMARY KEY(titleId, ordering, nameId),
	FOREIGN KEY(titleId)
	REFERENCES movie.titleBasics(titleId),
	FOREIGN KEY(nameId)
	REFERENCES movie.nameBasics
);

CREATE TABLE movie.wi (
  titleId CHAR(10) NOT NULL,
  word TEXT,
  field CHAR(1),
  lexeme TEXT,
	PRIMARY KEY(titleId, word, field),
	FOREIGN KEY(titleId)
	REFERENCES movie.titleBasics
);

CREATE TABLE movie.titleAkas (
  titleId CHAR(10) NOT NULL,
  ordering INT4,
  title TEXT,
  region VARCHAR(10),
  language VARCHAR(10),
  types VARCHAR(256),
  attributes VARCHAR(256),
  isOriginalTitle BOOL,
	PRIMARY KEY(titleId, ordering),
	FOREIGN KEY(titleId)
	REFERENCES movie.titleBasics
);

CREATE TABLE movie.titleRatings (
  titleId CHAR(10) UNIQUE NOT NULL PRIMARY KEY,
  averageRating numeric(5,1),
  numvotes INT4,
	FOREIGN KEY(titleId)
	REFERENCES movie.titleBasics
);

INSERT INTO movie.titleBasics(titleId, titleType, primaryTitle, originalTitle, isAdult, startYear, endYear, runtimeMinutes, genres)
SELECT tconst, titletype, primarytitle, originaltitle, isadult, startyear, endyear, runtimeminutes, genres
FROM title_basics;

INSERT INTO movie.titleAkas(titleId, ordering, title, region, language, types, attributes, isOriginalTitle)
SELECT titleid, ordering, title, region, language, types, attributes, isoriginaltitle
FROM title_akas;

INSERT INTO movie.titleCrew(titleId, directors, writers)
SELECT tconst, directors, writers
FROM title_crew;

INSERT INTO movie.titleRatings(titleId, averageRating, numvotes)
SELECT tconst, averagerating, numvotes
FROM title_ratings;

INSERT INTO movie.titleEpisode(titleId, parentTId, seasonNumber, episodeNumber)
SELECT tconst, parenttconst, seasonnumber, episodenumber
FROM title_episode;

INSERT INTO movie.wi(titleId, word, field, lexeme)
SELECT tconst, word, field, lexeme
FROM wi;

INSERT INTO movie.nameBasics(nameId, primaryName, birthYear, deathYear, primaryProfession, knownForTitles)
SELECT nconst, primaryname, birthyear, deathyear, primaryprofession, knownfortitles
FROM name_basics;

INSERT INTO movie.titlePrincipals(titleId, ordering, nameId, category, job, characters)
SELECT t.tconst, t.ordering, t.nconst, t.category, t.job, t.characters
FROM title_principals t, name_basics n
WHERE t.nconst=n.nconst;

INSERT INTO movie.omdb_data(titleId, poster, awards, plot)
SELECT o.tconst, o.poster, o.awards, o.plot
FROM omdb_data o, title_basics t
WHERE o.tconst = t.tconst;

-- Adding User Framework

CREATE TABLE "user".user (
  username varchar(256) UNIQUE NOT NULL PRIMARY KEY,
  password varchar(256) NOT NULL,
  salt varchar(256) NOT NULL,
  isAdmin bool,
  isAdult bool
);

CREATE TABLE "user".nameBookmark
(
  username varchar(256) NOT NULL,
  nameId char(10),
  PRIMARY KEY(username, nameId),
  CONSTRAINT FK_username FOREIGN KEY (username) REFERENCES "user".user(username), 
  CONSTRAINT FK_nameId FOREIGN KEY (nameId) REFERENCES Movie.namebasics(nameId)
);

CREATE TABLE "user".titleBookmark (
  username varchar(256) NOT NULL,
  titleId char(10),
  PRIMARY KEY(username, titleId),
  CONSTRAINT FK_username FOREIGN KEY (username) REFERENCES "user".user(username),
  CONSTRAINT FK_titleId FOREIGN KEY (titleId) REFERENCES Movie.titlebasics(titleId)
);

CREATE TABLE "user".searchHistory (
  username varchar(256) NOT NULL,
  searchKey Text,
  PRIMARY KEY(username, searchKey),
  CONSTRAINT FK_username FOREIGN KEY (username) REFERENCES "user".user(username)
);

CREATE TABLE "user".ratings (
  username varchar(256) NOT NULL,
  titleId char(10),
  rate int4,
  comment text,
  PRIMARY KEY(username, titleId),
  CONSTRAINT FK_username FOREIGN KEY (username) REFERENCES "user".user(username),
  CONSTRAINT FK_titleId FOREIGN KEY (titleId) REFERENCES Movie.titlebasics(titleId)
);