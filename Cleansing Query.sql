CREATE DATABASE NashvilleHousing
USE NashvilleHousing

-- SELECT DATA 
------------------------------------------------------

SELECT * FROM NashvilleData


-- STANDARIZE DATE FORMAT
------------------------------------------------------

-- This query usually work to convert the data type but for some reason it doesn't work in this case 
SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM NashvilleData

UPDATE NashvilleData
SET SaleDate = CONVERT(date, SaleDate)

-- So for the other way I use the Alter Table
ALTER TABLE NashvilleData
ADD SaleDateConverted DATE

UPDATE NashvilleData
SET SaleDateConverted = CONVERT(date, SaleDate)

ALTER TABLE NashvilleData
DROP COLUMN SaleDate

sp_rename 'NashvilleData.SaleDateConverted','SaleDate','COLUMN';

-- POPULATE PROPERTY ADDRESS DATA
------------------------------------------------------
/*There are several null data in PropertyAdress column. To fill in the empty data in the column can adjust to the same ParcelId, 
it's because the same ParcelId refer to the same PropertyAdress*/

SELECT *
FROM NashvilleData
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing..NashvilleData a
JOIN NashvilleHousing..NashvilleData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing..NashvilleData a
JOIN NashvilleHousing..NashvilleData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- SPLIT PROPERTY ADDRESS AND OWNER ADDRESS INTO INDIVIDUAL COLUMNS 
------------------------------------------------------
	
	--Using SUBSTRING and CHARINDEX
	
SELECT PropertyAddress
FROM NashvilleData

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS PropertySplitAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS PropertySplitCity
FROM NashvilleData

ALTER TABLE NashvilleData
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleData
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

	-- Using PARSENAME to split OwnerAddress

SELECT OwnerAddress
FROM NashvilleData

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleData

ALTER TABLE NashvilleData
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleData
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleData
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


-- CHANGE SOLD AS VACANT DATA FROM "N" TO "NO" AND "Y" TO "YES" 
----------------------------------------------------------------

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	     WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant 
	END
FROM NashvilleData

UPDATE NashvilleData
SET SoldAsVacant = 	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						 WHEN SoldAsVacant = 'N' THEN 'No'
						 ELSE SoldAsVacant 
					END
				FROM NashvilleData


-- REMOVE DUPLICATES DATA 
----------------------------------------------------------------

WITH RowNumCTE AS ( 
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY 
						ParcelID, 
						PropertyAddress, 
						SalePrice, 
						SaleDate,
						LegalReference
						ORDER BY UniqueID) Row_num
FROM NashvilleData
)

SELECT * 
FROM RowNumCTE
WHERE Row_num > 1
ORDER BY PropertyAddress

DELETE 
FROM RowNumCTE
WHERE Row_num > 1


