CREATE DATABASE BookwormHaven;
USE BookwormHaven;
SET SQL_SAFE_UPDATES = 0;

-- Create author table - in a separate table for normalisation and to reduce redundancy.
CREATE TABLE authors(
-- Author_id is automatically assigned as 1,2,3 etc. for convenience
author_id int AUTO_INCREMENT PRIMARY KEY ,
author_name varchar(100) NOT NULL
);
-- Inserting values into author table
INSERT INTO authors(author_name) VALUES
    ('Jill Tomlinson'),
    ('Michael Bond '),
    ('Arthur C. Clarke'),
    ('Madame Romaine De Lyon'),
    ('Chris Scarre'),
    ('Phil Green'),
    ('Agatha Christie'),
    ('Sarah J. Maas'),
    ('Eric Carle');
select * from authors;

-- Create books table
CREATE TABLE books(
-- Automatically generated book_id
book_id int AUTO_INCREMENT PRIMARY KEY,
title  varchar(300) NOT NULL,
-- Foreign key referring to author table
author_id int NOT NULL,
Foreign key (author_id) REFERENCES authors(author_id),
genre varchar(100),
publication_year int,
price decimal(6,2) NOT NULL,
-- Extra: average review, stock and sale 
average_review decimal(3,2),
stock int NOT NULL,
sale int
);

-- Insert values into books table
INSERT INTO books (title, author_id, genre, publication_year, price,stock) VALUES
	  ('The Owl Who Was Afraid of the Dark', 1, 'Children', 2014, 6.99,5),
    ('Paddington at the Palace', 2, 'Children', 2019, 7.99,4),
    ('2001: Space Odyssey', 3, 'Science Fiction', 2018, 9.99,10),
    ('The Art of Cooking Omelettes', 4, 'Cooking', 2013, 12.95,1),
    ('The Penguin Historical Atlas of Ancient Rome', 5, 'History', 1995, 14.99,10),
    ('Vegetable Gardening for Beginners: A simple easy-to-follow guide to grow bountiful, organic and sustainable produce in your backyard. Vertical gardening and companion planting secrets included', 6, 'Home and Garden', 2020, 27.95,19),
    ('Dumb Witness - Poirot', 7, 'Mystery', 2015, 9.99,6),
    ('A Court of Thorns and Roses', 8, 'Fantasy', 2020, 8.99,7),
    ('And Then There Were None', 7, 'Mystery', 2015, 8.99,5),
    ('The Very Hungry Caterpillar', 9, 'Children', 1994, 7.99,4);
select * from books;
-- Create customers table
CREATE TABLE customers(
customer_id int AUTO_INCREMENT PRIMARY KEY,
-- Names entered as first and last name separately as this is more flexible and allows for easier manipulation e.g. the bookstore is able to, for example, send email addressed to Dear "first name" which is more personable 
first_name varchar(50) NOT NULL,
last_name varchar(50) NOT NULL,
-- The full name is specified as a requirement and so is added as a column here and is automatically filled. 
full_name varchar(50),
email varchar(100) NOT NULL,
phone_number varchar(50),
is_chapter_chaser boolean NOT NULL,
points decimal(6,1), 
shipping_address varchar(100) NOT NULL
);

-- Insert data into customers table
INSERT INTO customers (first_name, last_name, email, phone_number, is_chapter_chaser,shipping_address)
VALUES
    ('John',' Smith', 'john.smith@example.com', '+44 20 1234 5678', true, '123 Oxford Street, London, UK'),
    ('Emily',' Johnson', 'emily.johnson@example.com', '+44 20 2345 6789', false, '456 Park Lane, Manchester, UK'),
    ('Daniel',' Brown', 'daniel.brown@example.com', '+44 20 3456 7890', true, '789 High Street, Edinburgh, UK'),
    ('Sophia',' Davis', 'sophia.davis@example.com', '+44 20 4567 8901', false, '101 King Street, Birmingham, UK'),
    ('Michael',' Wilson', 'michael.wilson@example.com', '+44 20 5678 9012', true, '222 Victoria Road, Glasgow, UK'),
    ('Olivia',' Taylor', 'olivia.taylor@example.com', '+44 20 6789 0123', false, '333 Queen Street, Liverpool, UK'),
    ('James',' Johnson', 'james.johnson@example.com', '+44 20 7890 1234', true, '444 George Street, Bristol, UK'),
    ('Ava',' Martinez', 'ava.martinez@example.com', '+44 20 8901 2345', false, '555 Highfield Avenue, Leeds, UK'),
    ('William',' Harris', 'william.harris@example.com', '+44 20 9012 3456', true, '666 Elmwood Road, Newcastle, UK'),
    ('Sophie',' Brown', 'sophie.brown@example.com', '+44 20 0123 4567', false, '777 Grove Street, Sheffield, UK');
select * from customers;
-- Full name automatically added
UPDATE customers
set full_name = CONCAT(first_name,'',last_name);

-- Chapter chasers start with a defualt 10 points
UPDATE customers
set points = 10

where is_chapter_chaser;
select * from customers;
-- Orders are managed using two tables to handle customers purchasing multiple books in one setting

-- Create the total orders table which gives an overview of the customer's order including the total price
create table total_orders(
total_order_id int AUTO_INCREMENT PRIMARY KEY,
customer_id int NOT NULL,
Foreign key (customer_id) REFERENCES customers(customer_id),
order_date date,
total_price decimal(10,2)
);

-- Create the order items table which has the individual books purchased
create table order_items(
order_items_id int AUTO_INCREMENT PRIMARY KEY,
total_order_id int NOT NULL,
Foreign key (total_order_id) REFERENCES total_orders(total_order_id),
book_id int NOT NULL,
Foreign key (book_id) REFERENCES books(book_id),
-- Extra: quantity and review
quantity int NOT NULL,
review int
);

-- Insert a new order for John Smith
INSERT INTO total_orders (customer_id, order_date)
VALUES (1, CURRENT_DATE());

-- Create a variable called "current_id" which stores the total_order_id just created for extra convenience (no need to keep track of total_order_ids)
SET @current_id = LAST_INSERT_ID();

-- Insert details about each individual book ordered to order items
INSERT INTO order_items (total_order_id, book_id, quantity)
-- Least function used to ensure customer order does not exceed available stock
VALUES
    (@current_id, 1, LEAST((SELECT stock FROM Books WHERE book_id = 1), 1)),
    (@current_id, 3, LEAST((SELECT stock FROM Books WHERE book_id = 3), 1));


-- Inserts a few more orders
INSERT INTO total_orders (customer_id, order_date)
VALUES (3, '2023-08-19');
SET @current_id = LAST_INSERT_ID();
INSERT INTO order_items (total_order_id, book_id, quantity)
VALUES
    (@current_id, 4, LEAST((SELECT stock FROM Books WHERE book_id = 4), 2)),
    (@current_id, 1, LEAST((SELECT stock FROM Books WHERE book_id = 1), 1));

INSERT INTO total_orders (customer_id, order_date)
VALUES (5, '2023-08-20');
SET @current_id = LAST_INSERT_ID();
INSERT INTO order_items (total_order_id, book_id, quantity)
VALUES
    (@current_id, 7, LEAST((SELECT stock FROM Books WHERE book_id = 7), 1)),
    (@current_id, 5, LEAST((SELECT stock FROM Books WHERE book_id = 5), 1));

  
INSERT INTO total_orders (customer_id, order_date)
VALUES (8, '2023-07-19');
SET @current_id = LAST_INSERT_ID();
INSERT INTO order_items (total_order_id, book_id, quantity)
VALUES
    (@current_id, 10, LEAST((SELECT stock FROM Books WHERE book_id = 10), 2)),
    (@current_id, 3, LEAST((SELECT stock FROM Books WHERE book_id = 3), 1));

INSERT INTO total_orders (customer_id, order_date)
VALUES (6, '2023-07-09');
SET @current_id = LAST_INSERT_ID();
INSERT INTO order_items (total_order_id, book_id, quantity)
VALUES
    (@current_id, 2, LEAST((SELECT stock FROM Books WHERE book_id = 2), 2)),
    (@current_id, 9, LEAST((SELECT stock FROM Books WHERE book_id = 9), 1));

-- Automatically calculate the total price for each order
UPDATE total_orders AS t_o
SET total_price= (
    SELECT SUM(b.price * oi.quantity)
    FROM order_items AS oi
    INNER JOIN books AS b ON oi.book_id = b.book_id
    WHERE oi.total_order_id = t_o.total_order_id
);

-- Show details about orders
SELECT 
oi.total_order_id, c.full_name, b.title, oi.quantity, t_o.total_price
FROM books AS b
INNER JOIN
order_items AS oi
ON b.book_id = oi.book_id
INNER JOIN total_orders AS t_o
ON oi.total_order_id = t_o.total_order_id
INNER JOIN customers AS c
ON c.customer_id = t_o.customer_id
ORDER BY oi.total_order_id ASC;

-- Automatically decrease stock 
UPDATE books AS b
-- COALESCE function used to avoid null values as stock cannot be null. If a book has not been purchased, then zero is minused. 
SET b.stock = b.stock -COALESCE ((
SELECT SUM(oi.quantity)
FROM order_items AS oi
WHERE oi.book_id = b.book_id),0);

-- Chapter chasers automatically get 10% of their spending as points
UPDATE customers AS c
SET c.points = c.points + 0.1*COALESCE ((
SELECT t_o.total_price
FROM total_orders AS t_o
WHERE  t_o.customer_id = c.customer_id AND c.is_chapter_chaser=TRUE),0);

select * from customers;
-- Update order_items as customers add some reviews
update order_items
set review = 4
where order_items_id = 1;
update order_items
set review = 3
where order_items_id = 2;
update order_items
set review = 5
where order_items_id = 3;
update order_items
set review = 5
where order_items_id = 4;
update order_items
set review = 4
where order_items_id = 8;

-- Calculate an average review for each book
UPDATE books AS b
SET b.average_review = (
SELECT AVG(oi.review)
FROM order_items AS oi
WHERE oi.book_id = b.book_id AND oi.review IS NOT NULL);

select * from books;
-- Show books ordered by popularity in a certain month 
SELECT b.book_id, b.title, SUM(oi.quantity) AS total_sold
FROM books AS b
INNER JOIN order_items AS oi ON b.book_id = oi.book_id
INNER JOIN total_orders AS t_o ON oi.total_order_id = t_o.total_order_id
WHERE YEAR(t_o.order_date) = 2023 AND MONTH(t_o.order_date) = 8 
GROUP BY b.book_id, b.title
ORDER BY total_sold DESC;

-- Show revenue
SELECT SUM(total_price) AS revenue 
FROM total_orders;

-- Show the books with minimum stock available - to see which books may need restocking
SELECT * FROM books
WHERE stock = (
SELECT MIN(stock)
FROM books);

-- Count the number of books in each genre
SELECT genre, COUNT(*) AS books_per_genre
FROM Books
GROUP BY genre;

-- Have a 25% sale on the most sold book(s)
UPDATE books AS b
INNER JOIN (
    SELECT oi.book_id, SUM(oi.quantity) AS total_sold
    FROM order_items oi
    GROUP BY oi.book_id
-- Using having (instead of ordering by descending and limiting to one row) in case multiple books are best sellers
    HAVING total_sold = (
        SELECT MAX(total_sold)
        FROM (
            SELECT SUM(oi.quantity) AS total_sold
            FROM order_items AS oi
            GROUP BY book_id
        ) AS book_totals
    )
) AS bestsellers ON b.book_id = bestsellers.book_id
SET b.sale = 25;


-- Apply any sales to book price
UPDATE books 
SET price = (1- (sale/100)) * price
WHERE sale > 0;

select * from books as books_after_sale;
-- Book Haven has a new offer for the top 3 customers with the most purchased books! Either doubling of their points if they are chapter chasers or giving them a free chapater chaser status if they are not
UPDATE customers as c
INNER JOIN(
SELECT c.customer_id, SUM(oi.quantity) AS purchased_books
FROM customers AS c
LEFT JOIN total_orders AS t_o ON c.customer_id = t_o.customer_id
LEFT JOIN order_items AS oi ON t_o.total_order_id = oi.total_order_id
GROUP BY c.customer_id
ORDER BY purchased_books DESC
LIMIT 3)
AS top_customers on c.customer_id = top_customers.customer_id
SET
c.points = CASE
-- Double points for chapter chasers
WHEN c.is_chapter_chaser THEN c.points *2 
-- 10 points for non chapter chasers (default)
ELSE 10 
END,
-- Make all top 3 customers chapter chasers
c.is_chapter_chaser = TRUE; 
select full_name, points, is_chapter_chaser from customers;



