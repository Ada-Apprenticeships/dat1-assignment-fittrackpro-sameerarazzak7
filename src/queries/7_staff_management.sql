.open fittrackpro.db
.mode column

-- 7.1 
SELECT staff_id, first_name, last_name, position AS 'role'
FROM staff;

-- 7.2 
SELECT s.staff_id AS 'trainer_id',
       (s.first_name || ' ' || s.last_name) AS 'trainer_name',
       COUNT(*) AS 'session_count'
FROM staff AS s
JOIN personal_training_sessions AS p
    ON s.staff_id = p.staff_id
WHERE p.session_date > '2025-01-20' AND p.session_date < '2025-02-19'
GROUP BY s.staff_id;
