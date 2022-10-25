--4. Query to simulate the transactions processes. (.sql)
--Asumsi ada Staff dengan ID ST001 melakukan transaksi Purchase pada Vendor dengan ID VE015 untuk membeli Televisi dengan ID TE013 
--sebanyak 10 buah pada tanggal 2021-12-27. Kemudian Televisi tersebut ditangani oleh Staff dengan ID ST005 yang menjual 2 buahnya 
--pada tanggal 2022-01-04, kepada Customer baru dengan data berikut:
--Nama: Lee Kwang Soo
--Email: kwangsoo.lee@gmail.com
--Gender: Male
--Phone: +6285208696969
--Address: 77 Wangsheng Street
--DOB: 1995-09-28
USE ENTV
GO

BEGIN TRAN

--Purchase
INSERT INTO PurchaseTransaction VALUES
('PE016', 'ST001', 'VE015', '2021-12-27');

SELECT * FROM PurchaseTransaction

INSERT INTO PurchaseTransactionDetail VALUES
('PE016', 'TE013', 10);

SELECT * FROM PurchaseTransactionDetail

--New Customer
INSERT INTO Customer VALUES 
('CU016', 'Lee Kwang Soo', 'kwangsoo.lee@gmail.com', 'Male', '+6285208696969', '77 Wangsheng Street', '1995-09-28');

SELECT * FROM Customer

--Sales
INSERT INTO SalesTransaction VALUES
('SA016', 'ST005', 'CU016', '2022-01-04');

SELECT * FROM SalesTransaction

INSERT INTO SalesTransactionDetail VALUES
('SA016', 'TE013', 2);

SELECT * FROM SalesTransactionDetail

ROLLBACK
COMMIT