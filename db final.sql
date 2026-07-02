--```````````````````````````````````drop the tables ```````````````````````````````````````````````````````
DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS rate_comment;
DROP TABLE IF EXISTS rating;
DROP TABLE IF EXISTS trip;
DROP TABLE IF EXISTS request;
DROP TABLE IF EXISTS wallet;
DROP TABLE IF EXISTS card;
DROP TABLE IF EXISTS payment_method;
DROP TABLE IF EXISTS drives;
DROP TABLE IF EXISTS vehicle;
DROP TABLE IF EXISTS driver;
DROP TABLE IF EXISTS rider;
DROP TABLE IF EXISTS person_phone;
DROP TABLE IF EXISTS model_type;
DROP TABLE IF EXISTS person;

--`````````````````````````````````````````drop etl`````````````````````````````````````````````````
DROP PROCEDURE IF EXISTS DW.run_full_etl;
DROP PROCEDURE IF EXISTS DW.etl_fact_trip;
DROP PROCEDURE IF EXISTS DW.etl_dim_location;
DROP PROCEDURE IF EXISTS DW.etl_dim_rating;
DROP PROCEDURE IF EXISTS DW.etl_dim_payment;
DROP PROCEDURE IF EXISTS DW.etl_dim_request;
DROP PROCEDURE IF EXISTS DW.etl_dim_vehicle;
DROP PROCEDURE IF EXISTS DW.etl_dim_driver;
DROP PROCEDURE IF EXISTS DW.etl_dim_rider;
DROP PROCEDURE IF EXISTS DW.etl_dim_date;
GO

--````````````````````````````````````````drop schema tables````````````````````````````````````````````````````````````````
IF OBJECT_ID('DW.fact_trip', 'U') IS NOT NULL DROP TABLE DW.fact_trip;

IF OBJECT_ID('DW.etl_log', 'U') IS NOT NULL DROP TABLE DW.etl_log;
IF EXISTS (SELECT * FROM sys.sequences WHERE object_id = OBJECT_ID('DW.LocationSeq'))
    DROP SEQUENCE DW.LocationSeq;

IF OBJECT_ID('DW.dim_location', 'U') IS NOT NULL DROP TABLE DW.dim_location;
IF OBJECT_ID('DW.dim_rating', 'U')   IS NOT NULL DROP TABLE DW.dim_rating;
IF OBJECT_ID('DW.dim_payment', 'U')  IS NOT NULL DROP TABLE DW.dim_payment;
IF OBJECT_ID('DW.dim_request', 'U')  IS NOT NULL DROP TABLE DW.dim_request;
IF OBJECT_ID('DW.dim_vehicle', 'U')  IS NOT NULL DROP TABLE DW.dim_vehicle;
IF OBJECT_ID('DW.dim_driver', 'U')   IS NOT NULL DROP TABLE DW.dim_driver;
IF OBJECT_ID('DW.dim_rider', 'U')    IS NOT NULL DROP TABLE DW.dim_rider;
IF OBJECT_ID('DW.dim_date', 'U')     IS NOT NULL DROP TABLE DW.dim_date;
GO

-- ````````````````````````````````````````````drop the schema``````````````````````````````````````````````

IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'DW')
BEGIN
    DROP SCHEMA DW;
END
GO

                                                     --DDL(eng:habiba hamdy)
													 --~~~~~~~~~~~~~~~~~~~~~

CREATE DATABASE RIDE_SYSTEM;
USE RIDE_SYSTEM;


-- Person
CREATE TABLE person (
    person_id   INT PRIMARY KEY,
    first_name  VARCHAR(50),
    last_name   VARCHAR(50),
    email       VARCHAR(100) UNIQUE,
    created_at  DATETIME,
    password    VARCHAR(255)
);

-- Person Phone
CREATE TABLE person_phone (
    person_id   INT,
    phone       VARCHAR(20),
    PRIMARY KEY (person_id, phone),
    FOREIGN KEY (person_id) REFERENCES person(person_id)
);

-- Rider
CREATE TABLE rider (
    rider_id            INT PRIMARY KEY,
    regestraion_date    DATE,
    FOREIGN KEY (rider_id) REFERENCES person(person_id)
);

-- Driver
CREATE TABLE driver (
    driver_id   INT PRIMARY KEY,
    license_no  VARCHAR(50),
    status      VARCHAR(20)
	CHECK(status IN('active','inactive')),
    longitude   DECIMAL(9,6),
    latitude    DECIMAL(9,6),
    FOREIGN KEY (driver_id) REFERENCES person(person_id)
);

-- Model Type
CREATE TABLE model_type (
    car_model   VARCHAR(50),
    car_type    VARCHAR(50),
    PRIMARY KEY (car_model)
);

-- Vehicle
CREATE TABLE vehicle (
    vehicle_id  INT PRIMARY KEY,
    driver_id   INT,
    car_model   VARCHAR(50),
    car_plate   VARCHAR(20),
    color       VARCHAR(30),
    year        INT,
    FOREIGN KEY (driver_id) REFERENCES driver(driver_id),
    FOREIGN KEY (car_model) REFERENCES model_type(car_model)
);

-- Drives
CREATE TABLE drives (
    driver_id   INT,
    vehicle_id  INT,
    PRIMARY KEY (driver_id, vehicle_id),
    FOREIGN KEY (driver_id) REFERENCES driver(driver_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicle(vehicle_id)
);

-- Request  
CREATE TABLE request (
    request_id          INT PRIMARY KEY,
    rider_id            INT NOT NULL,
    pick_up_location     VARCHAR(255),
    drop_off_location     VARCHAR(255),
    request_time        DATETIME,
    status              VARCHAR(20)
	CHECK (status IN('completed','cancelled','pending','in_progress')),
    vehicle_category    VARCHAR(50),
    fare                DECIMAL(10,2),      
    created_at          DATETIME,
    accepted_at         DATETIME,
    FOREIGN KEY (rider_id) REFERENCES rider(rider_id)
);

-- Trip
CREATE TABLE trip (
    trip_id     INT PRIMARY KEY,
    request_id  INT,
    driver_id   INT,
    vehicle_id  INT,
    start_time  DATETIME,
    end_time    DATETIME,
    status      VARCHAR(20)
    CHECK (status IN('completed','in_progress')),
    final_fare  DECIMAL(10,2),
    FOREIGN KEY (request_id) REFERENCES request(request_id),
    FOREIGN KEY (driver_id) REFERENCES driver(driver_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicle(vehicle_id)
);

-- Rating
CREATE TABLE rating (
    rate_id         INT PRIMARY KEY,
    trip_id         INT,
    driver_id       INT,
    rider_id        INT,
    rider_score     DECIMAL(3,1),
    driver_score    DECIMAL(3,1),
    rate_date       DATE,
    FOREIGN KEY (trip_id) REFERENCES trip(trip_id),
    FOREIGN KEY (driver_id) REFERENCES driver(driver_id),
    FOREIGN KEY (rider_id) REFERENCES rider(rider_id)
);

-- Rate Comment
CREATE TABLE rate_comment (
    rate_id     INT PRIMARY KEY,
    comment     TEXT,
    FOREIGN KEY (rate_id) REFERENCES rating(rate_id)
);

-- Payment Method
CREATE TABLE payment_method (
    method_id   INT PRIMARY KEY,
    type        VARCHAR(30)
);

-- Card
CREATE TABLE card (
    method_id   INT PRIMARY KEY,
    card_no     VARCHAR(20),
    card_type   VARCHAR(20),
    FOREIGN KEY (method_id) REFERENCES payment_method(method_id)
);

-- Wallet
CREATE TABLE wallet (
    method_id   INT PRIMARY KEY,
    wallet_id   VARCHAR(50),
    provider    VARCHAR(50),
    FOREIGN KEY (method_id) REFERENCES payment_method(method_id)
);

-- Payment
CREATE TABLE payment (
    payment_id  INT PRIMARY KEY,
    trip_id     INT NOT NULL,
    amount      DECIMAL(10,2),
    status      VARCHAR(20)
	CHECK (status IN('paid','faild','refunded')),
    paid_at     DATETIME,
    method_id   INT NOT NULL,
    FOREIGN KEY (trip_id) REFERENCES trip(trip_id),
    FOREIGN KEY (method_id) REFERENCES payment_method(method_id)
);
--                                        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--                                         DATA POPULATION (ENG:habiba yahia)
--                                        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ``````````````````````````````````````````` PERSON (50 rows)```````````````````````````````````````````
INSERT INTO person (person_id, first_name, last_name, email, created_at, password) VALUES
(1,  'Ahmed',    'Hassan',    'ahmed.hassan@email.com',    '2023-01-10 08:00:00', 'hashed_pw_1'),
(2,  'Mohamed',  'Ali',       'mohamed.ali@email.com',     '2023-01-12 09:15:00', 'hashed_pw_2'),
(3,  'Sara',     'Omar',      'sara.omar@email.com',       '2023-01-15 10:30:00', 'hashed_pw_3'),
(4,  'Fatima',   'Khalid',    'fatima.khalid@email.com',   '2023-01-18 11:00:00', 'hashed_pw_4'),
(5,  'Omar',     'Ibrahim',   'omar.ibrahim@email.com',    '2023-01-20 12:00:00', 'hashed_pw_5'),
(6,  'Nour',     'Mahmoud',   'nour.mahmoud@email.com',    '2023-01-22 08:30:00', 'hashed_pw_6'),
(7,  'Youssef',  'Salem',     'youssef.salem@email.com',   '2023-01-25 09:00:00', 'hashed_pw_7'),
(8,  'Layla',    'Mostafa',   'layla.mostafa@email.com',   '2023-01-28 10:00:00', 'hashed_pw_8'),
(9,  'Karim',    'Nasser',    'karim.nasser@email.com',    '2023-02-01 11:30:00', 'hashed_pw_9'),
(10, 'Hana',     'Adel',      'hana.adel@email.com',       '2023-02-03 08:45:00', 'hashed_pw_10'),
(11, 'Tarek',    'Fawzy',     'tarek.fawzy@email.com',     '2023-02-05 09:30:00', 'hashed_pw_11'),
(12, 'Dina',     'Samir',     'dina.samir@email.com',      '2023-02-08 10:15:00', 'hashed_pw_12'),
(13, 'Bassem',   'Ragab',     'bassem.ragab@email.com',    '2023-02-10 11:00:00', 'hashed_pw_13'),
(14, 'Rania',    'Hamdy',     'rania.hamdy@email.com',     '2023-02-12 12:30:00', 'hashed_pw_14'),
(15, 'Sherif',   'Lotfy',     'sherif.lotfy@email.com',    '2023-02-15 08:00:00', 'hashed_pw_15'),
(16, 'Mona',     'Gamal',     'mona.gamal@email.com',      '2023-02-18 09:15:00', 'hashed_pw_16'),
(17, 'Amr',      'Shawky',    'amr.shawky@email.com',      '2023-02-20 10:30:00', 'hashed_pw_17'),
(18, 'Ines',     'Taha',      'ines.taha@email.com',       '2023-02-22 11:45:00', 'hashed_pw_18'),
(19, 'Wael',     'Abdalla',   'wael.abdalla@email.com',    '2023-02-25 08:30:00', 'hashed_pw_19'),
(20, 'Salma',    'Barakat',   'salma.barakat@email.com',   '2023-02-28 09:00:00', 'hashed_pw_20'),
(21, 'Hassan',   'Zaki',      'hassan.zaki@email.com',     '2023-03-02 10:00:00', 'hashed_pw_21'),
(22, 'Nadia',    'Fouad',     'nadia.fouad@email.com',     '2023-03-05 11:15:00', 'hashed_pw_22'),
(23, 'Khaled',   'Mansour',   'khaled.mansour@email.com',  '2023-03-08 08:45:00', 'hashed_pw_23'),
(24, 'Aya',      'Sayed',     'aya.sayed@email.com',       '2023-03-10 09:30:00', 'hashed_pw_24'),
(25, 'Mahmoud',  'Bishara',   'mahmoud.bishara@email.com', '2023-03-12 10:15:00', 'hashed_pw_25'),
(26, 'Yasmin',   'Hafez',     'yasmin.hafez@email.com',    '2023-03-15 11:00:00', 'hashed_pw_26'),
(27, 'Tamer',    'Desouki',   'tamer.desouki@email.com',   '2023-03-18 12:00:00', 'hashed_pw_27'),
(28, 'Reem',     'Badawi',    'reem.badawi@email.com',     '2023-03-20 08:30:00', 'hashed_pw_28'),
(29, 'Hazem',    'Osman',     'hazem.osman@email.com',     '2023-03-22 09:15:00', 'hashed_pw_29'),
(30, 'Mariam',   'Saleh',     'mariam.saleh@email.com',    '2023-03-25 10:30:00', 'hashed_pw_30'),
-- Drivers start from person_id 31
(31, 'Samy',     'Wahba',     'samy.wahba@email.com',      '2023-01-05 08:00:00', 'hashed_pw_31'),
(32, 'Heba',     'Sobhy',     'heba.sobhy@email.com',      '2023-01-07 09:00:00', 'hashed_pw_32'),
(33, 'Adel',     'Gaber',     'adel.gaber@email.com',      '2023-01-09 10:00:00', 'hashed_pw_33'),
(34, 'Noha',     'Helmy',     'noha.helmy@email.com',      '2023-01-11 11:00:00', 'hashed_pw_34'),
(35, 'Fady',     'Eskander',  'fady.eskander@email.com',   '2023-01-13 12:00:00', 'hashed_pw_35'),
(36, 'Ramzy',    'Attia',     'ramzy.attia@email.com',     '2023-01-15 08:30:00', 'hashed_pw_36'),
(37, 'Samir',    'Ghoneim',   'samir.ghoneim@email.com',   '2023-01-17 09:30:00', 'hashed_pw_37'),
(38, 'Hossam',   'Fahmy',     'hossam.fahmy@email.com',    '2023-01-19 10:30:00', 'hashed_pw_38'),
(39, 'Ashraf',   'Morsy',     'ashraf.morsy@email.com',    '2023-01-21 11:30:00', 'hashed_pw_39'),
(40, 'Emad',     'Rizk',      'emad.rizk@email.com',       '2023-01-23 12:30:00', 'hashed_pw_40'),
(41, 'Walid',    'Aziz',      'walid.aziz@email.com',      '2023-01-25 08:00:00', 'hashed_pw_41'),
(42, 'Nabil',    'Kamel',     'nabil.kamel@email.com',     '2023-01-27 09:00:00', 'hashed_pw_42'),
(43, 'Ihab',     'Nassar',    'ihab.nassar@email.com',     '2023-01-29 10:00:00', 'hashed_pw_43'),
(44, 'Gamal',    'Farag',     'gamal.farag@email.com',     '2023-01-31 11:00:00', 'hashed_pw_44'),
(45, 'Magdy',    'Hanna',     'magdy.hanna@email.com',     '2023-02-02 12:00:00', 'hashed_pw_45'),
(46, 'Sherif',   'Qassem',    'sherif.qassem@email.com',   '2023-02-04 08:00:00', 'hashed_pw_46'),
(47, 'Alaa',     'Dabbour',   'alaa.dabbour@email.com',    '2023-02-06 09:00:00', 'hashed_pw_47'),
(48, 'Mostafa',  'Elewa',     'mostafa.elewa@email.com',   '2023-02-08 10:00:00', 'hashed_pw_48'),
(49, 'Ibrahim',  'Shahin',    'ibrahim.shahin@email.com',  '2023-02-10 11:00:00', 'hashed_pw_49'),
(50, 'Fawzy',    'Metwally',  'fawzy.metwally@email.com',  '2023-02-12 12:00:00', 'hashed_pw_50');


--```````````````````````````````````````````````` PERSON_PHONE (50 rows)````````````````````````````````````````````````
INSERT INTO person_phone (person_id, phone) VALUES
(1,  '01001234501'), (2,  '01001234502'), (3,  '01001234503'),
(4,  '01001234504'), (5,  '01001234505'), (6,  '01001234506'),
(7,  '01001234507'), (8,  '01001234508'), (9,  '01001234509'),
(10, '01001234510'), (11, '01001234511'), (12, '01001234512'),
(13, '01001234513'), (14, '01001234514'), (15, '01001234515'),
(16, '01001234516'), (17, '01001234517'), (18, '01001234518'),
(19, '01001234519'), (20, '01001234520'), (21, '01001234521'),
(22, '01001234522'), (23, '01001234523'), (24, '01001234524'),
(25, '01001234525'), (26, '01001234526'), (27, '01001234527'),
(28, '01001234528'), (29, '01001234529'), (30, '01001234530'),
(31, '01001234531'), (32, '01001234532'), (33, '01001234533'),
(34, '01001234534'), (35, '01001234535'), (36, '01001234536'),
(37, '01001234537'), (38, '01001234538'), (39, '01001234539'),
(40, '01001234540'), (41, '01001234541'), (42, '01001234542'),
(43, '01001234543'), (44, '01001234544'), (45, '01001234545'),
(46, '01001234546'), (47, '01001234547'), (48, '01001234548'),
(49, '01001234549'), (50, '01001234550');



--`````````````````````````````````````````` RIDER (30 rows)`````````````````````````````````````````````````````

INSERT INTO rider (rider_id, regestraion_date) VALUES
(1,  '2023-01-10'), (2,  '2023-01-12'), (3,  '2023-01-15'),
(4,  '2023-01-18'), (5,  '2023-01-20'), (6,  '2023-01-22'),
(7,  '2023-01-25'), (8,  '2023-01-28'), (9,  '2023-02-01'),
(10, '2023-02-03'), (11, '2023-02-05'), (12, '2023-02-08'),
(13, '2023-02-10'), (14, '2023-02-12'), (15, '2023-02-15'),
(16, '2023-02-18'), (17, '2023-02-20'), (18, '2023-02-22'),
(19, '2023-02-25'), (20, '2023-02-28'), (21, '2023-03-02'),
(22, '2023-03-05'), (23, '2023-03-08'), (24, '2023-03-10'),
(25, '2023-03-12'), (26, '2023-03-15'), (27, '2023-03-18'),
(28, '2023-03-20'), (29, '2023-03-22'), (30, '2023-03-25');


--````````````````````````````````````````` DRIVER (20 row)``````````````````````````````````````````````````
INSERT INTO driver (driver_id, license_no, status, longitude, latitude) VALUES
(31, 'LIC-31-2020', 'active',   31.2357, 30.0444),
(32, 'LIC-32-2019', 'active',   31.2401, 30.0612),
(33, 'LIC-33-2021', 'active',   31.2289, 30.0556),
(34, 'LIC-34-2018', 'active',   31.2500, 30.0700),
(35, 'LIC-35-2022', 'active',   31.2350, 30.0480),
(36, 'LIC-36-2020', 'active',   31.2275, 30.0390),
(37, 'LIC-37-2019', 'active',   31.2445, 30.0530),
(38, 'LIC-38-2021', 'active',   31.2310, 30.0620),
(39, 'LIC-39-2018', 'active',   31.2380, 30.0510),
(40, 'LIC-40-2022', 'active',   31.2420, 30.0460),
(41, 'LIC-41-2020', 'active',   31.2265, 30.0575),
(42, 'LIC-42-2019', 'active',   31.2495, 30.0415),
(43, 'LIC-43-2021', 'active',   31.2330, 30.0640),
(44, 'LIC-44-2018', 'active',   31.2385, 30.0490),
(45, 'LIC-45-2022', 'active',   31.2455, 30.0525),
(46, 'LIC-46-2020', 'inactive', 31.2360, 30.0470),
(47, 'LIC-47-2019', 'active',   31.2430, 30.0540),
(48, 'LIC-48-2021', 'active',   31.2295, 30.0590),
(49, 'LIC-49-2018', 'inactive', 31.2370, 30.0430),
(50, 'LIC-50-2022', 'active',   31.2410, 30.0560);


--``````````````````````````````````````````````` MODEL_TYPE `````````````````````````````````````````````````````
INSERT INTO model_type (car_model, car_type) VALUES
('Toyota Corolla',    'Sedan'),
('Hyundai Elantra',   'Sedan'),
('Kia Sportage',      'SUV'),
('Nissan Sunny',      'Sedan'),
('Chevrolet Aveo',    'Hatchback'),
('Toyota Yaris',      'Hatchback'),
('Mitsubishi Lancer', 'Sedan'),
('Honda Civic',       'Sedan');


-- `````````````````````````````````````VEHICLE (20 rows – one per driver)```````````````````````````````````````````
INSERT INTO vehicle (vehicle_id, driver_id, car_model, car_plate, color, year) VALUES
(1,  31, 'Toyota Corolla',    'ABC-101', 'White',  2020),
(2,  32, 'Hyundai Elantra',   'DEF-202', 'Black',  2019),
(3,  33, 'Kia Sportage',      'GHI-303', 'Silver', 2021),
(4,  34, 'Nissan Sunny',      'JKL-404', 'Blue',   2018),
(5,  35, 'Chevrolet Aveo',    'MNO-505', 'Red',    2022),
(6,  36, 'Toyota Yaris',      'PQR-606', 'White',  2020),
(7,  37, 'Mitsubishi Lancer', 'STU-707', 'Grey',   2019),
(8,  38, 'Honda Civic',       'VWX-808', 'Black',  2021),
(9,  39, 'Toyota Corolla',    'YZA-909', 'White',  2018),
(10, 40, 'Hyundai Elantra',   'BCD-110', 'Silver', 2022),
(11, 41, 'Kia Sportage',      'EFG-211', 'Blue',   2020),
(12, 42, 'Nissan Sunny',      'HIJ-312', 'White',  2019),
(13, 43, 'Chevrolet Aveo',    'KLM-413', 'Red',    2021),
(14, 44, 'Toyota Yaris',      'NOP-514', 'Grey',   2018),
(15, 45, 'Honda Civic',       'QRS-615', 'Black',  2022),
(16, 46, 'Toyota Corolla',    'TUV-716', 'White',  2020),
(17, 47, 'Hyundai Elantra',   'WXY-817', 'Silver', 2019),
(18, 48, 'Kia Sportage',      'ZAB-918', 'Blue',   2021),
(19, 49, 'Mitsubishi Lancer', 'CDE-119', 'Grey',   2018),
(20, 50, 'Honda Civic',       'FGH-220', 'Black',  2022);


-- ``````````````````````````````````````````````DRIVES (20 rows)``````````````````````````````````````````````````````
INSERT INTO drives (driver_id, vehicle_id) VALUES
(31,1),(32,2),(33,3),(34,4),(35,5),
(36,6),(37,7),(38,8),(39,9),(40,10),
(41,11),(42,12),(43,13),(44,14),(45,15),
(46,16),(47,17),(48,18),(49,19),(50,20);


-- ```````````````````````````````````````````````PAYMENT_METHOD (20 rows)```````````````````````````````````````````````
INSERT INTO payment_method (method_id, type) VALUES
(1,  'card'),   (2,  'wallet'), (3,  'card'),
(4,  'wallet'), (5,  'card'),   (6,  'wallet'),
(7,  'card'),   (8,  'wallet'), (9,  'card'),
(10, 'wallet'), (11, 'card'),   (12, 'wallet'),
(13, 'card'),   (14, 'wallet'), (15, 'card'),
(16, 'wallet'), (17, 'card'),   (18, 'wallet'),
(19, 'card'),   (20, 'wallet');


-- ``````````````````````````````````````````````CARD (10 rows)````````````````````````````````````````````````
INSERT INTO card (method_id, card_no, card_type) VALUES
(1,  '4111111111111001', 'Visa'),
(3,  '5500000000000003', 'MasterCard'),
(5,  '4111111111110005', 'Visa'),
(7,  '5500000000000007', 'MasterCard'),
(9,  '4111111111110009', 'Visa'),
(11, '5500000000000011', 'MasterCard'),
(13, '4111111111110013', 'Visa'),
(15, '5500000000000015', 'MasterCard'),
(17, '4111111111110017', 'Visa'),
(19, '5500000000000019', 'MasterCard');


--```````````````````````````````````````` WALLET (10 rows)````````````````````````````````````````````````
INSERT INTO wallet (method_id, wallet_id, provider) VALUES
(2,  'WLT-002', 'Fawry'),
(4,  'WLT-004', 'Vodafone Cash'),
(6,  'WLT-006', 'Fawry'),
(8,  'WLT-008', 'Orange Money'),
(10, 'WLT-010', 'Vodafone Cash'),
(12, 'WLT-012', 'Fawry'),
(14, 'WLT-014', 'Orange Money'),
(16, 'WLT-016', 'Vodafone Cash'),
(18, 'WLT-018', 'Fawry'),
(20, 'WLT-020', 'Orange Money');


-- `````````````````````````````````````` REQUEST  (100 rows)`````````````````````````````````````````````````````````


INSERT INTO request (request_id, rider_id, pick_up_location, drop_off_location, request_time, status, vehicle_category, fare, created_at, accepted_at) VALUES
-- completed (1-60) 
(1,  1,  'Tahrir Square',   'Heliopolis',      '2023-05-01 08:00:00', 'completed',   'Sedan',     45.00, '2023-05-01 07:58:00', '2023-05-01 08:02:00'),
(2,  2,  'Maadi',           'Downtown Cairo',  '2023-05-01 09:00:00', 'completed',   'Sedan',     38.50, '2023-05-01 08:58:00', '2023-05-01 09:03:00'),
(3,  3,  'Nasr City',       'Giza',            '2023-05-02 10:00:00', 'completed',   'SUV',       75.00, '2023-05-02 09:57:00', '2023-05-02 10:04:00'),
(4,  4,  'Zamalek',         '6th of October',  '2023-05-02 11:00:00', 'completed',   'Sedan',     90.00, '2023-05-02 10:58:00', '2023-05-02 11:05:00'),
(5,  5,  'Dokki',           'New Cairo',       '2023-05-03 08:30:00', 'completed',   'Sedan',     60.00, '2023-05-03 08:28:00', '2023-05-03 08:33:00'),
(6,  6,  'Shubra',          'Maadi',           '2023-05-03 09:30:00', 'completed',   'Hatchback', 35.00, '2023-05-03 09:28:00', '2023-05-03 09:34:00'),
(7,  7,  'Ain Shams',       'Zamalek',         '2023-05-04 10:30:00', 'completed',   'Sedan',     50.00, '2023-05-04 10:28:00', '2023-05-04 10:33:00'),
(8,  8,  'Helwan',          'Nasr City',       '2023-05-04 11:30:00', 'completed',   'Sedan',     55.00, '2023-05-04 11:28:00', '2023-05-04 11:32:00'),
(9,  9,  'New Cairo',       'Tahrir Square',   '2023-05-05 08:00:00', 'completed',   'SUV',       80.00, '2023-05-05 07:58:00', '2023-05-05 08:04:00'),
(10, 10, 'Mohandessin',     'Heliopolis',      '2023-05-05 09:00:00', 'completed',   'Sedan',     42.00, '2023-05-05 08:58:00', '2023-05-05 09:03:00'),
(11, 11, 'Heliopolis',      'Dokki',           '2023-05-06 10:00:00', 'completed',   'Sedan',     48.00, '2023-05-06 09:58:00', '2023-05-06 10:02:00'),
(12, 12, 'Downtown Cairo',  'Shubra',          '2023-05-06 11:00:00', 'completed',   'Hatchback', 30.00, '2023-05-06 10:58:00', '2023-05-06 11:04:00'),
(13, 13, 'Giza',            'Ain Shams',       '2023-05-07 08:30:00', 'completed',   'Sedan',     65.00, '2023-05-07 08:28:00', '2023-05-07 08:35:00'),
(14, 14, '6th of October',  'Mohandessin',     '2023-05-07 09:30:00', 'completed',   'SUV',       70.00, '2023-05-07 09:28:00', '2023-05-07 09:33:00'),
(15, 15, 'New Cairo',       'Maadi',           '2023-05-08 10:30:00', 'completed',   'Sedan',     40.00, '2023-05-08 10:28:00', '2023-05-08 10:33:00'),
(16, 16, 'Tahrir Square',   'New Cairo',       '2023-05-08 11:30:00', 'completed',   'Sedan',     62.00, '2023-05-08 11:28:00', '2023-05-08 11:35:00'),
(17, 17, 'Zamalek',         'Nasr City',       '2023-05-09 08:00:00', 'completed',   'Sedan',     47.00, '2023-05-09 07:58:00', '2023-05-09 08:03:00'),
(18, 18, 'Heliopolis',      '6th of October',  '2023-05-09 09:00:00', 'completed',   'SUV',       95.00, '2023-05-09 08:58:00', '2023-05-09 09:05:00'),
(19, 19, 'Maadi',           'Giza',            '2023-05-10 10:00:00', 'completed',   'Sedan',     52.00, '2023-05-10 09:58:00', '2023-05-10 10:04:00'),
(20, 20, 'Dokki',           'Shubra',          '2023-05-10 11:00:00', 'completed',   'Hatchback', 28.00, '2023-05-10 10:58:00', '2023-05-10 11:02:00'),
(21, 21, 'Shubra',          'Helwan',          '2023-05-11 08:00:00', 'completed',   'Sedan',     44.00, '2023-05-11 07:58:00', '2023-05-11 08:03:00'),
(22, 22, 'Nasr City',       'Mohandessin',     '2023-05-11 09:00:00', 'completed',   'Sedan',     57.00, '2023-05-11 08:58:00', '2023-05-11 09:04:00'),
(23, 23, 'Heliopolis',      'Maadi',           '2023-05-12 10:00:00', 'completed',   'Hatchback', 33.00, '2023-05-12 09:57:00', '2023-05-12 10:03:00'),
(24, 24, 'Giza',            'New Cairo',       '2023-05-12 11:00:00', 'completed',   'SUV',       88.00, '2023-05-12 10:58:00', '2023-05-12 11:06:00'),
(25, 25, '6th of October',  'Tahrir Square',   '2023-05-13 08:30:00', 'completed',   'Sedan',     73.00, '2023-05-13 08:28:00', '2023-05-13 08:34:00'),
(26, 26, 'Mohandessin',     'Ain Shams',       '2023-05-13 09:30:00', 'completed',   'Sedan',     54.00, '2023-05-13 09:28:00', '2023-05-13 09:34:00'),
(27, 27, 'Zamalek',         'Helwan',          '2023-05-14 10:30:00', 'completed',   'Sedan',     49.00, '2023-05-14 10:28:00', '2023-05-14 10:33:00'),
(28, 28, 'Maadi',           'Nasr City',       '2023-05-14 11:30:00', 'completed',   'Sedan',     58.00, '2023-05-14 11:28:00', '2023-05-14 11:35:00'),
(29, 29, 'Downtown Cairo',  'Zamalek',         '2023-05-15 08:00:00', 'completed',   'Sedan',     36.00, '2023-05-15 07:58:00', '2023-05-15 08:03:00'),
(30, 30, 'Shubra',          'Giza',            '2023-05-15 09:00:00', 'completed',   'Hatchback', 42.00, '2023-05-15 08:57:00', '2023-05-15 09:04:00'),
(31, 1,  'Helwan',          'Mohandessin',     '2023-05-16 10:00:00', 'completed',   'Sedan',     66.00, '2023-05-16 09:58:00', '2023-05-16 10:04:00'),
(32, 2,  'Ain Shams',       'Downtown Cairo',  '2023-05-16 11:00:00', 'completed',   'Sedan',     39.00, '2023-05-16 10:58:00', '2023-05-16 11:03:00'),
(33, 3,  'New Cairo',       '6th of October',  '2023-05-17 08:30:00', 'completed',   'SUV',       91.00, '2023-05-17 08:28:00', '2023-05-17 08:36:00'),
(34, 4,  'Nasr City',       'Heliopolis',      '2023-05-17 09:30:00', 'completed',   'Sedan',     31.00, '2023-05-17 09:28:00', '2023-05-17 09:33:00'),
(35, 5,  'Giza',            'Shubra',          '2023-05-18 10:30:00', 'completed',   'Hatchback', 37.00, '2023-05-18 10:28:00', '2023-05-18 10:34:00'),
(36, 6,  'Zamalek',         'Maadi',           '2023-05-18 11:30:00', 'completed',   'Sedan',     46.00, '2023-05-18 11:28:00', '2023-05-18 11:34:00'),
(37, 7,  'Mohandessin',     'New Cairo',       '2023-05-19 08:00:00', 'completed',   'Sedan',     69.00, '2023-05-19 07:58:00', '2023-05-19 08:05:00'),
(38, 8,  '6th of October',  'Ain Shams',       '2023-05-19 09:00:00', 'completed',   'SUV',       84.00, '2023-05-19 08:58:00', '2023-05-19 09:06:00'),
(39, 9,  'Helwan',          'Tahrir Square',   '2023-05-20 10:00:00', 'completed',   'Sedan',     53.00, '2023-05-20 09:57:00', '2023-05-20 10:04:00'),
(40, 10, 'Downtown Cairo',  'Nasr City',       '2023-05-20 11:00:00', 'completed',   'Sedan',     41.00, '2023-05-20 10:58:00', '2023-05-20 11:03:00'),
(41, 11, 'Maadi',           'Helwan',          '2023-05-21 08:00:00', 'completed',   'Sedan',     50.00, '2023-05-21 07:58:00', '2023-05-21 08:03:00'),
(42, 12, 'Shubra',          'Zamalek',         '2023-05-21 09:00:00', 'completed',   'Sedan',     43.00, '2023-05-21 08:57:00', '2023-05-21 09:04:00'),
(43, 13, 'Heliopolis',      'Giza',            '2023-05-22 10:00:00', 'completed',   'SUV',       77.00, '2023-05-22 09:58:00', '2023-05-22 10:05:00'),
(44, 14, 'Nasr City',       'Mohandessin',     '2023-05-22 11:00:00', 'completed',   'Sedan',     56.00, '2023-05-22 10:58:00', '2023-05-22 11:04:00'),
(45, 15, 'Giza',            'Heliopolis',      '2023-05-23 08:30:00', 'completed',   'Sedan',     62.00, '2023-05-23 08:28:00', '2023-05-23 08:34:00'),
(46, 16, 'New Cairo',       'Shubra',          '2023-05-23 09:30:00', 'completed',   'Hatchback', 34.00, '2023-05-23 09:28:00', '2023-05-23 09:34:00'),
(47, 17, 'Tahrir Square',   'Ain Shams',       '2023-05-24 10:30:00', 'completed',   'Sedan',     48.00, '2023-05-24 10:28:00', '2023-05-24 10:33:00'),
(48, 18, '6th of October',  'Downtown Cairo',  '2023-05-24 11:30:00', 'completed',   'Sedan',     87.00, '2023-05-24 11:28:00', '2023-05-24 11:36:00'),
(49, 19, 'Mohandessin',     'Helwan',          '2023-05-25 08:00:00', 'completed',   'Sedan',     55.00, '2023-05-25 07:58:00', '2023-05-25 08:04:00'),
(50, 20, 'Zamalek',         'New Cairo',       '2023-05-25 09:00:00', 'completed',   'Sedan',     71.00, '2023-05-25 08:57:00', '2023-05-25 09:05:00'),
(51, 21, 'Ain Shams',       'Maadi',           '2023-05-26 10:00:00', 'completed',   'Sedan',     59.00, '2023-05-26 09:58:00', '2023-05-26 10:04:00'),
(52, 22, 'Downtown Cairo',  'Heliopolis',      '2023-05-26 11:00:00', 'completed',   'Sedan',     35.00, '2023-05-26 10:58:00', '2023-05-26 11:03:00'),
(53, 23, 'Nasr City',       'Tahrir Square',   '2023-05-27 08:30:00', 'completed',   'Sedan',     40.00, '2023-05-27 08:28:00', '2023-05-27 08:33:00'),
(54, 24, 'Giza',            'Nasr City',       '2023-05-27 09:30:00', 'completed',   'SUV',       83.00, '2023-05-27 09:28:00', '2023-05-27 09:36:00'),
(55, 25, 'Helwan',          '6th of October',  '2023-05-28 10:30:00', 'completed',   'Sedan',     96.00, '2023-05-28 10:28:00', '2023-05-28 10:36:00'),
(56, 26, 'Shubra',          'Mohandessin',     '2023-05-28 11:30:00', 'completed',   'Hatchback', 32.00, '2023-05-28 11:28:00', '2023-05-28 11:34:00'),
(57, 27, 'Heliopolis',      'New Cairo',       '2023-05-29 08:00:00', 'completed',   'Sedan',     67.00, '2023-05-29 07:58:00', '2023-05-29 08:05:00'),
(58, 28, 'Zamalek',         'Giza',            '2023-05-29 09:00:00', 'completed',   'Sedan',     74.00, '2023-05-29 08:57:00', '2023-05-29 09:06:00'),
(59, 29, 'Maadi',           'Ain Shams',       '2023-05-30 10:00:00', 'completed',   'Sedan',     47.00, '2023-05-30 09:58:00', '2023-05-30 10:04:00'),
(60, 30, 'Mohandessin',     'Downtown Cairo',  '2023-05-30 11:00:00', 'completed',   'Sedan',     29.00, '2023-05-30 10:58:00', '2023-05-30 11:03:00'),
-- cancelled – driver never accepted (61-75) 
(61, 1,  'Tahrir Square',   'Helwan',          '2023-06-01 08:00:00', 'cancelled',   'Sedan',     44.00, '2023-06-01 07:58:00', NULL),
(62, 2,  'Maadi',           'Giza',            '2023-06-01 09:00:00', 'cancelled',   'SUV',       76.00, '2023-06-01 08:57:00', NULL),
(63, 3,  'Shubra',          'Mohandessin',     '2023-06-02 10:00:00', 'cancelled',   'Hatchback', 31.00, '2023-06-02 09:58:00', NULL),
(64, 4,  'Heliopolis',      'Ain Shams',       '2023-06-02 11:00:00', 'cancelled',   'Sedan',     49.00, '2023-06-02 10:58:00', NULL),
(65, 5,  'Nasr City',       'New Cairo',       '2023-06-03 08:30:00', 'cancelled',   'Sedan',     68.00, '2023-06-03 08:28:00', NULL),
(66, 6,  'New Cairo',       'Downtown Cairo',  '2023-06-03 09:30:00', 'cancelled',   'Sedan',     78.00, '2023-06-03 09:28:00', NULL),
(67, 7,  'Helwan',          'Zamalek',         '2023-06-04 10:30:00', 'cancelled',   'Sedan',     61.00, '2023-06-04 10:28:00', NULL),
(68, 8,  'Mohandessin',     'Nasr City',       '2023-06-04 11:30:00', 'cancelled',   'Sedan',     52.00, '2023-06-04 11:28:00', NULL),
(69, 9,  'Ain Shams',       'Maadi',           '2023-06-05 08:00:00', 'cancelled',   'Sedan',     37.00, '2023-06-05 07:58:00', NULL),
(70, 10, 'Downtown Cairo',  'Shubra',          '2023-06-05 09:00:00', 'cancelled',   'Hatchback', 28.00, '2023-06-05 08:57:00', NULL),
(71, 11, '6th of October',  'Tahrir Square',   '2023-06-06 10:00:00', 'cancelled',   'Sedan',     94.00, '2023-06-06 09:58:00', NULL),
(72, 12, 'Zamalek',         'New Cairo',       '2023-06-06 11:00:00', 'cancelled',   'Sedan',     72.00, '2023-06-06 10:58:00', NULL),
(73, 13, 'Heliopolis',      'Giza',            '2023-06-07 08:30:00', 'cancelled',   'SUV',       80.00, '2023-06-07 08:28:00', NULL),
(74, 14, 'Nasr City',       'Helwan',          '2023-06-07 09:30:00', 'cancelled',   'Sedan',     46.00, '2023-06-07 09:28:00', NULL),
(75, 15, 'Maadi',           'Mohandessin',     '2023-06-08 10:30:00', 'cancelled',   'Sedan',     40.00, '2023-06-08 10:28:00', NULL),
--  cancelled – rider cancelled AFTER driver accepted (76-85) 
(76, 16, 'Tahrir Square',   '6th of October',  '2023-06-08 11:30:00', 'cancelled',   'Sedan',     85.00, '2023-06-08 11:28:00', '2023-06-08 11:33:00'),
(77, 17, 'Shubra',          'Ain Shams',       '2023-06-09 08:00:00', 'cancelled',   'Sedan',     55.00, '2023-06-09 07:58:00', '2023-06-09 08:03:00'),
(78, 18, 'Giza',            'Heliopolis',      '2023-06-09 09:00:00', 'cancelled',   'SUV',       89.00, '2023-06-09 08:57:00', '2023-06-09 09:04:00'),
(79, 19, 'New Cairo',       'Shubra',          '2023-06-10 10:00:00', 'cancelled',   'Hatchback', 34.00, '2023-06-10 09:58:00', '2023-06-10 10:03:00'),
(80, 20, 'Helwan',          'Zamalek',         '2023-06-10 11:00:00', 'cancelled',   'Sedan',     60.00, '2023-06-10 10:58:00', '2023-06-10 11:02:00'),
(81, 21, 'Mohandessin',     'Helwan',          '2023-06-11 08:00:00', 'cancelled',   'Sedan',     58.00, '2023-06-11 07:58:00', '2023-06-11 08:04:00'),
(82, 22, 'Ain Shams',       'Giza',            '2023-06-11 09:00:00', 'cancelled',   'Sedan',     66.00, '2023-06-11 08:57:00', '2023-06-11 09:05:00'),
(83, 23, 'Nasr City',       'Heliopolis',      '2023-06-12 10:00:00', 'cancelled',   'Sedan',     82.00, '2023-06-12 09:58:00', '2023-06-12 10:04:00'),
(84, 24, 'Downtown Cairo',  'New Cairo',       '2023-06-12 11:00:00', 'cancelled',   'Sedan',     75.00, '2023-06-12 10:58:00', '2023-06-12 11:06:00'),
(85, 25, 'Zamalek',         'Ain Shams',       '2023-06-13 08:30:00', 'cancelled',   'Sedan',     51.00, '2023-06-13 08:28:00', '2023-06-13 08:34:00'),
--pending (86-95) 
(86, 26, 'Helwan',          'Zamalek',         '2023-06-13 09:30:00', 'pending',     'Sedan',     60.00, '2023-06-13 09:28:00', NULL),
(87, 27, 'Downtown Cairo',  'New Cairo',       '2023-06-14 10:30:00', 'pending',     'Sedan',     75.00, '2023-06-14 10:28:00', NULL),
(88, 28, 'Tahrir Square',   'Nasr City',       '2023-06-14 11:30:00', 'pending',     'SUV',       82.00, '2023-06-14 11:28:00', NULL),
(89, 29, '6th of October',  'Maadi',           '2023-06-15 08:00:00', 'pending',     'Sedan',     91.00, '2023-06-15 07:58:00', NULL),
(90, 30, 'Heliopolis',      'Downtown Cairo',  '2023-06-15 09:00:00', 'pending',     'Hatchback', 34.00, '2023-06-15 08:57:00', NULL),
(91, 1,  'Giza',            'Shubra',          '2023-06-16 10:00:00', 'pending',     'Sedan',     43.00, '2023-06-16 09:58:00', NULL),
(92, 2,  'Mohandessin',     'Helwan',          '2023-06-16 11:00:00', 'pending',     'Sedan',     58.00, '2023-06-16 10:58:00', NULL),
(93, 3,  'Ain Shams',       'Giza',            '2023-06-17 08:30:00', 'pending',     'Sedan',     66.00, '2023-06-17 08:28:00', NULL),
(94, 4,  'New Cairo',       'Heliopolis',      '2023-06-17 09:30:00', 'pending',     'SUV',       79.00, '2023-06-17 09:28:00', NULL),
(95, 5,  'Nasr City',       'Zamalek',         '2023-06-18 10:30:00', 'pending',     'Sedan',     53.00, '2023-06-18 10:28:00', NULL),
--in_progress (96-100) 
(96,  6,  'Maadi',          '6th of October',  '2023-06-18 11:00:00', 'in_progress', 'Sedan',     88.00, '2023-06-18 10:58:00', '2023-06-18 11:05:00'),
(97,  7,  'Shubra',         'Tahrir Square',   '2023-06-19 08:00:00', 'in_progress', 'Hatchback', 32.00, '2023-06-19 07:58:00', '2023-06-19 08:02:00'),
(98,  8,  'Helwan',         'Ain Shams',       '2023-06-19 09:00:00', 'in_progress', 'Sedan',     57.00, '2023-06-19 08:57:00', '2023-06-19 09:04:00'),
(99,  9,  'Zamalek',        'Mohandessin',     '2023-06-20 10:00:00', 'in_progress', 'Sedan',     45.00, '2023-06-20 09:58:00', '2023-06-20 10:03:00'),
(100,10,  'Nasr City',      'Downtown Cairo',  '2023-06-20 11:00:00', 'in_progress', 'Sedan',     38.00, '2023-06-20 10:58:00', '2023-06-20 11:02:00');


--````````````````````````````````````````TRIP  (65 rows)```````````````````````````````````````````````````````````


INSERT INTO trip (trip_id, request_id, driver_id, vehicle_id, start_time, end_time, status, final_fare) VALUES
-- completed trips (1-60)
(1,  1,  31, 1,  '2023-05-01 08:05:00', '2023-05-01 08:40:00', 'completed', 47.00),
(2,  2,  32, 2,  '2023-05-01 09:06:00', '2023-05-01 09:35:00', 'completed', 39.00),
(3,  3,  33, 3,  '2023-05-02 10:07:00', '2023-05-02 10:55:00', 'completed', 78.00),
(4,  4,  34, 4,  '2023-05-02 11:08:00', '2023-05-02 12:10:00', 'completed', 92.00),
(5,  5,  35, 5,  '2023-05-03 08:36:00', '2023-05-03 09:15:00', 'completed', 61.00),
(6,  6,  36, 6,  '2023-05-03 09:37:00', '2023-05-03 10:05:00', 'completed', 36.00),
(7,  7,  37, 7,  '2023-05-04 10:36:00', '2023-05-04 11:10:00', 'completed', 51.00),
(8,  8,  38, 8,  '2023-05-04 11:35:00', '2023-05-04 12:15:00', 'completed', 56.00),
(9,  9,  39, 9,  '2023-05-05 08:07:00', '2023-05-05 09:00:00', 'completed', 82.00),
(10, 10, 40, 10, '2023-05-05 09:06:00', '2023-05-05 09:45:00', 'completed', 43.00),
(11, 11, 41, 11, '2023-05-06 10:05:00', '2023-05-06 10:48:00', 'completed', 49.00),
(12, 12, 42, 12, '2023-05-06 11:07:00', '2023-05-06 11:35:00', 'completed', 31.00),
(13, 13, 43, 13, '2023-05-07 08:38:00', '2023-05-07 09:20:00', 'completed', 67.00),
(14, 14, 44, 14, '2023-05-07 09:36:00', '2023-05-07 10:20:00', 'completed', 72.00),
(15, 15, 45, 15, '2023-05-08 10:36:00', '2023-05-08 11:10:00', 'completed', 41.00),
(16, 16, 47, 17, '2023-05-08 11:38:00', '2023-05-08 12:25:00', 'completed', 64.00),
(17, 17, 48, 18, '2023-05-09 08:06:00', '2023-05-09 08:50:00', 'completed', 48.00),
(18, 18, 50, 20, '2023-05-09 09:08:00', '2023-05-09 10:15:00', 'completed', 97.00),
(19, 19, 31, 1,  '2023-05-10 10:07:00', '2023-05-10 10:55:00', 'completed', 53.00),
(20, 20, 32, 2,  '2023-05-10 11:05:00', '2023-05-10 11:40:00', 'completed', 29.00),
(21, 21, 33, 3,  '2023-05-11 08:06:00', '2023-05-11 08:50:00', 'completed', 45.00),
(22, 22, 34, 4,  '2023-05-11 09:07:00', '2023-05-11 09:55:00', 'completed', 58.00),
(23, 23, 35, 5,  '2023-05-12 10:06:00', '2023-05-12 10:40:00', 'completed', 34.00),
(24, 24, 36, 6,  '2023-05-12 11:09:00', '2023-05-12 12:05:00', 'completed', 89.00),
(25, 25, 37, 7,  '2023-05-13 08:37:00', '2023-05-13 09:25:00', 'completed', 74.00),
(26, 26, 38, 8,  '2023-05-13 09:37:00', '2023-05-13 10:20:00', 'completed', 55.00),
(27, 27, 39, 9,  '2023-05-14 10:36:00', '2023-05-14 11:15:00', 'completed', 50.00),
(28, 28, 40, 10, '2023-05-14 11:38:00', '2023-05-14 12:25:00', 'completed', 59.00),
(29, 29, 41, 11, '2023-05-15 08:06:00', '2023-05-15 08:45:00', 'completed', 37.00),
(30, 30, 42, 12, '2023-05-15 09:07:00', '2023-05-15 09:50:00', 'completed', 43.00),
(31, 31, 43, 13, '2023-05-16 10:07:00', '2023-05-16 10:55:00', 'completed', 67.00),
(32, 32, 44, 14, '2023-05-16 11:06:00', '2023-05-16 11:45:00', 'completed', 40.00),
(33, 33, 45, 15, '2023-05-17 08:39:00', '2023-05-17 09:35:00', 'completed', 93.00),
(34, 34, 47, 17, '2023-05-17 09:36:00', '2023-05-17 10:10:00', 'completed', 32.00),
(35, 35, 48, 18, '2023-05-18 10:37:00', '2023-05-18 11:15:00', 'completed', 38.00),
(36, 36, 50, 20, '2023-05-18 11:37:00', '2023-05-18 12:20:00', 'completed', 47.00),
(37, 37, 31, 1,  '2023-05-19 08:08:00', '2023-05-19 09:00:00', 'completed', 70.00),
(38, 38, 32, 2,  '2023-05-19 09:09:00', '2023-05-19 10:05:00', 'completed', 85.00),
(39, 39, 33, 3,  '2023-05-20 10:07:00', '2023-05-20 10:55:00', 'completed', 54.00),
(40, 40, 34, 4,  '2023-05-20 11:06:00', '2023-05-20 11:48:00', 'completed', 42.00),
(41, 41, 35, 5,  '2023-05-21 08:06:00', '2023-05-21 08:52:00', 'completed', 51.00),
(42, 42, 36, 6,  '2023-05-21 09:07:00', '2023-05-21 09:50:00', 'completed', 44.00),
(43, 43, 37, 7,  '2023-05-22 10:08:00', '2023-05-22 11:00:00', 'completed', 78.00),
(44, 44, 38, 8,  '2023-05-22 11:07:00', '2023-05-22 11:58:00', 'completed', 57.00),
(45, 45, 39, 9,  '2023-05-23 08:37:00', '2023-05-23 09:20:00', 'completed', 63.00),
(46, 46, 40, 10, '2023-05-23 09:37:00', '2023-05-23 10:12:00', 'completed', 35.00),
(47, 47, 41, 11, '2023-05-24 10:36:00', '2023-05-24 11:18:00', 'completed', 49.00),
(48, 48, 42, 12, '2023-05-24 11:39:00', '2023-05-24 12:35:00', 'completed', 88.00),
(49, 49, 43, 13, '2023-05-25 08:07:00', '2023-05-25 08:55:00', 'completed', 56.00),
(50, 50, 44, 14, '2023-05-25 09:08:00', '2023-05-25 10:00:00', 'completed', 72.00),
(51, 51, 45, 15, '2023-05-26 10:07:00', '2023-05-26 10:50:00', 'completed', 60.00),
(52, 52, 47, 17, '2023-05-26 11:06:00', '2023-05-26 11:42:00', 'completed', 36.00),
(53, 53, 48, 18, '2023-05-27 08:36:00', '2023-05-27 09:15:00', 'completed', 41.00),
(54, 54, 50, 20, '2023-05-27 09:39:00', '2023-05-27 10:35:00', 'completed', 84.00),
(55, 55, 31, 1,  '2023-05-28 10:39:00', '2023-05-28 11:45:00', 'completed', 97.00),
(56, 56, 32, 2,  '2023-05-28 11:37:00', '2023-05-28 12:15:00', 'completed', 33.00),
(57, 57, 33, 3,  '2023-05-29 08:08:00', '2023-05-29 08:58:00', 'completed', 68.00),
(58, 58, 34, 4,  '2023-05-29 09:09:00', '2023-05-29 10:05:00', 'completed', 75.00),
(59, 59, 35, 5,  '2023-05-30 10:07:00', '2023-05-30 10:52:00', 'completed', 48.00),
(60, 60, 36, 6,  '2023-05-30 11:06:00', '2023-05-30 11:40:00', 'completed', 30.00),
-- in_progress trips (61-65) – end_time and final_fare are NULL
(61, 96, 37, 7,  '2023-06-18 11:08:00', NULL, 'in_progress', NULL),
(62, 97, 38, 8,  '2023-06-19 08:05:00', NULL, 'in_progress', NULL),
(63, 98, 39, 9,  '2023-06-19 09:07:00', NULL, 'in_progress', NULL),
(64, 99, 40, 10, '2023-06-20 10:06:00', NULL, 'in_progress', NULL),
(65,100, 41, 11, '2023-06-20 11:05:00', NULL, 'in_progress', NULL);


-- ````````````````````````````````````````RATING  (60 rows)````````````````````````````````````````````````````

INSERT INTO rating (rate_id, trip_id, driver_id, rider_id, rider_score, driver_score, rate_date) VALUES
(1,  1,  31, 1,  4.5, 4.8, '2023-05-01'),
(2,  2,  32, 2,  4.0, 4.5, '2023-05-01'),
(3,  3,  33, 3,  5.0, 4.9, '2023-05-02'),
(4,  4,  34, 4,  3.5, 4.0, '2023-05-02'),
(5,  5,  35, 5,  4.8, 4.7, '2023-05-03'),
(6,  6,  36, 6,  4.2, 4.3, '2023-05-03'),
(7,  7,  37, 7,  4.6, 4.6, '2023-05-04'),
(8,  8,  38, 8,  4.3, 4.1, '2023-05-04'),
(9,  9,  39, 9,  4.9, 5.0, '2023-05-05'),
(10, 10, 40, 10, 4.1, 4.4, '2023-05-05'),
(11, 11, 41, 11, 4.7, 4.8, '2023-05-06'),
(12, 12, 42, 12, 4.3, 4.2, '2023-05-06'),
(13, 13, 43, 13, 5.0, 4.9, '2023-05-07'),
(14, 14, 44, 14, 4.7, 4.9, '2023-05-07'),
(15, 15, 45, 15, 4.4, 4.6, '2023-05-08'),
(16, 16, 47, 16, 4.8, 4.7, '2023-05-08'),
(17, 17, 48, 17, 4.5, 4.5, '2023-05-09'),
(18, 18, 50, 18, 4.0, 4.3, '2023-05-09'),
(19, 19, 31, 19, 4.6, 4.8, '2023-05-10'),
(20, 20, 32, 20, 4.2, 4.4, '2023-05-10'),
(21, 21, 33, 21, 4.8, 4.7, '2023-05-11'),
(22, 22, 34, 22, 4.1, 4.5, '2023-05-11'),
(23, 23, 35, 23, 4.5, 4.6, '2023-05-12'),
(24, 24, 36, 24, 3.8, 4.2, '2023-05-12'),
(25, 25, 37, 25, 4.9, 5.0, '2023-05-13'),
(26, 26, 38, 26, 4.3, 4.4, '2023-05-13'),
(27, 27, 39, 27, 4.6, 4.7, '2023-05-14'),
(28, 28, 40, 28, 4.4, 4.5, '2023-05-14'),
(29, 29, 41, 29, 4.7, 4.8, '2023-05-15'),
(30, 30, 42, 30, 4.2, 4.3, '2023-05-15'),
(31, 31, 43, 1,  4.9, 4.9, '2023-05-16'),
(32, 32, 44, 2,  4.0, 4.1, '2023-05-16'),
(33, 33, 45, 3,  5.0, 5.0, '2023-05-17'),
(34, 34, 47, 4,  3.7, 4.0, '2023-05-17'),
(35, 35, 48, 5,  4.5, 4.6, '2023-05-18'),
(36, 36, 50, 6,  4.3, 4.4, '2023-05-18'),
(37, 37, 31, 7,  4.8, 4.9, '2023-05-19'),
(38, 38, 32, 8,  4.1, 4.2, '2023-05-19'),
(39, 39, 33, 9,  4.6, 4.7, '2023-05-20'),
(40, 40, 34, 10, 4.4, 4.5, '2023-05-20'),
(41, 41, 35, 11, 4.7, 4.8, '2023-05-21'),
(42, 42, 36, 12, 4.2, 4.3, '2023-05-21'),
(43, 43, 37, 13, 5.0, 4.9, '2023-05-22'),
(44, 44, 38, 14, 4.5, 4.6, '2023-05-22'),
(45, 45, 39, 15, 4.8, 4.7, '2023-05-23'),
(46, 46, 40, 16, 4.3, 4.4, '2023-05-23'),
(47, 47, 41, 17, 4.6, 4.5, '2023-05-24'),
(48, 48, 42, 18, 3.9, 4.2, '2023-05-24'),
(49, 49, 43, 19, 4.7, 4.8, '2023-05-25'),
(50, 50, 44, 20, 4.4, 4.6, '2023-05-25'),
(51, 51, 45, 21, 4.9, 5.0, '2023-05-26'),
(52, 52, 47, 22, 4.1, 4.3, '2023-05-26'),
(53, 53, 48, 23, 4.5, 4.7, '2023-05-27'),
(54, 54, 50, 24, 4.8, 4.9, '2023-05-27'),
(55, 55, 31, 25, 4.3, 4.4, '2023-05-28'),
(56, 56, 32, 26, 4.6, 4.5, '2023-05-28'),
(57, 57, 33, 27, 4.2, 4.3, '2023-05-29'),
(58, 58, 34, 28, 4.7, 4.8, '2023-05-29'),
(59, 59, 35, 29, 5.0, 4.9, '2023-05-30'),
(60, 60, 36, 30, 4.4, 4.5, '2023-05-30');


-- ```````````````````````````````````````````RATE_COMMENT `````````````````````````````````````````````````````````
INSERT INTO rate_comment (rate_id, comment) VALUES
(1,  'Great driver, very polite!'),
(2,  'Good ride, clean car.'),
(3,  'Excellent service, highly recommended.'),
(5,  'Very smooth and fast trip.'),
(7,  'Comfortable ride, on time.'),
(9,  'Best driver I ever had!'),
(11, 'Professional and friendly.'),
(13, 'Perfect trip, will use again.'),
(15, 'Quick pickup, nice driver.'),
(17, 'Clean car and safe driving.'),
(19, 'Very punctual and polite.'),
(22, 'Smooth ride, no complaints.'),
(25, 'Exceptional service!'),
(28, 'Pleasant journey, good music.'),
(31, 'Very professional driver.'),
(37, 'Arrived on time, friendly chat.'),
(43, 'Super clean car, great driver.'),
(51, 'One of the best rides so far.'),
(55, 'Fantastic experience overall.'),
(59, 'Would definitely book again.');


-- `````````````````````````````````````PAYMENT  (60 rows)``````````````````````````````````````````````````````````````

INSERT INTO payment (payment_id, trip_id, amount, status, paid_at, method_id) VALUES
(1,  1,  47.00, 'paid', '2023-05-01 08:41:00', 1),
(2,  2,  39.00, 'paid', '2023-05-01 09:36:00', 2),
(3,  3,  78.00, 'paid', '2023-05-02 10:56:00', 3),
(4,  4,  92.00, 'paid', '2023-05-02 12:11:00', 4),
(5,  5,  61.00, 'paid', '2023-05-03 09:16:00', 5),
(6,  6,  36.00, 'paid', '2023-05-03 10:06:00', 6),
(7,  7,  51.00, 'paid', '2023-05-04 11:11:00', 7),
(8,  8,  56.00, 'paid', '2023-05-04 12:16:00', 8),
(9,  9,  82.00, 'paid', '2023-05-05 09:01:00', 9),
(10, 10, 43.00, 'paid', '2023-05-05 09:46:00', 10),
(11, 11, 49.00, 'paid', '2023-05-06 10:49:00', 11),
(12, 12, 31.00, 'paid', '2023-05-06 11:36:00', 12),
(13, 13, 67.00, 'paid', '2023-05-07 09:21:00', 13),
(14, 14, 72.00, 'paid', '2023-05-07 10:21:00', 14),
(15, 15, 41.00, 'paid', '2023-05-08 11:11:00', 15),
(16, 16, 64.00, 'paid', '2023-05-08 12:26:00', 16),
(17, 17, 48.00, 'paid', '2023-05-09 08:51:00', 17),
(18, 18, 97.00, 'paid', '2023-05-09 10:16:00', 18),
(19, 19, 53.00, 'paid', '2023-05-10 10:56:00', 19),
(20, 20, 29.00, 'paid', '2023-05-10 11:41:00', 20),
(21, 21, 45.00, 'paid', '2023-05-11 08:51:00', 1),
(22, 22, 58.00, 'paid', '2023-05-11 09:56:00', 2),
(23, 23, 34.00, 'paid', '2023-05-12 10:41:00', 3),
(24, 24, 89.00, 'paid', '2023-05-12 12:06:00', 4),
(25, 25, 74.00, 'paid', '2023-05-13 09:26:00', 5),
(26, 26, 55.00, 'paid', '2023-05-13 10:21:00', 6),
(27, 27, 50.00, 'paid', '2023-05-14 11:16:00', 7),
(28, 28, 59.00, 'paid', '2023-05-14 12:26:00', 8),
(29, 29, 37.00, 'paid', '2023-05-15 08:46:00', 9),
(30, 30, 43.00, 'paid', '2023-05-15 09:51:00', 10),
(31, 31, 67.00, 'paid', '2023-05-16 10:56:00', 11),
(32, 32, 40.00, 'paid', '2023-05-16 11:46:00', 12),
(33, 33, 93.00, 'paid', '2023-05-17 09:36:00', 13),
(34, 34, 32.00, 'paid', '2023-05-17 10:11:00', 14),
(35, 35, 38.00, 'paid', '2023-05-18 11:16:00', 15),
(36, 36, 47.00, 'paid', '2023-05-18 12:21:00', 16),
(37, 37, 70.00, 'paid', '2023-05-19 09:01:00', 17),
(38, 38, 85.00, 'paid', '2023-05-19 10:06:00', 18),
(39, 39, 54.00, 'paid', '2023-05-20 10:56:00', 19),
(40, 40, 42.00, 'paid', '2023-05-20 11:49:00', 20),
(41, 41, 51.00, 'paid', '2023-05-21 08:53:00', 1),
(42, 42, 44.00, 'paid', '2023-05-21 09:51:00', 2),
(43, 43, 78.00, 'paid', '2023-05-22 11:01:00', 3),
(44, 44, 57.00, 'paid', '2023-05-22 11:59:00', 4),
(45, 45, 63.00, 'paid', '2023-05-23 09:21:00', 5),
(46, 46, 35.00, 'paid', '2023-05-23 10:13:00', 6),
(47, 47, 49.00, 'paid', '2023-05-24 11:19:00', 7),
(48, 48, 88.00, 'paid', '2023-05-24 12:36:00', 8),
(49, 49, 56.00, 'paid', '2023-05-25 08:56:00', 9),
(50, 50, 72.00, 'paid', '2023-05-25 10:01:00', 10),
(51, 51, 60.00, 'paid', '2023-05-26 10:51:00', 11),
(52, 52, 36.00, 'paid', '2023-05-26 11:43:00', 12),
(53, 53, 41.00, 'paid', '2023-05-27 09:16:00', 13),
(54, 54, 84.00, 'paid', '2023-05-27 10:36:00', 14),
(55, 55, 97.00, 'paid', '2023-05-28 11:46:00', 15),
(56, 56, 33.00, 'paid', '2023-05-28 12:16:00', 16),
(57, 57, 68.00, 'paid', '2023-05-29 08:59:00', 17),
(58, 58, 75.00, 'paid', '2023-05-29 10:06:00', 18),
(59, 59, 48.00, 'paid', '2023-05-30 10:53:00', 19),
(60, 60, 30.00, 'paid', '2023-05-30 11:41:00', 20);


-- lets check the tables:
SELECT * FROM person;
SELECT * FROM person_phone;
SELECT * FROM rider;
SELECT * FROM driver;
SELECT * FROM vehicle;
SELECT * FROM drives;
SELECT * FROM model_type;
SELECT * FROM request;
SELECT * FROM trip;
SELECT * FROM rating;
SELECT * FROM rate_comment;
SELECT * FROM payment_method;
SELECT * FROM card;
SELECT * FROM wallet;
SELECT * FROM payment;
                                             --BASIC QUERIES(eng:mostafa Al_husseiny)
											 --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- ``````````````````````````````Q1: List all riders with their name and registration date``````````````````````````````
SELECT
    p.person_id,
    p.first_name + ' ' + p.last_name   AS full_name,
    r.regestraion_date
FROM rider r
JOIN person p ON r.rider_id = p.person_id;


-- ``````````````````````Q2: List all active drivers with their license number and vehicle info`````````````````````````````````````
SELECT
    p.first_name + ' ' + p.last_name   AS driver_name,
    d.license_no,
    v.car_model,
    v.car_plate,
    v.color,
    v.year
FROM driver d
JOIN person  p ON d.driver_id  = p.person_id
JOIN vehicle v ON v.driver_id  = d.driver_id
WHERE d.status = 'active';


-- ``````````````````````````Q3: All completed trips with rider name, driver name, fare and duration in minutes`````````````````````````````````
SELECT
    t.trip_id,
    rp.first_name + ' ' + rp.last_name   AS rider_name,
    dp.first_name + ' ' + dp.last_name   AS driver_name,
    t.final_fare,
    DATEDIFF(MINUTE, t.start_time, t.end_time)  AS duration_minutes
FROM trip t
JOIN request req ON t.request_id  = req.request_id
JOIN rider   ri  ON req.rider_id  = ri.rider_id
JOIN person  rp  ON ri.rider_id   = rp.person_id
JOIN driver  dr  ON t.driver_id   = dr.driver_id
JOIN person  dp  ON dr.driver_id  = dp.person_id
WHERE t.status = 'completed';


-- `````````````````````````````````````````Q4: Count of requests per status``````````````````````````````````````````````````
SELECT
    status,
    COUNT(*) AS total_requests
FROM request
GROUP BY status;


-- ```````````````````````````````````Q5: Top 5 highest-earning drivers (by total final fare)````````````````````````````````
SELECT TOP 5
    p.first_name + ' ' + p.last_name   AS driver_name,
    SUM(t.final_fare)                   AS total_earned
FROM trip    t
JOIN driver  d ON t.driver_id  = d.driver_id
JOIN person  p ON d.driver_id  = p.person_id
WHERE t.status = 'completed'
GROUP BY p.person_id, p.first_name, p.last_name
ORDER BY total_earned DESC;


-- ```````````````````````````````Q6: Riders who have never cancelled a request````````````````````````````````
SELECT
    p.person_id,
    p.first_name + ' ' + p.last_name   AS full_name
FROM rider  r
JOIN person p ON r.rider_id = p.person_id
WHERE r.rider_id NOT IN (
    SELECT rider_id FROM request WHERE status = 'cancelled'
);


--`````````````````````````````````` Q7: Average driver score per driver (from ratings)`````````````````````````````````
SELECT
    p.first_name + ' ' + p.last_name   AS driver_name,
    ROUND(AVG(ra.driver_score), 2)      AS avg_driver_score,
    COUNT(ra.rate_id)                   AS total_ratings
FROM rating  ra
JOIN driver  d  ON ra.driver_id = d.driver_id
JOIN person  p  ON d.driver_id  = p.person_id
GROUP BY p.person_id, p.first_name, p.last_name
ORDER BY avg_driver_score DESC;


-- ``````````````````````````````````````Q8: Payment breakdown by method type`````````````````````````````````````````
SELECT
    pm.type                             AS payment_type,
    COUNT(pay.payment_id)               AS total_transactions,
    SUM(pay.amount)                     AS total_amount,
    ROUND(AVG(pay.amount), 2)           AS avg_amount
FROM payment        pay
JOIN payment_method pm  ON pay.method_id = pm.method_id
WHERE pay.status = 'paid'
GROUP BY pm.type;



--                                        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--                                         STORED PROCEDURE&TRANSACTIONS(eng:mostafa Al_husseiny)
--                                         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--Book Ride 
--This stored procedure represents a transaction for booking a ride. 
--It validates that the rider exists,
--generates a new request ID, 
--then inserts a new pending request
GO
 create or ALTER PROCEDURE sp_BookRide
    @rider_id           INT,
    @pick_up_location   VARCHAR(255),
    @drop_off_location  VARCHAR(255),
    @vehicle_category   VARCHAR(50),
    @fare               DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM rider WHERE rider_id = @rider_id)
        BEGIN
            RAISERROR('Rider ID does not exist.', 16, 1);
        END

        DECLARE @new_request_id INT;

        SELECT @new_request_id = ISNULL(MAX(request_id), 0) + 1
        FROM request;

        INSERT INTO request (
            request_id,
            rider_id,
            pick_up_location,
            drop_off_location,
            request_time,
            status,
            vehicle_category,
            fare,
            created_at,
            accepted_at
        )
        VALUES (
            @new_request_id,
            @rider_id,
            @pick_up_location,
            @drop_off_location,
            GETDATE(),
            'pending',
            @vehicle_category,
            @fare,
            GETDATE(),
            NULL
        );

        COMMIT TRANSACTION;

        SELECT 'Ride booked successfully' AS message,
               @new_request_id AS request_id;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        SELECT ERROR_MESSAGE() AS error_message;
    END CATCH
END;
GO



SELECT TOP 5 
    request_id, rider_id, pick_up_location, drop_off_location, status, fare, created_at
FROM request
ORDER BY request_id DESC;
--------------------------
EXEC sp_BookRide
    @rider_id = 1,
    @pick_up_location = 'Alexandria Station',
    @drop_off_location = 'Stanley',
    @vehicle_category = 'Sedan',
    @fare = 120.00;
	
--                                        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--                                         STORED PROCEDURE&TRANSACTIONS(eng:habiba samy)
--                                         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--``````````````````````````````````````````````````Transaction 2: Accept Ride Request`````````````````````````````````
CREATE OR ALTER PROCEDURE sp_AcceptRide
    @request_id INT,
    @driver_id INT,
    @vehicle_id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check request exists and is still pending
        IF NOT EXISTS (
            SELECT 1 
            FROM request WITH (UPDLOCK, HOLDLOCK)
            WHERE request_id = @request_id
              AND status = 'pending'
        )
        BEGIN
            RAISERROR('Request does not exist or is not pending.', 16, 1);
        END

        -- Check driver exists
        IF NOT EXISTS (
            SELECT 1 
            FROM driver
            WHERE driver_id = @driver_id
			AND status = 'active'
        )
        BEGIN
		    RAISERROR('Driver does not exist or is not active.', 16, 1);

        END
		-- Check vehicle exists in company vehicles
IF NOT EXISTS (
    SELECT 1
    FROM vehicle
    WHERE vehicle_id = @vehicle_id
)
BEGIN
    RAISERROR('Vehicle does not exist.', 16, 1);
END
        IF EXISTS (
    SELECT 1
    FROM trip WITH (UPDLOCK, HOLDLOCK)
    WHERE vehicle_id = @vehicle_id
      AND status IN ('accepted', 'in_progress')
)
BEGIN
    RAISERROR('Vehicle is already assigned to another active trip.', 16, 1);
END

        DECLARE @new_trip_id INT;

        SELECT @new_trip_id = ISNULL(MAX(trip_id), 0) + 1
        FROM trip;

        UPDATE request
        SET status = 'accepted',
            accepted_at = GETDATE()
        WHERE request_id = @request_id;

        INSERT INTO trip (
            trip_id,
            request_id,
            driver_id,
            vehicle_id,
            start_time,
            end_time,
            status,
            final_fare
        )
        VALUES (
            @new_trip_id,
            @request_id,
            @driver_id,
            @vehicle_id,
            NULL,
            NULL,
            'accepted',
            NULL
        );
		UPDATE driver
        SET status = 'inactive'
        WHERE driver_id = @driver_id;

        COMMIT TRANSACTION;

        SELECT 'Ride accepted successfully' AS message,
               @new_trip_id AS trip_id;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        SELECT ERROR_MESSAGE() AS error_message;
    END CATCH
END;
GO
------------------
EXEC sp_AcceptRide
    @request_id = 105,    @driver_id = 42,
    @vehicle_id = 1;



SELECT request_id, rider_id, status, accepted_at
FROM request
WHERE request_id = 105;

SELECT TOP 5 trip_id, request_id, driver_id, vehicle_id, status
FROM trip
ORDER BY trip_id DESC;
----------------Transaction 3: Start Trip-------------------------------------------------------------
CREATE or alter  PROCEDURE sp_StartTrip
    @trip_id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1
            FROM trip
            WHERE trip_id = @trip_id
              AND status = 'accepted'
        )
        BEGIN
            RAISERROR('Trip does not exist or is not accepted.', 16, 1);
        END

        UPDATE trip
        SET status = 'in_progress',
            start_time = GETDATE()
        WHERE trip_id = @trip_id;

        UPDATE request
        SET status = 'in_progress'
        WHERE request_id = (
            SELECT request_id 
            FROM trip 
            WHERE trip_id = @trip_id
        );

        COMMIT TRANSACTION;

        SELECT 'Trip started successfully' AS message;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        SELECT ERROR_MESSAGE() AS error_message;
    END CATCH
END;
GO

---------------------


EXEC sp_StartTrip @trip_id = 69;

SELECT trip_id, request_id, status, start_time
FROM trip
WHERE trip_id = 69;

SELECT r.request_id, r.status
FROM request r
JOIN trip t ON r.request_id = t.request_id
WHERE t.trip_id = 69;


----------------Transaction 4: Complete Trip + Payment----------------------------------------------------------------------------------------------
CREATE or alter PROCEDURE sp_CompleteTrip
    @trip_id INT,
    @final_fare DECIMAL(10,2),
    @method_id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1
            FROM trip
            WHERE trip_id = @trip_id
              AND status = 'in_progress'
        )
        BEGIN
            RAISERROR('Trip does not exist or is not in progress.', 16, 1);
        END

        IF NOT EXISTS (
            SELECT 1
            FROM payment_method
            WHERE method_id = @method_id
        )
        BEGIN
            RAISERROR('Payment method does not exist.', 16, 1);
        END

        DECLARE @new_payment_id INT;

        SELECT @new_payment_id = ISNULL(MAX(payment_id), 0) + 1
        FROM payment;

        UPDATE trip
        SET status = 'completed',
            end_time = GETDATE(),
            final_fare = @final_fare
        WHERE trip_id = @trip_id;
		UPDATE driver
        SET status = 'active'
           WHERE driver_id = (
           SELECT driver_id
          FROM trip
          WHERE trip_id = @trip_id);

        UPDATE request
        SET status = 'completed'
        WHERE request_id = (
            SELECT request_id
            FROM trip
            WHERE trip_id = @trip_id
        );

        INSERT INTO payment (
            payment_id,
            trip_id,
            amount,
            status,
            paid_at,
            method_id
        )
        VALUES (
            @new_payment_id,
            @trip_id,
            @final_fare,
            'paid',
            GETDATE(),
            @method_id
        );

        COMMIT TRANSACTION;

        SELECT 'Trip completed and payment recorded successfully' AS message,
               @new_payment_id AS payment_id;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        SELECT ERROR_MESSAGE() AS error_message;
    END CATCH
END;
GO

----------------------------
EXEC sp_CompleteTrip
    @trip_id = 66,
    @final_fare = 150.00,
    @method_id = 1;

SELECT trip_id, request_id, status, end_time, final_fare
FROM trip
WHERE trip_id = 66;

SELECT r.request_id, r.status
FROM request r
JOIN trip t ON r.request_id = t.request_id
WHERE t.trip_id = 66;

SELECT payment_id, trip_id, amount, status, paid_at, method_id
FROM payment
WHERE trip_id = 66;





--````````````````````````````````````````````````Transaction 5: Cancel Request``````````````````````````````````````````````````````````
CREATE  or alter PROCEDURE sp_CancelRequest
    @request_id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1
            FROM request
            WHERE request_id = @request_id
              AND status IN ('pending', 'accepted')
        )
        BEGIN
            RAISERROR('Request cannot be cancelled.', 16, 1);
        END

        UPDATE request
        SET status = 'cancelled'
        WHERE request_id = @request_id;

        UPDATE trip
        SET status = 'cancelled',
            end_time = GETDATE()
        WHERE request_id = @request_id
          AND status = 'accepted';


		  
UPDATE d
SET d.status = 'active'
FROM driver d
JOIN trip t ON d.driver_id = t.driver_id
WHERE t.request_id = @request_id
  AND t.status = 'cancelled'; 

		 

        COMMIT TRANSACTION;

        SELECT 'Request cancelled successfully' AS message;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        SELECT ERROR_MESSAGE() AS error_message;
    END CATCH
END;
GO



--------------------------



EXEC sp_CancelRequest @request_id = 105;

SELECT request_id, status
FROM request
WHERE request_id = 105;

SELECT trip_id, request_id, status, end_time
FROM trip
WHERE request_id = 105;


--```````````````````````````````Concurrency Scenario: Two drivers try to accept same request````````````````````````````````````````````````
--In Session 1, I updated a ride request and kept the transaction open using WAITFOR DELAY.
--In Session 2, I tried to update the same request at the same time.
--SQL Server blocked Session 2 because Session 1 was holding an exclusive lock on the row.
--This prevents two drivers from accepting the same ride request at the same tim
EXEC sp_BookRide
    @rider_id = 1,
    @pick_up_location = 'Alexandria Station',
    @drop_off_location = 'Stanley',
    @vehicle_category = 'Sedan',
    @fare = 120.00;
SELECT request_id, status, accepted_at
FROM request
WHERE request_id = 109;
--`````````````````````````````````````````````Part A: Demonstrate Transaction Rollback```````````````````````````````````````````````````````


SELECT request_id, status
FROM request
WHERE request_id = 101;


BEGIN TRANSACTION;
UPDATE request
SET status = 'cancelled'
WHERE request_id = 101;

SELECT request_id, status
FROM request
WHERE request_id = 101;

ROLLBACK TRANSACTION;

SELECT request_id, status
FROM request
WHERE request_id = 101;
-------started a transaction and updated the request status to cancelled.
---Before committing, I used ROLLBACK.
--SQL Server undid the update and restored the old value.
--This shows the Atomicity property of transaction

--``````````````````````````````````````````````Part B: Simulate Failure`````````````````````````````````````````````````````
--1. Before failure
SELECT request_id, status
FROM request
WHERE request_id = 101;





--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ During transaction before closing session~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
GO

BEGIN TRANSACTION;

UPDATE request
SET status = 'cancelled'
WHERE request_id = 101;

SELECT request_id, status
FROM request
WHERE request_id = 101;

-- Do not COMMIT
-- Do not ROLLBACK

-----------

SELECT request_id, status, accepted_at
FROM request
WHERE request_id = 101;
-----To simulate a system failure, I started a transaction and updated the request status.
------Then I closed the session before executing COMMIT.
------Since the transaction was not committed, SQL Server treated it as an incomplete transaction.
-------During recovery, SQL Server used the transaction log to undo the uncommitted changes.
------As a result, the database returned to its previous consistent state.

                                            --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                                            -- WINDOW FUNCTIONS(eng:mostafa Al_husseiny)
											--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--``````````````````````````````` ROW_NUMBER — Rank each driver's trips by fare (highest first)``````````````````````````````````
SELECT
    p.first_name + ' ' + p.last_name           AS driver_name,
    t.trip_id,
    t.final_fare,
    ROW_NUMBER() OVER (
        PARTITION BY t.driver_id
        ORDER BY t.final_fare DESC
    )                                           AS trip_rank_by_fare
FROM trip   t
JOIN driver d ON t.driver_id = d.driver_id
JOIN person p ON d.driver_id = p.person_id
WHERE t.status = 'completed';


-- ``````````````````````````RANK — Rank drivers overall by total trips completed```````````````````````````````````
SELECT
    driver_name,
    total_trips,
    RANK() OVER (ORDER BY total_trips DESC)     AS overall_rank
FROM (
    SELECT
        p.first_name + ' ' + p.last_name        AS driver_name,
        COUNT(t.trip_id)                         AS total_trips
    FROM trip   t
    JOIN driver d ON t.driver_id = d.driver_id
    JOIN person p ON d.driver_id = p.person_id
    WHERE t.status = 'completed'
    GROUP BY p.person_id, p.first_name, p.last_name
) driver_totals;



-- ````````````````````````````SUM OVER — Running total of daily revenue```````````````````````````````````````````
SELECT
    CAST(t.end_time AS DATE)                        AS trip_date,
    t.trip_id,
    t.final_fare,
    SUM(t.final_fare) OVER (
        ORDER BY t.end_time
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                               AS running_total_revenue
FROM trip t
WHERE t.status = 'completed'
ORDER BY t.end_time;


-- ````````````````````LAG — Compare each driver's current trip fare to their previous trip fare````````````````````````````````
SELECT
    p.first_name + ' ' + p.last_name               AS driver_name,
    t.trip_id,
    t.start_time,
    t.final_fare,
    LAG(t.final_fare) OVER (
        PARTITION BY t.driver_id
        ORDER BY t.start_time
    )                                               AS prev_trip_fare,
    t.final_fare - LAG(t.final_fare) OVER (
        PARTITION BY t.driver_id
        ORDER BY t.start_time
    )                                               AS fare_difference
FROM trip   t
JOIN driver d ON t.driver_id = d.driver_id
JOIN person p ON d.driver_id = p.person_id
WHERE t.status = 'completed';
--                                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                                   --INDEXING (eng:bassem tarek)
								   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   --````````````````````````````````1. INDEXES ON FOREIGN KEYS```````````````````````````````````````
-- trip → request
CREATE NONCLUSTERED INDEX idx_trip_request
ON trip(request_id);

-- trip → driver
CREATE NONCLUSTERED INDEX idx_trip_driver
ON trip(driver_id);

-- trip → vehicle
CREATE NONCLUSTERED INDEX idx_trip_vehicle
ON trip(vehicle_id);

-- request → rider
CREATE NONCLUSTERED INDEX idx_request_rider
ON request(rider_id);

-- payment → trip
CREATE NONCLUSTERED INDEX idx_payment_trip
ON payment(trip_id);

-- rating → trip
CREATE NONCLUSTERED INDEX idx_rating_trip          
ON rating(trip_id);

-- rating → driver
CREATE NONCLUSTERED INDEX idx_rating_driver        
ON rating(driver_id);


   --```````````````````````````````2. INDEXES ON FILTERING COLUMNS````````````````````````````````

CREATE NONCLUSTERED INDEX idx_trip_status
ON trip(status);

CREATE NONCLUSTERED INDEX idx_request_status
ON request(status);

CREATE NONCLUSTERED INDEX idx_payment_status
ON payment(status);

CREATE NONCLUSTERED INDEX idx_driver_status
ON driver(status);

-- payment → paid_at  
CREATE NONCLUSTERED INDEX idx_payment_paid_at      
ON payment(paid_at);


  --```````````````````````````````````` 3. COMPOSITE INDEXES`````````````````````````````````

-- rider + status  (Rider Behaviour Query)
CREATE NONCLUSTERED INDEX idx_request_rider_status
ON request(rider_id, status);

-- status + trip_id  (Completed Trips Query)
CREATE NONCLUSTERED INDEX idx_trip_status_id
ON trip(status, trip_id);

-- trip + method  (Payment Lookup)
CREATE NONCLUSTERED INDEX idx_payment_trip_method
ON payment(trip_id, method_id);

-- driver + status  (Driver Performance Query)
CREATE NONCLUSTERED INDEX idx_trip_driver_status   
ON trip(driver_id, status);


                                       --4. OPTIMIZED QUERIES(eng: bassem tarek)
									   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- ````````````````````````Optimized Query 1: Completed Trips with Rider Name & Payment`````````````````````````````
CREATE NONCLUSTERED INDEX idx_trip_status_cover
ON trip(status)
INCLUDE (trip_id, request_id, start_time, end_time);  

GO

SELECT
    t.trip_id,
    p.first_name,
    p.last_name,
    pay.amount
FROM       trip     t    WITH (NOLOCK)
JOIN       payment  pay  WITH (NOLOCK)  ON pay.trip_id    = t.trip_id
JOIN       request  r    WITH (NOLOCK)  ON r.request_id   = t.request_id
JOIN       rider    rd   WITH (NOLOCK)  ON rd.rider_id    = r.rider_id
JOIN       person   p    WITH (NOLOCK)  ON p.person_id    = rd.rider_id
WHERE t.status = 'completed';

GO



--``````````````````````````` Optimized Query 2: Driver Performance (Trips Count + Avg Rating)````````````````````````````````
SELECT
    d.driver_id,
    COUNT(t.trip_id)         AS total_trips,
    ROUND(AVG(rt.driver_score), 2) AS avg_rating
FROM       driver  d
LEFT JOIN  trip    t   ON t.driver_id = d.driver_id
                      AND t.status    = 'completed'   
LEFT JOIN  rating  rt  ON rt.trip_id  = t.trip_id
GROUP BY   d.driver_id;

GO


--```````````````````````````````````` Optimized Query 3: Total Revenue per Day````````````````````````````
SELECT
    CAST(paid_at AS DATE)    AS payment_date,
    SUM(amount)              AS total_revenue
FROM payment
WHERE status = 'paid'
GROUP BY CAST(paid_at AS DATE)
ORDER BY payment_date;        

GO

--`````````````````````````````````````` Optimized Query 4: Most Active Riders````````````````````````````````
SELECT
    r.rider_id,
    COUNT(req.request_id)   AS total_requests
FROM       rider   r
JOIN       request req ON req.rider_id = r.rider_id
GROUP BY   r.rider_id
ORDER BY   total_requests DESC;

GO


   --``````````````````````````````````` USING EXPLAIN FOR ANALYSIS```````````````````````````````````````````
SET SHOWPLAN_TEXT ON;
GO

SELECT t.trip_id, pay.amount
FROM   trip    t
JOIN   payment pay ON pay.trip_id = t.trip_id
WHERE  t.status = 'completed';

GO
SET SHOWPLAN_TEXT OFF;
GO

   --``````````````````````````````````````VIEW FOR FREQUENT QUERY````````````````````````````````````````````
CREATE OR ALTER VIEW completed_trips_summary AS
SELECT
    t.trip_id,
    p.first_name,
    p.last_name,
    pay.amount,
    t.start_time,
    t.end_time
FROM       trip     t
JOIN       payment  pay ON pay.trip_id   = t.trip_id
JOIN       request  r   ON r.request_id  = t.request_id
JOIN       rider    rd  ON rd.rider_id   = r.rider_id
JOIN       person   p   ON p.person_id   = rd.rider_id
WHERE t.status = 'completed';

GO

-- View
SELECT * FROM completed_trips_summary;
GO



--                                          QUERY TUNING (eng:bassem tarek)
--                                          ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--  1. UPDATE STATISTICS

UPDATE STATISTICS trip;
UPDATE STATISTICS request;
UPDATE STATISTICS payment;
UPDATE STATISTICS rating;
UPDATE STATISTICS driver;
UPDATE STATISTICS rider;
GO


--  2. SARGable Conditions
--before
SELECT * FROM payment
WHERE CAST(paid_at AS DATE) = '2023-05-01';
--after
SELECT * FROM payment
WHERE paid_at >= '2023-05-01'
  AND paid_at  < '2023-05-02';

GO
--before
SELECT * FROM trip
WHERE YEAR(start_time) = 2023;
--after
SELECT * FROM trip
WHERE start_time >= '2023-05-01'
  AND start_time  < '2024-05-01';

GO


--  remove select

-- before
SELECT * FROM completed_trips_summary;

-- after
SELECT
    trip_id,
    first_name,
    last_name,
    amount
FROM completed_trips_summary;

GO

-- using nested CTE insteadof subqueries

-- before
SELECT driver_id, total_trips
FROM (
    SELECT driver_id, COUNT(trip_id) AS total_trips
    FROM trip
    WHERE status = 'completed'
    GROUP BY driver_id
) AS sub
WHERE total_trips > 1;

GO

-- after
WITH driver_trips AS (
    SELECT
        driver_id,
        COUNT(trip_id) AS total_trips
    FROM trip
    WHERE status = 'completed'
    GROUP BY driver_id
)
SELECT driver_id, total_trips
FROM   driver_trips
WHERE  total_trips > 1
ORDER BY total_trips DESC;

GO


--  5. using EXISTS instead of IN

-- before
SELECT rider_id FROM rider
WHERE rider_id IN (
    SELECT rider_id FROM request
    WHERE status = 'completed'
);

GO

-- after
SELECT rider_id FROM rider r
WHERE EXISTS (
    SELECT 1 FROM request req
    WHERE  req.rider_id = r.rider_id
      AND  req.status   = 'completed'
);

GO


--  6. using INNER JOIN for WHERE  filtering

-- before
SELECT t.trip_id, p.amount
FROM trip t, payment p
WHERE t.trip_id = p.trip_id
  AND t.status  = 'completed';

GO

-- after
SELECT t.trip_id, p.amount
FROM  trip    t
JOIN  payment p ON p.trip_id = t.trip_id
WHERE t.status = 'completed';

GO


--  7. avoid DISTINCT when not necessary 

-- before
SELECT DISTINCT rider_id
FROM request
WHERE status = 'completed';

GO

-- after
SELECT rider_id
FROM request
WHERE status = 'completed'
GROUP BY rider_id;

GO


--  8. Execution Plan Analysis (before & after tuning)

SET SHOWPLAN_TEXT ON;
GO

-- before
SELECT * FROM trip
WHERE YEAR(start_time) = 2024;

GO
SET SHOWPLAN_TEXT OFF;
GO

SET SHOWPLAN_TEXT ON;
GO

-- after
SELECT trip_id, driver_id, status, final_fare
FROM trip
WHERE start_time >= '2023-05-01'
  AND start_time  < '2024-05-01';

GO
SET SHOWPLAN_TEXT OFF;
GO





                                      --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                                      --Star Schema (Data Warehouse) (eng:habiba yahia)
                                      --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
GO
CREATE SCHEMA DW;
GO


--DIMENSION TABLES:

-- `````````````````````````````````````````DIM_DATE`````````````````````````````````````````````
CREATE TABLE DW.dim_date (
    date_id         INT PRIMARY KEY,
    full_date       DATE,
    year            INT,
    quarter         INT,
    month           INT,
    month_name      VARCHAR(20),
    day             INT,
    day_of_week     VARCHAR(20)
);

-- ```````````````````````````````````````````DIM_RIDER```````````````````````````````````````````````````
CREATE TABLE DW.dim_rider (
    rider_id            INT PRIMARY KEY,
    first_name          VARCHAR(50),
    last_name           VARCHAR(50),
    email               VARCHAR(100),
    phone               VARCHAR(20),
    registration_date   DATE
);

-- ````````````````````````````````````````````DIM_DRIVER``````````````````````````````````````````````````` 
CREATE TABLE DW.dim_driver (
    driver_id       INT PRIMARY KEY,
    first_name      VARCHAR(50),
    last_name       VARCHAR(50),
    email           VARCHAR(100),
    phone           VARCHAR(20),
    license_no      VARCHAR(50),
    status          VARCHAR(20)
);

-- `````````````````````````````````````````````DIM_VEHICLE``````````````````````````````````````````````
CREATE TABLE DW.dim_vehicle (
    vehicle_id      INT PRIMARY KEY,
    driver_id       INT,
    car_model       VARCHAR(50),
    car_type        VARCHAR(50),
    car_plate       VARCHAR(20),
    color           VARCHAR(30),
    year            INT
);

-- `````````````````````````````````````````````DIM_REQUEST```````````````````````````````````````````````
CREATE TABLE DW.dim_request (
    request_id          INT PRIMARY KEY,
    pick_up_location    VARCHAR(255),
    drop_off_location   VARCHAR(255),
    vehicle_category    VARCHAR(50),
    status              VARCHAR(20)
);

--``````````````````````````````````````````````DIM_PAYMENT ``````````````````````````````````````````
CREATE TABLE DW.dim_payment (
    payment_id      INT PRIMARY KEY,
    method_type     VARCHAR(30),
    card_no         VARCHAR(20),
    card_type       VARCHAR(20),
    wallet_id       VARCHAR(50),
    wallet_provider VARCHAR(50),
    status          VARCHAR(20)
);

-- ```````````````````````````````````````````````DIM_RATING `````````````````````````````````````````````````
CREATE TABLE DW.dim_rating (
    rate_id         INT PRIMARY KEY,
    rider_score     DECIMAL(3,1),
    driver_score    DECIMAL(3,1),
    comment         TEXT
);

-- ````````````````````````````````````````````````DIM_LOCATION```````````````````````````````````````````````````
CREATE TABLE DW.dim_location (
    location_id     INT PRIMARY KEY,
    area            VARCHAR(100)
);

--`````````````````````````````````````````````````FACT TABLE```````````````````````````````````````````````

CREATE TABLE DW.fact_trip (
    trip_id         INT PRIMARY KEY,
    date_id         INT,
    rider_id        INT,
    driver_id       INT,
    vehicle_id      INT,
    request_id      INT,
    payment_id      INT,
    rate_id         INT,
    location_id     INT,

-- ```````````````````````````````````````````````````Measures````````````````````````````````````````````````
    start_time      DATETIME,
    end_time        DATETIME,
    trip_status     VARCHAR(20),
    final_fare      DECIMAL(10,2),
    rider_score     DECIMAL(3,1),
    driver_score    DECIMAL(3,1),

--````````````````````````````````````````````` Foreign Key Constraints``````````````````````````````

    FOREIGN KEY (date_id)     REFERENCES DW.dim_date(date_id),
    FOREIGN KEY (rider_id)    REFERENCES DW.dim_rider(rider_id),
    FOREIGN KEY (driver_id)   REFERENCES DW.dim_driver(driver_id),
    FOREIGN KEY (vehicle_id)  REFERENCES DW.dim_vehicle(vehicle_id),
    FOREIGN KEY (request_id)  REFERENCES DW.dim_request(request_id),
    FOREIGN KEY (payment_id)  REFERENCES DW.dim_payment(payment_id),
    FOREIGN KEY (rate_id)     REFERENCES DW.dim_rating(rate_id),
    FOREIGN KEY (location_id) REFERENCES DW.dim_location(location_id)
);

                                     --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                                     --ETL:Incremental load(eng:habiba yahia):
									 --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--  ```````````````````````````````````````````````ETL LOG TABLE```````````````````````````````````````````````````

IF OBJECT_ID('DW.etl_log', 'U') IS NULL
BEGIN
    CREATE TABLE DW.etl_log (
        log_id          INT IDENTITY(1,1) PRIMARY KEY,
        table_name      VARCHAR(100),
        last_load_time  DATETIME,
        rows_inserted   INT DEFAULT 0,
        status          VARCHAR(20),
        run_at          DATETIME DEFAULT GETDATE()
    );
END
GO

--  `````````````````````````````````````````````1. ETL_DIM_DATE```````````````````````````````````````````

CREATE OR ALTER PROCEDURE DW.etl_dim_date
AS
BEGIN
    DECLARE @v_last_load DATETIME;
    DECLARE @v_inserted  INT;

    SELECT @v_last_load = COALESCE(MAX(last_load_time), '1900-01-01')
    FROM   DW.etl_log
    WHERE  table_name = 'dim_date' AND status = 'SUCCESS';

    INSERT INTO DW.dim_date (
        date_id, full_date, year, quarter, month, month_name, day, day_of_week
    )
    SELECT DISTINCT
        CAST(CONVERT(VARCHAR(8), d, 112) AS INT)  AS date_id,
        CAST(d AS DATE)                           AS full_date,
        YEAR(d)                                   AS year,
        DATEPART(QUARTER, d)                      AS quarter,
        MONTH(d)                                  AS month,
        DATENAME(MONTH, d)                        AS month_name,
        DAY(d)                                    AS day,
        DATENAME(WEEKDAY, d)                      AS day_of_week
    FROM (
        SELECT start_time AS d FROM Trip WHERE start_time > @v_last_load
        UNION
        SELECT end_time        FROM Trip WHERE end_time   > @v_last_load
    ) AS dates
    WHERE d IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM DW.dim_date
          WHERE date_id = CAST(CONVERT(VARCHAR(8), d, 112) AS INT)
      );

    SET @v_inserted = @@ROWCOUNT;

    INSERT INTO DW.etl_log (table_name, last_load_time, rows_inserted, status)
    VALUES ('dim_date', GETDATE(), @v_inserted, 'SUCCESS');
END
GO


-- ```````````````````````````````````````````` 2. ETL_DIM_RIDER``````````````````````````````````````````

CREATE OR ALTER PROCEDURE DW.etl_dim_rider
AS
BEGIN
    DECLARE @v_last_load DATETIME;
    DECLARE @v_inserted  INT;

    SELECT @v_last_load = COALESCE(MAX(last_load_time), '1900-01-01')
    FROM   DW.etl_log
    WHERE  table_name = 'dim_rider' AND status = 'SUCCESS';

    MERGE DW.dim_rider AS target
    USING (
        SELECT
            r.rider_id,
            p.first_name,
            p.last_name,
            p.email,
            pp.phone,
            r.regestraion_date
        FROM rider r
        JOIN  person       p  ON p.person_id  = r.rider_id
        LEFT JOIN person_phone pp ON pp.person_id = r.rider_id
        WHERE p.created_at > @v_last_load
    ) AS source
    ON (target.rider_id = source.rider_id)
    WHEN MATCHED THEN
        UPDATE SET
            target.first_name        = source.first_name,
            target.phone             = source.phone
    WHEN NOT MATCHED THEN
        INSERT (rider_id, first_name, last_name, email, phone, registration_date)
        VALUES (source.rider_id, source.first_name, source.last_name,
                source.email, source.phone, source.regestraion_date);

    SET @v_inserted = @@ROWCOUNT;

    INSERT INTO DW.etl_log (table_name, last_load_time, rows_inserted, status)
    VALUES ('dim_rider', GETDATE(), @v_inserted, 'SUCCESS');
END
GO


--  `````````````````````````````````````````````3. ETL_DIM_DRIVER```````````````````````````````````````````````````````

CREATE OR ALTER PROCEDURE DW.etl_dim_driver
AS
BEGIN
    DECLARE @v_last_load DATETIME;
    DECLARE @v_inserted  INT;

    SELECT @v_last_load = COALESCE(MAX(last_load_time), '1900-01-01')
    FROM   DW.etl_log
    WHERE  table_name = 'dim_driver' AND status = 'SUCCESS';

    MERGE DW.dim_driver AS target
    USING (
        SELECT
            d.driver_id,
            p.first_name,
            p.last_name,
            p.email,
            pp.phone,
            d.license_no,
            d.status
        FROM driver d
        JOIN  person       p  ON p.person_id  = d.driver_id
        LEFT JOIN person_phone pp ON pp.person_id = d.driver_id
        WHERE p.created_at > @v_last_load
    ) AS source
    ON (target.driver_id = source.driver_id)
    WHEN MATCHED THEN
        UPDATE SET
            target.status = source.status,
            target.phone  = source.phone
    WHEN NOT MATCHED THEN
        INSERT (driver_id, first_name, last_name, email, phone, license_no, status)
        VALUES (source.driver_id, source.first_name, source.last_name,
                source.email, source.phone, source.license_no, source.status);

    SET @v_inserted = @@ROWCOUNT;

    INSERT INTO DW.etl_log (table_name, last_load_time, rows_inserted, status)
    VALUES ('dim_driver', GETDATE(), @v_inserted, 'SUCCESS');
END
GO


-- ````````````````````````````````````````````` 4. ETL_DIM_VEHICLE``````````````````````````````````````````````

CREATE OR ALTER PROCEDURE DW.etl_dim_vehicle
AS
BEGIN
    DECLARE @v_last_load DATETIME;
    DECLARE @v_inserted  INT;

    SELECT @v_last_load = COALESCE(MAX(last_load_time), '1900-01-01')
    FROM   DW.etl_log
    WHERE  table_name = 'dim_vehicle' AND status = 'SUCCESS';

    INSERT INTO DW.dim_vehicle (
        vehicle_id, driver_id, car_model, car_type, car_plate, color, year
    )
    SELECT
        v.vehicle_id,
        v.driver_id,
        v.car_model,
        mt.car_type,
        v.car_plate,
        v.color,
        v.year
    FROM vehicle v
    JOIN model_type mt ON mt.car_model = v.car_model
    WHERE NOT EXISTS (
        SELECT 1 FROM DW.dim_vehicle dv
        WHERE dv.vehicle_id = v.vehicle_id
    );

    SET @v_inserted = @@ROWCOUNT;

    INSERT INTO DW.etl_log (table_name, last_load_time, rows_inserted, status)
    VALUES ('dim_vehicle', GETDATE(), @v_inserted, 'SUCCESS');
END
GO


-- ````````````````````````````````````````` 5. ETL_DIM_REQUEST```````````````````````````````````````

CREATE OR ALTER PROCEDURE DW.etl_dim_request
AS
BEGIN
    DECLARE @v_last_load DATETIME;
    DECLARE @v_inserted  INT;

    SELECT @v_last_load = COALESCE(MAX(last_load_time), '1900-01-01')
    FROM   DW.etl_log
    WHERE  table_name = 'dim_request' AND status = 'SUCCESS';

    MERGE DW.dim_request AS target
    USING (
        SELECT
            request_id,
            pick_up_location,
            drop_off_location,
            vehicle_category,
            status
        FROM Request
        WHERE created_at > @v_last_load
    ) AS source
    ON (target.request_id = source.request_id)
    WHEN MATCHED THEN
        UPDATE SET
            target.pick_up_location  = source.pick_up_location,
            target.drop_off_location = source.drop_off_location,
            target.status            = source.status
    WHEN NOT MATCHED THEN
        INSERT (request_id, pick_up_location, drop_off_location, vehicle_category, status)
        VALUES (source.request_id, source.pick_up_location, source.drop_off_location,
                source.vehicle_category, source.status);

    SET @v_inserted = @@ROWCOUNT;

    INSERT INTO DW.etl_log (table_name, last_load_time, rows_inserted, status)
    VALUES ('dim_request', GETDATE(), @v_inserted, 'SUCCESS');
END
GO


--  `````````````````````````````````````````````6:ETL_DIM_PAYMENT````````````````````````````````````````````

CREATE OR ALTER PROCEDURE DW.etl_dim_payment
AS
BEGIN
    DECLARE @v_last_load DATETIME;
    DECLARE @v_inserted  INT;

    SELECT @v_last_load = COALESCE(MAX(last_load_time), '1900-01-01')
    FROM   DW.etl_log
    WHERE  table_name = 'dim_payment' AND status = 'SUCCESS';

    MERGE DW.dim_payment AS target
    USING (
        SELECT
            pay.payment_id,
            pm.type    AS method_type,
            c.card_no,
            c.card_type,
            w.wallet_id,
            w.provider AS wallet_provider,
            pay.status
        FROM payment pay
        JOIN  payment_method pm ON pm.method_id = pay.method_id
        LEFT JOIN card   c ON c.method_id = pay.method_id
        LEFT JOIN wallet w ON w.method_id = pay.method_id
        WHERE pay.paid_at > @v_last_load
           OR (pay.paid_at IS NULL
               AND pay.payment_id NOT IN (SELECT payment_id FROM DW.dim_payment))
    ) AS source
    ON (target.payment_id = source.payment_id)
    WHEN MATCHED THEN
        UPDATE SET
            target.status = source.status
    WHEN NOT MATCHED THEN
        INSERT (payment_id, method_type, card_no, card_type, wallet_id, wallet_provider, status)
        VALUES (source.payment_id, source.method_type, source.card_no, source.card_type,
                source.wallet_id, source.wallet_provider, source.status);

    SET @v_inserted = @@ROWCOUNT;

    INSERT INTO DW.etl_log (table_name, last_load_time, rows_inserted, status)
    VALUES ('dim_payment', GETDATE(), @v_inserted, 'SUCCESS');
END
GO


--`````````````````````````````````````````  7:ETL_DIM_RATING```````````````````````````````````````````

CREATE OR ALTER PROCEDURE DW.etl_dim_rating
AS
BEGIN
    DECLARE @v_last_load DATETIME;
    DECLARE @v_inserted  INT;

    SELECT @v_last_load = COALESCE(MAX(last_load_time), '1900-01-01')
    FROM   DW.etl_log
    WHERE  table_name = 'dim_rating' AND status = 'SUCCESS';

    MERGE DW.dim_rating AS target
    USING (
        SELECT
            r.rate_id,
            r.rider_score,
            r.driver_score,
            rc.comment
        FROM rating r
        LEFT JOIN rate_comment rc ON rc.rate_id = r.rate_id
        WHERE r.rate_date > CAST(@v_last_load AS DATE)
    ) AS source
    ON (target.rate_id = source.rate_id)
    WHEN MATCHED THEN
        UPDATE SET
            target.rider_score  = source.rider_score,
            target.driver_score = source.driver_score,
            target.comment      = source.comment
    WHEN NOT MATCHED THEN
        INSERT (rate_id, rider_score, driver_score, comment)
        VALUES (source.rate_id, source.rider_score, source.driver_score, source.comment);

    SET @v_inserted = @@ROWCOUNT;

    INSERT INTO DW.etl_log (table_name, last_load_time, rows_inserted, status)
    VALUES ('dim_rating', GETDATE(), @v_inserted, 'SUCCESS');
END
GO


--```````````````````````````````````````````````  8:ETL_DIM_LOCATION`````````````````````````````````````````


CREATE OR ALTER PROCEDURE DW.etl_dim_location
AS
BEGIN
    DECLARE @v_last_load DATETIME;
    DECLARE @v_inserted  INT;

    SELECT @v_last_load = COALESCE(MAX(last_load_time), '1900-01-01')
    FROM   DW.etl_log
    WHERE  table_name = 'dim_location' AND status = 'SUCCESS';

    INSERT INTO DW.dim_location (location_id, area)
    SELECT
        NEXT VALUE FOR DW.LocationSeq,
        source.AreaName
    FROM (
        SELECT DISTINCT pick_up_location AS AreaName FROM Request WHERE created_at > @v_last_load
        UNION
        SELECT DISTINCT drop_off_location            FROM Request WHERE created_at > @v_last_load
    ) AS source
    WHERE source.AreaName IS NOT NULL
      AND source.AreaName NOT IN (SELECT area FROM DW.dim_location);

    SET @v_inserted = @@ROWCOUNT;

    INSERT INTO DW.etl_log (table_name, last_load_time, rows_inserted, status)
    VALUES ('dim_location', GETDATE(), @v_inserted, 'SUCCESS');
END
GO


--  ````````````````````````````````````````9:ETL_FACT_TRIP``````````````````````````````````````````````````

CREATE OR ALTER PROCEDURE DW.etl_fact_trip
AS
BEGIN
    DECLARE @v_last_load DATETIME;
    DECLARE @v_inserted  INT;

    SELECT @v_last_load = COALESCE(MAX(last_load_time), '1900-01-01')
    FROM   DW.etl_log
    WHERE  table_name = 'fact_trip' AND status = 'SUCCESS';

    INSERT INTO DW.fact_trip (
        trip_id, date_id, rider_id, driver_id, vehicle_id,
        request_id, payment_id, rate_id, location_id,
        start_time, end_time, trip_status, final_fare,
         rider_score, driver_score
    )
    SELECT
        t.trip_id,
        CAST(CONVERT(VARCHAR(8), t.start_time, 112) AS INT)  AS date_id,
        rq.rider_id,
        t.driver_id,
        t.vehicle_id,
        t.request_id,
        pay.payment_id,
        rat.rate_id,
        loc.location_id,
        t.start_time,
        t.end_time,
        t.status                                              AS trip_status,
        t.final_fare,
        rat.rider_score,
        rat.driver_score
    FROM Trip t
    JOIN     Request          rq  ON rq.request_id  = t.request_id
    LEFT JOIN DW.dim_location loc ON loc.area        = rq.pick_up_location
    LEFT JOIN DW.dim_payment  pay ON pay.payment_id IN (
                  SELECT payment_id FROM payment WHERE trip_id = t.trip_id)
    LEFT JOIN DW.dim_rating   rat ON rat.rate_id    IN (
                  SELECT rate_id    FROM rating    WHERE trip_id = t.trip_id)
    WHERE t.start_time > @v_last_load
      AND t.trip_id NOT IN (SELECT trip_id FROM DW.fact_trip);

    SET @v_inserted = @@ROWCOUNT;

    INSERT INTO DW.etl_log (table_name, last_load_time, rows_inserted, status)
    VALUES ('fact_trip', GETDATE(), @v_inserted, 'SUCCESS');
END
GO


--````````````````````````````````````````MASTER PROCEDURE```````````````````````````````````````````

CREATE OR ALTER PROCEDURE DW.run_full_etl
AS
BEGIN
    EXEC DW.etl_dim_date;
    EXEC DW.etl_dim_rider;
    EXEC DW.etl_dim_driver;
    EXEC DW.etl_dim_vehicle;
    EXEC DW.etl_dim_request;
    EXEC DW.etl_dim_payment;
    EXEC DW.etl_dim_rating;
    EXEC DW.etl_dim_location;
    EXEC DW.etl_fact_trip;

    SELECT * FROM DW.etl_log ORDER BY run_at DESC;
END
GO

-- lets check etl:
EXEC DW.run_full_etl;

-- lets check the schema tables after etl:
SELECT*FROM DW.dim_date;
SELECT*FROM DW.dim_rider;
SELECT*FROM DW.dim_driver;
SELECT*FROM DW.dim_vehicle;
SELECT*FROM DW.dim_request;
SELECT*FROM DW.dim_payment;
SELECT*FROM DW.dim_rating;
SELECT*FROM DW.dim_location;
SELECT*FROM DW.fact_trip;
                                --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
                                --  ANALYTICAL QUERIES (eng:mostafa Al_husseiny):
								--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ```````````````````````q1. Daily Revenue Summary:`````````````````````````````

SELECT
    d.full_date                             AS trip_date,
    COUNT(f.trip_id)                        AS total_trips,
    SUM(f.final_fare)                       AS total_revenue,
    ROUND(AVG(f.final_fare), 2)             AS avg_fare,
    MIN(f.final_fare)                       AS min_fare,
    MAX(f.final_fare)                       AS max_fare
FROM       DW.fact_trip f
JOIN       DW.dim_date  d  ON d.date_id = f.date_id
WHERE f.trip_status = 'completed'
GROUP BY   d.full_date
ORDER BY   d.full_date;


-- ````````````````````````````q2. Revenue by Vehicle Category: ```````````````````````````````

SELECT
    r.vehicle_category,
    COUNT(f.trip_id)                        AS total_trips,
    SUM(f.final_fare)                       AS total_revenue,
    ROUND(AVG(f.final_fare), 2)             AS avg_fare
FROM       DW.fact_trip    f
JOIN       DW.dim_request  r  ON r.request_id = f.request_id
WHERE f.trip_status = 'completed'
GROUP BY   r.vehicle_category
ORDER BY   total_revenue DESC;


-- `````````````````````q3. Driver Performance Scorecard:```````````````````````````````

SELECT
    d.first_name + ' ' + d.last_name       AS driver_name,
    d.license_no,
    COUNT(f.trip_id)                        AS trips_completed,
    SUM(f.final_fare)                       AS total_revenue,
    ROUND(AVG(f.driver_score), 2)           AS avg_rating,
    ROUND(AVG(DATEDIFF(MINUTE, f.start_time, f.end_time)), 1)
                                            AS avg_duration_min
FROM       DW.fact_trip   f
JOIN       DW.dim_driver  d  ON d.driver_id = f.driver_id
WHERE f.trip_status = 'completed'
GROUP BY   d.driver_id, d.first_name, d.last_name, d.license_no
ORDER BY   total_revenue DESC;


--````````````````````````` q4. Rider Behaviour Analysis:`````````````````````````````

SELECT
    ri.first_name + ' ' + ri.last_name     AS rider_name,
    COUNT(f.trip_id)                        AS total_trips,
    SUM(CASE WHEN f.trip_status = 'cancelled' THEN 1 ELSE 0 END)
                                            AS cancelled_count,
    ROUND(
        100.0 * SUM(CASE WHEN f.trip_status = 'cancelled' THEN 1 ELSE 0 END)
        / COUNT(f.trip_id), 1
    )                                       AS cancellation_rate_pct,
    ISNULL(SUM(f.final_fare), 0)        AS total_spent
FROM       DW.fact_trip  f
JOIN       DW.dim_rider  ri ON ri.rider_id = f.rider_id
GROUP BY   ri.rider_id, ri.first_name, ri.last_name
ORDER BY   total_spent DESC;


--````````````````````q5. Payment Method Adoption & Revenue Share:`````````````````````````

SELECT
    p.method_type                           AS payment_type,
    COUNT(f.trip_id)                        AS total_payments,
    SUM(f.final_fare)                   AS total_revenue,
    ROUND(
        100.0 * SUM(f.final_fare)
        / SUM(SUM(f.final_fare)) OVER (), 2
    )                                       AS revenue_share_pct
FROM       DW.fact_trip    f
JOIN       DW.dim_payment  p  ON p.payment_id = f.payment_id
WHERE p.status = 'paid'
GROUP BY   p.method_type;


--`````````````````````````q6. Peak Hour Analysis: Which hours generate the most trips and revenue?````````````````````````

SELECT
    DATEPART(HOUR, f.start_time)            AS hour_of_day,
    COUNT(f.trip_id)                        AS total_trips,
    SUM(f.final_fare)                       AS total_revenue,
    ROUND(AVG(f.final_fare), 2)             AS avg_fare
FROM       DW.fact_trip f
WHERE f.trip_status = 'completed'
GROUP BY   DATEPART(HOUR, f.start_time)
ORDER BY   total_trips DESC;


--``````````````````````````````q7. Top Pickup Locations by Trip Volume:````````````````````````````

SELECT
    l.area                                  AS pick_up_location,
    COUNT(f.trip_id)                        AS total_trips,
    SUM(f.final_fare)                       AS total_revenue,
    ROUND(AVG(f.final_fare), 2)             AS avg_fare
FROM       DW.fact_trip     f
JOIN       DW.dim_location  l  ON l.location_id = f.location_id
WHERE f.trip_status = 'completed'
GROUP BY   l.location_id, l.area
ORDER BY   total_trips DESC;

                                -- ADDITIONAL ANALYTICAL QUERIES:
                                --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--``````````````````q8. Monthly Revenue Trend`````````````````````

SELECT
    d.year,
    d.month,
    d.month_name,
    COUNT(f.trip_id)                            AS total_trips,
    SUM(f.final_fare)                           AS total_revenue,
    LAG(SUM(f.final_fare)) OVER (
        ORDER BY d.year, d.month
    )                                           AS prev_month_revenue,
    ROUND(
        100.0 * (SUM(f.final_fare) - LAG(SUM(f.final_fare)) OVER (ORDER BY d.year, d.month))
        / NULLIF(LAG(SUM(f.final_fare)) OVER (ORDER BY d.year, d.month), 0), 2
    )                                           AS revenue_growth_pct
FROM       DW.fact_trip f
JOIN       DW.dim_date  d  ON d.date_id = f.date_id
WHERE f.trip_status = 'completed'
GROUP BY   d.year, d.month, d.month_name
ORDER BY   d.year, d.month;


-- ````````````````````````q9. Quarterly Revenue Summary:``````````````````````

SELECT
    d.year,
    d.quarter,
    COUNT(f.trip_id)                            AS total_trips,
    SUM(f.final_fare)                           AS total_revenue,
    ROUND(AVG(f.final_fare), 2)                 AS avg_fare
FROM       DW.fact_trip f
JOIN       DW.dim_date  d  ON d.date_id = f.date_id
WHERE f.trip_status = 'completed'
GROUP BY   d.year, d.quarter
ORDER BY   d.year, d.quarter;


-- `````````````````````````q10. Driver Ranking````````````````````````

SELECT
    RANK() OVER (ORDER BY ROUND(AVG(f.driver_score), 2) DESC)
                                                AS rating_rank,
    RANK() OVER (ORDER BY SUM(f.final_fare) DESC)
                                                AS revenue_rank,
    d.first_name + ' ' + d.last_name           AS driver_name,
    d.license_no,
    COUNT(f.trip_id)                            AS total_trips,
    SUM(f.final_fare)                           AS total_revenue,
    ROUND(AVG(f.driver_score), 2)               AS avg_rating
FROM       DW.fact_trip  f
JOIN       DW.dim_driver d  ON d.driver_id = f.driver_id
WHERE f.trip_status = 'completed'
GROUP BY   d.driver_id, d.first_name, d.last_name, d.license_no
ORDER BY   avg_rating DESC;


-- `````````````````````q11:Rider Loyalty Segmentation````````````````

SELECT
    ri.first_name + ' ' + ri.last_name         AS rider_name,
    COUNT(f.trip_id)                            AS total_trips,
    SUM(f.final_fare)                       AS total_spent,
    ROUND(AVG(f.rider_score), 2)                AS avg_score_given,
    CASE
        WHEN COUNT(f.trip_id) >= 20 THEN 'VIP'
        WHEN COUNT(f.trip_id) >= 10 THEN 'Regular'
        WHEN COUNT(f.trip_id) >= 3  THEN 'Occasional'
        ELSE                             'New'
    END                                         AS rider_segment
FROM       DW.fact_trip f
JOIN       DW.dim_rider ri ON ri.rider_id = f.rider_id
GROUP BY   ri.rider_id, ri.first_name, ri.last_name
ORDER BY   total_trips DESC;


--``````````````````````````q12. Vehicle Type vs Average Rating`````````````````````````````

SELECT
    v.car_type,
    COUNT(f.trip_id)                            AS total_trips,
    ROUND(AVG(f.driver_score), 2)               AS avg_driver_score,
    ROUND(AVG(f.rider_score),  2)               AS avg_rider_score,
    ROUND(AVG(f.final_fare),   2)               AS avg_fare
FROM       DW.fact_trip   f
JOIN       DW.dim_vehicle v  ON v.vehicle_id = f.vehicle_id
WHERE f.trip_status = 'completed'
GROUP BY   v.car_type
ORDER BY   avg_driver_score DESC;


-- ```````````````````````````````q13. Payment Status Analysis```````````````````````

SELECT
    p.status                                    AS payment_status,
    COUNT(f.trip_id)                            AS total_count,
    SUM(f.final_fare)                       AS total_amount,
    ROUND(
        100.0 * COUNT(f.trip_id)
        / SUM(COUNT(f.trip_id)) OVER (), 2
    )                                           AS count_pct,
    ROUND(
        100.0 * SUM(f.final_fare)
        / SUM(SUM(f.final_fare)) OVER (), 2
    )                                           AS amount_pct
FROM       DW.fact_trip   f
JOIN       DW.dim_payment p  ON p.payment_id = f.payment_id
GROUP BY   p.status;


--````````````````````````````q14. Trip Duration vs Fare Analysis``````````````````````

SELECT
    v.car_type,
    ROUND(AVG(DATEDIFF(MINUTE, f.start_time, f.end_time)), 1)
                                                AS avg_duration_min,
    ROUND(AVG(f.final_fare), 2)                 AS avg_fare,
    ROUND(
        AVG(f.final_fare)
        / NULLIF(AVG(DATEDIFF(MINUTE, f.start_time, f.end_time)), 0), 2
    )                                           AS fare_per_minute
FROM       DW.fact_trip   f
JOIN       DW.dim_vehicle v  ON v.vehicle_id = f.vehicle_id
WHERE f.trip_status = 'completed'
  AND f.end_time    > f.start_time
GROUP BY   v.car_type
ORDER BY   avg_duration_min DESC;


--```````````````````````````````q15. Day of Week Performance:````````````````````````````

SELECT
    d.day_of_week,
    COUNT(f.trip_id)                            AS total_trips,
    SUM(f.final_fare)                           AS total_revenue,
    ROUND(AVG(f.final_fare), 2)                 AS avg_fare,
    ROUND(AVG(f.driver_score), 2)               AS avg_driver_rating
FROM       DW.fact_trip f
JOIN       DW.dim_date  d  ON d.date_id = f.date_id
WHERE f.trip_status = 'completed'
GROUP BY   d.day_of_week
ORDER BY   total_trips DESC;


--````````````````````````````q16. Low Rated Trips Analysis:```````````````````````````````

SELECT
    d.first_name + ' ' + d.last_name           AS driver_name,
    v.car_type,
    v.car_model,
    f.final_fare,
    DATEDIFF(MINUTE, f.start_time, f.end_time) AS duration_min,
    f.driver_score,
    f.rider_score,
    rat.comment
FROM       DW.fact_trip   f
JOIN       DW.dim_driver  d   ON d.driver_id   = f.driver_id
JOIN       DW.dim_vehicle v   ON v.vehicle_id  = f.vehicle_id
JOIN       DW.dim_rating  rat ON rat.rate_id   = f.rate_id
WHERE f.driver_score <= 3
   OR f.rider_score  <= 3
ORDER BY   f.driver_score ASC;