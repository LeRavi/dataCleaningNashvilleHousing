/*
data cleaning in sql queries
*/

Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format remove time


Select saleDate2, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- alter tabler and update instead ^ not working

ALTER TABLE NashvilleHousing
Add SaleDate2 Date;

Update NashvilleHousing
SET SaleDate2 = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data, parcelID and propertyAddress is the same 

Select *
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID




Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address --(-1) to remove the ,
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address -- (+1) to start from after the , 

From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplittetAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplittetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplittetCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplittetCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select * -- check result
From PortfolioProject.dbo.NashvilleHousing





Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

-- faster way to split column use parsename

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) -- need to replace the , with . thats what parsename looks for, it does it backwards
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplittetAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplittetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplittetCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplittetCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplittetState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplittetState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

-- check count
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

-- change y and n to yes and no
Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates for practice purpose
-- create cte
-- assuming the choosen partition list holds enough information to make the row a duplicate
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate2,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

