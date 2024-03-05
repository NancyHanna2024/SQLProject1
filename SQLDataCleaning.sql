--Cleaning data in SQL Queries
--select * from PortfolioProject.dbo.NashvilleHousing
--Standardize Date Format
-- if you select SaleDate it will be in DateTime format
--TO Convert it into Date format
select SaleDate ,CONVERT(date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing
--if you try the following code it won't change the DateTime format
update PortfolioProject.dbo.NashvilleHousing
set SaleDate=CONVERT(date,SaleDate)
--To get the SaleDate in Date format we alter the
--table by creating a new column as following 
--First step: run the following code
Alter table  PortfolioProject.dbo.NashvilleHousing
add SaleDateConverted date ;
--Second step :comment the previous code and run the following code
update PortfolioProject.dbo.NashvilleHousing
set SaleDateConverted=CONVERT(date,SaleDate)

select SaleDateConverted 
from PortfolioProject.dbo.NashvilleHousing

--populate property address data تعبئة بيانات عنوان العقار
--some of PropertyAddress=Null
select ParcelID ,PropertyAddress 
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress  IS NULL
/*WE note that if the ParcelIDs of two properties are equal then they have the same PropertyAddress
so instead of Nulls we can fill the same PropertyAddress for porperties which owne the same ParcelIDs ,,in order to do so we will join the table to itself*/
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress 
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
--علشان نحط نفس العنوان نعمل الكود التالى
update a --you should use an alias not the original name or you will get an error
set a.PropertyAddress=ISnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out the Address into individual columns
--(address , city, state)
select PropertyAddress,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))as City
from PortfolioProject.dbo.NashvilleHousing 

alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitAddress nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitCity nvarchar(255);
update PortfolioProject.dbo.NashvilleHousing
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
--
select *
from PortfolioProject.dbo.NashvilleHousing

--Breaking the owner Address into (address , city, state)

select OwnerAddress,parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing


alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress=parsename(replace(OwnerAddress,',','.'),3)

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitCity nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitCity=parsename(replace(OwnerAddress,',','.'),2)

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitState nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitState=parsename(replace(OwnerAddress,',','.'),1)

select * 
from PortfolioProject.dbo.NashvilleHousing

--Change Y and N to Yes and No in SoldAsVacant field
select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant

--

select (SoldAsVacant),
case 
    when SoldAsVacant='N' then 'No'
	when SoldAsVacant='Y' then 'Yes'
	else SoldAsVacant
end

from PortfolioProject.dbo.NashvilleHousing
order by SoldAsVacant

update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant=case 
    when SoldAsVacant='N' then 'No'
	when SoldAsVacant='Y' then 'Yes'
	else SoldAsVacant
end

select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
--Remove Duplicates
with RowNumCTE
AS
(
select parcelid,PropertyAddress,SalePrice,SaleDate,LegalReference,ROW_NUMBER() 
over (partition by parcelid,PropertyAddress,saleprice,saledate,
legalreference
      order by parcelid )as Row_num
from PortfolioProject.dbo.NashvilleHousing
)
SELECT * FROM RowNumCTE
WHERE Row_num >1
ORDER BY PropertyAddress
--Then we exchange the select word with delete word and rerun the code
with RowNumCTE AS
(
select parcelid,PropertyAddress,SalePrice,SaleDate,LegalReference,ROW_NUMBER() 
over (partition by parcelid,PropertyAddress,saleprice,saledate,
legalreference
      order by parcelid )as Row_num
from PortfolioProject.dbo.NashvilleHousing
)
delete   FROM RowNumCTE
WHERE Row_num >1
--To be sure of deleted rows we rerun the code with select 
with RowNumCTE AS
(
select parcelid,PropertyAddress,SalePrice,SaleDate,LegalReference,ROW_NUMBER() 
over (partition by parcelid,PropertyAddress,saleprice,saledate,
legalreference
      order by parcelid )as Row_num
from PortfolioProject.dbo.NashvilleHousing
)
select *   FROM RowNumCTE
WHERE Row_num >1
