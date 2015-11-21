DROP DATABASE brussels_sprouts_recipes
createdb brussels_sprouts_recipes;
psql brussels_sprouts_recipes < shema.sql
CREATE TABLE recipes (id SERIAL PRIMARY KEY, title varchar(100));
CREATE TABLE comments (id SERIAL PRIMARY KEY, text varchar(255));
