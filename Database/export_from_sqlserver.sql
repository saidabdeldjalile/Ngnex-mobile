-- =====================================================================
-- SCRIPT DE MIGRATION & EXPORTATION : SQL SERVER (NGNEX_DB) -> SQLITE / REST
-- =====================================================================
-- À exécuter dans SQL Server Management Studio (SSMS) sur la base NGNEX_DB
-- =====================================================================

USE NGNEX_DB;
GO

-- 1. Vérification de la structure des tables SQL Server
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('product', 'categorie', 'products', 'categories')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
GO

-- 2. Génération automatique du JSON pour l'API REST NGNEX (Catégories)
SELECT (
    SELECT
        id AS [id],
        nom AS [nom],
        ISNULL(description, '') AS [description],
        ISNULL(image_url, '') AS [image_url]
    FROM dbo.categorie
    FOR JSON PATH
) AS CategoriesJSON;
GO

-- 3. Génération automatique du JSON pour l'API REST NGNEX (Produits)
SELECT (
    SELECT
        p.id AS [id],
        p.category_id AS [category_id],
        ISNULL(c.nom, '') AS [category_name],
        p.nom AS [nom],
        p.reference AS [reference],
        ISNULL(p.barcode, '') AS [barcode],
        ISNULL(p.description, '') AS [description],
        p.prix AS [prix],
        p.stock AS [stock],
        ISNULL(p.image_url, '') AS [image_url],
        ISNULL(p.caracteristiques, '') AS [caracteristiques]
    FROM dbo.product p
    LEFT JOIN dbo.categorie c ON p.category_id = c.id
    FOR JSON PATH
) AS ProductsJSON;
GO

-- 4. Exemples d'INSERT direct pour SQLite (à copier dans database.sql si besoin)
SELECT
    'INSERT OR REPLACE INTO Categorie (id, nom, description, image_url) VALUES (' +
    CAST(id AS VARCHAR) + ', ' +
    'N''' + REPLACE(nom, '''', '''''') + ''', ' +
    'N''' + REPLACE(ISNULL(description, ''), '''', '''''') + ''', ' +
    'N''' + REPLACE(ISNULL(image_url, ''), '''', '''''') + ''');'
FROM dbo.categorie;

SELECT
    'INSERT OR REPLACE INTO Product (id, category_id, nom, reference, barcode, description, prix, stock, image_url, caracteristiques) VALUES (' +
    CAST(id AS VARCHAR) + ', ' +
    CAST(category_id AS VARCHAR) + ', ' +
    'N''' + REPLACE(nom, '''', '''''') + ''', ' +
    'N''' + REPLACE(reference, '''', '''''') + ''', ' +
    'N''' + REPLACE(ISNULL(barcode, ''), '''', '''''') + ''', ' +
    'N''' + REPLACE(ISNULL(description, ''), '''', '''''') + ''', ' +
    CAST(prix AS VARCHAR) + ', ' +
    CAST(stock AS VARCHAR) + ', ' +
    'N''' + REPLACE(ISNULL(image_url, ''), '''', '''''') + ''', ' +
    'N''' + REPLACE(ISNULL(caracteristiques, ''), '''', '''''') + ''');'
FROM dbo.product;
GO
