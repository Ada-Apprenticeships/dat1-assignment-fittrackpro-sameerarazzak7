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
    name                            TEXT NOT NULL,
    address                         TEXT NOT NULL,
    phone_number                    TEXT NOT NULL
                                         DEFAULT 'info@location.com' 
                                         CHECK(phone_number LIKE '% ___ ____'
                                                AND phone_number NOT GLOB '*[^0-9 ]*'),
    email                           TEXT NOT NULL 
                                         CHECK(email LIKE '%@%.%'),
    opening_hours                   TEXT NOT NULL 
                                         DEFAULT '09:00-17:00'
                                         CHECK(opening_hours LIKE '__:__-__:__'
                                                AND opening_hours NOT GLOB '*[^0-9:-]*'
                                                AND substr(opening_hours,1,2) <= '23'
                                                AND substr(opening_hours,4,2) <= '59'
                                                AND substr(opening_hours,7,2) <= '23'
                                                AND substr(opening_hours,10,2) <= '59'
                                                AND substr(opening_hours,1,5) < substr(opening_hours,7,5))
);


CREATE TABLE members (
    member_id                       INTEGER PRIMARY KEY NOT NULL,
    first_name                      TEXT NOT NULL,
    last_name                       TEXT NOT NULL,
    email                           TEXT NOT NULL 
                                         CHECK(email LIKE '%@%.%'),
    phone_number                    TEXT NOT NULL 
                                         CHECK(phone_number LIKE '_____ ______'
                                                AND phone_number NOT GLOB '*[^0-9 ]*'),
    date_of_birth                   TEXT NOT NULL 
                                         CHECK(date(date_of_birth) IS NOT NULL
                                                AND date_of_birth = date(date_of_birth)),
    join_date                       TEXT NOT NULL 
                                         DEFAULT (date('now'))    
                                         CHECK(date(join_date) IS NOT NULL
                                                AND join_date = date(join_date)),
    emergency_contact_name          TEXT NOT NULL,
    emergency_contact_phone         TEXT NOT NULL 
                                         CHECK(emergency_contact_phone LIKE '_____ ______'
                                                AND emergency_contact_phone NOT GLOB '*[^0-9 ]*')
);

CREATE TABLE staff (    
    staff_id                        INTEGER PRIMARY KEY NOT NULL,
    first_name                      TEXT NOT NULL,
    last_name                       TEXT NOT NULL, 
    email                           TEXT NOT NULL
                                         CHECK(email LIKE '%@%.%'),
    phone_number                    TEXT NOT NULL 
                                         CHECK(phone_number LIKE '_____ ______'
                                                AND phone_number NOT GLOB '*[^0-9 ]*'),
    position                        TEXT NOT NULL 
                                         CHECK(position IN ('Trainer', 'Manager', 'Receptionist', 'Maintenance')),
    hire_date                       TEXT NOT NULL 
                                         DEFAULT (date('now'))
                                         CHECK(date(hire_date) IS NOT NULL
                                                AND hire_date = date(hire_date)),
    location_id                     INTEGER NOT NULL, 
    FOREIGN KEY(location_id)        REFERENCES locations
);

CREATE TABLE equipment (
    equipment_id                    INTEGER PRIMARY KEY NOT NULL, 
    name                            TEXT NOT NULL,
    type                            TEXT NOT NULL
                                         CHECK(type IN ('Cardio', 'Strength')),
    purchase_date                   TEXT NOT NULL
                                         DEFAULT (date('now'))
                                         CHECK(date(purchase_date) IS NOT NULL
                                                AND purchase_date = date(purchase_date)),
    last_maintenance_date           TEXT NOT NULL
                                         CHECK(date(last_maintenance_date) IS NOT NULL
                                                AND last_maintenance_date = date(last_maintenance_date)),
    next_maintenance_date           TEXT NOT NULL
                                         CHECK(date(next_maintenance_date) IS NOT NULL
                                                AND next_maintenance_date = date(next_maintenance_date)),
    location_id                     INTEGER NOT NULL,
    FOREIGN KEY(location_id)        REFERENCES locations
);

CREATE TABLE classes (
    class_id                        INTEGER PRIMARY KEY NOT NULL,
    name                            TEXT NOT NULL,
    description                     TEXT NOT NULL,
    capacity                        INTEGER NOT NULL,
    duration                        INTEGER NOT NULL,
    location_id                     INTEGER NOT NULL, 
    FOREIGN KEY(location_id)        REFERENCES locations
);

CREATE TABLE class_schedule (
    schedule_id                     INTEGER PRIMARY KEY NOT NULL,
    class_id                        INTEGER NOT NULL,
    staff_id                        INTEGER NOT NULL,
    start_time                      TEXT NOT NULL
                                         CHECK(datetime(start_time) IS NOT NULL
                                                AND start_time = datetime(start_time)),
    end_time                        TEXT NOT NULL
                                         CHECK(datetime(end_time) IS NOT NULL
                                                AND end_time = datetime(end_time)),
    FOREIGN KEY(class_id)           REFERENCES classes,
    FOREIGN KEY(staff_id)           REFERENCES staff
);

CREATE TABLE memberships (
    membership_id                   INTEGER PRIMARY KEY NOT NULL,
    member_id                       INTEGER NOT NULL,
    type                            TEXT NOT NULL,
    start_date                      TEXT NOT NULL
                                         DEFAULT (date('now'))
                                         CHECK(date(start_date) IS NOT NULL
                                                AND start_date = date(start_date)),
    end_date                        TEXT NOT NULL
                                         CHECK(date(end_date) IS NOT NULL
                                                AND end_date = date(end_date)),
    status                          TEXT NOT NULL
                                         DEFAULT 'Active'
                                         CHECK(status IN ('Active', 'Inactive')),
    FOREIGN KEY(member_id)          REFERENCES members
);

CREATE TABLE attendance (
    attendance_id                   INTEGER PRIMARY KEY NOT NULL,
    member_id                       INTEGER NOT NULL,
    location_id                     INTEGER NOT NULL,
    check_in_time                   TEXT NOT NULL
                                         CHECK(datetime(check_in_time) IS NOT NULL
                                                AND check_in_time = datetime(check_in_time)),
    check_out_time                  TEXT DEFAULT (datetime('now'))
                                         CHECK(check_out_time = datetime(check_out_time)),
    FOREIGN KEY(member_id)          REFERENCES members,
    FOREIGN KEY(location_id)        REFERENCES locations
);

CREATE TABLE class_attendance (
    class_attendance_id             INTEGER PRIMARY KEY NOT NULL,
    schedule_id                     INTEGER NOT NULL,
    member_id                       INTEGER NOT NULL,
    attendance_status               TEXT NOT NULL
                                         CHECK(attendance_status IN ('Registered', 'Attended', 'Unattended')),
    FOREIGN KEY(schedule_id)        REFERENCES class_schedule,
    FOREIGN KEY(member_id)          REFERENCES members
);

CREATE TABLE payments (
    payment_id                      INTEGER PRIMARY KEY NOT NULL,
    member_id                       INTEGER NOT NULL,
    amount                          NUMERIC NOT NULL,
    payment_date                    TEXT NOT NULL
                                         DEFAULT (datetime('now'))    
                                         CHECK(datetime(payment_date) IS NOT NULL
                                                AND payment_date = datetime(payment_date)),
    payment_method                  TEXT NOT NULL
                                         CHECK(payment_method IN ('Credit Card', 'Bank Transfer', 'PayPal', 'Cash')),
    payment_type                    TEXT NOT NULL
                                         DEFAULT 'Monthly membership fee'
                                         CHECK(payment_type IN ('Monthly membership fee', 'Day pass')),
    FOREIGN KEY(member_id)          REFERENCES members
);

CREATE TABLE personal_training_sessions (
    session_id                      INTEGER PRIMARY KEY NOT NULL,
    member_id                       INTEGER NOT NULL,
    staff_id                        INTEGER NOT NULL,
    session_date                    TEXT NOT NULL
                                         CHECK(date(session_date) IS NOT NULL
                                                AND session_date = date(session_date)),
    start_time                      TEXT NOT NULL
                                         CHECK(time(start_time) IS NOT NULL
                                                AND start_time = time(start_time)),
    end_time                        TEXT NOT NULL
                                         CHECK(time(end_time) IS NOT NULL
                                                AND end_time = time(end_time)),
    notes                           TEXT NOT NULL
                                         DEFAULT '',
    FOREIGN KEY(member_id)          REFERENCES members,
    FOREIGN KEY(staff_id)           REFERENCES staff
);

CREATE TABLE member_health_metrics (
    metric_id                       INTEGER PRIMARY KEY NOT NULL,
    member_id                       INTEGER NOT NULL,
    measurement_date                TEXT NOT NULL
                                         DEFAULT (date('now'))
                                         CHECK(date(measurement_date) IS NOT NULL
                                                AND measurement_date = date(measurement_date)),
    weight                          NUMERIC NOT NULL,
    body_fat_percentage             NUMERIC NOT NULL,
    muscle_mass                     NUMERIC NOT NULL,
    bmi                             NUMERIC NOT NULL,
    FOREIGN KEY(member_id)          REFERENCES members
);

CREATE TABLE equipment_maintenance_log (
    log_id                          INTEGER PRIMARY KEY NOT NULL,
    equipment_id                    INTEGER NOT NULL,
    maintenance_date                TEXT NOT NULL
                                         CHECK(date(maintenance_date) IS NOT NULL
                                                AND maintenance_date = date(maintenance_date)),
    description                     TEXT NOT NULL
                                         DEFAULT '',
    staff_id                        INTEGER NOT NULL,
    FOREIGN KEY(equipment_id)       REFERENCES equipment,
    FOREIGN KEY(staff_id)           REFERENCES staff
);