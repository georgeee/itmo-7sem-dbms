CREATE TABLE abc (
  id serial primary key,
  name varchar(30) default null
);

INSERT INTO abc (name) VALUES ('фёдор'), ('иван');

SELECT * FROM abc
