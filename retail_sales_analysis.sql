-- ============================================
-- Retail Sales Analysis
-- PostgreSQL
-- ============================================


-- ============================================
-- 1. CREATE SCHEMA
-- ============================================

create schema larissa;


-- ============================================
-- 2. CREATE TABLES
-- ============================================

CREATE table larissa.customers(
    customer_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    signup_date DATE NOT NULL,
    country TEXT NOT NULL
);

-- Products Table
CREATE TABLE larissa.products (
    product_id SERIAL PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT NOT NULL,
    price NUMERIC(10,2) NOT NULL
);

-- Orders Table
CREATE TABLE larissa.orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES larissa.customers(customer_id),
    order_date DATE NOT NULL,
    total_amount NUMERIC(10,2) NOT NULL
);

-- Order Details Table (Many-to-Many between Orders and Products)
CREATE TABLE larissa.order_details (
    order_id INT REFERENCES larissa.orders(order_id),
    product_id INT REFERENCES larissa.products(product_id),
    quantity INT NOT NULL,
    PRIMARY key (order_id, product_id)
);


-- ============================================
-- 3. INSERT DATA
-- ============================================

INSERT INTO larissa.customers VALUES('101', 'ALICE', '2023-01-15', 'USA');
INSERT INTO larissa.customers VALUES('102', 'BOB', '2023-02-20', 'CANADA');
INSERT INTO larissa.customers VALUES('103', 'CHARLIE', '2023-03-05', 'USA');
INSERT INTO larissa.customers VALUES('104', 'DIANA', '2023-04-10', 'CANADA');

select * from larissa.customers;

INSERT INTO larissa.products VALUES('1', 'LAPTOP', 'ELETRONICS', '1000.00');
INSERT INTO larissa.products VALUES('2', 'PHONE', 'ELETRONICS', '700.00');
INSERT INTO larissa.products VALUES('3', 'SHOES', 'FASHION', '150.00');
INSERT INTO larissa.products VALUES('4', 'T-SHIRT', 'FASHION', '50.00');

select * from larissa.products;

INSERT INTO larissa.orders VALUES('1', '101', '2023-02-01', '1000.00');
INSERT INTO larissa.orders VALUES('2', '101', '2023-06-10', '700.00');
INSERT INTO larissa.orders VALUES('3', '102', '2023-03-01', '150.00');
INSERT INTO larissa.orders VALUES('4', '103', '2023-03-10', '700.00');
INSERT INTO larissa.orders VALUES('5', '103', '2023-05-15', '50.00');
INSERT INTO larissa.orders VALUES('6', '104', '2023-04-20', '1000.00');

select * from larissa.orders;

INSERT INTO larissa.order_details VALUES('1', '1', '1');
INSERT INTO larissa.order_details VALUES('2', '2', '1');
INSERT INTO larissa.order_details VALUES('3', '3', '1');
INSERT INTO larissa.order_details VALUES('4', '2', '1');
INSERT INTO larissa.order_details VALUES('5', '4', '1');
INSERT INTO larissa.order_details VALUES('6', '1', '1');

select * from larissa.order_details;


-- ============================================
-- 4. ANALYSIS QUERIES
-- ============================================

--- Challenge 1: Top-Selling Product
--- Find the top 2 products by total sales revenue

select p.product_name, sum(p.price) + sum(o.total_amount) as TOTAL_REVENUE
from larissa.products p, larissa.orders o
where p.product_id = o.order_id
group by p.product_name
order by total_revenue DESC
limit 2;


--- Challenge 2: Repeat Customers ---
--- Find customers who have made more than one order and
--- display the number of orders they placed

select c.customer_id, name, count(o.customer_id) as order_count
from larissa.customers c
join larissa.orders o
on c.customer_id = o.customer_id
group by c.customer_id
having count(o.customer_id) > 1;


--- Challenge 3: First Purchase Per Customer
--- For each customer, find their first order date and the total amount spent in that order

select distinct on (o.customer_id)
o.customer_id, c.name, o.order_date as first_order, o.total_amount as amount_spent
from larissa.orders o
join larissa.customers c
on o.customer_id = c.customer_id
order by o.customer_id, o.order_date;


--- Challenge 4: Customer Lifetime Value (CLV)
--- Calculate each customer’s total lifetime value (total spending)

select c.name, c.customer_id, sum(total_amount) as total_spent
from larissa.customers c
join larissa.orders o
on c.customer_id = o.customer_id
group by c.name, c.customer_id
order by c.customer_id;


--- Bonus Challenge: Sales Contribution by Category
--- Calculate the percentage contribution of each product category to total sales revenue.

select * from larissa.products;
select * from larissa.orders;
select * from larissa.order_details;

-- select category, sum(p.price) as total_revenue,
-- COUNT (*) / (select count (*) from larissa.order_details) as "% TOTAL"
-- from larissa.products p
-- join larissa.order_details od
-- on p.product_id = od.product_id
-- group by category
-- order by category;

select category, sum(p.price * od.quantity) as total_revenue
from larissa.products p
join larissa.order_details od
on p.product_id = od.product_id
group by category
order by category;

select * from
larissa.ORDER_DETAILS OD,
larissa.products p
where od.product_id = p.product_id;

select sum (op.price * ox.quantity) total_sales
from larissa.order_details ox,
     larissa.products op
where ox.product_id = op.product_id;
