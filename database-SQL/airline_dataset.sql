--DROP TABLE AIRCRAFT;
--DROP TABLE AIRPORTS;
--DROP TABLE BOOKINGS;
--DROP TABLE CREW;
--DROP TABLE FLIGHTS;
--DROP TABLE PASSENGERS;
--DROP TABLE PAYMENTS;
--DROP TABLE SCHEDULES;


-- ====================================================
-- Table: Aircraft
-- ====================================================
CREATE TABLE Aircraft (
  aircraft_id NUMBER PRIMARY KEY,
  model VARCHAR2(50),
  manufacturer VARCHAR2(50),
  capacity NUMBER,
  registration_number VARCHAR2(20),
  year_built NUMBER
);

-- ====================================================
-- Table: Airports
-- ====================================================
CREATE TABLE Airports (
  airport_id NUMBER PRIMARY KEY,
  name VARCHAR2(100),
  city VARCHAR2(50),
  country VARCHAR2(50),
  iata_code VARCHAR2(5),
  icao_code VARCHAR2(5)
);

-- ====================================================
-- Table: Flights
-- ====================================================
CREATE TABLE Flights (
  flight_id NUMBER PRIMARY KEY,
  flight_number VARCHAR2(10),
  aircraft_id NUMBER,
  departure_airport_id NUMBER,
  arrival_airport_id NUMBER,
  departure_time TIMESTAMP,
  arrival_time TIMESTAMP,
  status VARCHAR2(20),
  CONSTRAINT fk_aircraft FOREIGN KEY (aircraft_id) REFERENCES Aircraft(aircraft_id),
  CONSTRAINT fk_departure_airport FOREIGN KEY (departure_airport_id) REFERENCES Airports(airport_id),
  CONSTRAINT fk_arrival_airport FOREIGN KEY (arrival_airport_id) REFERENCES Airports(airport_id)
);

-- ====================================================
-- Table: Passengers
-- ====================================================
CREATE TABLE Passengers (
  passenger_id NUMBER PRIMARY KEY,
  first_name VARCHAR2(50),
  last_name VARCHAR2(50),
  email VARCHAR2(100),
  phone VARCHAR2(20),
  date_of_birth DATE,
  passport_number VARCHAR2(20)
);

-- ====================================================
-- Table: Bookings
-- ====================================================
CREATE TABLE Bookings (
  booking_id NUMBER PRIMARY KEY,
  passenger_id NUMBER,
  flight_id NUMBER,
  booking_date DATE,
  seat_number VARCHAR2(5),
  booking_status VARCHAR2(20),
  CONSTRAINT fk_passenger FOREIGN KEY (passenger_id) REFERENCES Passengers(passenger_id),
  CONSTRAINT fk_flight FOREIGN KEY (flight_id) REFERENCES Flights(flight_id)
);

-- ====================================================
-- Table: Crew
-- ====================================================
CREATE TABLE Crew (
  crew_id NUMBER PRIMARY KEY,
  first_name VARCHAR2(50),
  last_name VARCHAR2(50),
  role VARCHAR2(50),
  phone VARCHAR2(20),
  email VARCHAR2(100)
);

-- ====================================================
-- Table: Schedules
-- ====================================================
CREATE TABLE Schedules (
  schedule_id NUMBER PRIMARY KEY,
  flight_id NUMBER,
  crew_id NUMBER,
  duty_date DATE,
  duty_start VARCHAR2(8),  -- Format: HH:MI:SS
  duty_end VARCHAR2(8),
  CONSTRAINT fk_schedule_flight FOREIGN KEY (flight_id) REFERENCES Flights(flight_id),
  CONSTRAINT fk_schedule_crew FOREIGN KEY (crew_id) REFERENCES Crew(crew_id)
);

-- ====================================================
-- Table: Payments
-- ====================================================
CREATE TABLE Payments (
  payment_id NUMBER PRIMARY KEY,
  booking_id NUMBER,
  payment_date DATE,
  amount NUMBER(10,2),
  payment_method VARCHAR2(50),
  payment_status VARCHAR2(20),
  CONSTRAINT fk_booking FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);

---------------------------------------------------------------------
-- Insert Data into Aircraft (15 rows)
---------------------------------------------------------------------
INSERT INTO Aircraft VALUES (1,  'Boeing 737',         'Boeing',    160, 'N737AA', 2010);
INSERT INTO Aircraft VALUES (2,  'Airbus A320',         'Airbus',    150, 'N320BA', 2012);
INSERT INTO Aircraft VALUES (3,  'Boeing 777',          'Boeing',    300, 'N777DL', 2015);
INSERT INTO Aircraft VALUES (4,  'Airbus A330',         'Airbus',    250, 'N330UA', 2013);
INSERT INTO Aircraft VALUES (5,  'Embraer 190',         'Embraer',   100, 'N190SW', 2014);
INSERT INTO Aircraft VALUES (6,  'Boeing 747',          'Boeing',    400, 'N747XX', 2008);
INSERT INTO Aircraft VALUES (7,  'Airbus A350',         'Airbus',    350, 'N350AA', 2016);
INSERT INTO Aircraft VALUES (8,  'Boeing 787',          'Boeing',    280, 'N787BA', 2017);
INSERT INTO Aircraft VALUES (9,  'Bombardier CRJ900',   'Bombardier',90, 'N900CR', 2011);
INSERT INTO Aircraft VALUES (10, 'Embraer E175',        'Embraer',    80, 'N175SW', 2018);
INSERT INTO Aircraft VALUES (11, 'Airbus A380',         'Airbus',    500, 'N380AA', 2007);
INSERT INTO Aircraft VALUES (12, 'Boeing 767',          'Boeing',    250, 'N767BB', 2009);
INSERT INTO Aircraft VALUES (13, 'Bombardier Q400',     'Bombardier',78, 'NQ4001', 2012);
INSERT INTO Aircraft VALUES (14, 'ATR 72',            'ATR',       70, 'NATR72', 2013);
INSERT INTO Aircraft VALUES (15, 'Boeing 757',          'Boeing',    200, 'N757XY', 2010);

---------------------------------------------------------------------
-- Insert Data into Airports (15 rows)
---------------------------------------------------------------------
INSERT INTO Airports VALUES (1,  'John F. Kennedy International Airport', 'New York',    'USA',        'JFK', 'KJFK');
INSERT INTO Airports VALUES (2,  'Los Angeles International Airport',       'Los Angeles', 'USA',        'LAX', 'KLAX');
INSERT INTO Airports VALUES (3,  'Heathrow Airport',                          'London',      'UK',         'LHR', 'EGLL');
INSERT INTO Airports VALUES (4,  'Charles de Gaulle Airport',                 'Paris',       'France',     'CDG', 'LFPG');
INSERT INTO Airports VALUES (5,  'Tokyo International Airport',               'Tokyo',       'Japan',      'HND', 'RJTT');
INSERT INTO Airports VALUES (6,  'Dubai International Airport',               'Dubai',       'UAE',        'DXB', 'OMDB');
INSERT INTO Airports VALUES (7,  'Frankfurt Airport',                         'Frankfurt',   'Germany',    'FRA', 'EDDF');
INSERT INTO Airports VALUES (8,  'Singapore Changi Airport',                  'Singapore',   'Singapore',  'SIN', 'WSSS');
INSERT INTO Airports VALUES (9,  'Sydney Kingsford Smith Airport',            'Sydney',      'Australia',  'SYD', 'YSSY');
INSERT INTO Airports VALUES (10, 'Toronto Pearson International Airport',     'Toronto',     'Canada',     'YYZ', 'CYYZ');
INSERT INTO Airports VALUES (11, 'Beijing Capital International Airport',     'Beijing',     'China',      'PEK', 'ZBAA');
INSERT INTO Airports VALUES (12, 'Amsterdam Schiphol Airport',                'Amsterdam',   'Netherlands','AMS', 'EHAM');
INSERT INTO Airports VALUES (13, 'Incheon International Airport',             'Incheon',     'South Korea','ICN', 'RKSI');
INSERT INTO Airports VALUES (14, 'Madrid-Barajas Airport',                    'Madrid',      'Spain',      'MAD', 'LEMD');
INSERT INTO Airports VALUES (15, 'Rome Fiumicino Airport',                    'Rome',        'Italy',      'FCO', 'LIRF');

---------------------------------------------------------------------
-- Insert Data into Flights (55 rows)
---------------------------------------------------------------------
INSERT INTO Flights VALUES (1,  'AA101', '1',  1,  2,  TIMESTAMP '2025-04-01 08:00:00', TIMESTAMP '2025-04-01 10:30:00', 'Scheduled');
INSERT INTO Flights VALUES (2,  'BA202', '2',  2,  3,  TIMESTAMP '2025-04-01 09:00:00', TIMESTAMP '2025-04-01 11:00:00', 'Scheduled');
INSERT INTO Flights VALUES (3,  'DL303', '3',  3,  4,  TIMESTAMP '2025-04-01 12:00:00', TIMESTAMP '2025-04-01 14:00:00', 'Delayed');
INSERT INTO Flights VALUES (4,  'UA404', '4',  4,  5,  TIMESTAMP '2025-04-02 06:00:00', TIMESTAMP '2025-04-02 08:30:00', 'Scheduled');
INSERT INTO Flights VALUES (5,  'SW505', '5',  5,  6,  TIMESTAMP '2025-04-02 10:00:00', TIMESTAMP '2025-04-02 12:15:00', 'Cancelled');
INSERT INTO Flights VALUES (6,  'AA606', '6',  6,  7,  TIMESTAMP '2025-04-03 14:00:00', TIMESTAMP '2025-04-03 16:30:00', 'Scheduled');
INSERT INTO Flights VALUES (7,  'BA707', '7',  7,  8,  TIMESTAMP '2025-04-03 18:00:00', TIMESTAMP '2025-04-03 20:00:00', 'Delayed');
INSERT INTO Flights VALUES (8,  'DL808', '8',  8,  9,  TIMESTAMP '2025-04-04 07:00:00', TIMESTAMP '2025-04-04 09:00:00', 'Scheduled');
INSERT INTO Flights VALUES (9,  'UA909', '9',  9, 10,  TIMESTAMP '2025-04-04 11:00:00', TIMESTAMP '2025-04-04 13:30:00', 'Scheduled');
INSERT INTO Flights VALUES (10, 'SW010', '10', 10, 11,  TIMESTAMP '2025-04-05 15:00:00', TIMESTAMP '2025-04-05 17:00:00', 'Scheduled');
INSERT INTO Flights VALUES (11, 'AF111', '11', 11, 12,  TIMESTAMP '2025-04-06 06:00:00', TIMESTAMP '2025-04-06 08:45:00', 'Scheduled');
INSERT INTO Flights VALUES (12, 'LH212', '12', 12, 13,  TIMESTAMP '2025-04-07 10:00:00', TIMESTAMP '2025-04-07 12:30:00', 'Delayed');
INSERT INTO Flights VALUES (13, 'EK313', '13', 13, 14,  TIMESTAMP '2025-04-08 14:00:00', TIMESTAMP '2025-04-08 16:00:00', 'Scheduled');
INSERT INTO Flights VALUES (14, 'SQ414', '14', 14, 15,  TIMESTAMP '2025-04-09 18:00:00', TIMESTAMP '2025-04-09 20:00:00', 'Cancelled');
INSERT INTO Flights VALUES (15, 'QF515', '15', 15,  1,  TIMESTAMP '2025-04-10 07:30:00', TIMESTAMP '2025-04-10 09:30:00', 'Scheduled');

INSERT INTO Flights VALUES (16, 'AA116', '1', 1, 2, TIMESTAMP '2025-04-11 08:00:00', TIMESTAMP '2025-04-11 10:30:00', 'Scheduled');
INSERT INTO Flights VALUES (17, 'BA117', '2', 2, 3, TIMESTAMP '2025-04-11 14:00:00', TIMESTAMP '2025-04-11 16:30:00', 'Scheduled');
INSERT INTO Flights VALUES (18, 'DL118', '3', 3, 4, TIMESTAMP '2025-04-12 08:00:00', TIMESTAMP '2025-04-12 10:30:00', 'Scheduled');
INSERT INTO Flights VALUES (19, 'UA119', '4', 4, 5, TIMESTAMP '2025-04-12 14:00:00', TIMESTAMP '2025-04-12 16:30:00', 'Scheduled');
INSERT INTO Flights VALUES (20, 'SW120', '5', 5, 6, TIMESTAMP '2025-04-13 08:00:00', TIMESTAMP '2025-04-13 10:30:00', 'Scheduled');
INSERT INTO Flights VALUES (21, 'AA121', '6', 6, 7, TIMESTAMP '2025-04-13 14:00:00', TIMESTAMP '2025-04-13 16:30:00', 'Scheduled');
INSERT INTO Flights VALUES (22, 'BA122', '7', 7, 8, TIMESTAMP '2025-04-14 08:00:00', TIMESTAMP '2025-04-14 10:30:00', 'Scheduled');
INSERT INTO Flights VALUES (23, 'DL123', '8', 8, 9, TIMESTAMP '2025-04-14 14:00:00', TIMESTAMP '2025-04-14 16:30:00', 'Scheduled');
INSERT INTO Flights VALUES (24, 'UA124', '9', 9, 10, TIMESTAMP '2025-04-15 08:00:00', TIMESTAMP '2025-04-15 10:30:00', 'Scheduled');
INSERT INTO Flights VALUES (25, 'SW125', '10', 10, 11, TIMESTAMP '2025-04-15 14:00:00', TIMESTAMP '2025-04-15 16:30:00', 'Scheduled');
INSERT INTO Flights VALUES (26, 'AA126', '11', 11, 12, TIMESTAMP '2025-04-16 08:00:00', TIMESTAMP '2025-04-16 10:30:00', 'Scheduled');
INSERT INTO Flights VALUES (27, 'BA127', '12', 12, 13, TIMESTAMP '2025-04-16 14:00:00', TIMESTAMP '2025-04-16 16:30:00', 'Scheduled');
INSERT INTO Flights VALUES (28, 'DL128', '13', 13, 14, TIMESTAMP '2025-04-17 08:00:00', TIMESTAMP '2025-04-17 10:30:00', 'Scheduled');
INSERT INTO Flights VALUES (29, 'UA129', '14', 14, 15, TIMESTAMP '2025-04-17 14:00:00', TIMESTAMP '2025-04-17 16:30:00', 'Scheduled');
INSERT INTO Flights VALUES (30, 'SW130', '15', 15, 1, TIMESTAMP '2025-04-18 08:00:00', TIMESTAMP '2025-04-18 10:30:00', 'Scheduled');
INSERT INTO Flights VALUES (31, 'AA131', '1', 1, 2, TIMESTAMP '2025-04-18 14:00:00', TIMESTAMP '2025-04-18 16:30:00', 'Scheduled');
INSERT INTO Flights VALUES (32, 'BA132', '2', 2, 3, TIMESTAMP '2025-04-19 08:00:00', TIMESTAMP '2025-04-19 10:30:00', 'Scheduled');
INSERT INTO Flights VALUES (33, 'DL133', '3', 3, 4, TIMESTAMP '2025-04-19 14:00:00', TIMESTAMP '2025-04-19 16:30:00', 'Scheduled');
INSERT INTO Flights VALUES (34, 'UA134', '4', 4, 5, TIMESTAMP '2025-04-20 08:00:00', TIMESTAMP '2025-04-20 10:30:00', 'Scheduled');
INSERT INTO Flights VALUES (35, 'SW135', '5', 5, 6, TIMESTAMP '2025-04-20 14:00:00', TIMESTAMP '2025-04-20 16:30:00', 'Scheduled');
INSERT INTO Flights VALUES (36, 'AA136', '6', 6, 7, TIMESTAMP '2025-04-21 08:00:00', TIMESTAMP '2025-04-21 10:30:00', 'Scheduled');
INSERT INTO Flights VALUES (37, 'BA137', '7', 7, 8, TIMESTAMP '2025-04-21 14:00:00', TIMESTAMP '2025-04-21 16:30:00', 'Scheduled');
INSERT INTO Flights VALUES (38, 'DL138', '8', 8, 9, TIMESTAMP '2025-04-22 08:00:00', TIMESTAMP '2025-04-22 10:30:00', 'Scheduled');
INSERT INTO Flights VALUES (39, 'UA139', '9', 9, 10, TIMESTAMP '2025-04-22 14:00:00', TIMESTAMP '2025-04-22 16:30:00', 'Scheduled');
INSERT INTO Flights VALUES (40, 'SW140', '10', 10, 11, TIMESTAMP '2025-04-23 08:00:00', TIMESTAMP '2025-04-23 10:30:00', 'Scheduled');
INSERT INTO Flights VALUES (41, 'AA141', '11', 11, 12, TIMESTAMP '2025-04-23 14:00:00', TIMESTAMP '2025-04-23 16:30:00', 'Scheduled');
INSERT INTO Flights VALUES (42, 'BA142', '12', 12, 13, TIMESTAMP '2025-04-24 08:00:00', TIMESTAMP '2025-04-24 10:30:00', 'Scheduled');
INSERT INTO Flights VALUES (43, 'DL143', '13', 13, 14, TIMESTAMP '2025-04-24 14:00:00', TIMESTAMP '2025-04-24 16:30:00', 'Scheduled');
INSERT INTO Flights VALUES (44, 'UA144', '14', 14, 15, TIMESTAMP '2025-04-25 08:00:00', TIMESTAMP '2025-04-25 10:30:00', 'Scheduled');
INSERT INTO Flights VALUES (45, 'SW145', '15', 15, 1, TIMESTAMP '2025-04-25 14:00:00', TIMESTAMP '2025-04-25 16:30:00', 'Scheduled');
INSERT INTO Flights VALUES (46, 'AA146', '1', 1, 2, TIMESTAMP '2025-04-26 08:00:00', TIMESTAMP '2025-04-26 10:30:00', 'Scheduled');
INSERT INTO Flights VALUES (47, 'BA147', '2', 2, 3, TIMESTAMP '2025-04-26 14:00:00', TIMESTAMP '2025-04-26 16:30:00', 'Scheduled');
INSERT INTO Flights VALUES (48, 'DL148', '3', 3, 4, TIMESTAMP '2025-04-27 08:00:00', TIMESTAMP '2025-04-27 10:30:00', 'Scheduled');
INSERT INTO Flights VALUES (49, 'UA149', '4', 4, 5, TIMESTAMP '2025-04-27 14:00:00', TIMESTAMP '2025-04-27 16:30:00', 'Scheduled');
INSERT INTO Flights VALUES (50, 'SW150', '5', 5, 6, TIMESTAMP '2025-04-28 08:00:00', TIMESTAMP '2025-04-28 10:30:00', 'Scheduled');
INSERT INTO Flights VALUES (51, 'AA151', '6', 6, 7, TIMESTAMP '2025-04-28 14:00:00', TIMESTAMP '2025-04-28 16:30:00', 'Scheduled');
INSERT INTO Flights VALUES (52, 'BA152', '7', 7, 8, TIMESTAMP '2025-04-29 08:00:00', TIMESTAMP '2025-04-29 10:30:00', 'Scheduled');
INSERT INTO Flights VALUES (53, 'DL153', '8', 8, 9, TIMESTAMP '2025-04-29 14:00:00', TIMESTAMP '2025-04-29 16:30:00', 'Scheduled');
INSERT INTO Flights VALUES (54, 'UA154', '9', 9, 10, TIMESTAMP '2025-04-30 08:00:00', TIMESTAMP '2025-04-30 10:30:00', 'Scheduled');
INSERT INTO Flights VALUES (55, 'SW155', '10', 10, 11, TIMESTAMP '2025-04-30 14:00:00', TIMESTAMP '2025-04-30 16:30:00', 'Scheduled');


---------------------------------------------------------------------
-- Insert Data into Passengers (15 rows)
---------------------------------------------------------------------
INSERT INTO Passengers VALUES (1,  'John',      'Doe',       'john.doe@example.com',      '123-456-7890', DATE '1985-05-15', 'P1234567');
INSERT INTO Passengers VALUES (2,  'Jane',      'Smith',     'jane.smith@example.com',    '234-567-8901', DATE '1990-08-20', 'P2345678');
INSERT INTO Passengers VALUES (3,  'Robert',    'Brown',     'robert.brown@example.com',  '345-678-9012', DATE '1978-11-02', 'P3456789');
INSERT INTO Passengers VALUES (4,  'Emily',     'Davis',     'emily.davis@example.com',   '456-789-0123', DATE '1992-03-10', 'P4567890');
INSERT INTO Passengers VALUES (5,  'Michael',   'Wilson',    'michael.wilson@example.com','567-890-1234', DATE '1980-07-07', 'P5678901');
INSERT INTO Passengers VALUES (6,  'Sarah',     'Miller',    'sarah.miller@example.com',  '678-901-2345', DATE '1988-12-12', 'P6789012');
INSERT INTO Passengers VALUES (7,  'David',     'Taylor',    'david.taylor@example.com',  '789-012-3456', DATE '1975-09-25', 'P7890123');
INSERT INTO Passengers VALUES (8,  'Laura',     'Anderson',  'laura.anderson@example.com','890-123-4567', DATE '1995-04-18', 'P8901234');
INSERT INTO Passengers VALUES (9,  'Daniel',    'Thomas',    'daniel.thomas@example.com', '901-234-5678', DATE '1982-02-22', 'P9012345');
INSERT INTO Passengers VALUES (10, 'Olivia',    'Jackson',   'olivia.jackson@example.com','012-345-6789', DATE '1998-06-30', 'P0123456');
INSERT INTO Passengers VALUES (11, 'William',   'Martin',    'william.martin@example.com','111-222-3333', DATE '1983-03-03', 'P1111111');
INSERT INTO Passengers VALUES (12, 'Sophia',    'Lewis',     'sophia.lewis@example.com',  '222-333-4444', DATE '1991-07-21', 'P2222222');
INSERT INTO Passengers VALUES (13, 'James',     'Walker',    'james.walker@example.com',  '333-444-5555', DATE '1986-12-12', 'P3333333');
INSERT INTO Passengers VALUES (14, 'Isabella',  'Harris',    'isabella.harris@example.com','444-555-6666', DATE '1993-11-11', 'P4444444');
INSERT INTO Passengers VALUES (15, 'Benjamin',  'Clark',     'benjamin.clark@example.com','555-666-7777', DATE '1989-09-09', 'P5555555');
INSERT INTO Passengers VALUES (16, 'Alex', 'Johnson', 'alex.johnson@example.com', '111-222-3333', DATE '1988-01-15', 'P16161616');
INSERT INTO Passengers VALUES (17, 'Emily', 'White', 'emily.white@example.com', '222-333-4444', DATE '1990-05-20', 'P17171717');
INSERT INTO Passengers VALUES (18, 'Michael', 'Green', 'michael.green@example.com', '333-444-5555', DATE '1985-07-30', 'P18181818');
INSERT INTO Passengers VALUES (19, 'Sarah', 'Black', 'sarah.black@example.com', '444-555-6666', DATE '1993-09-10', 'P19191919');
INSERT INTO Passengers VALUES (20, 'David', 'Clark', 'david.clark@example.com', '555-666-7777', DATE '1982-11-05', 'P20202020');
INSERT INTO Passengers VALUES (21, 'Laura', 'Adams', 'laura.adams@example.com', '666-777-8888', DATE '1994-03-15', 'P21212121');
INSERT INTO Passengers VALUES (22, 'Daniel', 'Baker', 'daniel.baker@example.com', '777-888-9999', DATE '1987-12-01', 'P22222222');
INSERT INTO Passengers VALUES (23, 'Olivia', 'Carter', 'olivia.carter@example.com', '888-999-0000', DATE '1991-08-08', 'P23232323');
INSERT INTO Passengers VALUES (24, 'James', 'Davis', 'james.davis@example.com', '999-000-1111', DATE '1989-04-22', 'P24242424');
INSERT INTO Passengers VALUES (25, 'Sophia', 'Evans', 'sophia.evans@example.com', '000-111-2222', DATE '1995-06-30', 'P25252525');
INSERT INTO Passengers VALUES (26, 'Benjamin', 'Foster', 'benjamin.foster@example.com', '111-222-3334', DATE '1986-10-10', 'P26262626');
INSERT INTO Passengers VALUES (27, 'Grace', 'Gibson', 'grace.gibson@example.com', '222-333-4445', DATE '1990-02-14', 'P27272727');
INSERT INTO Passengers VALUES (28, 'Lucas', 'Harris', 'lucas.harris@example.com', '333-444-5556', DATE '1984-12-25', 'P28282828');
INSERT INTO Passengers VALUES (29, 'Mia', 'Irwin', 'mia.irwin@example.com', '444-555-6667', DATE '1993-07-07', 'P29292929');
INSERT INTO Passengers VALUES (30, 'Ethan', 'Jones', 'ethan.jones@example.com', '555-666-7778', DATE '1988-03-03', 'P30303030');

BEGIN
  FOR i IN 31 .. 480 LOOP
    INSERT INTO Passengers 
    VALUES (
      i,
      'First' || i,
      'Last' || i,
      'user' || i || '@example.com',
      '000-000-' || TO_CHAR(i, 'FM0000'),
      DATE '1993-07-07',
      'P' || LPAD(i, 7, '0')
    );
  END LOOP;
  COMMIT;
END;
/



---------------------------------------------------------------------
-- Insert Data into Bookings (15 rows)
---------------------------------------------------------------------
INSERT INTO Bookings VALUES (1,  1,  1,  DATE '2025-03-15', '12A', 'Confirmed');
INSERT INTO Bookings VALUES (2,  2,  2,  DATE '2025-03-16', '14B', 'Confirmed');
INSERT INTO Bookings VALUES (3,  3,  3,  DATE '2025-03-17', '16C', 'Cancelled');
INSERT INTO Bookings VALUES (4,  4,  4,  DATE '2025-03-18', '18D', 'Confirmed');
INSERT INTO Bookings VALUES (5,  5,  5,  DATE '2025-03-19', '20E', 'Confirmed');
INSERT INTO Bookings VALUES (6,  6,  6,  DATE '2025-03-20', '22F', 'Pending');
INSERT INTO Bookings VALUES (7,  7,  7,  DATE '2025-03-21', '24A', 'Confirmed');
INSERT INTO Bookings VALUES (8,  8,  8,  DATE '2025-03-22', '26B', 'Confirmed');
INSERT INTO Bookings VALUES (9,  9,  9,  DATE '2025-03-23', '28C', 'Confirmed');
INSERT INTO Bookings VALUES (10, 10, 10,  DATE '2025-03-24', '30D', 'Confirmed');
INSERT INTO Bookings VALUES (11, 11, 10,  DATE '2025-03-25', '32E', 'Confirmed');
INSERT INTO Bookings VALUES (12, 12, 10,  DATE '2025-03-26', '34F', 'Cancelled');
INSERT INTO Bookings VALUES (13, 13, 3,  DATE '2025-03-27', '36A', 'Confirmed');
INSERT INTO Bookings VALUES (14, 14, 4,  DATE '2025-03-28', '38B', 'Pending');
INSERT INTO Bookings VALUES (15, 15, 7,  DATE '2025-03-29', '40C', 'Confirmed');
INSERT INTO Bookings VALUES (16, 16, 1, DATE '2025-03-30', '10A', 'Confirmed');
INSERT INTO Bookings VALUES (17, 17, 2, DATE '2025-03-30', '11B', 'Confirmed');
INSERT INTO Bookings VALUES (18, 18, 3, DATE '2025-03-30', '12C', 'Confirmed');
INSERT INTO Bookings VALUES (19, 19, 4, DATE '2025-03-30', '13D', 'Confirmed');
INSERT INTO Bookings VALUES (20, 20, 5, DATE '2025-03-30', '14E', 'Confirmed');
INSERT INTO Bookings VALUES (21, 21, 6, DATE '2025-03-30', '15F', 'Confirmed');
INSERT INTO Bookings VALUES (22, 22, 7, DATE '2025-03-30', '16A', 'Confirmed');
INSERT INTO Bookings VALUES (23, 23, 8, DATE '2025-03-30', '17B', 'Confirmed');
INSERT INTO Bookings VALUES (24, 24, 9, DATE '2025-03-30', '18C', 'Confirmed');
INSERT INTO Bookings VALUES (25, 25, 10, DATE '2025-03-30', '19D', 'Confirmed');
INSERT INTO Bookings VALUES (26, 26, 1, DATE '2025-03-30', '20E', 'Confirmed');
INSERT INTO Bookings VALUES (27, 27, 2, DATE '2025-03-30', '21F', 'Confirmed');
INSERT INTO Bookings VALUES (28, 28, 3, DATE '2025-03-30', '22A', 'Confirmed');
INSERT INTO Bookings VALUES (29, 29, 4, DATE '2025-03-30', '23B', 'Confirmed');
INSERT INTO Bookings VALUES (30, 30, 5, DATE '2025-03-30', '24C', 'Confirmed');

BEGIN
  FOR i IN 31 .. 480 LOOP
    INSERT INTO Bookings 
    VALUES (
      i,                          -- booking_id
      i,                          -- passenger_id (assumes new passengers with matching IDs)
      MOD(i,15) + 1,              -- flight_id (cycles through 1 to 15)
      DATE '2025-03-30',          -- fixed booking date
      TO_CHAR(MOD(i, 30) + 1) || CHR(65 + MOD(i, 6)),  -- seat_number (e.g., "1A", "2B", etc.)
      'Confirmed'                 -- booking status
    );
  END LOOP;
  COMMIT;
END;
/


---------------------------------------------------------------------
-- Insert Data into Crew (15 rows)
---------------------------------------------------------------------
INSERT INTO Crew VALUES (1,  'James',       'Wilson',      'Pilot',            '111-222-3333', 'james.wilson@example.com');
INSERT INTO Crew VALUES (2,  'Robert',      'Johnson',     'Co-Pilot',         '222-333-4444', 'robert.johnson@example.com');
INSERT INTO Crew VALUES (3,  'Emily',       'Clark',       'Flight Attendant', '333-444-5555', 'emily.clark@example.com');
INSERT INTO Crew VALUES (4,  'Linda',       'Taylor',      'Flight Attendant', '444-555-6666', 'linda.taylor@example.com');
INSERT INTO Crew VALUES (5,  'Michael',     'Brown',       'Pilot',            '555-666-7777', 'michael.brown@example.com');
INSERT INTO Crew VALUES (6,  'Sarah',       'Davis',       'Co-Pilot',         '666-777-8888', 'sarah.davis@example.com');
INSERT INTO Crew VALUES (7,  'David',       'Miller',      'Flight Attendant', '777-888-9999', 'david.miller@example.com');
INSERT INTO Crew VALUES (8,  'Laura',       'Martinez',    'Flight Attendant', '888-999-0000', 'laura.martinez@example.com');
INSERT INTO Crew VALUES (9,  'James',       'Anderson',    'Pilot',            '999-000-1111', 'james.anderson@example.com');
INSERT INTO Crew VALUES (10, 'Patricia',    'Thomas',      'Flight Attendant', '000-111-2222', 'patricia.thomas@example.com');
INSERT INTO Crew VALUES (11, 'Christopher', 'Moore',       'Pilot',            '101-202-3030', 'christopher.moore@example.com');
INSERT INTO Crew VALUES (12, 'Karen',       'Martin',      'Co-Pilot',         '202-303-4040', 'karen.martin@example.com');
INSERT INTO Crew VALUES (13, 'Brian',       'Thompson',    'Flight Attendant', '303-404-5050', 'brian.thompson@example.com');
INSERT INTO Crew VALUES (14, 'Jennifer',    'Garcia',      'Flight Attendant', '404-505-6060', 'jennifer.garcia@example.com');
INSERT INTO Crew VALUES (15, 'Kevin',       'Rodriguez',   'Pilot',            '505-606-7070', 'kevin.rodriguez@example.com');

---------------------------------------------------------------------
-- Insert Data into Schedules (15 rows)
---------------------------------------------------------------------
INSERT INTO Schedules VALUES (1,  1,  1,  DATE '2025-04-01', '07:00:00', '11:00:00');
INSERT INTO Schedules VALUES (2,  2,  2,  DATE '2025-04-01', '08:00:00', '12:00:00');
INSERT INTO Schedules VALUES (3,  3,  3,  DATE '2025-04-01', '11:00:00', '15:00:00');
INSERT INTO Schedules VALUES (4,  4,  4,  DATE '2025-04-02', '05:00:00', '09:00:00');
INSERT INTO Schedules VALUES (5,  5,  5,  DATE '2025-04-02', '09:00:00', '13:00:00');
INSERT INTO Schedules VALUES (6,  6,  6,  DATE '2025-04-03', '13:00:00', '17:00:00');
INSERT INTO Schedules VALUES (7,  7,  7,  DATE '2025-04-03', '17:00:00', '21:00:00');
INSERT INTO Schedules VALUES (8,  8,  8,  DATE '2025-04-04', '06:00:00', '10:00:00');
INSERT INTO Schedules VALUES (9,  9,  9,  DATE '2025-04-04', '10:00:00', '14:00:00');
INSERT INTO Schedules VALUES (10, 10, 10,  DATE '2025-04-05', '14:00:00', '18:00:00');
INSERT INTO Schedules VALUES (11, 11, 11,  DATE '2025-04-06', '07:30:00', '11:30:00');
INSERT INTO Schedules VALUES (12, 12, 12,  DATE '2025-04-07', '08:00:00', '12:00:00');
INSERT INTO Schedules VALUES (13, 13, 13,  DATE '2025-04-08', '09:00:00', '13:00:00');
INSERT INTO Schedules VALUES (14, 14, 14,  DATE '2025-04-09', '10:00:00', '14:00:00');
INSERT INTO Schedules VALUES (15, 15, 15,  DATE '2025-04-10', '11:00:00', '15:00:00');

---------------------------------------------------------------------
-- Insert Data into Payments (15 rows)
---------------------------------------------------------------------
INSERT INTO Payments VALUES (1,  1,  DATE '2025-03-16', 200.00, 'Credit Card', 'Completed');
INSERT INTO Payments VALUES (2,  2,  DATE '2025-03-17', 250.00, 'Debit Card',  'Completed');
INSERT INTO Payments VALUES (3,  3,  DATE '2025-03-18', 300.00, 'PayPal',      'Refunded');
INSERT INTO Payments VALUES (4,  4,  DATE '2025-03-19', 150.00, 'Credit Card', 'Completed');
INSERT INTO Payments VALUES (5,  5,  DATE '2025-03-20', 180.00, 'Credit Card', 'Completed');
INSERT INTO Payments VALUES (6,  6,  DATE '2025-03-21', 220.00, 'Debit Card',  'Pending');
INSERT INTO Payments VALUES (7,  7,  DATE '2025-03-22', 210.00, 'Credit Card', 'Completed');
INSERT INTO Payments VALUES (8,  8,  DATE '2025-03-23', 190.00, 'PayPal',      'Completed');
INSERT INTO Payments VALUES (9,  9,  DATE '2025-03-24', 230.00, 'Credit Card', 'Completed');
INSERT INTO Payments VALUES (10, 10,  DATE '2025-03-25', 205.00, 'Debit Card',  'Completed');
INSERT INTO Payments VALUES (11, 11,  DATE '2025-03-26', 215.00, 'Credit Card', 'Completed');
INSERT INTO Payments VALUES (12, 12,  DATE '2025-03-27', 225.00, 'PayPal',      'Cancelled');
INSERT INTO Payments VALUES (13, 13,  DATE '2025-03-28', 235.00, 'Debit Card',  'Completed');
INSERT INTO Payments VALUES (14, 14,  DATE '2025-03-29', 245.00, 'Credit Card', 'Pending');
INSERT INTO Payments VALUES (15, 15,  DATE '2025-03-30', 255.00, 'Debit Card',  'Completed');



---------------------------------------------------------------------
-- SEQUENCE CREATION
---------------------------------------------------------------------
DROP SEQUENCE Bookings_seq;

CREATE SEQUENCE Bookings_seq START WITH 1001 INCREMENT BY 1;






---------------------------------------------------------------------
-- PROCEDURE CREATE BOOKING
---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_CreateBooking (
    p_passenger_id IN Bookings.passenger_id%TYPE,
    p_flight_id    IN Bookings.flight_id%TYPE,
    p_seat_number  IN Bookings.seat_number%TYPE,
    o_booking_id   OUT Bookings.booking_id%TYPE,
    o_error_msg    OUT VARCHAR2
)
IS
    v_new_id Bookings.booking_id%TYPE;
    v_seat_count NUMBER;
BEGIN
    -- Validate Inputs
    IF p_passenger_id IS NULL OR p_flight_id IS NULL OR p_seat_number IS NULL THEN
        o_booking_id := NULL;
        o_error_msg := 'Passenger ID, Flight ID, and Seat Number are required.';
        RETURN;
    END IF;

    -- Check if seat is already booked
    SELECT COUNT(*)
    INTO v_seat_count
    FROM Bookings
    WHERE flight_id = p_flight_id
      AND seat_number = p_seat_number
      AND booking_status = 'Confirmed'; -- Or Pending? Be consistent

    IF v_seat_count > 0 THEN
        o_booking_id := NULL;
        o_error_msg := 'Seat ' || p_seat_number || ' is already booked on this flight.';
        RETURN;
    END IF;

    -- Check if passenger exists (optional, but good practice)
    SELECT COUNT(*) INTO v_seat_count FROM Passengers WHERE passenger_id = p_passenger_id;
    IF v_seat_count = 0 THEN
         o_booking_id := NULL;
         o_error_msg := 'Invalid Passenger ID provided.';
         RETURN;
    END IF;
     -- Check if flight exists and is scheduled (optional)
    SELECT COUNT(*) INTO v_seat_count FROM Flights WHERE flight_id = p_flight_id AND status='Scheduled';
     IF v_seat_count = 0 THEN
         o_booking_id := NULL;
         o_error_msg := 'Invalid or non-scheduled Flight ID provided.';
         RETURN;
    END IF;


    -- Get the next available booking ID
    SELECT Bookings_seq.NEXTVAL INTO v_new_id FROM DUAL;

    -- Insert the new booking
    INSERT INTO Bookings (booking_id, passenger_id, flight_id, booking_date, seat_number, booking_status)
    VALUES (v_new_id, p_passenger_id, p_flight_id, SYSDATE, p_seat_number, 'Confirmed'); -- Start as Confirmed

    o_booking_id := v_new_id;
    o_error_msg := NULL; -- Success

EXCEPTION
    WHEN OTHERS THEN
        o_booking_id := NULL;
        o_error_msg := 'Error creating booking: ' || SQLERRM;
END;
/




---------------------------------------------------------------------
-- PROCEDURE GET PASSENGER LIST
---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_GetPassengerList (
    o_passenger_cursor OUT SYS_REFCURSOR -- Output cursor
)
IS
BEGIN
    OPEN o_passenger_cursor FOR
        SELECT passenger_id, first_name, last_name
        FROM Passengers
        ORDER BY last_name, first_name;
EXCEPTION
    WHEN OTHERS THEN
        -- Consider logging the error or raising it
        -- For simplicity here, we let it propagate or return empty if OPEN fails
        NULL;
END;
/



---------------------------------------------------------------------
-- PROCEDURE CREATE NEW PASSENGER
---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_CreatePassenger (
    p_first_name      IN Passengers.first_name%TYPE,
    p_last_name       IN Passengers.last_name%TYPE,
    p_email           IN Passengers.email%TYPE,
    p_phone           IN Passengers.phone%TYPE,
    p_date_of_birth   IN VARCHAR2, -- Pass as YYYY-MM-DD string
    p_passport_number IN Passengers.passport_number%TYPE,
    o_passenger_id    OUT Passengers.passenger_id%TYPE,
    o_error_msg       OUT VARCHAR2
)
IS
    v_new_id Passengers.passenger_id%TYPE;
    v_dob DATE;
BEGIN
    -- Attempt to convert date string
    BEGIN
         v_dob := TO_DATE(p_date_of_birth, 'YYYY-MM-DD');
    EXCEPTION
         WHEN OTHERS THEN
              o_passenger_id := NULL;
              o_error_msg := 'Invalid Date of Birth format. Use YYYY-MM-DD.';
              RETURN; -- Exit procedure
    END;

    -- Validate email format (basic) - more robust checks are possible
    IF p_email IS NULL OR INSTR(p_email, '@') = 0 OR INSTR(p_email, '.') = 0 THEN
         o_passenger_id := NULL;
         o_error_msg := 'Invalid email format provided.';
         RETURN;
    END IF;

    -- Check for required fields (add others if needed)
    IF p_first_name IS NULL OR p_last_name IS NULL THEN
         o_passenger_id := NULL;
         o_error_msg := 'First Name and Last Name are required.';
         RETURN;
    END IF;

    -- Get next ID
    SELECT NVL(MAX(passenger_id), 0) + 1 INTO v_new_id FROM Passengers; -- Or use a sequence

    INSERT INTO Passengers (passenger_id, first_name, last_name, email, phone, date_of_birth, passport_number)
    VALUES (v_new_id, p_first_name, p_last_name, p_email, p_phone, v_dob, p_passport_number);

    o_passenger_id := v_new_id;
    o_error_msg := NULL; -- Success

EXCEPTION
    WHEN OTHERS THEN
        o_passenger_id := NULL;
        o_error_msg := 'Error creating passenger: ' || SQLERRM;
        -- Consider ROLLBACK if part of a larger transaction elsewhere
END;
/



---------------------------------------------------------------------
-- PROCEDURE GET AVAILABLE FLIGHTS
---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_GetAvailableFlights (
    p_dep_loc_id       IN Flights.departure_airport_id%TYPE DEFAULT NULL,
    p_arr_loc_id       IN Flights.arrival_airport_id%TYPE DEFAULT NULL,
    p_start_date_str   IN VARCHAR2 DEFAULT NULL, -- YYYY-MM-DD
    p_end_date_str     IN VARCHAR2 DEFAULT NULL, -- YYYY-MM-DD
    o_flight_cursor    OUT SYS_REFCURSOR
)
IS
    v_start_date DATE := TO_DATE(p_start_date_str, 'YYYY-MM-DD');
    v_end_date DATE := TO_DATE(p_end_date_str, 'YYYY-MM-DD');
BEGIN
    OPEN o_flight_cursor FOR
        SELECT
            f.flight_id,
            f.flight_number,
            f.departure_time,
            f.arrival_time,
            dep_ap.name as departure_airport, -- Use dep_ap.name
            arr_ap.name as arrival_airport,  -- Use arr_ap.name
            ac.capacity
        FROM Flights f
        JOIN Airports dep_ap ON f.departure_airport_id = dep_ap.airport_id
        JOIN Airports arr_ap ON f.arrival_airport_id = arr_ap.airport_id
        JOIN Aircraft ac ON f.aircraft_id = ac.aircraft_id
        WHERE f.status = 'Scheduled' -- Only show scheduled flights
          AND f.departure_time > SYSDATE -- Only show future flights
          -- Optional Filters
          AND (p_dep_loc_id IS NULL OR f.departure_airport_id = p_dep_loc_id)
          AND (p_arr_loc_id IS NULL OR f.arrival_airport_id = p_arr_loc_id)
          AND (v_start_date IS NULL OR TRUNC(f.departure_time) >= v_start_date)
          AND (v_end_date IS NULL OR TRUNC(f.departure_time) <= v_end_date)
        ORDER BY f.departure_time;
EXCEPTION
    WHEN OTHERS THEN
         -- Handle potential TO_DATE errors if format is wrong or NULL passed incorrectly
         -- Re-open cursor with potentially fewer filters or handle error
         OPEN o_flight_cursor FOR SELECT 1 FROM DUAL WHERE 1=0; -- Return empty cursor on error
END;
/

-- Need SP_GetAirports for filter dropdowns
CREATE OR REPLACE PROCEDURE SP_GetAirports (
    o_airport_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN o_airport_cursor FOR
        SELECT airport_id, name, city, country -- Use 'name'
        FROM Airports
        ORDER BY name; -- Use 'name'
END;
/

---------------------------------------------------------------------
-- PROCEDURE GET FLIGHT SEAT LAYOUT
---------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE SP_GetFlightLayout (
    p_flight_id      IN Flights.flight_id%TYPE,
    o_capacity       OUT Aircraft.capacity%TYPE,
    o_booked_seats   OUT SYS_REFCURSOR
)
IS
    v_aircraft_id Aircraft.aircraft_id%TYPE;
BEGIN
    -- Get Aircraft Capacity
    SELECT ac.capacity, ac.aircraft_id
    INTO o_capacity, v_aircraft_id
    FROM Flights f
    JOIN Aircraft ac ON f.aircraft_id = ac.aircraft_id
    WHERE f.flight_id = p_flight_id;

    -- Get Booked Seats
    OPEN o_booked_seats FOR
        SELECT seat_number
        FROM Bookings
        WHERE flight_id = p_flight_id
          AND booking_status = 'Confirmed'; -- Or maybe include 'Pending'?

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        o_capacity := 0;
         OPEN o_booked_seats FOR SELECT 1 FROM DUAL WHERE 1=0; -- Empty cursor
    WHEN OTHERS THEN
        o_capacity := -1; -- Indicate error
         OPEN o_booked_seats FOR SELECT 1 FROM DUAL WHERE 1=0; -- Empty cursor
END;
/



---------------------------------------------------------------------
-- PROCEDURE SEARCH BOOKINGS
---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_SearchBookings (
    p_booking_id     IN Bookings.booking_id%TYPE DEFAULT NULL,
    p_passenger_id   IN Bookings.passenger_id%TYPE DEFAULT NULL,
    o_booking_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    -- Ensure at least one parameter is provided (logic handled in Flask)
    -- This query joins all necessary tables to get the required output
    OPEN o_booking_cursor FOR
        SELECT
            b.booking_id,
            p.passenger_id,
            p.first_name || ' ' || p.last_name AS passenger_name,
            f.flight_id,
            f.flight_number,
            dep_ap.name AS departure_location,
            arr_ap.name AS arrival_location,
            b.seat_number,
            b.booking_status
        FROM Bookings b
        JOIN Passengers p ON b.passenger_id = p.passenger_id
        JOIN Flights f ON b.flight_id = f.flight_id
        JOIN Airports dep_ap ON f.departure_airport_id = dep_ap.airport_id
        JOIN Airports arr_ap ON f.arrival_airport_id = arr_ap.airport_id
        WHERE
            (p_booking_id IS NULL OR b.booking_id = p_booking_id)
        AND
            (p_passenger_id IS NULL OR b.passenger_id = p_passenger_id)
        ORDER BY
            b.booking_id DESC; -- Or order by passenger name, flight, etc.

EXCEPTION
    WHEN OTHERS THEN
        -- Return an empty cursor on error
        OPEN o_booking_cursor FOR SELECT 1 FROM DUAL WHERE 1 = 0;
END;
/



-- Count Procedure Example (Combine multiple counts)
CREATE OR REPLACE PROCEDURE SP_GetDashboardCounts (
    o_passenger_count OUT NUMBER,
    o_flight_count    OUT NUMBER, -- Count of scheduled future flights
    o_booking_count   OUT NUMBER, -- Count of confirmed bookings
    o_aircraft_count  OUT NUMBER,
    o_crew_count      OUT NUMBER
)
IS
BEGIN
    SELECT COUNT(*) INTO o_passenger_count FROM Passengers;
    SELECT COUNT(*) INTO o_flight_count FROM Flights WHERE status = 'Scheduled' AND departure_time > SYSDATE;
    SELECT COUNT(*) INTO o_booking_count FROM Bookings WHERE booking_status = 'Confirmed';
    SELECT COUNT(*) INTO o_aircraft_count FROM Aircraft;
    SELECT COUNT(*) INTO o_crew_count FROM Crew;
EXCEPTION
    WHEN OTHERS THEN
        o_passenger_count := -1; -- Indicate error
        o_flight_count    := -1;
        o_booking_count   := -1;
        o_aircraft_count  := -1;
        o_crew_count      := -1;
END;
/

-- Flights Per Day (Example)
CREATE OR REPLACE PROCEDURE SP_GetFlightsPerDay (
    p_days_limit      IN NUMBER DEFAULT 30, -- How many days forward
    o_flight_data     OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN o_flight_data FOR
        SELECT TRUNC(departure_time) AS flight_date, COUNT(*) AS flight_count
        FROM Flights
        WHERE departure_time BETWEEN SYSDATE AND SYSDATE + p_days_limit
        GROUP BY TRUNC(departure_time)
        ORDER BY flight_date;
END;
/

-- Booking Status Distribution
CREATE OR REPLACE PROCEDURE SP_GetBookingStatusDist (
    o_status_data OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN o_status_data FOR
        SELECT booking_status, COUNT(*) as status_count
        FROM Bookings
        GROUP BY booking_status;
END;
/

-- Aircraft Model Distribution
CREATE OR REPLACE PROCEDURE SP_GetAircraftModelDist (
    o_model_data OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN o_model_data FOR
        SELECT model, COUNT(*) as model_count
        FROM Aircraft
        GROUP BY model
        ORDER BY model_count DESC;
END;
/
