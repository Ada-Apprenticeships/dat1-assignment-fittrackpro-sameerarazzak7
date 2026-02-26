.open fittrackpro.db
.mode column

-- 6.1 
INSERT INTO attendance (attendance_id, member_id, location_id, check_in_time)
VALUES (4, 7, 1, '2025-02-14 16:30:00');

-- 6.2 
-- SELECT date(check_in_time) AS 'visit_date', 
--        time(check_in_time) AS 'check_in_time', 
--        time(check_out_time) AS 'check_out_time'
-- FROM attendance
-- WHERE member_id = 5;

-- 6.3 
SELECT CASE strftime('%w', check_in_time)
        WHEN '0' THEN 'Sunday'
        WHEN '1' THEN 'Monday'
        WHEN '2' THEN 'Tuesday'
        WHEN '3' THEN 'Wednesday'
        WHEN '4' THEN 'Thursday'
        WHEN '5' THEN 'Friday'
        WHEN '6' THEN 'Saturday'
    END  AS 'day_of_week',
    COUNT(*) AS 'visit_count'
FROM attendance
GROUP BY strftime('%w', check_in_time)
ORDER BY strftime('%w', check_in_time) DESC
LIMIT 1;

-- 6.4 
SELECT l.name, AVG(attendance_count) AS 'avg_daily_attendance'
FROM locations AS l
LEFT JOIN (
        SELECT location_id, COUNT(*) AS attendance_count
        FROM attendance
        GROUP BY location_id) AS a
    ON l.location_id = a.location_id
GROUP BY l.name;
