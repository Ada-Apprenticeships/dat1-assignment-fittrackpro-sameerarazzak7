.open fittrackpro.db
.mode column

PRAGMA foreign_keys = OFF;

DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS equipment;
DROP TABLE IF EXISTS classes;
DROP TABLE IF EXISTS class_schedule;
DROP TABLE IF EXISTS memberships;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS class_attendance;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS personal_training_sessions;
DROP TABLE IF EXISTS member_health_metrics;
DROP TABLE IF EXISTS equipment_maintenance_log;

-- avoids dependency issues during rebuild of tables
PRAGMA foreign_keys = ON;

CREATE TABLE locations (
    location_id                     INTEGER PRIMARY KEY NOT NULL,
    name                            TEXT,
    address                         TEXT,
    phone_number                    TEXT CHECK(phone_number LIKE '% ___ ____'
                                        AND phone_number NOT GLOB '*[^0-9 ]*'),
    email                           TEXT CHECK(email LIKE '%@%.%'),
    opening_hours                   TEXT CHECK(opening_hours LIKE '__:__-__:__'
                                        AND opening_hours NOT GLOB '*[^0-9:-]*'
                                        AND substr(opening_hours,1,2) <= '23'
                                        AND substr(opening_hours,4,2) <= '59'
                                        AND substr(opening_hours,7,2) <= '23'
                                        AND substr(opening_hours,10,2) <= '59'
                                        AND substr(opening_hours,1,5) < substr(opening_hours,7,5))
);


CREATE TABLE members (
    member_id                       INTEGER PRIMARY KEY NOT NULL,
    first_name                      TEXT,
    last_name                       TEXT,
    email                           TEXT LIKE '%@%.%',
    phone_number                    TEXT CHECK(phone_number LIKE '_____ ______'
                                        AND phone_number NOT GLOB '*[^0-9 ]*'),
    date_of_birth                   TEXT CHECK(date(date_of_birth) IS NOT NULL
                                        AND date_of_birth = date(date_of_birth)),
    join_date                       TEXT CHECK(date(join_date) IS NOT NULL
                                        AND join_date = date(join_date)),
    emergency_contact_name          TEXT,
    emergency_contact_phone         TEXT CHECK(emergency_contact_phone LIKE '_____ ______'
                                        AND emergency_contact_phone NOT GLOB '*[^0-9 ]*')
);

CREATE TABLE staff (    
    staff_id                        INTEGER PRIMARY KEY NOT NULL,
    first_name                      TEXT,
    last_name                       TEXT, 
    email                           TEXT LIKE '%@%.%',
    phone_number                    TEXT CHECK(phone_number LIKE '_____ ______'
                                        AND phone_number NOT GLOB '*[^0-9 ]*'),
    position                        TEXT CHECK(position IN 
                                        ('Trainer', 'Manager', 'Receptionist', 'Maintenance')),
    hire_date                       TEXT CHECK(date(hire_date) IS NOT NULL
                                        AND hire_date = date(hire_date)),
    location_id                     INTEGER, 
    FOREIGN KEY(location_id)        REFERENCES locations
);

CREATE TABLE equipment (
    equipment_id                    INTEGER PRIMARY KEY NOT NULL, 
    name                            TEXT,
    type                            TEXT CHECK(type IN 
                                        ('Cardio', 'Strength')),
    purchase_date                   TEXT CHECK(date(purchase_date) IS NOT NULL
                                        AND purchase_date = date(purchase_date)),
    last_maintenance_date           TEXT CHECK(date(last_maintenance_date) IS NOT NULL
                                        AND last_maintenance_date = date(last_maintenance_date)),
    next_maintenance_date           TEXT CHECK(date(next_maintenance_date) IS NOT NULL
                                        AND next_maintenance_date = date(next_maintenance_date)),
    location_id                     INTEGER,
    FOREIGN KEY(location_id)        REFERENCES locations
);

CREATE TABLE classes (
    class_id                        INTEGER PRIMARY KEY NOT NULL,
    name                            TEXT,
    description                     TEXT,
    capacity                        INTEGER,
    duration                        INTEGER,
    location_id                     INTEGER, 
    FOREIGN KEY(location_id)        REFERENCES locations
);

CREATE TABLE class_schedule (
    schedule_id                     INTEGER PRIMARY KEY NOT NULL,
    class_id                        INTEGER,
    staff_id                        INTEGER,
    start_time                      TEXT CHECK(start_time IS NOT NULL
                                        AND start_time = datetime(start_time)),
    end_time                        TEXT CHECK(end_time IS NOT NULL
                                        AND end_time = datetime(end_time)),
    FOREIGN KEY(class_id)           REFERENCES classes,
    FOREIGN KEY(staff_id)           REFERENCES staff
);

CREATE TABLE memberships (
    membership_id                   INTEGER PRIMARY KEY NOT NULL,
    member_id                       INTEGER,
    type                            TEXT,
    start_date                      TEXT CHECK(start_date IS NOT NULL
                                        AND start_date = date(start_date)),
    end_date                        TEXT CHECK(end_date IS NOT NULL
                                        AND end_date = date(end_date)),
    status                          TEXT CHECK(status IN 
                                        ('Active', 'Inactive')),
    FOREIGN KEY(member_id)          REFERENCES members
);

CREATE TABLE attendance (
    attendance_id                   INTEGER PRIMARY KEY NOT NULL,
    member_id                       INTEGER,
    location_id                     INTEGER,
    check_in_time                   TEXT CHECK(check_in_time IS NOT NULL
                                        AND check_in_time = datetime(check_in_time)),
    check_out_time                  TEXT CHECK(check_out_time = datetime(check_out_time)),
    FOREIGN KEY(member_id)          REFERENCES members,
    FOREIGN KEY(location_id)        REFERENCES locations
);

CREATE TABLE class_attendance (
    class_attendance_id             INTEGER PRIMARY KEY NOT NULL,
    schedule_id                     INTEGER,
    member_id                       INTEGER,
    attendance_status               TEXT CHECK(attendance_status IN 
                                        ('Registered', 'Attended', 'Unattended')),
    FOREIGN KEY(schedule_id)        REFERENCES class_schedule,
    FOREIGN KEY(member_id)          REFERENCES members
);

CREATE TABLE payments (
    payment_id                      INTEGER PRIMARY KEY NOT NULL,
    member_id                       INTEGER,
    amount                          NUMERIC,
    payment_date                    TEXT CHECK(payment_date IS NOT NULL
                                        AND payment_date = datetime(payment_date)),
    payment_method                  TEXT CHECK(payment_method IN 
                                        ('Credit Card', 'Bank Transfer', 'PayPal', 'Cash')),
    payment_type                    TEXT CHECK(payment_type IN 
                                        ('Monthly membership fee', 'Day pass')),
    FOREIGN KEY(member_id)          REFERENCES members
);

CREATE TABLE personal_training_sessions (
    session_id                      INTEGER PRIMARY KEY NOT NULL,
    member_id                       INTEGER,
    staff_id                        INTEGER,
    session_date                    TEXT CHECK(session_date IS NOT NULL
                                        AND session_date = date(session_date)),
    start_time                      TEXT CHECK(start_time IS NOT NULL
                                        AND start_time = time(start_time)),
    end_time                        TEXT CHECK(end_time IS NOT NULL
                                        AND end_time = time(end_time)),
    notes                           TEXT,
    FOREIGN KEY(member_id)          REFERENCES members,
    FOREIGN KEY(staff_id)           REFERENCES staff
);

CREATE TABLE member_health_metrics (
    metric_id                       INTEGER PRIMARY KEY NOT NULL,
    member_id                       INTEGER,
    measurement_date                TEXT CHECK(date(measurement_date) IS NOT NULL
                                        AND measurement_date = date(measurement_date)),
    weight                          NUMERIC,
    body_fat_percentage             NUMERIC,
    muscle_mass                     NUMERIC,
    bmi                             NUMERIC,
    FOREIGN KEY(member_id)          REFERENCES members
);

CREATE TABLE equipment_maintenance_log (
    log_id                          INTEGER PRIMARY KEY NOT NULL,
    equipment_id                    INTEGER,
    maintenance_date                TEXT CHECK(date(maintenance_date) IS NOT NULL
                                        AND maintenance_date = date(maintenance_date)),
    description                     TEXT,
    staff_id                        INTEGER,
    FOREIGN KEY(equipment_id)       REFERENCES equipment,
    FOREIGN KEY(staff_id)           REFERENCES staff
);