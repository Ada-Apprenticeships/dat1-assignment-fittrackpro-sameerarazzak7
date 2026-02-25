.open fittrackpro.db
.mode column

-- 1.1
SELECT member_id, first_name, last_name, email, join_date
FROM members;

-- 1.2
UPDATE members
SET phone_number = '07000 100005', 
    email = 'emily.jones.updated@email.com'
WHERE member_id = 5;

-- 1.3
SELECT COUNT(*) AS 'no_of_members'
FROM members;

-- 1.4
SELECT m.member_id, m.first_name, m.last_name, COUNT(*) AS 'registration_count'
FROM members AS m
JOIN class_attendance AS c
    ON m.member_id = c.member_id
WHERE c.attendance_status = 'Registered' -- all registered classes and their members
GROUP BY m.member_id
ORDER BY registration_count DESC
LIMIT 1;

-- 1.5
SELECT m.member_id, m.first_name, m.last_name, COUNT(*) AS 'registration_count'
FROM members AS m
JOIN class_attendance AS c
    ON m.member_id = c.member_id
WHERE c.attendance_status = 'Registered' -- all registered classes and their members
GROUP BY m.member_id
ORDER BY registration_count 
LIMIT 1;

-- 1.6
SELECT COUNT(*) AS 'Count'
FROM ( -- list of members who attend more than once
    SELECT member_id
    FROM class_attendance 
    WHERE attendance_status = 'Attended'
    GROUP BY member_id
        HAVING COUNT(*) >= 2
);
