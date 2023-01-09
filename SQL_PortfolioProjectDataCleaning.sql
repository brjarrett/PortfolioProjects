/* Cleaning data in SQL
*/

Select *
FROM PortfolioProject..NashvilleHousing


-- Standardized date format (sale date)

Select SaleDate, CONVERT(DATE, SaleDate)
FROM PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate) -- this does not work, no change made (still has date/time)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted DATE;
Update PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

Select SaleDateConverted
FROM PortfolioProject..NashvilleHousing

-- Populate Property Address Data

Select *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress is null

Select *
FROM PortfolioProject..NashvilleHousing
-- WHERE PropertyAddress is null
ORDER BY ParcelID

-- Do self join to be able to match parcel ID to property address and for duplicate parcel IDs use one to fill in a property address with null value

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE a -- need to use alias for update statement
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

-- Breaking out address into individual columns (address, city, state)

Select PropertyAddress
FROM PortfolioProject..NashvilleHousing
-- WHERE PropertyAddress is null
-- ORDER BY ParcelID

-- CHARINDEX(',', PropertyAddress) gives position the comma is found, if we use -1 in substring we select one position before the comma
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousing

-- now add two new columns to add the address change in

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);
Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);
Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
FROM PortfolioProject..NashvilleHousing


-- now look at owner address.  note, PARSENAME only works with periods, so need to change our comma delimator to a period. Also, PARSENAME runs backwarks so go from last deliminator to the first, in this case we have 3 things to separate out

Select OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing

-- now add three new columns to add the address changes in

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);
Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);
Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);
Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
FROM PortfolioProject..NashvilleHousing

-- had to run through one by one, to make more efficient, should look like:
ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
ADD OwnerSplitCity NVARCHAR(255),
ADD OwnerSplitState NVARCHAR(255);
Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change Y and N to yes and no in "sold as vacant" field

-- use distinct func to see problem (have yes, y, no, and n)
SELECT DISTINCT(SoldASVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldASVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

-- Remove Duplicates
-- make a CTE to querry off

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY 
				UniqueID
				) row_num
FROM PortfolioProject..NashvilleHousing
-- ORDER BY ParcelID
)


-- Check code, 104 duplicate entries
--Select *
--FROM RowNumCTE
--Where row_num > 1
--ORDER BY PropertyAddress

DELETE
FROM RowNumCTE
Where row_num > 1

-- Delete unused Columns (original columns that were not clean data format)

Select *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



