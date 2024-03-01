SELECT* FROM NashData

-- Standardize DateTime format in the saleDate column

Select SaleDate,CONVERT(Date,SalDate) 
From DataPortfolioDb..NashData

Alter Table NashData
Add SalDate Date;

Update NashData
Set SalDate = CONVERT(Date,SaleDate)

ALTER TABLE DataPortfolioDb..NashData
DROP COLUMN saleDate;

--Populate usind the ID to fill in missing data

Select Nash1.ParcelID,Nash1.PropertyAddress,Nash2.ParcelID,Nash2.PropertyAddress,ISNULL(Nash1.PropertyAddress,Nash2.PropertyAddress)
	From DataPortfolioDb..NashData Nash1
	Join DataPortfolioDb..NashData Nash2
	on Nash1.ParcelID = Nash2.ParcelID
	and Nash1.PropertyAddress<> Nash2.PropertyAddress
	Where Nash1.PropertyAddress is null

Update Nash1
Set PropertyAddress = ISNULL(Nash1.PropertyAddress,Nash2.PropertyAddress)
From DataPortfolioDb..NashData Nash1
	Join DataPortfolioDb..NashData Nash2
	on Nash1.ParcelID = Nash2.ParcelID
	and Nash1.PropertyAddress<> Nash2.PropertyAddress
	Where Nash1.PropertyAddress is null

--Creating two new Columns from PropertyAddress
Select
SUBSTRING(PropertyAddress,1,CharIndex(',',PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress,CharIndex(',',PropertyAddress) +1,LEN(PropertyAddress)) as City
From DataPortfolioDb..NashData

Alter Table NashData
Add PropAddress nvarchar(255) ;


Update NashData
Set  PropAddress = SUBSTRING(PropertyAddress,1,CharIndex(',',PropertyAddress) -1) 

Alter Table NashData
Add PropCity nvarchar(255);

Update NashData
Set PropCity  = SUBSTRING(PropertyAddress,CharIndex(',',PropertyAddress) +1,LEN(PropertyAddress))


--Creating two new Columns from OwenerAddress

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3), 
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)

From DataPortfolioDb..NashData

Alter Table NashData
Add OwnerNAddress Nvarchar(255);

Update NashData
Set OwnerNAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter Table NashData
Add OwnerNCity Nvarchar(255);

Update NashData
Set OwnerNCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table NashData
Add OwnerNState Nvarchar(255);

Update NashData
Set OwnerNState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Change value in Sold as vacant

Select SoldAsVacant 
,case when SoldAsVacant = 'y' Then 'Yes'
	  when SoldAsVacant = 'N' Then 'No'
	  Else SoldAsVacant 
	  End
From DataPortfolioDb..NashData

Update NashData 
Set  SoldAsVacant = case when SoldAsVacant = 'y' Then 'Yes'
	  when SoldAsVacant = 'N' Then 'No'
	  Else SoldAsVacant 
	  End
From DataPortfolioDb..NashData

--Remove Duplicates
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SalDate,
                         LegalReference
            ORDER BY UniqueID  -- Error: Missing ASC or DESC for sorting order
        ) AS row_num
    FROM DataPortfolioDb..NashData
	 
With RowNum AS
( SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SalDate,
                         LegalReference
            ORDER BY UniqueID  -- Error: Missing ASC or DESC for sorting order
        )  row_num
    FROM DataPortfolioDb..NashData 
)
Delete From RowNum
	where row_num >1

	Select* from RowNum
	--order by PropertyAddress
Select* from RowNum
where row_num >1-- to verify if it worked

--Delete unused column

Select* From DataPortfolioDb..NashData

Alter Table DataPortfolioDb..NashData
Drop Column OwnerAddress,TaxDistrict,PropertyAddress

