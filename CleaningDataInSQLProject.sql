/*

Cleaning Data in SQL Queries

*/

SELECT * 
FROM [PortfolioProject].[dbo].[NashvilleHousing]

--STANDARDIZE DATE FORMAT

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM [PortfolioProject].[dbo].[NashvilleHousing]

Update [PortfolioProject].[dbo].[NashvilleHousing]
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE	 [PortfolioProject].[dbo].[NashvilleHousing]
add SaleDateConverted Date; 

Update [PortfolioProject].[dbo].[NashvilleHousing]
SET SaleDateConverted = CONVERT(Date,SaleDate)

--POPULATE PROPERTY ADDRESS DATA FOR NULL ADDRESS VALUES

SELECT *
FROM [PortfolioProject].[dbo].[NashvilleHousing]
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID , b.PropertyAddress
FROM [PortfolioProject].[dbo].[NashvilleHousing] a
JOIN [PortfolioProject].[dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM [PortfolioProject].[dbo].[NashvilleHousing] a
JOIN [PortfolioProject].[dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM [PortfolioProject].[dbo].[NashvilleHousing]
--WHERE PropertyAddress is null
--ORDER BY

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))as Address
FROM [PortfolioProject].[dbo].[NashvilleHousing]

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
Add PropertySplitAddress nvarchar(255);

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
Add PropertySplitCity nvarchar(255)

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM [PortfolioProject].[dbo].[NashvilleHousing]

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
Add OwnerSplitAddress nvarchar(255);

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
Add OwnerSplitCity nvarchar(255)

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
Add OwnerSplitState nvarchar(255)

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

--Change Y and N to Yes and No in "Sold as Vacant" Field

SELECT Distinct SoldAsVacant, COUNT(SoldAsVacant)
FROM [PortfolioProject].[dbo].[NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM [PortfolioProject].[dbo].[NashvilleHousing]

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID, 
					PropertyAddress,
					SalePrice, 
					SaleDate, 
					LegalReference
					ORDER BY
						UniqueID
						) row_num


FROM [PortfolioProject].[dbo].[NashvilleHousing]
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1

--Delete Unused Columns

SELECT *
FROM [PortfolioProject].[dbo].[NashvilleHousing]

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
