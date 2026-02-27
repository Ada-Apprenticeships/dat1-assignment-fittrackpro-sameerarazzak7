.open fittrackpro.db
.mode column

-- 4.1 - all classes and their instructors
SELECT c.class_id, 
       c.name AS class_name, 
       s.first_name AS instructor_name
FROM classes AS c
JOIN staff AS s
    ON c.location_id = s.location_id
WHERE s.position = 'Trainer'; 

-- 4.2 - classes on 2025-02-01
SELECT c.class_id, 
       c.name, 
       cs.start_time, 
       cs.end_time, 
       (c.capacity - COUNT(ca.member_id)) AS available_spots
FROM classes AS c
JOIN class_schedule AS cs
    ON c.class_id = cs.class_id
LEFT JOIN class_attendance AS ca
    ON cs.schedule_id = ca.schedule_id
    AND ca.attendance_status IN ('Registered', 'Attended')
WHERE date(cs.start_time) = '2025-02-01'
GROUP BY cs.schedule_id;

-- 4.3 - enroll member 11 in Spin
INSERT INTO class_attendance 
    (class_attendance_id, schedule_id, member_id, attendance_status)
VALUES 
    (8, 1, 1, 'Registered');

-- 4.4 - cancel member 3 registration for schedule 7
DELETE FROM class_attendance
WHERE class_attendance_id = 3;

-- 4.5 - most popular class by registration
SELECT c.class_id, 
       c.name AS 'class_name', 
       COUNT(ca.attendance_status) AS registration_count
FROM classes AS c
JOIN class_schedule AS cs
    ON c.class_id = cs.class_id
LEFT JOIN class_attendance AS ca
    ON cs.schedule_id = ca.schedule_id
    AND ca.attendance_status = 'Registered'
WHERE date(cs.start_time) = '2025-02-01'
ORDER BY COUNT(ca.attendance_status);

-- 4.6 - average classes per member 
SELECT AVG(class_count) AS avg_classes_per_member
FROM (
    SELECT member_id,
           COUNT(*) AS class_count
    FROM class_attendance
    WHERE attendance_status IN ('Registered', 'Attended')
    GROUP BY member_id
);