Select *
From dbo.NashvilleHousing

--Standardize Date Format

----- Step 2.-----

Select saleDateConverted, CONVERT(Date, SaleDate)
From [Portfolioversion1.0] ..NashvilleHousing

Update NashvilleHousing 
set SaleDateConverted = CONVERT(date, SaleDate)

-------Step 1.----
Alter Table NashvilleHousing 
add saledateconverted date;

Update NashvilleHousing 
set SaleDateConverted = CONVERT(date, SaleDate)

---- Populate Property Address data


Select *
From dbo.NashvilleHousing
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From  dbo.NashvilleHousing a
JOIN  dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From dbo.NashvilleHousing 
-----

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
------

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Select *
From dbo.NashvilleHousing

-----------
ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);
------------

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

---------------
Select *
From dbo.NashvilleHousing

-----------

Select OwnerAddress
From dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From dbo.NashvilleHousing

-------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From dbo.NashvilleHousing
Group by SoldAsVacant
order by 2



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


---------------------------------


-- Delete Unused Columns



Select *
From dbo.NashvilleHousing


ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate