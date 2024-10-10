CREATE TABLE authors (
    id bigserial NOT NULL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE books (
    id bigserial NOT NULL PRIMARY KEY,
    title TEXT,
    release_date DATE NOT NULL,
    price DOUBLE PRECISION DEFAULT 0 NOT NULL,
    author_id BIGINT REFERENCES authors
);

INSERT INTO authors (name) VALUES
('J.K. Rowling'),    -- 1
('George R.R. Martin'),  -- 2
('J.R.R. Tolkien'),  -- 3
('Agatha Christie'), -- 4
('Haruki Murakami'), -- 5
('Stephen King'),    -- 6
('Jane Austen'),     -- 7
('Isaac Asimov'),    -- 8
('Margaret Atwood'), -- 9
('Mark Twain');      -- 10

INSERT INTO books (title, release_date, price, author_id) VALUES
('Harry Potter and the Philosophers Stone', '1997-06-26', 39.99, 1),
('Harry Potter and the Chamber of Secrets', '1998-07-02', 34.99, 1),
('Harry Potter and the Prisoner of Azkaban', '1999-07-08', 40.99, 1),
('A Game of Thrones', '1996-08-06', 45.00, 2),
('A Clash of Kings', '1998-11-16', 47.99, 2),
('A Storm of Swords', '2000-08-08', 42.99, 2),
('The Hobbit', '1937-09-21', 30.50, 3),
('The Fellowship of the Ring', '1954-07-29', 35.00, 3),
('The Two Towers', '1954-11-11', 36.99, 3),
('The Return of the King', '1955-10-20', 39.50, 3),
('Murder on the Orient Express', '1934-01-01', 25.00, 4),
('The ABC Murders', '1936-01-06', 28.50, 4),
('And Then There Were None', '1939-11-06', 29.99, 4),
('Kafka on the Shore', '2002-09-12', 32.00, 5),
('Norwegian Wood', '1987-09-04', 31.00, 5),
('1Q84', '2009-05-29', 48.99, 5),
('The Shining', '1977-01-28', 29.99, 6),
('It', '1986-09-15', 35.99, 6),
('Pride and Prejudice', '1813-01-28', 24.99, 7),
('Sense and Sensibility', '1811-10-30', 23.50, 7),
('Foundation', '1951-06-01', 31.50, 8),
('I, Robot', '1950-12-02', 27.99, 8),
('The Handmaids Tale', '1985-08-17', 28.99, 9),
('Oryx and Crake', '2003-05-01', 34.00, 9),
('Adventures of Huckleberry Finn', '1884-12-10', 22.00, 10),
('The Adventures of Tom Sawyer', '1876-06-25', 20.50, 10);


CREATE OR REPLACE FUNCTION hello_username_timestamp()
RETURNS varchar
LANGUAGE plpgsql AS
$$
BEGIN
    RETURN CONCAT('hello ', current_user, ', ' , current_timestamp);
END;
$$;


SELECT hello_username_timestamp();


drop function sp_product;
CREATE or replace function sp_product(x double precision, y double precision,
    OUT sum1 double precision,
    OUT mul double precision,
	OUT diff double precision,
	OUT div double precision)
language plpgsql AS
    $$
        BEGIN
			sum1 = x + y;
            mul = x * y;
			IF x > y THEN
        		diff = x - y;
    		ELSE
        		diff = y - x;
    		END IF;
            div = x / y;
        end;
    $$;

select sp_product(5, 10);



drop function sp_product;
CREATE or replace function sp_product(x INTEGER, y INTEGER,
    OUT smaller INTEGER)
language plpgsql AS
    $$
        BEGIN
			IF x > y THEN
        		smaller = y;
    		ELSIF y > x THEN
        		smaller = x;
			ELSE
				smaller = NULL;
    		END IF;
        end;
    $$;

select sp_product(15, 10);


drop function sp_product;
CREATE or replace function sp_product(x INTEGER, y INTEGER, z INTEGER,
    OUT smallest INTEGER)
language plpgsql AS
    $$
        BEGIN
			IF x > y AND z > y THEN
        		smallest = y;
    		ELSIF y > x AND z > x THEN
        		smallest = x;
			ELSE
				smallest = z;
    		END IF;
        end;
    $$;

select sp_product(15, 40, 20);


DROP FUNCTION IF EXISTS random_between;
CREATE OR REPLACE FUNCTION random_between(
    min_val INTEGER,
    max_val INTEGER
)
RETURNS INTEGER
LANGUAGE plpgsql AS
$$
BEGIN
    RETURN FLOOR(RANDOM() * (max_val - min_val + 1)) + min_val;
END;
$$;

SELECT random_between(1, 10);


DROP FUNCTION IF EXISTS books_stats;
CREATE OR REPLACE FUNCTION books_stats(
	OUT min_price double precision,
	OUT max_price double precision,
	OUT avg_price double precision,
	OUT amount_of_books INTEGER)
LANGUAGE plpgsql AS
$$
BEGIN
	SELECT MIN(b.price) INTO min_price FROM books b;
	SELECT MAX(b.price) INTO max_price FROM books b;
	SELECT AVG(b.price)::numeric(10, 2) INTO avg_price FROM books b;
	SELECT COUNT(b.title) INTO amount_of_books FROM books b;
END;
$$;

SELECT 
    min_price, 
    max_price, 
    avg_price, 
    amount_of_books 
FROM books_stats();


DROP FUNCTION IF EXISTS most_written;
CREATE OR REPLACE FUNCTION most_written(
	OUT author_name varchar,
	OUT amount_of_books_written INTEGER)
LANGUAGE plpgsql AS
$$
BEGIN
	SELECT a.name, COUNT(b.id) INTO author_name, amount_of_books_written
	FROM authors a 
	JOIN books b ON b.author_id = a.id 
	GROUP BY a.name 
	ORDER BY amount_of_books_written DESC 
	LIMIT 1;
END;
$$;

SELECT * FROM most_written();


DROP FUNCTION IF EXISTS cheapest_book;
CREATE OR REPLACE FUNCTION cheapest_book(
	OUT cheapest_book varchar)
LANGUAGE plpgsql AS
$$
BEGIN
	SELECT b.title INTO cheapest_book FROM books b WHERE (b.price) = (SELECT MIN(b.price) FROM books b);
END;
$$;

SELECT * FROM cheapest_book();


DROP FUNCTION IF EXISTS avg_lines;
CREATE OR REPLACE FUNCTION avg_lines(
	OUT avg_lines double precision)
LANGUAGE plpgsql AS
$$
BEGIN
	SELECT ((SELECT COUNT(*) FROM books) + (SELECT COUNT(*) FROM authors)) / 2 INTO avg_lines;
END;
$$;

SELECT * FROM avg_lines();



DROP FUNCTION IF EXISTS id_return_title;
CREATE OR REPLACE FUNCTION id_return_title(
	OUT id_return INTEGER)
LANGUAGE plpgsql AS
$$
BEGIN
	INSERT INTO books (title, release_date, price, author_id) VALUES ('Rich Dad Poor Dad', '2000-04-01', 39, 4);
	SELECT b.id INTO id_return FROM books b WHERE b.title = 'Rich Dad Poor Dad';
END;
$$;

SELECT * FROM id_return_title();
SELECT * FROM books;

DROP FUNCTION IF EXISTS id_return_author;
CREATE OR REPLACE FUNCTION id_return_title(
	OUT id_return INTEGER)
LANGUAGE plpgsql AS
$$
BEGIN
	INSERT INTO books (title, release_date, price, author_id) VALUES ('Rich Dad Poor Dad', '2000-04-01', 39, 4);
	SELECT b.id INTO id_return FROM books b WHERE b.title = 'Rich Dad Poor Dad';
END;
$$;

SELECT * FROM id_return_title();
SELECT * FROM books;