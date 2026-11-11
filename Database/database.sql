-- Schema SQLite pour NGNEX Mobile (Basé sur la structure SQL Server NGNEX_DB)

CREATE TABLE IF NOT EXISTS Categorie (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT NOT NULL,
    description TEXT,
    image_url TEXT
);

CREATE TABLE IF NOT EXISTS Product (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER NOT NULL,
    nom TEXT NOT NULL,
    reference TEXT UNIQUE NOT NULL,
    barcode TEXT UNIQUE,
    description TEXT,
    prix REAL NOT NULL DEFAULT 0.0,
    stock INTEGER NOT NULL DEFAULT 0,
    image_url TEXT,
    caracteristiques TEXT,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Categorie(id)
);

CREATE TABLE IF NOT EXISTS CartItems (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    quantite INTEGER NOT NULL DEFAULT 1,
    prix_unitaire REAL NOT NULL DEFAULT 0.0,
    FOREIGN KEY (product_id) REFERENCES Product(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Quotes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    numero TEXT UNIQUE NOT NULL,
    date_creation TEXT DEFAULT CURRENT_TIMESTAMP,
    statut TEXT NOT NULL DEFAULT 'En attente',
    customer_name TEXT NOT NULL,
    company_name TEXT,
    customer_phone TEXT NOT NULL,
    customer_email TEXT,
    address TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS QuoteItems (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    quote_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    product_name TEXT NOT NULL,
    product_ref TEXT,
    quantite INTEGER NOT NULL DEFAULT 1,
    prix_unitaire REAL NOT NULL DEFAULT 0.0,
    FOREIGN KEY (quote_id) REFERENCES Quotes(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(id)
);

-- Index pour optimiser les recherches
CREATE INDEX IF NOT EXISTS idx_product_category ON Product(category_id);
CREATE INDEX IF NOT EXISTS idx_product_barcode ON Product(barcode);
CREATE INDEX IF NOT EXISTS idx_product_reference ON Product(reference);
CREATE INDEX IF NOT EXISTS idx_quotes_numero ON Quotes(numero);

-- Données initiales NGNEX 08
INSERT OR IGNORE INTO Categorie (id, nom, description, image_url) VALUES
(1, 'Terminaux tout-en-un', 'Terminaux tactiles fiables et performants pour les commerces.', 'https://ngnex08.dz/images/aio.jpg'),
(2, 'Imprimantes de tickets', 'Imprimantes thermiques rapides pour les reçus et les tickets de caisse.', 'https://ngnex08.dz/images/printer.jpg'),
(3, 'Lecteurs de codes-barres', 'Lecteurs filaires et sans fil compatibles avec les codes 1D et 2D.', 'https://ngnex08.dz/images/scanner.jpg'),
(4, 'Tiroirs-caisses', 'Tiroirs-caisses renforcés avec ouverture automatique RJ11.', 'https://ngnex08.dz/images/drawer.jpg'),
(5, 'Balances commerciales', 'Balances électroniques avec impression de tickets et d’étiquettes.', 'https://ngnex08.dz/images/scale.jpg'),
(6, 'Papier et ?tiquettes', 'Rouleaux thermiques et ?tiquettes pour balances et imprimantes.', 'catalog_product_011.jpg');

INSERT OR IGNORE INTO Product (id, category_id, nom, reference, barcode, description, prix, stock, image_url, caracteristiques) VALUES
(1, 1, 'Terminal tactile NGNEX Pro 15,6 pouces', 'AIO-156-PRO', '613000100101', 'Terminal de caisse à écran tactile capacitif de 15,6 pouces, avec processeur Intel Core i3 de 11e génération, 8 Go de mémoire vive et SSD de 256 Go.', 85000.0, 12, 'https://ngnex08.dz/images/p1.jpg', 'Processeur : Intel Core i3-1115G4|Écran : 15,6 pouces, tactile HD 1920 × 1080|Mémoire : 8 Go DDR4|Stockage : SSD NVMe 256 Go|Châssis : aluminium|Ports : 6 USB, 2 COM, 1 LAN'),
(2, 1, 'Terminal double écran NGNEX Dual 15,6/10,1 pouces', 'AIO-DUAL-156', '613000100102', 'Terminal de point de vente à double écran, avec affichage destiné au client.', 115000.0, 5, 'https://ngnex08.dz/images/p2.jpg', 'Écran principal : 15,6 pouces tactile|Écran client : 10,1 pouces non tactile|Processeur : Intel Core i5|Mémoire : 16 Go|Stockage : SSD 512 Go'),
(3, 2, 'Imprimante thermique NGNEX 80 mm USB + LAN', 'PRT-80-LAN', '613000200201', 'Imprimante de tickets rapide (260 mm/s), avec découpe automatique et trois interfaces.', 18500.0, 25, 'https://ngnex08.dz/images/p3.jpg', 'Vitesse : 260 mm/s|Largeur du papier : 80 mm|Découpe : automatique|Interfaces : USB, LAN et RS232'),
(4, 2, 'Imprimante portable NGNEX Mobile-58', 'PRT-58-BT', '613000200202', 'Imprimante portable de tickets 58 mm, avec Bluetooth, USB et batterie rechargeable de 2 000 mAh.', 12500.0, 18, 'https://ngnex08.dz/images/p4.jpg', 'Largeur du papier : 58 mm|Connexion : Bluetooth 4.0 et USB|Batterie : lithium-ion 2 000 mAh|Autonomie : 8 h'),
(5, 3, 'Lecteur 2D omnidirectionnel NGNEX Desktop', 'SCAN-2D-DESK', '613000300301', 'Lecteur mains libres rapide, compatible avec les codes 1D et 2D, pour les commerces et les pharmacies.', 24000.0, 15, 'https://ngnex08.dz/images/p5.jpg', 'Capteur : CMOS 1 280 × 800|Codes compatibles : QR Code, Data Matrix, PDF417, EAN-13 et Code 128|Interface : USB'),
(6, 3, 'Lecteur laser sans fil NGNEX Wireless-100', 'SCAN-1D-WL', '613000300302', 'Lecteur sans fil 2,4 GHz, avec une portée de 100 mètres et une mémoire hors ligne.', 14500.0, 30, 'https://ngnex08.dz/images/p6.jpg', 'Portée : 100 m|Mémoire : 50 000 codes|Batterie : 1 800 mAh|Résistance aux chutes : 1,5 m'),
(7, 4, 'Tiroir-caisse métallique NGNEX 410', 'DRAWER-410', '613000400401', 'Tiroir-caisse renforcé avec 5 compartiments à billets, 8 compartiments à pièces et une serrure à 3 positions.', 13500.0, 20, 'https://ngnex08.dz/images/p7.jpg', 'Dimensions : 410 × 420 × 100 mm|Compartiments : 5 pour billets et 8 pour pièces|Connexion : RJ11|Poids : 6,2 kg'),
(8, 5, 'Balance commerciale NGNEX 30 kg avec imprimante', 'SCALE-30-PRT', '613000500501', 'Balance commerciale avec imprimante de tickets et d’étiquettes intégrée et double affichage LCD.', 65000.0, 8, 'https://ngnex08.dz/images/p8.jpg', 'Portée : 30 kg|Précision : 2 g/5 g|PLU : 10 000|Double affichage LCD client/vendeur|Plateau en inox');

-- Produits reconnus ? partir des photos locales ; prix et stock ? confirmer.
INSERT OR IGNORE INTO Product (category_id, nom, reference, barcode, description, prix, stock, image_url, caracteristiques) VALUES
(1, 'Tout-en-un MSI AE200 tactile 19,5 pouces, 8 Go, SSD 128 Go', 'PHOTO-001', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_001.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(1, 'Tout-en-un Enegma i3 4e génération, SSD 128 Go, batterie', 'PHOTO-002', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_002.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(1, 'Tout-en-un Enegma i3 4e génération avec imprimante et batterie', 'PHOTO-003', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_003.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(1, 'Tout-en-un Lenovo i3 4e génération, 4 Go, HDD 500 Go (occasion)', 'PHOTO-004', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_004.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(1, 'Tout-en-un MSI 21 pouces, processeur AMD', 'PHOTO-005', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_005.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(1, 'Tout-en-un SafePos Pro, i5 3e génération, 8 Go, SSD 128 Go', 'PHOTO-006', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_006.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(1, 'Tout-en-un SafePos, i5, 8 Go, SSD 128 Go', 'PHOTO-007', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_007.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(5, 'Balance ACLAS S6', 'PHOTO-008', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_008.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(5, 'Balance Rengta RLS 1000', 'PHOTO-009', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_009.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(4, 'Tiroir-caisse Smart RJ11, 415 mm', 'PHOTO-010', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_010.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(6, 'Carton d''étiquettes 2040, 20 unités', 'PHOTO-011', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_011.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(6, 'Étiquettes pour balance 45 x 58 mm, 20 rouleaux', 'PHOTO-012', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_012.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(6, 'Étiquettes pour balance 45 x 58 mm, 48 rouleaux', 'PHOTO-013', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_013.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(6, 'Étiquettes pour balance 45 x 58 mm, 60 rouleaux', 'PHOTO-014', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_014.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(4, 'Tiroir-caisse 410 mm', 'PHOTO-015', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_015.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(1, 'Écran HP 17 pouces', 'PHOTO-016', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_016.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(1, 'Écran HP 19 pouces', 'PHOTO-017', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_017.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(1, 'Écran Enegma 19 pouces HDMI', 'PHOTO-018', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_018.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(1, 'Écran tactile HFPOS 15 pouces', 'PHOTO-019', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_019.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(1, 'Écran tactile HFPOS 15,6 pouces', 'PHOTO-020', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_020.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(1, 'Terminal tactile HFPOS i5 avec afficheur N700', 'PHOTO-021', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_021.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante tickets Smart POS 802 USB et Wi-Fi', 'PHOTO-022', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_022.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante de bordereaux Smart SP9025D', 'PHOTO-023', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_023.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante laser Canon LBP 6030', 'PHOTO-024', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_024.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante multifonction Canon MF 3010', 'PHOTO-025', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_025.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante tickets CB Smart 80VI USB série', 'PHOTO-026', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_026.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante CB Smart POS RP411', 'PHOTO-027', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_027.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante code-barres 2120 USB', 'PHOTO-028', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_028.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante code-barres XP-233B', 'PHOTO-029', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_029.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante tickets Exprinter XP-N160II', 'PHOTO-030', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_030.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante tickets Smart 335', 'PHOTO-031', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_031.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante thermique 80180', 'PHOTO-032', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_032.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante tickets SafePos 80250', 'PHOTO-033', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_033.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante tickets Smart RP-330', 'PHOTO-034', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_034.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante tickets Smart RP-332 réseau', 'PHOTO-035', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_035.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante tickets Smart SP331', 'PHOTO-036', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_036.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante tickets Xprinter D200N USB et LAN', 'PHOTO-037', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_037.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante tickets Xprinter XP-D260N', 'PHOTO-038', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_038.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante Wi-Fi SP 300I', 'PHOTO-039', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_039.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante Wi-Fi SP 300IW', 'PHOTO-040', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_040.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante Xprinter XP-Q80K Wi-Fi', 'PHOTO-041', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_041.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante Xprinter XP-Q302F', 'PHOTO-042', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_042.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(2, 'Imprimante Xprinter XP-Q371U', 'PHOTO-043', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_043.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(3, 'Lecteur code-barres Smart SP-6221 avec support', 'PHOTO-044', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_044.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(3, 'Lecteur code-barres carré SP-9608H', 'PHOTO-045', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_045.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(3, 'Lecteur code-barres fixe Smart XB-8602', 'PHOTO-046', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_046.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(3, 'Lecteur code-barres HENEX HC-3208R avec support', 'PHOTO-047', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_047.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(3, 'Lecteur code-barres anneau HENEX H-500 sans fil', 'PHOTO-048', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_048.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(3, 'Lecteur code-barres Smart 5066 sans fil', 'PHOTO-049', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_049.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(3, 'Lecteur code-barres Sunlux 6500A avec support', 'PHOTO-050', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_050.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(3, 'Lecteur code-barres LC-3000L', 'PHOTO-051', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_051.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(3, 'Lecteur code-barres 2D SP-X86', 'PHOTO-052', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_052.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(3, 'Lecteur code-barres Smart 1500U avec support', 'PHOTO-053', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_053.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(3, 'Lecteur code-barres Icon 4010 avec support', 'PHOTO-054', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_054.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(3, 'Lecteur code-barres Elitpos SC-5510', 'PHOTO-055', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_055.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(3, 'Lecteur code-barres fixe 2D SP-8608G', 'PHOTO-056', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_056.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(3, 'Lecteur code-barres Newland 2D', 'PHOTO-057', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_057.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(3, 'Lecteur code-barres Opticon', 'PHOTO-058', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_058.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(3, 'Lecteur code-barres Smart 1D 5066', 'PHOTO-059', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_059.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(3, 'Lecteur code-barres SafePos 2D 8860', 'PHOTO-060', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_060.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(3, 'Lecteur code-barres sans fil Smart SP-M40', 'PHOTO-061', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_061.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(3, 'Lecteur code-barres SP-8500', 'PHOTO-062', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_062.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(3, 'Lecteur code-barres Sunlux 3610 2D', 'PHOTO-063', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_063.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(3, 'Lecteur code-barres fixe SmartPOS SP 8602', 'PHOTO-064', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_064.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(1, 'Ordinateur Lenovo i5, 6 Go RAM, HDD 500 Go', 'PHOTO-065', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_065.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(6, 'Carton de papier thermique 80 x 80', 'PHOTO-066', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_066.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(1, 'PC tactile A3 i3, SSD 128 Go', 'PHOTO-067', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_067.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(1, 'PC tactile Smart P2 i5 4e génération, SSD 128 Go, 8 Go, Wi-Fi', 'PHOTO-068', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_068.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(1, 'PC tactile Smart i5 L150, SSD 128 Go, rouge', 'PHOTO-069', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_069.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(1, 'Vérificateur de prix tactile 10,1 pouces avec support', 'PHOTO-070', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_070.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(6, 'Rouleau de papier thermique 80 x 80', 'PHOTO-071', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_071.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(4, 'Tiroir-caisse SafePos 410', 'PHOTO-072', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_072.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(4, 'Tiroir-caisse BZ 6 kg', 'PHOTO-073', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_073.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(4, 'Tiroir-caisse Enegma 415 blanc', 'PHOTO-074', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_074.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(4, 'Tiroir-caisse en inox', 'PHOTO-075', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_075.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(4, 'Tiroir-caisse Smart 410 économique', 'PHOTO-076', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_076.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(4, 'Tiroir-caisse Smart 335 compact', 'PHOTO-077', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_077.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(1, 'Unité centrale HP i5 6e génération, SSD 256 Go', 'PHOTO-078', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_078.jpg', 'Fiche technique à confirmer auprès de NGNEX.'),
(1, 'Vérificateur de prix SafePos', 'PHOTO-079', NULL, 'Prix et disponibilité à confirmer auprès de NGNEX.', 0, 0, 'catalog_product_079.jpg', 'Fiche technique à confirmer auprès de NGNEX.');
