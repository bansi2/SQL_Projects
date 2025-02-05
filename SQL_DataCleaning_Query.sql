------------------------------------------------------------------------------------------------------------------
-- Data cleaning Project
------------------------------------------------------------------------------------------------------------------
--Project Direction
/*
	Step1) We will first convert all the salesDate in a yyyy/mm/dd manner
*/



select *
From PortfolioProject..HousingData
where PropertyAddress is null
update HousingData
set SaleDate = convert(Date,SaleDate)
-- update keyword is not updating the column so we will use alter table function

Alter table HousingData
Add SaleDateConverted Date;

update HousingData
Set SaleDateConverted = CONVERT(Date, SaleDate)


---------------------------------------------------------------------------------------------------------------------------
--Populating the property address : Basiclly what we are doning in this is that we will find the property address which is null and 
--find the same unique id of that property and check if it has address on it, if so we will populate it.
---------------------------------------------------------------------------------------------------------------------------
-- this was used to check for the null values
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..HousingData a
Join PortfolioProject..HousingData b
	on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- this code is used to update the table 
update a
set a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..HousingData a
Join PortfolioProject..HousingData b
	on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------------
--- Fixing Property Address with seperating it in address, city,state
--- We will be using Substring and CHARINDEX to separate the whole address in 2 parts
--- SUBSTRING(col_name, start_point, end_point)
--- CHARINDEX(find_char, Triming_till_that_char)
--------------------------------------------------------------------------------------------------------------------------------


Select  
Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as address,
Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as city
From PortfolioProject..HousingData

----For property address
Alter Table PortfolioProject..HousingData
Add Property_Address char(255);

Update PortfolioProject..HousingData
Set Property_Address = Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) 


----for city name

Alter Table PortfolioProject..HousingData
Add Property_city char(255);

Update PortfolioProject..HousingData
Set Property_city = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))



---------- Using PARSENAME to get address ,  city , state from owner address

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as owner_address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as owner_city,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as owner_state
From PortfolioProject..HousingData

---- Adding the owner address in new column
Alter Table PortfolioProject..HousingData
Add owner_address char(255);

Update PortfolioProject..HousingData
Set owner_address = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

--adding the owner city in new column
Alter Table PortfolioProject..HousingData
Add owner_city char(255);

Update PortfolioProject..HousingData
Set owner_city = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

--- adding the owner state in new column
Alter Table PortfolioProject..HousingData
Add owner_state char(255);

Update PortfolioProject..HousingData
Set owner_state = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


----------------------------------------------------------------------------------------------------------------------------
---- let's now convert the N and Y into NO and YES using Case statment
----------------------------------------------------------------------------------------------------------------------------

---- Basic code for converting the y and n to yes and no
select SoldAsVacant
	,Case When SoldAsVacant = 'N' Then 'No'
		 When SoldAsVacant = 'Y' Then 'Yes'
		 Else SoldAsVacant
	End
From PortfolioProject..HousingData 

---- Now we will use this logic in update query

Update PortfolioProject..HousingData
Set SoldAsVacant =	Case When SoldAsVacant = 'N' Then 'No'
						 When SoldAsVacant = 'Y' Then 'Yes'
						 Else SoldAsVacant
					End


---------------------------------------------------------------------------------------------------------------------------------------
---- Removing the Duplicates by using the CTE and windows function {Row_Number}
---------------------------------------------------------------------------------------------------------------------------------------

With RowDuplicate as(
Select *, Row_Number() over( 
							Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
							Order by UniqueId
							) row_dups
From PortfolioProject..HousingData
)

--Delete
--From RowDuplicate
--Where row_dups > 1

select * 
From RowDuplicate
Where row_dups > 1

--------------------------------------------------------------------------------------------------------------------------------
--- Deleting unwanted and unused columns
--------------------------------------------------------------------------------------------------------------------------------

Alter Table PortfolioProject..HousingData
Drop Column OwnerAddress,TaxDistrict, PropertyAddress

Select *
From PortfolioProject..HousingData