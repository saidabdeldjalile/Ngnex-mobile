-- =====================================================================
-- SCRIPT DE CRÉATION DES TABLES SQL SERVER (Base : NGNEX_DB)
-- =====================================================================
-- Assurez-vous que la base NGNEX_DB existe et est sélectionnée dans SSMS.
-- =====================================================================

USE NGNEX_DB;
GO

-- 1. SUPPRESSION DES ANCIENNES TABLES (Si réinitialisation requise)
IF OBJECT_ID('dbo.quote_items', 'U') IS NOT NULL DROP TABLE dbo.quote_items;
IF OBJECT_ID('dbo.quotes', 'U') IS NOT NULL DROP TABLE dbo.quotes;
IF OBJECT_ID('dbo.cart_items', 'U') IS NOT NULL DROP TABLE dbo.cart_items;
IF OBJECT_ID('dbo.product', 'U') IS NOT NULL DROP TABLE dbo.product;
IF OBJECT_ID('dbo.categorie', 'U') IS NOT NULL DROP TABLE dbo.categorie;
GO

-- =====================================================================
-- 2. CRÉATION DES TABLES PRINCIPALES
-- =====================================================================

-- Table 1: Catégories de produits NGNEX
CREATE TABLE dbo.categorie (
    id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_categorie PRIMARY KEY CLUSTERED,
    nom NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX) NULL,
    image_url NVARCHAR(500) NULL,
    created_at DATETIME NOT NULL CONSTRAINT DF_categorie_created DEFAULT GETDATE()
);
GO

-- Table 2: Catalogue de produits NGNEX (Matériel POS, Caisse, Informatique)
CREATE TABLE dbo.product (
    id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_product PRIMARY KEY CLUSTERED,
    category_id INT NOT NULL,
    nom NVARCHAR(200) NOT NULL,
    reference NVARCHAR(50) NOT NULL,
    barcode NVARCHAR(50) NULL,
    description NVARCHAR(MAX) NULL,
    prix DECIMAL(18, 2) NOT NULL CONSTRAINT DF_product_prix DEFAULT 0.00,
    stock INT NOT NULL CONSTRAINT DF_product_stock DEFAULT 0,
    image_url NVARCHAR(500) NULL,
    caracteristiques NVARCHAR(MAX) NULL,
    updated_at DATETIME NOT NULL CONSTRAINT DF_product_updated DEFAULT GETDATE(),
    CONSTRAINT FK_product_categorie FOREIGN KEY (category_id) REFERENCES dbo.categorie(id) ON DELETE CASCADE,
    CONSTRAINT UQ_product_reference UNIQUE (reference),
    CONSTRAINT UQ_product_barcode UNIQUE (barcode)
);
GO

-- Table 3: Panier d'achat local (Facultatif côté serveur, utilisé en secours)
CREATE TABLE dbo.cart_items (
    id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_cart_items PRIMARY KEY CLUSTERED,
    product_id INT NOT NULL,
    quantite INT NOT NULL CONSTRAINT DF_cart_qty DEFAULT 1,
    prix_unitaire DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    CONSTRAINT FK_cart_product FOREIGN KEY (product_id) REFERENCES dbo.product(id) ON DELETE CASCADE
);
GO

-- Table 4: Demandes de devis clients NGNEX 08
CREATE TABLE dbo.quotes (
    id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_quotes PRIMARY KEY CLUSTERED,
    numero NVARCHAR(50) NOT NULL,
    date_creation DATETIME NOT NULL CONSTRAINT DF_quotes_date DEFAULT GETDATE(),
    statut NVARCHAR(50) NOT NULL CONSTRAINT DF_quotes_statut DEFAULT N'En attente',
    customer_name NVARCHAR(150) NOT NULL,
    company_name NVARCHAR(150) NULL,
    customer_phone NVARCHAR(50) NOT NULL,
    customer_email NVARCHAR(100) NULL,
    address NVARCHAR(250) NULL,
    notes NVARCHAR(MAX) NULL,
    CONSTRAINT UQ_quotes_numero UNIQUE (numero)
);
GO

-- Table 5: Détails des articles inclus dans chaque devis
CREATE TABLE dbo.quote_items (
    id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_quote_items PRIMARY KEY CLUSTERED,
    quote_id INT NOT NULL,
    product_id INT NOT NULL,
    product_name NVARCHAR(200) NOT NULL,
    product_ref NVARCHAR(50) NULL,
    quantite INT NOT NULL CONSTRAINT DF_quote_items_qty DEFAULT 1,
    prix_unitaire DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    CONSTRAINT FK_quote_items_quotes FOREIGN KEY (quote_id) REFERENCES dbo.quotes(id) ON DELETE CASCADE,
    CONSTRAINT FK_quote_items_product FOREIGN KEY (product_id) REFERENCES dbo.product(id)
);
GO

-- =====================================================================
-- 3. CRÉATION DES INDEX DE PERFORMANCE
-- =====================================================================
CREATE NONCLUSTERED INDEX IX_product_category ON dbo.product(category_id);
CREATE NONCLUSTERED INDEX IX_product_barcode ON dbo.product(barcode);
CREATE NONCLUSTERED INDEX IX_product_reference ON dbo.product(reference);
CREATE NONCLUSTERED INDEX IX_quotes_numero ON dbo.quotes(numero);
GO

-- =====================================================================
-- 4. INSERTION DES DONNÉES INITIALES NGNEX 08 (SEED DATA)
-- =====================================================================
SET IDENTITY_INSERT dbo.categorie ON;

INSERT INTO dbo.categorie (id, nom, description, image_url) VALUES
(1, N'Terminaux tout-en-un', N'Terminaux tactiles fiables et performants pour les commerces.', N'https://ngnex08.dz/images/aio.jpg'),
(2, N'Imprimantes de tickets', N'Imprimantes thermiques rapides pour les reçus et les tickets de caisse.', N'https://ngnex08.dz/images/printer.jpg'),
(3, N'Lecteurs de codes-barres', N'Lecteurs filaires et sans fil compatibles avec les codes 1D et 2D.', N'https://ngnex08.dz/images/scanner.jpg'),
(4, N'Tiroirs-caisses', N'Tiroirs-caisses renforcés avec ouverture automatique RJ11.', N'https://ngnex08.dz/images/drawer.jpg'),
(5, N'Balances commerciales', N'Balances électroniques avec impression de tickets et d’étiquettes.', N'https://ngnex08.dz/images/scale.jpg');

SET IDENTITY_INSERT dbo.categorie OFF;
GO

SET IDENTITY_INSERT dbo.product ON;

INSERT INTO dbo.product (id, category_id, nom, reference, barcode, description, prix, stock, image_url, caracteristiques) VALUES
(1, 1, N'Terminal tactile NGNEX Pro 15,6 pouces', N'AIO-156-PRO', N'613000100101', N'Terminal de caisse à écran tactile capacitif de 15,6 pouces, avec processeur Intel Core i3 de 11e génération, 8 Go de mémoire vive et SSD de 256 Go.', 85000.00, 12, N'https://ngnex08.dz/images/p1.jpg', N'Processeur : Intel Core i3-1115G4|Écran : 15,6 pouces, tactile HD 1920 × 1080|Mémoire : 8 Go DDR4|Stockage : SSD NVMe 256 Go|Châssis : aluminium|Ports : 6 USB, 2 COM, 1 LAN'),
(2, 1, N'Terminal double écran NGNEX Dual 15,6/10,1 pouces', N'AIO-DUAL-156', N'613000100102', N'Terminal de point de vente à double écran, avec affichage destiné au client.', 115000.00, 5, N'https://ngnex08.dz/images/p2.jpg', N'Écran principal : 15,6 pouces tactile|Écran client : 10,1 pouces non tactile|Processeur : Intel Core i5|Mémoire : 16 Go|Stockage : SSD 512 Go'),
(3, 2, N'Imprimante thermique NGNEX 80 mm USB + LAN', N'PRT-80-LAN', N'613000200201', N'Imprimante de tickets rapide (260 mm/s), avec découpe automatique et trois interfaces.', 18500.00, 25, N'https://ngnex08.dz/images/p3.jpg', N'Vitesse : 260 mm/s|Largeur du papier : 80 mm|Découpe : automatique|Interfaces : USB, LAN et RS232'),
(4, 2, N'Imprimante portable NGNEX Mobile-58', N'PRT-58-BT', N'613000200202', N'Imprimante portable de tickets 58 mm, avec Bluetooth, USB et batterie rechargeable de 2 000 mAh.', 12500.00, 18, N'https://ngnex08.dz/images/p4.jpg', N'Largeur du papier : 58 mm|Connexion : Bluetooth 4.0 et USB|Batterie : lithium-ion 2 000 mAh|Autonomie : 8 h'),
(5, 3, N'Lecteur 2D omnidirectionnel NGNEX Desktop', N'SCAN-2D-DESK', N'613000300301', N'Lecteur mains libres rapide, compatible avec les codes 1D et 2D, pour les commerces et les pharmacies.', 24000.00, 15, N'https://ngnex08.dz/images/p5.jpg', N'Capteur : CMOS 1 280 × 800|Codes compatibles : QR Code, Data Matrix, PDF417, EAN-13 et Code 128|Interface : USB'),
(6, 3, N'Lecteur laser sans fil NGNEX Wireless-100', N'SCAN-1D-WL', N'613000300302', N'Lecteur sans fil 2,4 GHz, avec une portée de 100 mètres et une mémoire hors ligne.', 14500.00, 30, N'https://ngnex08.dz/images/p6.jpg', N'Portée : 100 m|Mémoire : 50 000 codes|Batterie : 1 800 mAh|Résistance aux chutes : 1,5 m'),
(7, 4, N'Tiroir-caisse métallique NGNEX 410', N'DRAWER-410', N'613000400401', N'Tiroir-caisse renforcé avec 5 compartiments à billets, 8 compartiments à pièces et une serrure à 3 positions.', 13500.00, 20, N'https://ngnex08.dz/images/p7.jpg', N'Dimensions : 410 × 420 × 100 mm|Compartiments : 5 pour billets et 8 pour pièces|Connexion : RJ11|Poids : 6,2 kg'),
(8, 5, N'Balance commerciale NGNEX 30 kg avec imprimante', N'SCALE-30-PRT', N'613000500501', N'Balance commerciale avec imprimante de tickets et d’étiquettes intégrée et double affichage LCD.', 65000.00, 8, N'https://ngnex08.dz/images/p8.jpg', N'Portée : 30 kg|Précision : 2 g/5 g|PLU : 10 000|Double affichage LCD client/vendeur|Plateau en inox');

SET IDENTITY_INSERT dbo.product OFF;
GO

-- =====================================================================
-- 5. PROCÉDURES STOCKÉES POUR ENVOYER DU JSON POUR L'API REST
-- =====================================================================

-- Procédure 1: Obtenir toutes les catégories au format JSON
CREATE OR ALTER PROCEDURE dbo.sp_GetCategoriesJSON
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.id AS [id],
        c.nom AS [nom],
        ISNULL(c.description, '') AS [description],
        ISNULL(c.image_url, '') AS [image_url],
        COUNT(p.id) AS [product_count]
    FROM dbo.categorie c
    LEFT JOIN dbo.product p ON c.id = p.category_id
    GROUP BY c.id, c.nom, c.description, c.image_url
    ORDER BY c.nom ASC
    FOR JSON PATH;
END;
GO

-- Procédure 2: Obtenir le catalogue de produits au format JSON
CREATE OR ALTER PROCEDURE dbo.sp_GetProductsJSON
    @CategoryID INT = 0,
    @SearchQuery NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
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
    WHERE (@CategoryID = 0 OR p.category_id = @CategoryID)
      AND (@SearchQuery IS NULL OR p.nom LIKE '%' + @SearchQuery + '%' OR p.reference LIKE '%' + @SearchQuery + '%' OR p.barcode LIKE '%' + @SearchQuery + '%')
    ORDER BY p.nom ASC
    FOR JSON PATH;
END;
GO

-- Procédure 3: Recherche par Code-barres pour le Scanner
CREATE OR ALTER PROCEDURE dbo.sp_GetProductByBarcodeJSON
    @Barcode NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1
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
    WHERE p.barcode = @Barcode OR p.reference = @Barcode
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END;
GO

PRINT '=====================================================================';
PRINT 'TABLES ET PROCÉDURES CRÉÉES DANS NGNEX_DB AVEC SUCCÈS !';
PRINT '=====================================================================';
GO
