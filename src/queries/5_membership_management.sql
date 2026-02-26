.open fittrackpro.db
.mode column

-- 5.1 
SELECT m.member_id, 
       m.first_name, 
       m.last_name, 
       type AS 'membership_type',
       m.join_date 
FROM members AS m
JOIN memberships AS ms
    ON m.member_id = ms.member_id
WHERE ms.status = 'Active';

-- 5.2 
SELECT ms.type AS 'membership_type', 
       ROUND(AVG((julianday(a.check_out_time) - julianday(a.check_in_time)) * 1440), 1) AS 'avg_visit_duration_minutes'
FROM attendance AS a
JOIN memberships AS ms
    ON a.member_id = ms.member_id
WHERE ms.status = 'Active'
GROUP BY ms.type;

-- 5.3 
SELECT m.member_id, m.first_name, m.last_name, m.email, ms.end_date
FROM members AS m
JOIN memberships AS ms
    ON m.member_id = ms.member_id
WHERE strftime('%Y', ms.end_date) = '2025';

