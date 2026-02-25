.open fittrackpro.db
.mode column

-- -- 2.1 
UPDATE payments
SET amount = 50.00,
    payment_date = datetime('now'),
    payment_method = 'Credit Card',
    payment_type = 'Monthly membership fee'
WHERE member_id = 11;

-- 2.2 
SELECT strftime('%Y-%m',payment_date) AS 'month', SUM(amount) AS 'total_revenue'
FROM payments
WHERE payment_type = 'Monthly membership fee'
GROUP BY strftime('%Y-%m',payment_date);

-- 2.3 
SELECT payment_id, amount, payment_date, payment_method
FROM payments 
WHERE payment_type = 'Day pass';