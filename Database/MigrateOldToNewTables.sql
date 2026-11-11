-- =====================================================================
-- SCRIPT DE MIGRATION DYNAMIQUE (NGNEX_DB)
-- =====================================================================
-- Ce script détecte automatiquement les noms de colonnes de vos anciennes tables
-- ('categories' et 'products') et migre les données vers ('categorie' et 'product').
-- =====================================================================

USE NGNEX_DB;
GO

-- 1. Suppression des contraintes de clés étrangères pointant vers categories / products
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id))
    + N'.' + QUOTENAME(OBJECT_NAME(parent_object_id))
    + N' DROP CONSTRAINT ' + QUOTENAME(name) + N';'
FROM sys.foreign_keys
WHERE referenced_object_id IN (OBJECT_ID('dbo.categories'), OBJECT_ID('dbo.products'));

IF LEN(@sql) > 0
    EXEC sp_executesql @sql;
GO

-- 2. MIGRATION DES CATÉGORIES (old 'categories' -> new 'categorie')
IF OBJECT_ID('dbo.categories', 'U') IS NOT NULL
BEGIN
    SET IDENTITY_INSERT dbo.categorie ON;

    DECLARE @colNom VARCHAR(50) = 'nom';
    IF COL_LENGTH('dbo.categories', 'name') IS NOT NULL SET @colNom = 'name';

    DECLARE @colImg VARCHAR(50) = 'image_url';
    IF COL_LENGTH('dbo.categories', 'image') IS NOT NULL SET @colImg = 'image';

    DECLARE @sqlCat NVARCHAR(MAX);
    SET @sqlCat = N'INSERT INTO dbo.categorie (id, nom, description, image_url) ' +
                  N'SELECT id, ' + QUOTENAME(@colNom) + N', description, ' +
                  IIF(COL_LENGTH('dbo.categories', @colImg) IS NOT NULL, QUOTENAME(@colImg), 'NULL') +
                  N' FROM dbo.categories WHERE id NOT IN (SELECT id FROM dbo.categorie);';

    EXEC sp_executesql @sqlCat;
    SET IDENTITY_INSERT dbo.categorie OFF;
    PRINT 'Migration des catégories réussie.';
END
GO

-- 3. MIGRATION DYNAMIQUE DES PRODUITS (old 'products' -> new 'product')
IF OBJECT_ID('dbo.products', 'U') IS NOT NULL
BEGIN
    SET IDENTITY_INSERT dbo.product ON;

    -- Détection automatique des colonnes existantes dans 'products'
    DECLARE @pNom VARCHAR(50) = 'nom';
    IF COL_LENGTH('dbo.products', 'name') IS NOT NULL SET @pNom = 'name';
    IF COL_LENGTH('dbo.products', 'libelle') IS NOT NULL SET @pNom = 'libelle';

    DECLARE @pRef VARCHAR(50) = 'reference';
    IF COL_LENGTH('dbo.products', 'ref') IS NOT NULL SET @pRef = 'ref';
    IF COL_LENGTH('dbo.products', 'code_article') IS NOT NULL SET @pRef = 'code_article';

    DECLARE @pBar VARCHAR(50) = 'barcode';
    IF COL_LENGTH('dbo.products', 'code_barre') IS NOT NULL SET @pBar = 'code_barre';

    DECLARE @pPrix VARCHAR(50) = 'prix';
    IF COL_LENGTH('dbo.products', 'price') IS NOT NULL SET @pPrix = 'price';
    IF COL_LENGTH('dbo.products', 'prix_ht') IS NOT NULL SET @pPrix = 'prix_ht';

    DECLARE @pStock VARCHAR(50) = 'stock';
    IF COL_LENGTH('dbo.products', 'quantity') IS NOT NULL SET @pStock = 'quantity';
    IF COL_LENGTH('dbo.products', 'qte') IS NOT NULL SET @pStock = 'qte';

    DECLARE @pImg VARCHAR(50) = 'image_url';
    IF COL_LENGTH('dbo.products', 'image') IS NOT NULL SET @pImg = 'image';

    DECLARE @pSpec VARCHAR(50) = 'caracteristiques';
    IF COL_LENGTH('dbo.products', 'specs') IS NOT NULL SET @pSpec = 'specs';
    IF COL_LENGTH('dbo.products', 'fiche_technique') IS NOT NULL SET @pSpec = 'fiche_technique';

    -- Construction dynamique de la requête SQL
    DECLARE @sqlProd NVARCHAR(MAX);
    SET @sqlProd = N'INSERT INTO dbo.product (id, category_id, nom, reference, barcode, description, prix, stock, image_url, caracteristiques) ' +
                   N'SELECT id, category_id, ' +
                   QUOTENAME(@pNom) + N', ' +
                   IIF(@pRef IS NOT NULL and COL_LENGTH('dbo.products', @pRef) IS NOT NULL, QUOTENAME(@pRef), '''''') + N', ' +
                   IIF(@pBar IS NOT NULL and COL_LENGTH('dbo.products', @pBar) IS NOT NULL, QUOTENAME(@pBar), 'NULL') + N', ' +
                   IIF(COL_LENGTH('dbo.products', 'description') IS NOT NULL, 'description', 'NULL') + N', ' +
                   IIF(@pPrix IS NOT NULL and COL_LENGTH('dbo.products', @pPrix) IS NOT NULL, QUOTENAME(@pPrix), '0') + N', ' +
                   IIF(@pStock IS NOT NULL and COL_LENGTH('dbo.products', @pStock) IS NOT NULL, QUOTENAME(@pStock), '0') + N', ' +
                   IIF(@pImg IS NOT NULL and COL_LENGTH('dbo.products', @pImg) IS NOT NULL, QUOTENAME(@pImg), 'NULL') + N', ' +
                   IIF(@pSpec IS NOT NULL and COL_LENGTH('dbo.products', @pSpec) IS NOT NULL, QUOTENAME(@pSpec), 'NULL') +
                   N' FROM dbo.products WHERE id NOT IN (SELECT id FROM dbo.product);';

    EXEC sp_executesql @sqlProd;
    SET IDENTITY_INSERT dbo.product OFF;
    PRINT 'Migration des produits réussie.';
END
GO

-- 4. Suppression des anciennes tables
IF OBJECT_ID('dbo.categories', 'U') IS NOT NULL DROP TABLE dbo.categories;
IF OBJECT_ID('dbo.products', 'U') IS NOT NULL DROP TABLE dbo.products;
IF OBJECT_ID('dbo.products_backup_20261020', 'U') IS NOT NULL DROP TABLE dbo.products_backup_20261020;
GO

PRINT '====================================================================='
PRINT 'MIGRATION ET NETTOYAGE TERMINÉS AVEC SUCCÈS !';
PRINT '====================================================================='
GO
