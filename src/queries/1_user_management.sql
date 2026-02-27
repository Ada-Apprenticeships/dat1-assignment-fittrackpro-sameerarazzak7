.open fittrackpro.db
.mode column

-- 1.1 - all members
SELECT member_id, 
       first_name, 
       last_name, 
       email, 
       join_date
FROM members;

-- 1.2 - update member 5 details
UPDATE members
SET phone_number = '07000 100005', 
    email = 'emily.jones.updated@email.com'
WHERE member_id = 5;

-- 1.3 - count all members
SELECT COUNT(*) AS total_members
FROM members;

-- 1.4 - members with most class registrations
SELECT m.member_id,
       m.first_name, 
       m.last_name, 
       COUNT(*) AS registration_count
FROM members AS m
JOIN class_attendance AS c
    ON m.member_id = c.member_id
WHERE c.attendance_status = 'Registered' -- all registered classes and their members
GROUP BY m.member_id
ORDER BY registration_count DESC
LIMIT 1;

-- 1.5 - members with least class registrations
SELECT m.member_id,
       m.first_name, 
       m.last_name, 
       COUNT(*) AS registration_count
FROM members AS m
JOIN class_attendance AS c
    ON m.member_id = c.member_id
WHERE c.attendance_status = 'Registered' 
GROUP BY m.member_id
ORDER BY registration_count 
LIMIT 1;

-- 1.6 - number of members with 2 or more class attendances
SELECT COUNT(*) AS Count
FROM ( -- list of members who attend more than once
    SELECT member_id
    FROM class_attendance 
    WHERE attendance_status = 'Attended'
    GROUP BY member_id
        HAVING COUNT(*) >= 2
);
