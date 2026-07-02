# Smart Ride System (Advanced Database Management)

## 📌 Project Overview
This project implements a comprehensive **Smart Ride System** designed to manage users, drivers, vehicle fleets, and trip transactions efficiently. The system bridges the gap between relational structures and non-relational frameworks, incorporating advanced database principles such as transactional integrity, concurrency control, query optimization, and OLAP data warehousing.

---

## 🛠️ Key Features & Technical Architecture

### 1. Database Design & Normalization
* **EERD Design:** Captures complex, multi-layered relationships such as `User-Trip` (One-to-Many), `Driver-Vehicle` (One-to-Many/One-to-One), and `Trip-Payment`.
* **Third Normal Form (3NF):** All relational tables are strictly normalized to 3NF to eliminate data redundancy and transitive dependencies (e.g., decoupling payment details and driver info from the main `Trips` table).

### 2. Implementation & Advanced Core Logic
* **Automated Bookings (Stored Procedures):** Implementation of a specialized `BookTrip` procedure that validates driver availability, logs the trip, and updates driver status in a single atomic operation.
* **Transactions & System Recovery:** Employs SQL Transactions with a robust `ROLLBACK` mechanism. If a payment gateway failure is simulated, the system securely reverts the trip status to 'Pending', preventing inconsistent data states.
* **Concurrency Control:** Simulated multi-session access on the same `DriverID`. Configured proper **Isolation Levels** to handle potential conflicts, managing temporary blocking states gracefully to eliminate "Lost Updates."

### 3. Performance Optimization & Analytics
* **Indexing Strategy:** * `Clustered Index` on `TripID` for lightning-fast primary key lookups.
  * `Non-Clustered Indexes` on `UserID` and `PickupTime` to highly optimize user search history queries.
* **Advanced Window Functions:** Applied complex analytical queries using:
  * `ROW_NUMBER()` to sequence chronological trips per user.
  * `RANK()` to rank top-performing drivers based on average ratings from the reviews schema.

### 4. Data Warehouse (Star Schema & OLAP)
Designed a separate OLAP architecture tailored for long-term trends and business intelligence analysis (e.g., monthly revenue growth, peak-hour ride frequency).
* **Fact Table:** `FactTrips` (Metrics: Fare, Distance, etc.)
* **Dimension Tables:** `DimUsers`, `DimDrivers`, `DimTime`

### 5. NoSQL Integration (MongoDB)
Mapped the `Users` entity into a flexible, schema-less **MongoDB Collection** to demonstrate hybrid database capabilities.
* Stored user preferences and multiple contact methods dynamically as nested documents.
* Implemented core CRUD operations (`Insert` profile data, `Find` with filters, and `Update` settings).

---

## 🧰 Technologies & Tools Used
* **RDBMS:** Microsoft SQL Server (T-SQL)
* **NoSQL:** MongoDB
* **Concepts:** 3NF Normalization, Transaction Management, Star Schema (OLAP), Index Tuning, Window Functions.

---

## 👥 Project Team
Developed by a team of 5 students for the *Advanced Database Systems* Course:
* **Habiba Hamdy Ali** (Database Design, Normalization & SQL Server Implementation)
* **Mostafa EL-Hosseny Mostafa**
* **Habiba Samy Mohammed** (Core Logic, Stored Procedures, Transactions & Recovery)
* **Basem Tarek** (Query Optimization & MongoDB Implementation)
* **Habiba Yahia** (Data Warehouse Design & ETL Process)
*