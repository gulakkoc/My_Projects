

-- NASHVILLE HOUSING - DATA CLEANING W/SQL

SELECT *
FROM Nashville
ORDER BY ParcelID

SELECT *
FROM Nashville
WHERE PropertyAddress IS NULL

/* We have some missing values in property address. However, there is a way to fill them up. 
Even though Unique ID is unique, parcel id is not unique. Whenever the parcel ids are the same, the addresses are the same.
As sale prices are different, I will assume that they are not duplicates, even though rest of them pretty much the same. As below example,
when the parcel id is the same, addresses are also the same but the sale prices are different. So, we are going to fill null property addresses
by using their parcel id.*/


/*UniqueID 	ParcelID	LandUse	PropertyAddress	SaleDate	SalePrice	LegalReference	SoldAsVacant	OwnerName	OwnerAddress	Acreage	TaxDistrict	LandValue	BuildingValue	TotalValue	YearBuilt	Bedrooms	FullBath	HalfBath
38174	061 15 0 015.00	SINGLE FAMILY	3916  BURRUS ST, NASHVILLE	2015-09-18 00:00:00.000	*****126500*****	20150928-0098269	No	KENNEDY, JACQUELINE	3916  BURRUS ST, NASHVILLE, TN	0.27	URBAN SERVICES DISTRICT	30000	81300	112100	1948	2	1	0
47093	061 15 0 015.00	SINGLE FAMILY	3916  BURRUS ST, NASHVILLE	2016-04-25 00:00:00.000	*****244900*****	20160428-0041279	No	KENNEDY, JACQUELINE	3916  BURRUS ST, NASHVILLE, TN	0.27	URBAN SERVICES DISTRICT	30000	81300	112100	1948	2	1	0 */


-- Here are the ones that we can fill by using their parcel id.
SELECT *
FROM Nashville
WHERE ParcelID IN

(SELECT ParcelID
FROM Nashville
WHERE PropertyAddress IS NULL)



SELECT A.ParcelID, B.ParcelID, A.PropertyAddress, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Nashville A
JOIN NASHVILLE B ON A.ParcelID = B.ParcelID
WHERE A.PropertyAddress IS NULL AND A.[UniqueID ]<> B.[UniqueID ]
ORDER BY A.ParcelID

-- Filling missing property addresses which were null.

Update a
set a.PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Nashville A
JOIN NASHVILLE B ON A.ParcelID = B.ParcelID
WHERE A.PropertyAddress IS NULL AND A.[UniqueID ]<> B.[UniqueID ]




SELECT landuse, count(LandUse)
FROM Nashville
group by LandUse
order by count(LandUse) desc

/*
landuse	(No column name)
SINGLE FAMILY	34197
**RESIDENTIAL CONDO	14080
VACANT RESIDENTIAL LAND	3547
VACANT RES LAND	1549
DUPLEX	1373
ZERO LOT LINE	1048
**CONDO	247
**RESIDENTIAL COMBO/MISC	95
TRIPLEX	92
QUADPLEX	39
**CONDOMINIUM OFC  OR OTHER COM CONDO	35
CHURCH	34
MOBILE HOME	20
DORMITORY/BOARDING HOUSE	19
SPLIT CLASS	17
VACANT COMMERCIAL LAND	17
PARKING LOT	11
FOREST	10
GREENBELT	10
PARSONAGE	6
GREENBELT/RES
GRRENBELT/RES	3
VACANT RESIENTIAL LAND	3
RESTURANT/CAFETERIA	2
NON-PROFIT CHARITABLE SERVICE	2
OFFICE BLDG (ONE OR TWO STORIES)	2
TERMINAL/DISTRIBUTION WAREHOUSE	2
VACANT RURAL LAND	2
VACANT ZONED MULTI FAMILY	2
APARTMENT: LOW RISE (BUILT SINCE 1960)	2
DAY CARE CENTER	2
NIGHTCLUB/LOUNGE	1
CLUB/UNION HALL/LODGE	1
CONVENIENCE MARKET WITHOUT GAS	1
METRO OTHER THAN OFC, SCHOOL,HOSP, OR PARK	1
STRIP SHOPPING CENTER	1
LIGHT MANUFACTURING	1
MORTUARY/CEMETERY	1
SMALL SERVICE SHOP	1
ONE STORY GENERAL RETAIL STORE	1 */	

/* To be able to have better analysis and better visualization, I will try to organize landuse column.
I will start with fixing the typos and grouping the same or similar type of lands under one name such as condos.*/


SELECT landuse, SalePrice, 
min(saleprice) over (partition by landuse) as minprice , 
max(saleprice) over (partition by landuse) as maxprice, 
avg(saleprice) over (partition by landuse) as avgprice
FROM Nashville
where LandUse in ('RESIDENTIAL CONDO','CONDO','RESIDENTIAL COMBO/MISC','CONDOMINIUM OFC  OR OTHER COM CONDO')

/*With above query, we can see that the prices are pretty much in the same range. 
Thus, I will go ahead and call all of them as 'Condo'.*/

Update Nashville
set LandUse = 'CONDO'
FROM Nashville 
where LandUse in ('RESIDENTIAL CONDO','Condo','RESIDENTIAL COMBO/MISC','CONDOMINIUM OFC  OR OTHER COM CONDO')

SELECT landuse, count(LandUse)
FROM Nashville
group by LandUse
order by count(LandUse) desc

Update Nashville
set LandUse = 'OTHER'
FROM Nashville 
where LandUse in ('QUADPLEX',	'CHURCH',	'MOBILE HOME',	'DORMITORY/BOARDING HOUSE',	'SPLIT CLASS',	'VACANT COMMERCIAL LAND',	
'PARKING LOT',	'GREENBELT',	'FOREST',	'PARSONAGE',	'VACANT RESIENTIAL LAND',	'GREENBELT/RES',	'GRRENBELT/RES',	
'DAY CARE CENTER',	'APARTMENT: LOW RISE (BUILT SINCE 1960)',	'VACANT RURAL LAND',	'TERMINAL/DISTRIBUTION WAREHOUSE',	
'RESTURANT/CAFETERIA',	'NON-PROFIT CHARITABLE SERVICE',	'OFFICE BLDG (ONE OR TWO STORIES)',	'VACANT ZONED MULTI FAMILY',	
'SMALL SERVICE SHOP',	'LIGHT MANUFACTURING',	'MORTUARY/CEMETERY',	'METRO OTHER THAN OFC, SCHOOL,HOSP, OR PARK',	
'CONVENIENCE MARKET WITHOUT GAS',	'GREENBELT/RES
GRRENBELT/RES', 'ONE STORY GENERAL RETAIL STORE',	'CLUB/UNION HALL/LODGE',	'NIGHTCLUB/LOUNGE',	'STRIP SHOPPING CENTER', 'TRIPLEX')

SELECT LANDUSE, COUNT(LANDUSE)
FROM Nashville
group by LandUse


SELECT *
FROM Nashville


/* We need to split property address in 2 as address and city, to be able to use it effectively.

To split them, I will be using parsename, since it is very easy to use. However, as parsename only will see periods, first I will 
replace commas with periods and then split the string.*/



SELECT parsename(replace(PropertyAddress,',','.'),2)
FROM Nashville

ALTER TABLE NASHVILLE
ADD PropertyAddressSplit nvarchar(255);

UPDATE Nashville
SET PROPERTYADDRESSSPLIT = parsename(replace(PropertyAddress,',','.'),2)

SELECT *
FROM Nashville

ALTER TABLE NASHVILLE
ADD PropertyCitySplit nvarchar(255);

UPDATE Nashville
SET PropertyCitySplit = parsename(replace(PropertyAddress,',','.'),1)


/* Now, we need to remove time from SaleDate as there is not time data.*/


SELECT cast(saledate as date)
FROM Nashville



ALTER TABLE NASHVILLE
ADD SaleDateConverted date;

UPDATE Nashville
SET SaleDateConverted = cast(saledate as date)


SELECT * FROM Nashville


select distinct(soldasvacant)
from Nashville

/* In SoldAsVacant column, we have N, No, Y and Yes. I will convert N as No and Y as Yes.

soldasvacant
N
Yes
Y
No
*/

UPDATE Nashville
SET SoldAsVacant = 'No'
where SoldAsVacant = 'N'

UPDATE Nashville
SET SoldAsVacant = 'Yes'
where SoldAsVacant = 'Y'

select distinct(soldasvacant)
from Nashville

--Now We only have Yes and No.

select * from Nashville;

-- I will do the same to owneraddress whatever we have done for property address


SELECT *
FROM Nashville
ORDER BY ParcelID

ALTER TABLE NASHVILLE
ADD OwnerAddressSplit nvarchar(255);

UPDATE Nashville
SET OwnerADDRESSSPLIT = parsename(replace(OwnerAddress,',','.'),3)

SELECT *
FROM Nashville

ALTER TABLE NASHVILLE
ADD OwnerCitySplit nvarchar(255);

UPDATE Nashville
SET OwnerCitySplit = parsename(replace(OwnerAddress,',','.'),2)

ALTER TABLE NASHVILLE
ADD OwnerStateSplit nvarchar(255);

UPDATE Nashville
SET OwnerStateSplit = parsename(replace(OwnerAddress,',','.'),1)




SELECT A.ParcelID, B.ParcelID, A.SalePrice, B.SalePrice
FROM Nashville A
JOIN NASHVILLE B ON A.ParcelID = B.ParcelID
WHERE A.SalePrice IS NULL AND A.[UniqueID ]<> B.[UniqueID ]
ORDER BY A.ParcelID

select distinct(TaxDistrict) from Nashville


-- Now, I will create a new table with the information that I will probably be using.

/*

USE [Nashville Housing]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Nashville_Housing_Clean](
	[UniqueID ] [float] NULL,
	[ParcelID] [nvarchar](255) NULL,
	[LandUse] [nvarchar](255) NULL,
	[SalePrice] [float] NULL,
	[SaleDate] [date] NULL,
	[PropertyAddress] [nvarchar](255) NULL,
	[PropertyCity] [nvarchar](255) NULL,
	[SoldAsVacant] [nvarchar](255) NULL,
	[Acreage] [float] NULL,
	[TaxDistrict] [nvarchar](255) NULL,
	[LandValue] [float] NULL,
	[BuildingValue] [float] NULL,
	[TotalValue] [float] NULL,
	[YearBuilt] [float] NULL,
	[Bedrooms] [float] NULL,
	[FullBath] [float] NULL,
	[HalfBath] [float] NULL,
	[OwnerAddress] [nvarchar](255) NULL,
	[OwnerCity] [nvarchar](255) NULL,
	[OwnerState] [nvarchar](255) NULL
) ON [PRIMARY]
GO
*/

/*

INSERT INTO Nashville_Housing_Clean SELECT 
  [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[SalePrice]
      ,[SaleDate]
      ,[PropertyAddressSplit]
      ,[PropertyCitySplit]
      ,[SoldAsVacant]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
      ,[OwnerAddress]
      ,[OwnerCitySplit]
      ,[OwnerStateSplit]
	  FROM Nashville;
*/



select * from Nashville_Housing_Clean