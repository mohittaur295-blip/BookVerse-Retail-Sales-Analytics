-- creating the database

Create Database Projectdb;
use projectdb;


-- creating the tables and importing the csv files into tables

create table books(
Book_id int primary key,
title varchar(250) not null,
author Varchar(150) not null,
genre varchar(80),
published_year year,
price decimal(10,2),
stock int);

create table customers(
customer_id int primary key,
name varchar(120),
email varchar(150) unique,
phone varchar(20),
city varchar(100),
country varchar(100));


create table orders(
order_id int primary key,
customer_id int,
Book_id int,
order_date date,
quantity int,
total_amount decimal (10,2),
foreign key(customer_id) references customers(customer_id),
foreign key(book_id) references books(book_id));

show tables;

describe books;
describe customers;
describe orders;

select * from books;
select * from customers;
select * from orders;

select count(*) as Total_Books from books;
select count(*) as Total_customers from customers;
select count(*) as Total_Orders from orders;


-- Checking duplicates 

SELECT
    Title,
    Author,
    Genre,
    Published_Year,
    COUNT(*) AS Duplicate_Count
FROM Books
GROUP BY
    Title,
    Author,
    Genre,
    Published_Year
HAVING COUNT(*) > 1;

SELECT
    Name,
    Phone,
    City,
    Country,
    COUNT(*) AS Duplicate_Count
FROM Customers
GROUP BY
    Name,
    Phone,
    City,
    Country
HAVING COUNT(*) > 1;

SELECT
    Customer_ID,
    Book_ID,
    Order_Date,
    Quantity,
    Total_Amount,
    COUNT(*) AS Duplicate_Count
FROM Orders
GROUP BY
    Customer_ID,
    Book_ID,
    Order_Date,
    Quantity,
    Total_Amount
HAVING COUNT(*) > 1;

-- missing values

SELECT * FROM Books WHERE Book_ID IS NULL OR Title IS NULL OR Author IS NULL OR Genre IS NULL OR Published_Year IS NULL OR Price IS NULL OR Stock IS NULL;

SELECT * FROM Customers WHERE Customer_ID IS NULL OR Name IS NULL OR Email IS NULL OR Phone IS NULL OR City IS NULL OR Country IS NULL;

SELECT * FROM Orders WHERE Order_ID IS NULL OR Customer_ID IS NULL OR Book_ID IS NULL OR Order_Date IS NULL OR Quantity IS NULL OR Total_Amount IS NULL;

-- checking the foreign key consistency

select o.* from orders o left join customers c on o.customer_id = c.customer_id where c.customer_id is null;

select o.* from orders o left join books b on o.book_id=b.book_id where b.book_id is null;

-- Basic analysis / Data exploration

-- Total Books
select count(*) as Total_Books from books;

-- Total customers
select count(*) as Total_Customers from customers;

-- Total Orders
select count(*) as Total_Orders from orders;

-- Different Genres
select distinct genre from books;

-- Different Countries
select distinct country from customers;

-- Total Books Sold
Select sum(quantity) as Total_Books_Solds from orders;

-- Total Revenue Generated
select sum(total_amount) as Total_Revenue from orders;

-- Average Order values
select avg(total_amount) as Average_value from orders;


-- Which books sold the most copies?
SELECT
    b.title,
    SUM(o.quantity) AS Total_Quantity
FROM books b
INNER JOIN orders o
    ON b.book_id = o.book_id
GROUP BY b.book_id, b.title
ORDER BY Total_Quantity DESC
LIMIT 10;
-- Which books generated the most revenue?
select b.title,o.total_amount as Revenue from books b left join orders o on b.book_id=o.book_id order by total_amount desc limit 10;

-- Which genres generated the most revenue?
select b.genre,sum(o.total_amount) as Revenue from books b left join orders o on b.book_id=o.book_id group by b.genre order by sum(o.total_amount) desc;

-- Which authors generated the most revenue?
select b.author,sum(o.total_amount) as Revenue from books b left join orders o on b.book_id=o.Book_id group by b.author order by sum(o.total_amount) desc limit 10;

-- What are the monthly sales trends?
SELECT
    YEAR(Order_Date) AS Year,
    MONTH(Order_Date) AS Month,
    SUM(Quantity) AS Total_Quantity_Sold,
    SUM(Total_Amount) AS Total_Revenue
FROM Orders
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date)
ORDER BY
    Year,
    Month;

-- What are the yearly sales trends?
SELECT
    YEAR(Order_Date) AS Year,
    SUM(Quantity) AS Total_Quantity_Sold,
    SUM(Total_Amount) AS Total_Revenue
FROM Orders
GROUP BY
    YEAR(Order_Date)
ORDER BY
    Year;

-- Which books have high sales volume?
select b.title,sum(o.quantity) as sale_volume from books b left join orders o on b.book_id=o.book_id group by title order by sum(o.quantity) desc limit 10;



-- Which books have high sales value?
select b.title,sum(o.total_amount) from books b left join orders o on b.book_id=o.book_id group by title order by sum(o.total_amount) desc limit 10;


-- How many orders has each customer placed?
select c.name,count(o.order_id) as Total_orders from customers c left join orders o on c.customer_id=o.customer_id group by c.name;

-- Which customers have placed multiple orders?
select c.name as Customer_with_Multiple_orders,count(o.order_id) as Order_count from customers c left join orders o on c.customer_id=o.customer_id group by c.name having Order_count>1;

-- Which customers have made the highest total purchases?
select c.name as Customer_with_highest_orders_purchase, sum(total_amount) as Total_Purchase from customers c left join orders o on c.customer_id=o.customer_id group by c.name order by Total_Purchase desc limit 5;

-- What is the average spending per customer?
select c.name,avg(o.total_amount) as Average_spendings from customers c inner join orders o on c.customer_id=o.customer_id group by c.name;

-- Which customers are repeat customers?
select c.name as Repeat_Customers,count(o.order_id) as Total_Orders from customers c left join orders o on c.customer_id=o.customer_id group by c.name having count(o.order_id)>1; 

-- Which countries have the highest number of orders?
select c.country, count(o.order_id) from customers c left join orders o on c.customer_id=o.customer_id group by c.country order by count(o.order_id)desc limit 10;

-- Which countries generate the highest revenue?
select c.country,sum(o.total_amount) as Revenue from customers c left join orders o on c.customer_id=o.customer_id group by c.country order by sum(o.total_amount) desc limit 10;

-- Which customers have purchased books from multiple genres?
SELECT
    c.Customer_ID,
    c.Name,
    COUNT(DISTINCT b.Genre) AS Different_Genres
FROM Customers c
JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
JOIN Books b
    ON o.Book_ID = b.Book_ID
GROUP BY
    c.Customer_ID,
    c.Name
HAVING COUNT(DISTINCT b.Genre) > 1
ORDER BY Different_Genres DESC;

-- How does customer purchasing behaviour change over time?
select year(order_date) as year,month(order_date) as month, count(order_id) as Orders from orders group by year,month order by year,month;

-- Which customers have the highest order frequency?
select c.name,count(o.order_id) as Order_Frequency from customers c left join orders o on c.customer_id=o.customer_id group by c.name order by count(o.order_id) desc;

-- Which books have the highest quantity sold?
select b.title, sum(o.quantity) Total_Quantity from books b inner join orders o on b.book_id=o.book_id group by b.title order by Total_Quantity desc limit 10; 

-- Which books generate the highest revenue?
select b.title, sum(o.total_amount) as Total_revenue from books b inner join orders o on b.book_id=o.book_id group by b.title order by Total_revenue desc limit 10;

-- Which genres have the highest sales volume?
select b.genre, sum(o.quantity) as Volume from books b inner join orders o on b.book_id=o.book_id group by b.genre order by Volume desc;

-- Which genres generate the highest revenue?
select b.genre, sum(total_amount) as Revenue from books b inner join orders o on b.book_id=o.book_id group by b.genre order by Revenue desc;

-- Which authors have the highest sales performance?
select b.author, sum(total_amount) as Revenue from books b inner join orders o on b.book_id=o.book_id group by b.author order by Revenue desc;

-- Which books have the highest prices?
select title,price from books order by price desc limit 10;

-- Which books have the lowest sales?
select b.title,coalesce(sum(o.quantity),0) from books b Left join orders o on b.book_id=o.book_id group by b.title order by sum(o.quantity) limit 10;

-- Which books have never been ordered?
select b.title,count(o.order_id) from books b left join orders o on b.book_id=o.book_id group by b.title having count(o.order_id)=0;

-- What is the relationship between book price and quantity sold?
select b.title, b.price, sum(o.quantity) from books b inner join orders o on b.book_id=o.book_id group by b.title,b.price order by b.price,sum(o.quantity);

-- Which books have high prices but low sales?
SELECT
    b.title,
    b.price,
    SUM(o.quantity) AS Total_Sales
FROM books b
INNER JOIN orders o
    ON b.book_id = o.book_id
GROUP BY b.book_id, b.title, b.price
HAVING
    b.price > (SELECT AVG(price) FROM books)
    AND SUM(o.quantity) < (
        SELECT AVG(Total_Sales)
        FROM (
            SELECT
                Book_ID,
                SUM(Quantity) AS Total_Sales
            FROM Orders
            GROUP BY Book_ID
        ) AS Sales
    )
ORDER BY b.price DESC;

-- Which authors contribute the most to total revenue?
select b.author, sum(o.total_amount) from books b inner join orders o on b.book_id=o.book_id group by b.author order by sum(o.total_amount) desc;

-- Which genres contribute the most to total quantity sold?
SELECT
    b.genre,
    SUM(o.quantity) AS Total_Quantity_Sold
FROM books b
INNER JOIN orders o
    ON b.book_id = o.book_id
GROUP BY b.genre
ORDER BY Total_Quantity_Sold DESC;


-- What is the current stock level of each book?
select title,stock from books;

-- Which books have low stock levels?
select title,stock from books order by stock;

-- How much stock is available in each genre?
select genre,sum(stock) from books group by genre;

-- Which genres have the highest total stock?
select genre,sum(stock) from books group by genre order by sum(stock) desc;

-- What is the inventory value of each book?
select title,price,stock,price * stock as inventory_value from books;

-- Which genres have the highest inventory value?
select genre,sum(price * stock) as inventory_value from books group by genre order by inventory_value desc;

-- Which authors have the highest inventory value?
select author,sum(price * stock) as inventory_value from books group by author order by inventory_value desc;

-- Which books have the highest-value inventory?
select title,sum(price * stock) as Inventory_value from books group by title order by inventory_value desc;

-- Which books have high stock but low sales?
SELECT
    b.Title,
    b.Stock,
    SUM(o.Quantity) AS Total_Sales
FROM Books b
LEFT JOIN Orders o
    ON b.Book_ID = o.Book_ID
GROUP BY b.Book_ID, b.Title, b.Stock
HAVING
    b.Stock > (SELECT AVG(Stock) FROM Books)
    AND SUM(o.Quantity) <
    (
        SELECT AVG(Total_Sales)
        FROM
        (
            SELECT Book_ID, SUM(Quantity) AS Total_Sales
            FROM Orders
            GROUP BY Book_ID
        ) AS sales
    )
ORDER BY b.Stock DESC;

-- Which books have low stock but high sales?
SELECT
    b.Title,
    b.Stock,
    SUM(o.Quantity) AS Total_Sales
FROM Books b
LEFT JOIN Orders o
    ON b.Book_ID = o.Book_ID
GROUP BY b.Book_ID, b.Title, b.Stock
HAVING
    b.Stock < (SELECT AVG(Stock) FROM Books)
    AND SUM(o.Quantity) >
    (
        SELECT AVG(Total_Sales)
        FROM
        (
            SELECT Book_ID, SUM(Quantity) AS Total_Sales
            FROM Orders
            GROUP BY Book_ID
        ) AS sales
    )
ORDER BY Total_Sales DESC;

-- Which books have never been ordered?
select b.title as BoOks_Never_ordered,o.order_id from books b left join orders o on b.book_id=o.book_id where o.order_id is null;

-- Which genres have high inventory but relatively low sales?
SELECT
    x.Genre,
    SUM(x.Stock) AS Total_Stock,
    SUM(x.Total_Sales) AS Total_Sales
FROM
(
    SELECT
        b.Book_ID,
        b.Genre,
        b.Stock,
        COALESCE(SUM(o.Quantity), 0) AS Total_Sales
    FROM Books b
    LEFT JOIN Orders o
        ON b.Book_ID = o.Book_ID
    GROUP BY
        b.Book_ID,
        b.Genre,
        b.Stock
) AS x
GROUP BY x.Genre
HAVING
    SUM(x.Stock) > (
        SELECT AVG(sum(Stock))
        FROM
        (
            SELECT
                Genre,
                SUM(Stock) AS Genre_Stock
            FROM Books
            GROUP BY Genre
        ) AS Stock_By_Genre
    )
    AND
    SUM(x.Total_Sales) < (
        SELECT AVG(Genre_Sales)
        FROM
        (
            SELECT
                b2.Genre,
                SUM(o2.Quantity) AS Genre_Sales
            FROM Books b2
            INNER JOIN Orders o2
                ON b2.Book_ID = o2.Book_ID
            GROUP BY b2.Genre
        ) AS Sales_By_Genre
    )
ORDER BY Total_Stock DESC;

-- who are the high-value customers?
SELECT
    c.name,
    SUM(o.total_amount) AS total_purchase
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.name
HAVING total_purchase > (
    SELECT AVG(total_purchase)
    FROM (
        SELECT
            customer_id,
            SUM(total_amount) AS total_purchase
        FROM orders
        GROUP BY customer_id
    ) AS customer_purchase
)
ORDER BY total_purchase DESC;

-- Which books/genres show strong demand?
select b.title,sum(o.quantity) from books b inner join orders o on b.book_id=o.book_id group by b.title order by sum(o.quantity) desc;

select b.genre,sum(o.quantity) from books b inner join orders o on b.book_id=o.book_id group by b.genre order by sum(o.quantity) desc;

-- Which customers purchase across multiple genres?
select c.name, count(distinct b.genre) as Genres_Purchased from customers c inner join orders o on c.customer_id = o.customer_id inner join books b on b.book_id=o.book_id group by c.name having Genres_Purchased>1 ;

-- Which books may need replenishment?
SELECT
    b.Title,
    b.Stock,
    SUM(o.Quantity) AS Total_Sales
FROM Books b
LEFT JOIN Orders o
    ON b.Book_ID = o.Book_ID
GROUP BY b.Book_ID, b.Title, b.Stock
HAVING
    b.Stock < (SELECT AVG(Stock) FROM Books)
    AND SUM(o.Quantity) >
    (
        SELECT AVG(Total_Sales)
        FROM
        (
            SELECT
                Book_ID,
                SUM(Quantity) AS Total_Sales
            FROM Orders
            GROUP BY Book_ID
        ) AS Sales
    )
ORDER BY stock;