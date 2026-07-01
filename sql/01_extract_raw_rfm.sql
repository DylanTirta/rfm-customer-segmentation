-- Buat Database
CREATE DATABASE arpand_ecommerce;
USE arpand_ecommerce;

drop DATABASE arpand_ecommerce;
SET GLOBAL local_infile = 1;

-- 1. Tabel Branch
CREATE TABLE branches (
    BranchID VARCHAR(20) PRIMARY KEY,
    FixedCostEUR DECIMAL(14 , 4 ),
    VariableCostEUR DECIMAL(14 , 4 ),
    CurrentAdStrategy VARCHAR(200)
);

-- 2. Tabel Customers
CREATE TABLE customers (
    CustomerID BIGINT PRIMARY KEY,
    Gender VARCHAR(10),
    Age INT,
    Country VARCHAR(100),
    City VARCHAR(100),
    BranchID VARCHAR(20),
    BranchName VARCHAR(100),
    LastPurchaseDate DATE,
    TotalTransactions INT,
    TotalSpent DECIMAL(15 , 4 ),
    Currency VARCHAR(10),
    PaymentType VARCHAR(50),
    CreditLimit DECIMAL(15 , 4 ),
    CONSTRAINT fk_customer_branch FOREIGN KEY (BranchID)
        REFERENCES branches (BranchID)
);

-- 3. Tabel Transactions
CREATE TABLE transactions (
    TransactionID BIGINT PRIMARY KEY AUTO_INCREMENT,
    CustomerID BIGINT,
    BranchID VARCHAR(20),
    EventType VARCHAR(50),
    TrafficMultiplier DECIMAL(15 , 4 ),
    ABTestGroup VARCHAR(50),
    SaleAmountEUR DECIMAL(15 , 4 ),
    TransactionDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_trans_customer FOREIGN KEY (CustomerID)
        REFERENCES customers (CustomerID),
    CONSTRAINT fk_trans_branch FOREIGN KEY (BranchID)
        REFERENCES branches (BranchID)
);

-- 4. Tabel Ad History
CREATE TABLE ad_history (
    AdHistoryID INT PRIMARY KEY AUTO_INCREMENT,
    BranchID VARCHAR(20),
    AdStrategy VARCHAR(200),
    StartDate DATE,
    EndDate DATE,
    CONSTRAINT fk_ad_branch FOREIGN KEY (BranchID)
        REFERENCES branches (BranchID)
);

-- Masukan data branches.csv
LOAD DATA LOCAL INFILE 'C:/Users/MyBook Hype AMD/Documents/Portofolio DA/Arpand E-Commerce/branches.csv' 
INTO TABLE branches
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(BranchID, FixedCostEUR, VariableCostEUR, CurrentAdStrategy);

-- Masukan data arpand_ecommerce_dataset
LOAD DATA LOCAL INFILE 'C:/Users/MyBook Hype AMD/Documents/Portofolio DA/Arpand E-Commerce/arpand_ecommerce_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES          
(CustomerID, Gender, Age, Country, City, BranchID, BranchName, LastPurchaseDate, TotalTransactions, TotalSpent, Currency, PaymentType, CreditLimit);

-- Masukan data transaction
LOAD DATA LOCAL INFILE 'C:/Users/MyBook Hype AMD/Documents/Portofolio DA/Arpand E-Commerce/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(EventType, TrafficMultiplier, ABTestGroup, SaleAmountEUR, BranchID, CustomerID);

-- Masukan data ad_history
LOAD DATA LOCAL INFILE 'C:/Users/MyBook Hype AMD/Documents/Portofolio DA/Arpand E-Commerce/ad_history.csv'
INTO TABLE ad_history
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(BranchID, AdStrategy, StartDate, EndDate);

-- Cek jumlah baris setiap tabel
SELECT 
    'customers' AS tabel, COUNT(*) as jumlah_baris
FROM
    customers 
UNION ALL SELECT 
    'transactions', COUNT(*)
FROM
    transactions 
UNION ALL SELECT 
    'branches', COUNT(*)
FROM
    branches 
UNION ALL SELECT 
    'ad_history', COUNT(*)
FROM
    ad_history;

-- Cek rentang tanggal
SELECT 
    MIN(LastPurchaseDate) AS tanggal_pertama,
    MAX(LastPurchaseDate) AS tanggal_terakhir
FROM
    customers;

-- Membuat View: rfm_raw
CREATE OR REPLACE VIEW rfm_raw AS
    SELECT 
        CustomerID,
        Gender,
        Age,
        Country,
        City,
        BranchID,
        PaymentType,
        LastPurchaseDate,
        DATEDIFF((SELECT 
                        DATE_ADD(MAX(LastPurchaseDate),
                                INTERVAL 1 DAY)
                    FROM
                        customers),
                LastPurchaseDate) AS Recency,
        TotalTransactions AS Frequency,
        ROUND(TotalSpent, 2) AS Monetary
    FROM
        customers;

-- Hasil Akhir untuk diekspor ke rfm_raw.csv
SELECT 
    *
FROM
    rfm_raw;