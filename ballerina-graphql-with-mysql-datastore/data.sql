CREATE DATABASE bookstore;
USE bookstore;
CREATE TABLE BOOK(book_id INT AUTO_INCREMENT, title VARCHAR(255), published_year INT, isbn VARCHAR(255), author_id INT, PRIMARY KEY (book_id));
CREATE TABLE AUTHOR(author_id INT AUTO_INCREMENT, name  VARCHAR(255), country VARCHAR(255), PRIMARY KEY (author_id));

INSERT INTO AUTHOR(name, country) VALUES("Jane Austen", "United Kingdom");
INSERT INTO AUTHOR(name, country) VALUES("Leo Tolstoy", "Russia");

INSERT INTO BOOK(title, published_year, isbn, author_id) 
SELECT "Pride and Prejudice", 1813, "9780679405429", author_id FROM AUTHOR where name = "Jane Austen";
INSERT INTO BOOK(title, published_year, isbn, author_id) 
SELECT "Sense and Sensibility", 1811, "9780486290492", author_id FROM AUTHOR where name = "Jane Austen";
INSERT INTO BOOK(title, published_year, isbn, author_id) 
SELECT "Emma", 1815, "8811582288", author_id FROM AUTHOR where name = "Jane Austen";
INSERT INTO BOOK(title, published_year, isbn, author_id) 
SELECT "War and Peace", 1867, "9780099512240", author_id FROM AUTHOR where name = "Leo Tolstoy";
INSERT INTO BOOK(title, published_year, isbn, author_id) 
SELECT "Anna Karenina", 1878, "9781101042472", author_id FROM AUTHOR where name = "Leo Tolstoy";
