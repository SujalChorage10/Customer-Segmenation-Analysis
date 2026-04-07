SELECT * FROM cleaned_marketing_campaign_data;

UPDATE cleaned_marketing_campaign_data
SET Dt_Customer = 
    substr(Dt_Customer, 7, 4) || '-' ||
    substr(Dt_Customer, 4, 2) || '-' ||
    substr(Dt_Customer, 1, 2);

SELECT Dt_Customer FROM cleaned_marketing_campaign_data LIMIT 10;

--FEATURE ENGINEERING --

CREATE TABLE marketing_clean AS
SELECT *,
    (2026 - Year_Birth) AS Age,
    (Kidhome + Teenhome) AS Total_Children,
    (MntWines + MntFruits + MntMeatProducts + 
     MntFishProducts + MntSweetProducts + MntGoldProds) AS Total_Spending,
    (NumWebPurchases + NumCatalogPurchases + NumStorePurchases) AS Total_Purchases
FROM cleaned_marketing_campaign_data;

SELECT * FROM marketing_clean LIMIT 10;


--CUSTOMER SEGMENTATION ANALYSIS--

SELECT 
    CASE 
        WHEN Income < 30000 THEN 'Low Income'
        WHEN Income BETWEEN 30000 AND 70000 THEN 'Mid Income'
        ELSE 'High Income'
    END AS Income_Group,
    COUNT(*) AS Customers
FROM marketing_clean
GROUP BY 1;


--CUSTOMER SEGMENTATION: SPENDING INSIGHT--
SELECT 
    CASE 
        WHEN Income < 30000 THEN 'Low Income'
        WHEN Income BETWEEN 30000 AND 70000 THEN 'Mid Income'
        ELSE 'High Income'
    END AS Income_Group,
    COUNT(*) AS Customers,
    AVG(Total_Spending) AS Avg_Spending
FROM marketing_clean
GROUP BY 1;

--CUSTOMER SEGMENTATION: PURCHASE BEHAVIOUR--
SELECT 
    CASE 
        WHEN Income < 30000 THEN 'Low Income'
        WHEN Income BETWEEN 30000 AND 70000 THEN 'Mid Income'
        ELSE 'High Income'
    END AS Income_Group,
    COUNT(*) AS Customers,
    AVG(Total_Purchases) AS Avg_Purchases
FROM marketing_clean
GROUP BY 1;

-- CAMPAIGN CONVERSION RATE--
SELECT COUNT (*)
FILTER (WHERE Response=1)*100.0/count(*) as Conversion_Rate
FROM marketing_clean;


--Channel Performance Analysis--
SELECT 
    SUM(NumWebPurchases) AS Web,
    SUM(NumCatalogPurchases) AS Catalog,
    SUM(NumStorePurchases) AS Store
FROM marketing_clean;

--Recency Analysis--
SELECT 
    CASE 
        WHEN Recency < 30 THEN 'Active'
        WHEN Recency BETWEEN 30 AND 90 THEN 'Warm'
        ELSE 'Inactive'
    END AS Customer_Status,
    COUNT(*) 
FROM marketing_clean
GROUP BY Customer_Status;

-- Campaign Effectivness--
SELECT 
    Response,
    AVG(NumWebPurchases) AS Web,
    AVG(NumStorePurchases) AS Store
FROM marketing_clean
GROUP BY Response;




--Feature Engineering: Customer Lifetime Value Analysis--

ALTER TABLE marketing_clean  ADD COLUMN Total_Spending REAL;
ALTER TABLE marketing_clean  ADD COLUMN Total_Purchases INT;
ALTER TABLE marketing_clean  ADD COLUMN Customer_Tenure REAL;

SELECT * FROM marketing_clean mc  

UPDATE marketing_clean
SET 
    Total_Spending = 
        COALESCE(MntWines, 0) + 
        COALESCE(MntFruits, 0) + 
        COALESCE(MntMeatProducts, 0) + 
        COALESCE(MntFishProducts, 0) + 
        COALESCE(MntSweetProducts, 0) + 
        COALESCE(MntGoldProds, 0),

    Total_Purchases = 
        COALESCE(NumWebPurchases, 0) + 
        COALESCE(NumCatalogPurchases, 0) + 
        COALESCE(NumStorePurchases, 0),

    Customer_Tenure = 
        2026 - CAST(substr(Dt_Customer, 7, 4) AS INT);

 SELECT* FROM marketing_clean mc 
 LIMIT 10;
    
    
SELECT 
    ID,
    Total_Spending,
    Customer_Tenure,
    Total_Spending * Customer_Tenure AS CLV
FROM marketing_clean mc;

SELECT* FROM marketing_clean mc ;

SELECT
    CASE 
        WHEN (Total_Spending * Customer_Tenure) > 2000000 THEN 'High Value'
        WHEN (Total_Spending * Customer_Tenure) BETWEEN 1000000 AND 2000000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS CLV_Segment,
    COUNT(*) AS Customers
FROM marketing_clean
GROUP BY CLV_Segment
ORDER BY CLV_Segment  DESC;

-- List of high value customers--
SELECT *
FROM marketing_clean
WHERE (Total_Spending * Customer_Tenure) > 2000000 ;

--List of medium value customers--
SELECT *
FROM marketing_clean
WHERE (Total_Spending * Customer_Tenure) BETWEEN 1000000 AND 2000000;

-- List of Loe value customers--
SELECT*
FROM marketing_clean
WHERE (Total_Spending * Customer_Tenure) < 1000000;

