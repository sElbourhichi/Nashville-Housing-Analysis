/*
EL-BOURHICHI Salah-Edine

Project Name : Cleaning Data in SQL Queries

*/

SELECT * 
FROM Cleaning..housing



-- Standarize Date Format 
	-- looking for null values


SELECT SaleDateConverted
FROM housing 
where SaleDateConverted is null


ALTER TABLE housing
ADD SaleDateConverted Date;


UPDATE housing
SET SaleDateConverted = CONVERT(date,SaleDate)


ALTER TABLE housing 
DROP COLUMN SaleDate


-- Populate Property Address Data 
	-- check if there is null values


	SELECT *
	FROM housing 
	where PropertyAddress is null
	order by ParcelID


	-- Populate null values

SELECT  a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(b.PropertyAddress, a.PropertyAddress)               
FROM housing a 
INNER JOIN housing b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where b.PropertyAddress is null

UPDATE b 
SET b.PropertyAddress = ISNULL(b.PropertyAddress, a.PropertyAddress) 
FROM housing a 
INNER JOIN housing b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where b.PropertyAddress is null



-- checking the result


SELECT *
FROM housing 
where PropertyAddress is null
order by ParcelID


-- Breaking out Adress into Individual Colummns ( Adress, City, State )
-- method 1



select PropertyAddress, 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1),
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
from housing   

ALTER TABLE housing 
ADD PropertyAdressSplit VARCHAR (255),
	PropertyCity VARCHAR (255)

UPDATE housing
SET PropertyAdressSplit = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1),
	PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


-- method 2 

select OwnerAddress, 
		PARSENAME(REPLACE(OwnerAddress, ',','.'),3) AS OwnerAddressSplit, 
	    PARSENAME(REPLACE(OwnerAddress, ',','.'),2) AS OwnerCity,
		PARSENAME(REPLACE(OwnerAddress, ',','.'),1) AS OwnerState
FROM housing 

ALTER TABLE housing 
ADD OwnerAddressSplit VARCHAR (255),
	OwnerCity VARCHAR (255),
	OwnerState VARCHAR (255)

UPDATE housing
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
	OwnerCity =  PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
	OwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


-- change Y and N to Yes and NO  

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM housing

UPDATE housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


--SELECT distinct SoldAsVacant, count(SoldAsVacant) 
--FROM housing
--group by SoldAsVacant
--ORDER BY 2

-- Delete Duplicates 


-- Remove Duplicates
WITH ROW_n AS (
SELECT *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 ORDER BY UniqueID ) AS num_row
FROM housing )

DELETE
From ROW_n
Where num_row > 1

	
-- Delete Unused Columns


Select *
From housing


ALTER TABLE housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress