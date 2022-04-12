DROP DATABASE bookstore;
CREATE DATABASE bookstore;
USE bookstore;
CREATE TABLE BOOK(book_id INT AUTO_INCREMENT, title VARCHAR(255), published_year INT, author_id INT, PRIMARY KEY (book_id));
CREATE TABLE AUTHOR(author_id INT AUTO_INCREMENT, name  VARCHAR(255), country VARCHAR(255), language VARCHAR(255), PRIMARY KEY (author_id));

INSERT INTO AUTHOR(name, country, language) VALUES("Jane Austen", "United Kingdom", "English");
INSERT INTO AUTHOR(name, country, language) VALUES("Leo Tolstoy", "Russia", "Russian");


INSERT INTO BOOK(title, published_year, author_id) SELECT "Pride and Prejudice", 1813, author_id FROM AUTHOR where name = "Jane Austen";
INSERT INTO BOOK(title, published_year, author_id) SELECT "Sense and Sensibility", 1811, author_id FROM AUTHOR where name = "Jane Austen";
INSERT INTO BOOK(title, published_year, author_id) SELECT "Emma", 1815, author_id FROM AUTHOR where name = "Jane Austen";

INSERT INTO BOOK(title, published_year, author_id) SELECT "War and Peace", 1867, author_id FROM AUTHOR where name = "Leo Tolstoy";
INSERT INTO BOOK(title, published_year, author_id) SELECT "Anna Karenina", 1878, author_id FROM AUTHOR where name = "Leo Tolstoy";
