/*

Cleaning Data in SQL Queries

*/



SELECT * FROM HousingData


--Standarize Date Format


SELECT SaleDateConverted, CONVERT(DATE,SaleDate)
FROM HousingData

UPDATE HousingData
SET SaleDate = CONVERT(DATE,SaleDate)


--If it doesn't update properly.

ALTER TABLE HousingData
ADD SaleDateConverted DATE;

UPDATE HousingData
SET SaleDateConverted = CONVERT(DATE,SaleDate)



--Populate Property Address Data


SELECT * FROM HousingData
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--Self Join

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM HousingData AS a
JOIN HousingData AS b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM HousingData AS a
JOIN HousingData AS b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



--Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress 
FROM HousingData
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM HousingData

ALTER TABLE HousingData
ADD PropertySplitAddress NVARCHAR(200);

UPDATE HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE HousingData
ADD PropertySplitCity NVARCHAR(200);

UPDATE HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT * FROM HousingData


SELECT OwnerAddress 
FROM HousingData

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM HousingData

ALTER TABLE HousingData
ADD OwnerSplitAddress NVARCHAR(200);

UPDATE HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE HousingData
ADD OwnerSplitCity NVARCHAR(200);

UPDATE HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE HousingData
ADD OwnerSplitState NVARCHAR(200);

UPDATE HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * FROM HousingData




--Change Y and N to Yes and No in "SoldAsVacant" Field


SELECT DISTINCT(SoldAsVacant)
FROM HousingData

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
     WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM HousingData

UPDATE HousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes'
     WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	 END




--Remove Duplicates


WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER(
	PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
	ORDER BY UniqueID) AS row_num
FROM HousingData	        
)

DELETE
FROM RowNumCTE
WHERE row_num > 1




--Delete unused Columns


SELECT * FROM HousingData

ALTER TABLE HousingData
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE HousingData
DROP COLUMN SaleDate





