--Rika Mochi
--ENTV
--10 Case
USE ENTV
GO
--1. Display StaffID, StaffName, VendorName, and Total Transaction (Obtained from counting the purchase transaction) for every transaction happens later than August and StaffName starts with letter 'B’.
SELECT 
	st.StaffID,
	st.StaffName,
	VendorName,
	[Total Transaction] = COUNT(PurchaseTransactionID)
FROM Staff st JOIN PurchaseTransaction pt 
	ON st.StaffID = pt.StaffID JOIN Vendor vd 
	ON pt.VendorID = vd.VendorID
WHERE MONTH(PurchaseTransactionDate) > 8 AND StaffName LIKE 'B%'
GROUP BY st.StaffID, st.StaffName, VendorName

--2. Display CustomerID (obtained by last 3 characters), CustomerName, and Total Spending (obtained from sum of all TelevisionPrice times Quantity) for every CustomerName contains letter 'a' and TelevisionName contains 'LED'.
SELECT 
	[CustomerID] = RIGHT(cs.CustomerID, 3),
	CustomerName,
	[Total Spending] = SUM(TelevisionPrice * SalesQuantity)
FROM Customer cs JOIN SalesTransaction st
	ON cs.CustomerID = st.CustomerID JOIN SalesTransactionDetail std 
	ON st.SalesTransactionID = std.SalesTransactionID JOIN Television tv 
	ON std.TelevisionID = tv.TelevisionID
WHERE CustomerName LIKE '%a%' AND TelevisionName LIKE '%LED%'
GROUP BY cs.CustomerID, CustomerName

--3. Display StaffName (obtained from the first name of the Staff), TelevisionName, and Total Price (obtained from sum of all TelevisionPrice times Quantity) for every transaction happens more than twice and TelevisionName contains 'UHD'.
--Sales Transaction
SELECT
	CASE
		WHEN CHARINDEX(' ', StaffName) > 0
			THEN LEFT(StaffName, CHARINDEX(' ', StaffName) - 1)
		ELSE StaffName
	END AS StaffName,
	TelevisionName,
	[Total Price] = SUM(TelevisionPrice * SalesQuantity)
FROM Television t JOIN SalesTransactionDetail std ON std.TelevisionID = t.TelevisionID
	JOIN SalesTransaction st ON std.SalesTransactionID = st.SalesTransactionID
	JOIN Staff s ON st.StaffID = s.StaffID
WHERE TelevisionName LIKE '%UHD%'
GROUP BY StaffName, TelevisionName
HAVING COUNT(std.SalesTransactionID) > 2
--Purchase Transaction
SELECT
	CASE
		WHEN CHARINDEX(' ', StaffName) > 0
			THEN LEFT(StaffName, CHARINDEX(' ', StaffName) - 1)
		ELSE StaffName
	END AS StaffName,
	TelevisionName,
	[Total Price] = SUM(TelevisionPrice * PurchaseQuantity)
FROM Television t JOIN PurchaseTransactionDetail ptd ON ptd.TelevisionID = t.TelevisionID
	JOIN PurchaseTransaction pt ON ptd.PurchaseTransactionID = pt.PurchaseTransactionID
	JOIN Staff s ON pt.StaffID = s.StaffID
WHERE TelevisionName LIKE '%UHD%'
GROUP BY StaffName, TelevisionName
HAVING COUNT(ptd.PurchaseTransactionID) > 2

--4. Display TelevisionName (obtained from TelevisionName in upper case format), Max Television Sold (obtained from the maximum quantity that has been sold in one transaction end with the word ‘ Pc(s)’), Total Television Sold (obtained from sum of the quantity that sold in all transaction end with the word ‘ Pc(s)’) for every Television which price is more than 3000000 and sales happens after February, order it by Total Television Sold ascendingly.
SELECT
	[TelevisionName] = UPPER(TelevisionName),
	[Max Television Sold] = CAST(MAX(SalesQuantity) AS VARCHAR) + ' Pc(s)',
	[Total Television Sold] = CAST(SUM(SalesQuantity) AS VARCHAR) + ' Pc(s)'
FROM Television t JOIN SalesTransactionDetail std ON t.TelevisionID = std.TelevisionID 
	JOIN SalesTransaction st ON std.SalesTransactionID = st.SalesTransactionID
WHERE TelevisionPrice > 3000000 AND MONTH(SalesTransactionDate) > 2
GROUP BY TelevisionName, SalesQuantity
ORDER BY [Total Television Sold] ASC

--5. Display VendorName,VendorPhone (obtained from vendorPhone with ‘+62’ replace by ‘0’), TelevisionName, TelevisionPrice (obtained from adding ‘Rp. ’ before TelevisionPrice) for every Television which price more than average of all TelevisionPrice and VendorName must be at least 2 words.
--(alias subquery)
SELECT
	VendorName,
	[VendorPhone] = REPLACE(VendorPhone, '+62', '0'),
	TelevisionName,
	[TelevisionPrice] = 'Rp. ' + CAST(TelevisionPrice AS VARCHAR)
FROM Vendor v JOIN PurchaseTransaction pt ON v.VendorID = pt.VendorID
	JOIN PurchaseTransactionDetail ptd ON pt.PurchaseTransactionID = ptd.PurchaseTransactionID
	JOIN Television t ON ptd.TelevisionID = t.TelevisionID,
	(
		 SELECT
			[AverageTVPrice] = AVG(TelevisionPrice)
		 FROM Television
	) a
WHERE TelevisionPrice > a.AverageTVPrice AND VendorName LIKE '% %'

--6. Display StaffID, StaffName, StaffEmail (obtained from words before ‘@’), and StaffSalary for every StaffSalary more than average of StaffSalary and taken care transaction for customer whose name contains ‘o’.
--(alias subquery)
SELECT
	s.StaffID,
	StaffName,
	[StaffEmail] = LEFT(StaffEmail, CHARINDEX('@', StaffEmail) - 1)
FROM Staff s JOIN SalesTransaction st ON s.StaffID = st.StaffID
	JOIN Customer c ON st.CustomerID = c.CustomerID,
	(
		SELECT [AverageSalary] = AVG(StaffSalary)
		FROM Staff
	) a
WHERE c.CustomerName LIKE '%o%' AND StaffSalary > a.AverageSalary

--7. Display TelevisionID (obtained from replacing ‘TE’ to ‘Television ’), TelevisionName, TelevisionBrand (obtained from TelevisionBrand in upper case format), and TotalSold (obtained from the sum of quantity sold to customer end with the word ‘ Pc(s)’) for every TelevisionName that contains the word ‘LED’ and TotalSold more than average of the total sold of all television , order it by TotalSold ascendingly.
--(alias subquery)
SELECT
	[TelevisionID] = 'Television' + SUBSTRING(t.TelevisionID, 3, LEN(t.TelevisionID)),
	[TelevisionBrand] = UPPER(BrandName),
	[Total Sold] = CAST(SUM(SalesQuantity) AS VARCHAR) + ' Pc(s)'
FROM Television t JOIN SalesTransactionDetail std ON std.TelevisionID = t.TelevisionID
	JOIN Brand b ON t.BrandID = b.BrandID,
	(
 		SELECT [AverageTotalSold] = AVG(asb1.SoldTotal)
 		FROM
		(
			SELECT [SoldTotal] = SUM(SalesQuantity)
			FROM SalesTransactionDetail
		) asb1
	) asb2
WHERE TelevisionName LIKE '%LED%'
GROUP BY t.TelevisionID, BrandName, asb2.AverageTotalSold
HAVING asb2.AverageTotalSold > SUM(SalesQuantity)
ORDER BY [Total Sold]

--8. Display VendorName, VendorEmail, VendorPhone (obtained by replacing VendorPhone first character into ‘+62’), and Total Quantity (obtained from the sum of quantity purchased and ended with ‘ Pc(s)’) for every purchase which television price is higher than the maximum television price in every purchase that occurred between the 3th and 6th month of the year and VendorName must at least 2 words.
--(alias subquery)
SELECT
	VendorName,
	VendorEmail,
	[VendorPhone] = '+62' + SUBSTRING(VendorPhone,2,LEN(VendorPhone)),
	[Total Quantity] = CAST(SUM(PurchaseQuantity) AS VARCHAR) + ' Pc(s)'
FROM Vendor v JOIN PurchaseTransaction pt 
	ON v.VendorID = pt.VendorID JOIN PurchaseTransactionDetail ptd 
	ON pt.PurchaseTransactionID = ptd.PurchaseTransactionID JOIN Television t
	ON ptd.TelevisionID = t.TelevisionID ,
	(
		SELECT
			[MaxTVPrice] = MAX(TelevisionPrice)
		FROM PurchaseTransaction st JOIN PurchaseTransactionDetail std 
			ON st.PurchaseTransactionID = std.PurchaseTransactionID JOIN Television t 
			ON std.TelevisionID = t.TelevisionID
		WHERE MONTH(PurchaseTransactionDate) BETWEEN 3 AND 6
	) a
WHERE VendorName LIKE '% %' AND
	TelevisionPrice > a.MaxTVPrice
GROUP BY VendorName, VendorEmail, VendorPhone

--9. Create a view named ‘CustomerTransaction’ to display CustomerName, CustomerEmail, Maximum Quantity Television (obtained from the maximum quantity sold and ended with ‘ Pc(s)’), and Minimum Quantity Television (obtained from the minimum quantity purchased and ended with ‘ Pc(s)’) for every customer whose name contains ‘b’ and the maximum quantity isn’t equal to its minimum quantity.
GO
CREATE VIEW CustomerTransaction AS
SELECT
	CustomerName,
	CustomerEmail,
	[Maximum Quantity Television] = CAST(MAX(SalesQuantity) AS VARCHAR) + ' Pc(s)',
	[Minimum Quantity Television] = CAST(MIN(SalesQuantity) AS VARCHAR) + ' Pc(s)'
FROM Customer c JOIN SalesTransaction st 
	ON c.CustomerID = st.CustomerID JOIN SalesTransactionDetail std
	ON st.SalesTransactionID = std.SalesTransactionID
WHERE CustomerName LIKE '%b%' COLLATE SQL_Latin1_General_Cp1_CS_AS
GROUP BY CustomerName, CustomerEmail
HAVING MAX(SalesQuantity) != MIN(SalesQuantity)

GO
SELECT * FROM CustomerTransaction

--10. Create a view named 'StaffTransaction' to display StaffName, StaffEmail, StaffPhone, Count Transaction (obtained from total number of transaction), and Total Television (obtained by total quantity of television purchased) for every transaction that the date of transaction happened later than 10th day and staff email ends with '@gmail.com'.
GO
CREATE VIEW StaffTransaction AS
SELECT
	StaffName,
	StaffEmail,
	StaffPhone,
	[Count Transaction] = COUNT(pt.PurchaseTransactionID),
	[Total Television] = SUM(PurchaseQuantity)
FROM Staff s JOIN PurchaseTransaction pt
	ON s.StaffID = pt.StaffID JOIN PurchaseTransactionDetail ptd
	ON pt.PurchaseTransactionID = ptd.PurchaseTransactionID
WHERE DAY(PurchaseTransactionDate) > 10 AND StaffEmail LIKE '%@gmail.com'
GROUP BY StaffName, StaffEmail, StaffPhone