.open fittrackpro.db
.mode column

-- 2.1 - add a new payment
UPDATE payments
SET amount = 50.00,
    payment_date = datetime('now'),
    payment_method = 'Credit Card',
    payment_type = 'Monthly membership fee'
WHERE member_id = 11;

-- 2.2 - calculate revenue per month
SELECT strftime('%Y-%m', payment_date) AS month, 
       SUM(amount) AS total_revenue
FROM payments
WHERE payment_type = 'Monthly membership fee'
GROUP BY strftime('%Y-%m', payment_date);

-- 2.3 - all day pass purchases
SELECT payment_id, 
       amount, 
       payment_date, 
       payment_method
FROM payments 
WHERE payment_type = 'Day pass';