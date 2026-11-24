-- =====================================================================
--  Billing demo : queries to run in VS Code AFTER making a few bills
--  Tip: keep the web page open next to VS Code. After each UPDATE or
--  DELETE, refresh "All bills" in the browser to see the change.
--  Bill numbers start at 1001. Change the ids below to match your bills.
-- =====================================================================
USE billing_demo;


-- ---------------------------------------------------------------------
-- PART 1 : See the data the web page generated
-- ---------------------------------------------------------------------
SELECT * FROM bills ORDER BY bill_id DESC;          -- one row per bill
SELECT * FROM bill_items ORDER BY item_id DESC;     -- one row per product sold
SELECT * FROM products;                             -- stock has gone down

-- How many rows did each table get?
SELECT 'bills' AS table_name, COUNT(*) AS row_count FROM bills
UNION ALL SELECT 'bill_items', COUNT(*) FROM bill_items;


-- ---------------------------------------------------------------------
-- PART 2 : Rebuild a printed receipt using a JOIN
-- ---------------------------------------------------------------------
SELECT b.bill_id, b.customer_name, b.bill_date,
       p.product_name, i.quantity, i.unit_price, i.line_total
FROM bills b
JOIN bill_items i ON i.bill_id    = b.bill_id
JOIN products   p ON p.product_id = i.product_id
WHERE b.bill_id = 1001;


-- ---------------------------------------------------------------------
-- PART 3 : UPDATE  (fix mistakes, change prices, restock)
-- ---------------------------------------------------------------------
-- 3a. Customer gave the wrong phone number
UPDATE bills SET phone = '9876543210' WHERE bill_id = 1001;

-- 3b. Customer paid by UPI, not Cash
UPDATE bills SET payment_mode = 'UPI' WHERE bill_id = 1001;

-- 3c. Price rise: all pens cost 10% more from today
UPDATE products SET price = ROUND(price * 1.10, 2) WHERE category = 'Pens';
--     Now make a NEW bill with a pen. Old bills keep the old price,
--     because bill_items stores unit_price at the time of sale.

-- 3d. New stock arrived
UPDATE products SET stock = stock + 50 WHERE product_id = 3;

-- 3e. Change the quantity on one bill line, then fix the bill total
UPDATE bill_items
SET    quantity = 3, line_total = unit_price * 3
WHERE  item_id = 1;

UPDATE bills
SET    total_amount = (SELECT SUM(line_total) FROM bill_items WHERE bill_id = 1001)
WHERE  bill_id = 1001;
--     Ask the class: what if we forget the second UPDATE?


-- ---------------------------------------------------------------------
-- PART 4 : DELETE  (cancel a bill)
-- ---------------------------------------------------------------------
-- Step 1: put the items back into stock
UPDATE products p
JOIN   bill_items i ON i.product_id = p.product_id
SET    p.stock = p.stock + i.quantity
WHERE  i.bill_id = 1002;

-- Step 2: delete the bill. ON DELETE CASCADE removes its bill_items too.
DELETE FROM bills WHERE bill_id = 1002;

SELECT * FROM bill_items WHERE bill_id = 1002;   -- returns nothing now


-- ---------------------------------------------------------------------
-- PART 5 : Change the table itself (ALTER)
-- ---------------------------------------------------------------------
ALTER TABLE bills ADD COLUMN discount DECIMAL(8,2) DEFAULT 0;

UPDATE bills SET discount = 20 WHERE total_amount >= 500;

SELECT bill_id, total_amount, discount,
       total_amount - discount AS amount_payable
FROM bills;
--     The web page still works: new bills just get discount = 0.


-- ---------------------------------------------------------------------
-- PART 6 : Reports from the generated data
-- ---------------------------------------------------------------------
-- Sales by payment mode
SELECT payment_mode, COUNT(*) AS bills, SUM(total_amount) AS sales
FROM bills
GROUP BY payment_mode
ORDER BY sales DESC;

-- Best-selling products
SELECT p.product_name, SUM(i.quantity) AS units_sold, SUM(i.line_total) AS revenue
FROM bill_items i
JOIN products p ON p.product_id = i.product_id
GROUP BY p.product_name
ORDER BY units_sold DESC;

-- Sales per day
SELECT DATE(bill_date) AS sale_day, COUNT(*) AS bills, SUM(total_amount) AS sales
FROM bills
GROUP BY DATE(bill_date)
ORDER BY sale_day;

-- Products running low (reorder list)
SELECT product_name, stock
FROM products
WHERE stock < 20
ORDER BY stock;

-- Biggest customer
SELECT customer_name, COUNT(*) AS visits, SUM(total_amount) AS spent
FROM bills
GROUP BY customer_name
ORDER BY spent DESC
LIMIT 1;


-- =====================================================================
--  Reset everything: run schema.sql again.
-- =====================================================================
