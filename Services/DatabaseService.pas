unit DatabaseService; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Classes, System.IOUtils, System.Generics.Collections, // Complete la declaration ou instruction en cours.
  FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option, // Complete la declaration ou instruction en cours.
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, // Complete la declaration ou instruction en cours.
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite, // Complete la declaration ou instruction en cours.
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait, // Complete la declaration ou instruction en cours.
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, // Complete la declaration ou instruction en cours.
  FireDAC.Comp.DataSet, Data.DB, // Complete la declaration ou instruction en cours.
  Product, ProductPhotoCatalog, Category, CartItem, Quote, Customer; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Couche de persistance SQLite pour le catalogue, le panier et les devis locaux.
  TDatabaseService = class // Complete la declaration ou instruction en cours.
  private // Complete la declaration ou instruction en cours.
    FConnection: TFDConnection; // Execute cette instruction dans le flux courant.
    FDBPath: string; // Execute cette instruction dans le flux courant.
    procedure CreateTables; // Declare une procedure de cette unite ou classe.
    procedure SeedInitialData; // Declare une procedure de cette unite ou classe.
    procedure SeedPhotoCatalog; // Declare une procedure de cette unite ou classe.
  public // Complete la declaration ou instruction en cours.
    constructor Create(AConnection: TFDConnection); // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.

    procedure InitializeDatabase; // Declare une procedure de cette unite ou classe.

    // Categories
    function GetCategories(AList: TCategoryList): Boolean; // Declare une fonction qui renvoie un resultat.
    function GetCategoryByID(AID: Integer; ACategory: TCategory): Boolean; // Declare une fonction qui renvoie un resultat.

    // Products
    function GetProducts(AList: TProductList; ACategoryID: Integer = 0; const ASearchQuery: string = ''; const ASortBy: string = ''): Boolean; // Declare une fonction qui renvoie un resultat.
    function GetProductByID(AID: Integer; AProduct: TProduct): Boolean; // Declare une fonction qui renvoie un resultat.
    function GetProductByBarcode(const ABarcode: string; AProduct: TProduct): Boolean; // Declare une fonction qui renvoie un resultat.
    function GetPopularProducts(AList: TProductList; ACount: Integer = 5): Boolean; // Declare une fonction qui renvoie un resultat.

    // Cart Local Storage
    function GetCartItems(AList: TCartItemList): Boolean; // Declare une fonction qui renvoie un resultat.
    function SaveCartItem(AItem: TCartItem): Boolean; // Declare une fonction qui renvoie un resultat.
    function UpdateCartItemQuantity(AProductID: Integer; AQty: Integer): Boolean; // Declare une fonction qui renvoie un resultat.
    function DeleteCartItem(AProductID: Integer): Boolean; // Declare une fonction qui renvoie un resultat.
    procedure ClearCart; // Declare une procedure de cette unite ou classe.

    // Quotes Local Storage
    function GetQuotes(AList: TQuoteList): Boolean; // Declare une fonction qui renvoie un resultat.
    function GetQuoteByID(AID: Integer; AQuote: TQuote): Boolean; // Declare une fonction qui renvoie un resultat.
    function SaveQuote(AQuote: TQuote): Boolean; // Declare une fonction qui renvoie un resultat.
    function UpdateQuoteStatus(AQuoteID: Integer; const AStatus: string): Boolean; // Declare une fonction qui renvoie un resultat.

    // DB maintenance
    procedure ResetDatabase; // Declare une procedure de cette unite ou classe.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

{ TDatabaseService }

constructor TDatabaseService.Create(AConnection: TFDConnection); // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Utilise la connexion fournie par le DataModule et détermine le fichier DB.
  inherited Create; // Appelle le comportement correspondant de la classe parente.
  FConnection := AConnection; // Attribue une nouvelle valeur a la variable indiquee.
  FDBPath := TPath.Combine(TPath.GetDocumentsPath, 'ngnex_mobile.db'); // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

destructor TDatabaseService.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // La connexion est possédée et libérée par le DataModule.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

procedure TDatabaseService.InitializeDatabase; // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Configure SQLite, crée le schéma puis initialise les données de catalogue.
  if FConnection = nil then Exit; // Verifie la condition avant de poursuivre.

  FConnection.Close; // Execute cette instruction dans le flux courant.
  FConnection.Params.Clear; // Execute cette instruction dans le flux courant.
  FConnection.Params.Add('DriverID=SQLite'); // Appelle la methode ou fonction avec les parametres indiques.
  FConnection.Params.Add('Database=' + FDBPath); // Appelle la methode ou fonction avec les parametres indiques.
  FConnection.Params.Add('ForeignKeys=On'); // Appelle la methode ou fonction avec les parametres indiques.
  FConnection.Params.Add('LockingMode=Normal'); // Appelle la methode ou fonction avec les parametres indiques.
  FConnection.Params.Add('Synchronous=Normal'); // Appelle la methode ou fonction avec les parametres indiques.
  FConnection.Connected := True; // Attribue une nouvelle valeur a la variable indiquee.

  CreateTables; // Execute cette instruction dans le flux courant.
  SeedInitialData; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

procedure TDatabaseService.CreateTables; // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  Q: TFDQuery; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Crée les tables et vues de compatibilité sans écraser les données existantes.
  Q := TFDQuery.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Q.Connection := FConnection; // Attribue une nouvelle valeur a la variable indiquee.

    Q.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
      'CREATE TABLE IF NOT EXISTS Categorie (' + // Complete la declaration ou instruction en cours.
      '  id INTEGER PRIMARY KEY AUTOINCREMENT, ' + // Complete la declaration ou instruction en cours.
      '  nom TEXT NOT NULL, ' + // Complete la declaration ou instruction en cours.
      '  description TEXT, ' + // Complete la declaration ou instruction en cours.
      '  image_url TEXT);' + // Complete la declaration ou instruction en cours.
      'CREATE VIEW IF NOT EXISTS Categories AS SELECT * FROM Categorie;'; // Execute cette instruction dans le flux courant.
    Q.ExecSQL; // Execute cette instruction dans le flux courant.

    Q.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
      'CREATE TABLE IF NOT EXISTS Product (' + // Complete la declaration ou instruction en cours.
      '  id INTEGER PRIMARY KEY AUTOINCREMENT, ' + // Complete la declaration ou instruction en cours.
      '  category_id INTEGER NOT NULL, ' + // Complete la declaration ou instruction en cours.
      '  nom TEXT NOT NULL, ' + // Complete la declaration ou instruction en cours.
      '  reference TEXT UNIQUE NOT NULL, ' + // Complete la declaration ou instruction en cours.
      '  barcode TEXT UNIQUE, ' + // Complete la declaration ou instruction en cours.
      '  description TEXT, ' + // Complete la declaration ou instruction en cours.
      '  prix REAL NOT NULL DEFAULT 0.0, ' + // Complete la declaration ou instruction en cours.
      '  stock INTEGER NOT NULL DEFAULT 0, ' + // Complete la declaration ou instruction en cours.
      '  image_url TEXT, ' + // Complete la declaration ou instruction en cours.
      '  caracteristiques TEXT, ' + // Complete la declaration ou instruction en cours.
      '  updated_at TEXT DEFAULT CURRENT_TIMESTAMP);' + // Complete la declaration ou instruction en cours.
      'CREATE VIEW IF NOT EXISTS Products AS SELECT * FROM Product;'; // Execute cette instruction dans le flux courant.
    Q.ExecSQL; // Execute cette instruction dans le flux courant.

    Q.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
      'CREATE TABLE IF NOT EXISTS CartItems (' + // Complete la declaration ou instruction en cours.
      '  id INTEGER PRIMARY KEY AUTOINCREMENT, ' + // Complete la declaration ou instruction en cours.
      '  product_id INTEGER NOT NULL, ' + // Complete la declaration ou instruction en cours.
      '  quantite INTEGER NOT NULL DEFAULT 1, ' + // Complete la declaration ou instruction en cours.
      '  prix_unitaire REAL NOT NULL DEFAULT 0.0);'; // Execute cette instruction dans le flux courant.
    Q.ExecSQL; // Execute cette instruction dans le flux courant.

    Q.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
      'CREATE TABLE IF NOT EXISTS Quotes (' + // Complete la declaration ou instruction en cours.
      '  id INTEGER PRIMARY KEY AUTOINCREMENT, ' + // Complete la declaration ou instruction en cours.
      '  numero TEXT UNIQUE NOT NULL, ' + // Complete la declaration ou instruction en cours.
      '  date_creation TEXT DEFAULT CURRENT_TIMESTAMP, ' + // Complete la declaration ou instruction en cours.
      '  statut TEXT NOT NULL DEFAULT ''En attente'', ' + // Complete la declaration ou instruction en cours.
      '  customer_name TEXT NOT NULL, ' + // Complete la declaration ou instruction en cours.
      '  company_name TEXT, ' + // Complete la declaration ou instruction en cours.
      '  customer_phone TEXT NOT NULL, ' + // Complete la declaration ou instruction en cours.
      '  customer_email TEXT, ' + // Complete la declaration ou instruction en cours.
      '  address TEXT, ' + // Complete la declaration ou instruction en cours.
      '  notes TEXT);'; // Execute cette instruction dans le flux courant.
    Q.ExecSQL; // Execute cette instruction dans le flux courant.

    Q.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
      'CREATE TABLE IF NOT EXISTS QuoteItems (' + // Complete la declaration ou instruction en cours.
      '  id INTEGER PRIMARY KEY AUTOINCREMENT, ' + // Complete la declaration ou instruction en cours.
      '  quote_id INTEGER NOT NULL, ' + // Complete la declaration ou instruction en cours.
      '  product_id INTEGER NOT NULL, ' + // Complete la declaration ou instruction en cours.
      '  product_name TEXT NOT NULL, ' + // Complete la declaration ou instruction en cours.
      '  product_ref TEXT, ' + // Complete la declaration ou instruction en cours.
      '  quantite INTEGER NOT NULL DEFAULT 1, ' + // Complete la declaration ou instruction en cours.
      '  prix_unitaire REAL NOT NULL DEFAULT 0.0);'; // Execute cette instruction dans le flux courant.
    Q.ExecSQL; // Execute cette instruction dans le flux courant.

  finally // Ouvre le nettoyage garanti meme apres une exception.
    Q.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TDatabaseService.SeedInitialData; // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  Q: TFDQuery; // Execute cette instruction dans le flux courant.
  CountCat, CountProd: Integer; // Execute cette instruction dans le flux courant.
  procedure ExecuteStatement(const ASQL: string); // Declare une procedure de cette unite ou classe.
  begin // Ouvre le bloc d instructions correspondant.
    Q.SQL.Text := ASQL; // Attribue une nouvelle valeur a la variable indiquee.
    Q.ExecSQL; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
begin // Ouvre le bloc d instructions correspondant.
  // Insère les données de démonstration manquantes et corrige certains anciens
  // libellés sans supprimer le contenu déjà enregistré par l'utilisateur.
  Q := TFDQuery.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Q.Connection := FConnection; // Attribue une nouvelle valeur a la variable indiquee.

    Q.SQL.Text := 'SELECT COUNT(*) FROM Categories'; // Attribue une nouvelle valeur a la variable indiquee.
    Q.Open; // Execute cette instruction dans le flux courant.
    CountCat := Q.Fields[0].AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
    Q.Close; // Execute cette instruction dans le flux courant.

    if CountCat = 0 then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      Q.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
        'INSERT INTO Categorie (id, nom, description, image_url) VALUES ' + // Complete la declaration ou instruction en cours.
        '(1, ''Terminaux tout-en-un'', ''Terminaux tactiles fiables et performants pour les commerces.'', ''cat_aio.png''), ' + // Complete la declaration ou instruction en cours.
        '(2, ''Imprimantes de tickets'', ''Imprimantes thermiques rapides pour les reçus et les tickets de caisse.'', ''cat_prt.png''), ' + // Complete la declaration ou instruction en cours.
        '(3, ''Lecteurs de codes-barres'', ''Lecteurs filaires et sans fil compatibles avec les codes 1D et 2D.'', ''cat_scan.png''), ' + // Complete la declaration ou instruction en cours.
        '(4, ''Tiroirs-caisses'', ''Tiroirs-caisses renforcés avec ouverture automatique RJ11.'', ''cat_drawer.png''), ' + // Complete la declaration ou instruction en cours.
        '(5, ''Balances commerciales'', ''Balances électroniques avec impression de tickets et d’étiquettes.'', ''cat_scale.png'')'; // Execute cette instruction dans le flux courant.
      Q.ExecSQL; // Execute cette instruction dans le flux courant.
    end; // Ferme le bloc ou la declaration en cours.

    Q.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
      'INSERT OR IGNORE INTO Categorie (id, nom, description, image_url) ' + // Complete la declaration ou instruction en cours.
      'VALUES (6, ''Papier et étiquettes'', ' + // Complete la declaration ou instruction en cours.
      '''Rouleaux thermiques et étiquettes pour balances et imprimantes.'', ' + // Complete la declaration ou instruction en cours.
      '''catalog_product_011.jpg'')'; // Execute cette instruction dans le flux courant.
    Q.ExecSQL; // Execute cette instruction dans le flux courant.

    Q.SQL.Text := 'SELECT COUNT(*) FROM Product'; // Attribue une nouvelle valeur a la variable indiquee.
    Q.Open; // Execute cette instruction dans le flux courant.
    CountProd := Q.Fields[0].AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
    Q.Close; // Execute cette instruction dans le flux courant.

    if CountProd = 0 then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      Q.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
        'INSERT INTO Product (id, category_id, nom, reference, barcode, description, prix, stock, image_url, caracteristiques) VALUES ' + // Complete la declaration ou instruction en cours.
        '(1, 1, ''Terminal tactile NGNEX Pro 15,6 pouces'', ''AIO-156-PRO'', ''613000100101'', ''Terminal de caisse à écran tactile capacitif de 15,6 pouces, avec processeur Intel Core i3 de 11e génération, 8 Go de mémoire vive et SSD de 256 Go.'', 85000.0, 12, ''prod_aio_pro.png'', ''Processeur : Intel Core i3-1115G4|Écran : 15,6 pouces, tactile HD 1920 × 1080|Mémoire : 8 Go DDR4|Stockage : SSD NVMe 256 Go|Châssis : aluminium|Ports : 6 USB, 2 COM, 1 LAN''), ' + // Complete la declaration ou instruction en cours.
        '(2, 1, ''Terminal double écran NGNEX Dual 15,6/10,1 pouces'', ''AIO-DUAL-156'', ''613000100102'', ''Terminal de point de vente à double écran, avec affichage destiné au client.'', 115000.0, 5, ''prod_aio_dual.png'', ''Écran principal : 15,6 pouces tactile|Écran client : 10,1 pouces non tactile|Processeur : Intel Core i5|Mémoire : 16 Go|Stockage : SSD 512 Go''), ' + // Complete la declaration ou instruction en cours.
        '(3, 2, ''Imprimante thermique NGNEX 80 mm USB + LAN'', ''PRT-80-LAN'', ''613000200201'', ''Imprimante de tickets rapide (260 mm/s), avec découpe automatique et trois interfaces.'', 18500.0, 25, ''prod_prt_lan.png'', ''Vitesse : 260 mm/s|Largeur du papier : 80 mm|Découpe : automatique|Interfaces : USB, LAN et RS232''), ' + // Complete la declaration ou instruction en cours.
        '(4, 2, ''Imprimante portable NGNEX Mobile-58'', ''PRT-58-BT'', ''613000200202'', ''Imprimante portable de tickets 58 mm, avec Bluetooth, USB et batterie rechargeable de 2 000 mAh.'', 12500.0, 18, ''prod_prt_bt.png'', ''Largeur du papier : 58 mm|Connexion : Bluetooth 4.0 et USB|Batterie : lithium-ion 2 000 mAh|Autonomie : 8 h''), ' + // Complete la declaration ou instruction en cours.
        '(5, 3, ''Lecteur 2D omnidirectionnel NGNEX Desktop'', ''SCAN-2D-DESK'', ''613000300301'', ''Lecteur mains libres rapide, compatible avec les codes 1D et 2D, pour les commerces et les pharmacies.'', 24000.0, 15, ''prod_scan_desk.png'', ''Capteur : CMOS 1 280 × 800|Codes compatibles : QR Code, Data Matrix, PDF417, EAN-13 et Code 128|Interface : USB''), ' + // Complete la declaration ou instruction en cours.
        '(6, 3, ''Lecteur laser sans fil NGNEX Wireless-100'', ''SCAN-1D-WL'', ''613000300302'', ''Lecteur sans fil 2,4 GHz, avec une portée de 100 mètres et une mémoire hors ligne.'', 14500.0, 30, ''prod_scan_wl.png'', ''Portée : 100 m|Mémoire : 50 000 codes|Batterie : 1 800 mAh|Résistance aux chutes : 1,5 m''), ' + // Complete la declaration ou instruction en cours.
        '(7, 4, ''Tiroir-caisse métallique NGNEX 410'', ''DRAWER-410'', ''613000400401'', ''Tiroir-caisse renforcé avec 5 compartiments à billets, 8 compartiments à pièces et une serrure à 3 positions.'', 13500.0, 20, ''prod_drawer_410.png'', ''Dimensions : 410 × 420 × 100 mm|Compartiments : 5 pour billets et 8 pour pièces|Connexion : RJ11|Poids : 6,2 kg''), ' + // Complete la declaration ou instruction en cours.
        '(8, 5, ''Balance commerciale NGNEX 30 kg avec imprimante'', ''SCALE-30-PRT'', ''613000500501'', ''Balance commerciale avec imprimante de tickets et d’étiquettes intégrée et double affichage LCD.'', 65000.0, 8, ''prod_scale_30.png'', ''Portée : 30 kg|Précision : 2 g/5 g|PLU : 10 000|Double affichage LCD client/vendeur|Plateau en inox'');'; // Execute cette instruction dans le flux courant.
      Q.ExecSQL; // Execute cette instruction dans le flux courant.
    end // Ferme le bloc ou la declaration en cours.
    else // Execute la branche alternative de la condition precedente.
    begin // Ouvre le bloc d instructions correspondant.
      Q.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
        'UPDATE Product SET image_url = CASE id ' + // Complete la declaration ou instruction en cours.
        'WHEN 1 THEN ''prod_aio_pro.png'' ' + // Complete la declaration ou instruction en cours.
        'WHEN 2 THEN ''prod_aio_dual.png'' ' + // Complete la declaration ou instruction en cours.
        'WHEN 3 THEN ''prod_prt_lan.png'' ' + // Complete la declaration ou instruction en cours.
        'WHEN 4 THEN ''prod_prt_bt.png'' ' + // Complete la declaration ou instruction en cours.
        'WHEN 5 THEN ''prod_scan_desk.png'' ' + // Complete la declaration ou instruction en cours.
        'WHEN 6 THEN ''prod_scan_wl.png'' ' + // Complete la declaration ou instruction en cours.
        'WHEN 7 THEN ''prod_drawer_410.png'' ' + // Complete la declaration ou instruction en cours.
        'WHEN 8 THEN ''prod_scale_30.png'' END ' + // Complete la declaration ou instruction en cours.
        'WHERE id BETWEEN 1 AND 8'; // Execute cette instruction dans le flux courant.
      Q.ExecSQL; // Execute cette instruction dans le flux courant.
    end; // Ferme le bloc ou la declaration en cours.

    Q.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
      'UPDATE Categorie SET image_url = CASE id ' + // Complete la declaration ou instruction en cours.
      'WHEN 1 THEN ''cat_aio.png'' ' + // Complete la declaration ou instruction en cours.
      'WHEN 2 THEN ''cat_prt.png'' ' + // Complete la declaration ou instruction en cours.
      'WHEN 3 THEN ''cat_scan.png'' ' + // Complete la declaration ou instruction en cours.
      'WHEN 4 THEN ''cat_drawer.png'' ' + // Complete la declaration ou instruction en cours.
      'WHEN 5 THEN ''cat_scale.png'' END ' + // Complete la declaration ou instruction en cours.
      'WHERE id BETWEEN 1 AND 5 AND (image_url IS NULL OR image_url = '''' OR image_url LIKE ''http%'')'; // Execute cette instruction dans le flux courant.
    Q.ExecSQL; // Execute cette instruction dans le flux courant.

    ExecuteStatement( // Appelle la methode ou fonction avec les parametres indiques.
      'UPDATE Categorie SET nom=''Terminaux tout-en-un'', description=''Terminaux tactiles fiables et performants pour les commerces.'' WHERE id=1 AND nom=''PC All-in-One Tactiles'''); // Execute cette instruction dans le flux courant.
    ExecuteStatement( // Appelle la methode ou fonction avec les parametres indiques.
      'UPDATE Categorie SET nom=''Imprimantes de tickets'', description=''Imprimantes thermiques rapides pour les reçus et les tickets de caisse.'' WHERE id=2 AND nom=''Imprimantes Tickets'''); // Execute cette instruction dans le flux courant.
    ExecuteStatement( // Appelle la methode ou fonction avec les parametres indiques.
      'UPDATE Categorie SET nom=''Lecteurs de codes-barres'', description=''Lecteurs filaires et sans fil compatibles avec les codes 1D et 2D.'' WHERE id=3 AND nom=''Lecteurs de Codes-barres'''); // Execute cette instruction dans le flux courant.
    ExecuteStatement( // Appelle la methode ou fonction avec les parametres indiques.
      'UPDATE Categorie SET description=''Tiroirs-caisses renforcés avec ouverture automatique RJ11.'' WHERE id=4 AND nom=''Tiroirs-caisses'' AND description LIKE ''Tiroirs-caisses renfor%monnaie/billets%RJ11.%'''); // Execute cette instruction dans le flux courant.
    ExecuteStatement( // Appelle la methode ou fonction avec les parametres indiques.
      'UPDATE Categorie SET nom=''Balances commerciales'', description=''Balances électroniques avec impression de tickets et d’étiquettes.'' WHERE id=5 AND nom=''Balances Professionnelles'''); // Execute cette instruction dans le flux courant.

    ExecuteStatement( // Appelle la methode ou fonction avec les parametres indiques.
      'UPDATE Product SET nom=''Terminal tactile NGNEX Pro 15,6 pouces'', description=''Terminal de caisse à écran tactile capacitif de 15,6 pouces, avec processeur Intel Core i3 de 11e génération, 8 Go de mémoire vive et SSD de 256 Go.'', caracteristiques=''Processeur : Intel Core i3-1115G4|Écran : 15,6 pouces, tactile HD 1920 × 1080|Mémoire : 8 Go DDR4|Stockage : SSD NVMe 256 Go|Châssis : aluminium|Ports : 6 USB, 2 COM, 1 LAN'' WHERE reference=''AIO-156-PRO'' AND nom=''POS Tactile NGNEX Pro 15.6 Inch'''); // Execute cette instruction dans le flux courant.
    ExecuteStatement( // Appelle la methode ou fonction avec les parametres indiques.
      'UPDATE Product SET nom=''Terminal double écran NGNEX Dual 15,6/10,1 pouces'', description=''Terminal de point de vente à double écran, avec affichage destiné au client.'', caracteristiques=''Écran principal : 15,6 pouces tactile|Écran client : 10,1 pouces non tactile|Processeur : Intel Core i5|Mémoire : 16 Go|Stockage : SSD 512 Go'' WHERE reference=''AIO-DUAL-156'' AND nom=''POS Tactile Double Ecran NGNEX Dual 15.6/10.1'''); // Execute cette instruction dans le flux courant.
    ExecuteStatement( // Appelle la methode ou fonction avec les parametres indiques.
      'UPDATE Product SET nom=''Imprimante thermique NGNEX 80 mm USB + LAN'', description=''Imprimante de tickets rapide (260 mm/s), avec découpe automatique et trois interfaces.'', caracteristiques=''Vitesse : 260 mm/s|Largeur du papier : 80 mm|Découpe : automatique|Interfaces : USB, LAN et RS232'' WHERE reference=''PRT-80-LAN'' AND nom=''Imprimante Ticket Thermique NGNEX 80mm USB+LAN'''); // Execute cette instruction dans le flux courant.
    ExecuteStatement( // Appelle la methode ou fonction avec les parametres indiques.
      'UPDATE Product SET nom=''Imprimante portable NGNEX Mobile-58'', description=''Imprimante portable de tickets 58 mm, avec Bluetooth, USB et batterie rechargeable de 2 000 mAh.'', caracteristiques=''Largeur du papier : 58 mm|Connexion : Bluetooth 4.0 et USB|Batterie : lithium-ion 2 000 mAh|Autonomie : 8 h'' WHERE reference=''PRT-58-BT'' AND nom=''Imprimante Ticket Portable Bluetooth NGNEX Mobile-58'''); // Execute cette instruction dans le flux courant.
    ExecuteStatement( // Appelle la methode ou fonction avec les parametres indiques.
      'UPDATE Product SET nom=''Lecteur 2D omnidirectionnel NGNEX Desktop'', description=''Lecteur mains libres rapide, compatible avec les codes 1D et 2D, pour les commerces et les pharmacies.'', caracteristiques=''Capteur : CMOS 1 280 × 800|Codes compatibles : QR Code, Data Matrix, PDF417, EAN-13 et Code 128|Interface : USB'' WHERE reference=''SCAN-2D-DESK'' AND nom=''Lecteur Code-barres 2D Omnidirectionnel NGNEX 2D-Desktop'''); // Execute cette instruction dans le flux courant.
    ExecuteStatement( // Appelle la methode ou fonction avec les parametres indiques.
      'UPDATE Product SET nom=''Lecteur laser sans fil NGNEX Wireless-100'', description=''Lecteur sans fil 2,4 GHz, avec une portée de 100 mètres et une mémoire hors ligne.'', caracteristiques=''Portée : 100 m|Mémoire : 50 000 codes|Batterie : 1 800 mAh|Résistance aux chutes : 1,5 m'' WHERE reference=''SCAN-1D-WL'' AND nom=''Douchette Laser Sans Fil NGNEX 1D Wireless-100'''); // Execute cette instruction dans le flux courant.
    ExecuteStatement( // Appelle la methode ou fonction avec les parametres indiques.
      'UPDATE Product SET nom=''Tiroir-caisse métallique NGNEX 410'', description=''Tiroir-caisse renforcé avec 5 compartiments à billets, 8 compartiments à pièces et une serrure à 3 positions.'', caracteristiques=''Dimensions : 410 × 420 × 100 mm|Compartiments : 5 pour billets et 8 pour pièces|Connexion : RJ11|Poids : 6,2 kg'' WHERE reference=''DRAWER-410'' AND nom=''Tiroir-Caisse Metal NGNEX Heavy Duty 410'''); // Execute cette instruction dans le flux courant.
    ExecuteStatement( // Appelle la methode ou fonction avec les parametres indiques.
      'UPDATE Product SET nom=''Balance commerciale NGNEX 30 kg avec imprimante'', description=''Balance commerciale avec imprimante de tickets et d’étiquettes intégrée et double affichage LCD.'', caracteristiques=''Portée : 30 kg|Précision : 2 g/5 g|PLU : 10 000|Double affichage LCD client/vendeur|Plateau en inox'' WHERE reference=''SCALE-30-PRT'' AND nom LIKE ''%Commerciale NGNEX 30kg Ticket'''); // Execute cette instruction dans le flux courant.

    ExecuteStatement( // Appelle la methode ou fonction avec les parametres indiques.
      'UPDATE Product SET image_url=''catalog_product_021.jpg'' WHERE reference=''AIO-156-PRO'''); // Execute cette instruction dans le flux courant.
    ExecuteStatement( // Appelle la methode ou fonction avec les parametres indiques.
      'UPDATE Product SET image_url=''catalog_product_022.jpg'' WHERE reference=''PRT-80-LAN'''); // Execute cette instruction dans le flux courant.
    ExecuteStatement( // Appelle la methode ou fonction avec les parametres indiques.
      'UPDATE Product SET image_url=''catalog_product_052.jpg'' WHERE reference=''SCAN-2D-DESK'''); // Execute cette instruction dans le flux courant.
    ExecuteStatement( // Appelle la methode ou fonction avec les parametres indiques.
      'UPDATE Product SET image_url=''catalog_product_061.jpg'' WHERE reference=''SCAN-1D-WL'''); // Execute cette instruction dans le flux courant.
    ExecuteStatement( // Appelle la methode ou fonction avec les parametres indiques.
      'UPDATE Product SET image_url=''catalog_product_015.jpg'' WHERE reference=''DRAWER-410'''); // Execute cette instruction dans le flux courant.
    ExecuteStatement( // Appelle la methode ou fonction avec les parametres indiques.
      'UPDATE Product SET image_url=''catalog_product_008.jpg'' WHERE reference=''SCALE-30-PRT'''); // Execute cette instruction dans le flux courant.

    SeedPhotoCatalog; // Execute cette instruction dans le flux courant.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Q.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TDatabaseService.SeedPhotoCatalog; // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  Q: TFDQuery; // Execute cette instruction dans le flux courant.
  Seed: TProductPhotoSeed; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Insère le catalogue illustré de façon idempotente et conserve prix et stock
  // à zéro tant que ces informations n'ont pas été confirmées.
  Q := TFDQuery.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Q.Connection := FConnection; // Attribue une nouvelle valeur a la variable indiquee.
    Q.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
      'INSERT OR IGNORE INTO Product ' + // Complete la declaration ou instruction en cours.
      '(category_id, nom, reference, barcode, description, prix, stock, image_url, caracteristiques) ' + // Complete la declaration ou instruction en cours.
      'VALUES (:category_id, :name, :reference, NULL, ' + // Complete la declaration ou instruction en cours.
      ':description, 0, 0, :image_url, :specs)'; // Execute cette instruction dans le flux courant.

    FConnection.StartTransaction; // Execute cette instruction dans le flux courant.
    try // Ouvre le bloc d instructions correspondant.
      for Seed in PHOTO_PRODUCT_CATALOG do // Parcourt les elements ou valeurs de cette boucle.
      begin // Ouvre le bloc d instructions correspondant.
        Q.ParamByName('category_id').AsInteger := Seed.CategoryID; // Attribue une nouvelle valeur a la variable indiquee.
        Q.ParamByName('name').AsString := Seed.Name; // Attribue une nouvelle valeur a la variable indiquee.
        Q.ParamByName('reference').AsString := Seed.Reference; // Attribue une nouvelle valeur a la variable indiquee.
        Q.ParamByName('description').AsString := // Attribue une nouvelle valeur a la variable indiquee.
          'Prix et disponibilité à confirmer auprès de NGNEX.'; // Execute cette instruction dans le flux courant.
        Q.ParamByName('image_url').AsString := Seed.ImageFileName; // Attribue une nouvelle valeur a la variable indiquee.
        Q.ParamByName('specs').AsString := // Attribue une nouvelle valeur a la variable indiquee.
          'Fiche technique à confirmer auprès de NGNEX.'; // Execute cette instruction dans le flux courant.
        Q.ExecSQL; // Execute cette instruction dans le flux courant.
      end; // Ferme le bloc ou la declaration en cours.
      FConnection.Commit; // Execute cette instruction dans le flux courant.
    except // Ouvre le traitement des exceptions du bloc protege.
      if FConnection.InTransaction then // Verifie la condition avant de poursuivre.
        FConnection.Rollback; // Execute cette instruction dans le flux courant.
      raise; // Propage une exception pour signaler l echec.
    end; // Ferme le bloc ou la declaration en cours.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Q.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

function TDatabaseService.GetCategories(AList: TCategoryList): Boolean; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Q: TFDQuery; // Execute cette instruction dans le flux courant.
  Cat: TCategory; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Charge les catégories et calcule le nombre de produits associés.
  Result := False; // Affecte la valeur de retour de la fonction.
  if (FConnection = nil) or (AList = nil) then Exit; // Verifie la condition avant de poursuivre.

  AList.Clear; // Execute cette instruction dans le flux courant.
  Q := TFDQuery.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Q.Connection := FConnection; // Attribue une nouvelle valeur a la variable indiquee.
    Q.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
      'SELECT c.id, c.nom, c.description, c.image_url, COUNT(p.id) as product_count ' + // Complete la declaration ou instruction en cours.
      'FROM Categories c ' + // Complete la declaration ou instruction en cours.
      'LEFT JOIN Products p ON c.id = p.category_id ' + // Complete la declaration ou instruction en cours.
      'GROUP BY c.id ORDER BY c.nom ASC'; // Execute cette instruction dans le flux courant.
    Q.Open; // Execute cette instruction dans le flux courant.

    while not Q.Eof do // Repete le bloc tant que la condition reste vraie.
    begin // Ouvre le bloc d instructions correspondant.
      Cat := TCategory.Create; // Attribue une nouvelle valeur a la variable indiquee.
      Cat.ID := Q.FieldByName('id').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      Cat.Name := Q.FieldByName('nom').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Cat.Description := Q.FieldByName('description').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Cat.ImageURL := Q.FieldByName('image_url').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Cat.ProductCount := Q.FieldByName('product_count').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      AList.Add(Cat); // Appelle la methode ou fonction avec les parametres indiques.
      Q.Next; // Execute cette instruction dans le flux courant.
    end; // Ferme le bloc ou la declaration en cours.
    Result := True; // Affecte la valeur de retour de la fonction.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Q.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

function TDatabaseService.GetCategoryByID(AID: Integer; ACategory: TCategory): Boolean; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Q: TFDQuery; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Remplit le modèle de catégorie fourni à partir de son identifiant.
  Result := False; // Affecte la valeur de retour de la fonction.
  if (FConnection = nil) or (ACategory = nil) then Exit; // Verifie la condition avant de poursuivre.

  Q := TFDQuery.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Q.Connection := FConnection; // Attribue une nouvelle valeur a la variable indiquee.
    Q.SQL.Text := 'SELECT id, nom, description, image_url FROM Categories WHERE id = :id'; // Attribue une nouvelle valeur a la variable indiquee.
    Q.ParamByName('id').AsInteger := AID; // Attribue une nouvelle valeur a la variable indiquee.
    Q.Open; // Execute cette instruction dans le flux courant.

    if not Q.IsEmpty then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      ACategory.ID := Q.FieldByName('id').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      ACategory.Name := Q.FieldByName('nom').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      ACategory.Description := Q.FieldByName('description').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      ACategory.ImageURL := Q.FieldByName('image_url').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Result := True; // Affecte la valeur de retour de la fonction.
    end; // Ferme le bloc ou la declaration en cours.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Q.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

function TDatabaseService.GetProducts(AList: TProductList; ACategoryID: Integer; const ASearchQuery, ASortBy: string): Boolean; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Q: TFDQuery; // Execute cette instruction dans le flux courant.
  Prod: TProduct; // Execute cette instruction dans le flux courant.
  SQLText, WhereClause, OrderClause: string; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Applique les filtres locaux de catégorie et de recherche, puis le tri choisi.
  Result := False; // Affecte la valeur de retour de la fonction.
  if (FConnection = nil) or (AList = nil) then Exit; // Verifie la condition avant de poursuivre.

  AList.Clear; // Execute cette instruction dans le flux courant.
  Q := TFDQuery.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Q.Connection := FConnection; // Attribue une nouvelle valeur a la variable indiquee.

    WhereClause := ' WHERE 1=1 '; // Attribue une nouvelle valeur a la variable indiquee.
    if ACategoryID > 0 then // Verifie la condition avant de poursuivre.
      WhereClause := WhereClause + ' AND p.category_id = ' + IntToStr(ACategoryID); // Attribue une nouvelle valeur a la variable indiquee.

    if Trim(ASearchQuery) <> '' then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      WhereClause := WhereClause + Format(' AND (p.nom LIKE %s OR p.reference LIKE %s OR p.barcode LIKE %s OR p.description LIKE %s) ', // Attribue une nouvelle valeur a la variable indiquee.
        [QuotedStr('%' + ASearchQuery + '%'), QuotedStr('%' + ASearchQuery + '%'), QuotedStr('%' + ASearchQuery + '%'), QuotedStr('%' + ASearchQuery + '%')]); // Execute cette instruction dans le flux courant.
    end; // Ferme le bloc ou la declaration en cours.

    OrderClause := ' ORDER BY p.nom ASC '; // Attribue une nouvelle valeur a la variable indiquee.
    if SameText(ASortBy, 'price_asc') then // Verifie la condition avant de poursuivre.
      OrderClause := ' ORDER BY p.prix ASC ' // Attribue une nouvelle valeur a la variable indiquee.
    else if SameText(ASortBy, 'price_desc') then // Execute la branche alternative de la condition precedente.
      OrderClause := ' ORDER BY p.prix DESC ' // Attribue une nouvelle valeur a la variable indiquee.
    else if SameText(ASortBy, 'newest') then // Execute la branche alternative de la condition precedente.
      OrderClause := ' ORDER BY p.id DESC '; // Attribue une nouvelle valeur a la variable indiquee.

    SQLText := // Attribue une nouvelle valeur a la variable indiquee.
      'SELECT p.id, p.category_id, c.nom as category_name, p.nom, p.reference, p.barcode, ' + // Complete la declaration ou instruction en cours.
      'p.description, p.prix, p.stock, p.image_url, p.caracteristiques, p.updated_at ' + // Complete la declaration ou instruction en cours.
      'FROM Products p ' + // Complete la declaration ou instruction en cours.
      'LEFT JOIN Categories c ON p.category_id = c.id ' + // Complete la declaration ou instruction en cours.
      WhereClause + OrderClause; // Execute cette instruction dans le flux courant.

    Q.SQL.Text := SQLText; // Attribue une nouvelle valeur a la variable indiquee.
    Q.Open; // Execute cette instruction dans le flux courant.

    while not Q.Eof do // Repete le bloc tant que la condition reste vraie.
    begin // Ouvre le bloc d instructions correspondant.
      Prod := TProduct.Create; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.ID := Q.FieldByName('id').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.CategoryID := Q.FieldByName('category_id').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.CategoryName := Q.FieldByName('category_name').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.Name := Q.FieldByName('nom').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.Reference := Q.FieldByName('reference').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.Barcode := Q.FieldByName('barcode').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.Description := Q.FieldByName('description').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.Price := Q.FieldByName('prix').AsFloat; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.Stock := Q.FieldByName('stock').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.ImageURL := Q.FieldByName('image_url').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.TechnicalSpecs := Q.FieldByName('caracteristiques').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      AList.Add(Prod); // Appelle la methode ou fonction avec les parametres indiques.
      Q.Next; // Execute cette instruction dans le flux courant.
    end; // Ferme le bloc ou la declaration en cours.
    Result := True; // Affecte la valeur de retour de la fonction.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Q.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

function TDatabaseService.GetProductByID(AID: Integer; AProduct: TProduct): Boolean; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Q: TFDQuery; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Charge les champs du produit et le nom de sa catégorie.
  Result := False; // Affecte la valeur de retour de la fonction.
  if (FConnection = nil) or (AProduct = nil) then Exit; // Verifie la condition avant de poursuivre.

  Q := TFDQuery.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Q.Connection := FConnection; // Attribue une nouvelle valeur a la variable indiquee.
    Q.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
      'SELECT p.id, p.category_id, c.nom as category_name, p.nom, p.reference, p.barcode, ' + // Complete la declaration ou instruction en cours.
      'p.description, p.prix, p.stock, p.image_url, p.caracteristiques ' + // Complete la declaration ou instruction en cours.
      'FROM Products p LEFT JOIN Categories c ON p.category_id = c.id WHERE p.id = :id'; // Execute cette instruction dans le flux courant.
    Q.ParamByName('id').AsInteger := AID; // Attribue une nouvelle valeur a la variable indiquee.
    Q.Open; // Execute cette instruction dans le flux courant.

    if not Q.IsEmpty then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      AProduct.ID := Q.FieldByName('id').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      AProduct.CategoryID := Q.FieldByName('category_id').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      AProduct.CategoryName := Q.FieldByName('category_name').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      AProduct.Name := Q.FieldByName('nom').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      AProduct.Reference := Q.FieldByName('reference').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      AProduct.Barcode := Q.FieldByName('barcode').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      AProduct.Description := Q.FieldByName('description').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      AProduct.Price := Q.FieldByName('prix').AsFloat; // Attribue une nouvelle valeur a la variable indiquee.
      AProduct.Stock := Q.FieldByName('stock').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      AProduct.ImageURL := Q.FieldByName('image_url').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      AProduct.TechnicalSpecs := Q.FieldByName('caracteristiques').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Result := True; // Affecte la valeur de retour de la fonction.
    end; // Ferme le bloc ou la declaration en cours.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Q.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

function TDatabaseService.GetProductByBarcode(const ABarcode: string; AProduct: TProduct): Boolean; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Q: TFDQuery; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Résout un code-barres ou une référence dans le catalogue local.
  Result := False; // Affecte la valeur de retour de la fonction.
  if (FConnection = nil) or (AProduct = nil) then Exit; // Verifie la condition avant de poursuivre.

  Q := TFDQuery.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Q.Connection := FConnection; // Attribue une nouvelle valeur a la variable indiquee.
    Q.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
      'SELECT p.id, p.category_id, c.nom as category_name, p.nom, p.reference, p.barcode, ' + // Complete la declaration ou instruction en cours.
      'p.description, p.prix, p.stock, p.image_url, p.caracteristiques ' + // Complete la declaration ou instruction en cours.
      'FROM Products p LEFT JOIN Categories c ON p.category_id = c.id WHERE p.barcode = :barcode OR p.reference = :ref'; // Execute cette instruction dans le flux courant.
    Q.ParamByName('barcode').AsString := Trim(ABarcode); // Attribue une nouvelle valeur a la variable indiquee.
    Q.ParamByName('ref').AsString := Trim(ABarcode); // Attribue une nouvelle valeur a la variable indiquee.
    Q.Open; // Execute cette instruction dans le flux courant.

    if not Q.IsEmpty then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      AProduct.ID := Q.FieldByName('id').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      AProduct.CategoryID := Q.FieldByName('category_id').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      AProduct.CategoryName := Q.FieldByName('category_name').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      AProduct.Name := Q.FieldByName('nom').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      AProduct.Reference := Q.FieldByName('reference').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      AProduct.Barcode := Q.FieldByName('barcode').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      AProduct.Description := Q.FieldByName('description').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      AProduct.Price := Q.FieldByName('prix').AsFloat; // Attribue une nouvelle valeur a la variable indiquee.
      AProduct.Stock := Q.FieldByName('stock').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      AProduct.ImageURL := Q.FieldByName('image_url').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      AProduct.TechnicalSpecs := Q.FieldByName('caracteristiques').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Result := True; // Affecte la valeur de retour de la fonction.
    end; // Ferme le bloc ou la declaration en cours.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Q.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

function TDatabaseService.GetPopularProducts(AList: TProductList; ACount: Integer): Boolean; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Q: TFDQuery; // Execute cette instruction dans le flux courant.
  Prod: TProduct; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Sélectionne un nombre limité de produits illustrés pour les écrans d'accueil.
  Result := False; // Affecte la valeur de retour de la fonction.
  if (FConnection = nil) or (AList = nil) then Exit; // Verifie la condition avant de poursuivre.

  AList.Clear; // Execute cette instruction dans le flux courant.
  Q := TFDQuery.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Q.Connection := FConnection; // Attribue une nouvelle valeur a la variable indiquee.
    Q.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
      'SELECT p.id, p.category_id, c.nom as category_name, p.nom, p.reference, p.barcode, ' + // Complete la declaration ou instruction en cours.
      'p.description, p.prix, p.stock, p.image_url, p.caracteristiques ' + // Complete la declaration ou instruction en cours.
      'FROM Products p LEFT JOIN Categories c ON p.category_id = c.id ' + // Complete la declaration ou instruction en cours.
      'WHERE p.reference LIKE ''PHOTO-%'' ' + // Complete la declaration ou instruction en cours.
      'AND p.id = (SELECT MIN(p2.id) FROM Products p2 ' + // Complete la declaration ou instruction en cours.
      'WHERE p2.category_id = p.category_id AND p2.reference LIKE ''PHOTO-%'') ' + // Complete la declaration ou instruction en cours.
      'ORDER BY p.category_id LIMIT :lim'; // Execute cette instruction dans le flux courant.
    Q.ParamByName('lim').AsInteger := ACount; // Attribue une nouvelle valeur a la variable indiquee.
    Q.Open; // Execute cette instruction dans le flux courant.

    while not Q.Eof do // Repete le bloc tant que la condition reste vraie.
    begin // Ouvre le bloc d instructions correspondant.
      Prod := TProduct.Create; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.ID := Q.FieldByName('id').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.CategoryID := Q.FieldByName('category_id').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.CategoryName := Q.FieldByName('category_name').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.Name := Q.FieldByName('nom').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.Reference := Q.FieldByName('reference').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.Barcode := Q.FieldByName('barcode').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.Description := Q.FieldByName('description').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.Price := Q.FieldByName('prix').AsFloat; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.Stock := Q.FieldByName('stock').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.ImageURL := Q.FieldByName('image_url').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.TechnicalSpecs := Q.FieldByName('caracteristiques').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      AList.Add(Prod); // Appelle la methode ou fonction avec les parametres indiques.
      Q.Next; // Execute cette instruction dans le flux courant.
    end; // Ferme le bloc ou la declaration en cours.
    Result := True; // Affecte la valeur de retour de la fonction.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Q.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

function TDatabaseService.GetCartItems(AList: TCartItemList): Boolean; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Q: TFDQuery; // Execute cette instruction dans le flux courant.
  Item: TCartItem; // Execute cette instruction dans le flux courant.
  Prod: TProduct; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Reconstruit les articles du panier en rechargeant également leurs données produit.
  Result := False; // Affecte la valeur de retour de la fonction.
  if (FConnection = nil) or (AList = nil) then Exit; // Verifie la condition avant de poursuivre.

  AList.Clear; // Execute cette instruction dans le flux courant.
  Q := TFDQuery.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Q.Connection := FConnection; // Attribue une nouvelle valeur a la variable indiquee.
    Q.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
      'SELECT ci.id, ci.product_id, ci.quantite, ci.prix_unitaire, ' + // Complete la declaration ou instruction en cours.
      'p.nom, p.reference, p.barcode, p.description, p.stock, p.image_url, p.caracteristiques, c.nom as category_name ' + // Complete la declaration ou instruction en cours.
      'FROM CartItems ci ' + // Complete la declaration ou instruction en cours.
      'LEFT JOIN Products p ON ci.product_id = p.id ' + // Complete la declaration ou instruction en cours.
      'LEFT JOIN Categories c ON p.category_id = c.id'; // Execute cette instruction dans le flux courant.
    Q.Open; // Execute cette instruction dans le flux courant.

    while not Q.Eof do // Repete le bloc tant que la condition reste vraie.
    begin // Ouvre le bloc d instructions correspondant.
      Item := TCartItem.Create; // Attribue une nouvelle valeur a la variable indiquee.
      Item.ID := Q.FieldByName('id').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      Item.ProductID := Q.FieldByName('product_id').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      Item.Quantity := Q.FieldByName('quantite').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      Item.UnitPrice := Q.FieldByName('prix_unitaire').AsFloat; // Attribue une nouvelle valeur a la variable indiquee.

      Prod := TProduct.Create; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.ID := Item.ProductID; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.Name := Q.FieldByName('nom').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.Reference := Q.FieldByName('reference').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.Barcode := Q.FieldByName('barcode').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.Description := Q.FieldByName('description').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.Price := Item.UnitPrice; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.Stock := Q.FieldByName('stock').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.ImageURL := Q.FieldByName('image_url').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.TechnicalSpecs := Q.FieldByName('caracteristiques').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.CategoryName := Q.FieldByName('category_name').AsString; // Attribue une nouvelle valeur a la variable indiquee.

      Item.Product := Prod; // Attribue une nouvelle valeur a la variable indiquee.
      AList.Add(Item); // Appelle la methode ou fonction avec les parametres indiques.
      Q.Next; // Execute cette instruction dans le flux courant.
    end; // Ferme le bloc ou la declaration en cours.
    Result := True; // Affecte la valeur de retour de la fonction.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Q.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

function TDatabaseService.SaveCartItem(AItem: TCartItem): Boolean; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Q: TFDQuery; // Execute cette instruction dans le flux courant.
  ExistingID: Integer; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Ajoute une ligne ou augmente la quantité de la ligne existante du même produit.
  Result := False; // Affecte la valeur de retour de la fonction.
  if (FConnection = nil) or (AItem = nil) then Exit; // Verifie la condition avant de poursuivre.

  Q := TFDQuery.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Q.Connection := FConnection; // Attribue une nouvelle valeur a la variable indiquee.
    Q.SQL.Text := 'SELECT id, quantite FROM CartItems WHERE product_id = :pid'; // Attribue une nouvelle valeur a la variable indiquee.
    Q.ParamByName('pid').AsInteger := AItem.ProductID; // Attribue une nouvelle valeur a la variable indiquee.
    Q.Open; // Execute cette instruction dans le flux courant.

    if not Q.IsEmpty then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      ExistingID := Q.FieldByName('id').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      Q.SQL.Text := 'UPDATE CartItems SET quantite = quantite + :qty, prix_unitaire = :price WHERE id = :id'; // Attribue une nouvelle valeur a la variable indiquee.
      Q.ParamByName('qty').AsInteger := AItem.Quantity; // Attribue une nouvelle valeur a la variable indiquee.
      Q.ParamByName('price').AsFloat := AItem.UnitPrice; // Attribue une nouvelle valeur a la variable indiquee.
      Q.ParamByName('id').AsInteger := ExistingID; // Attribue une nouvelle valeur a la variable indiquee.
      Q.ExecSQL; // Execute cette instruction dans le flux courant.
    end // Ferme le bloc ou la declaration en cours.
    else // Execute la branche alternative de la condition precedente.
    begin // Ouvre le bloc d instructions correspondant.
      Q.SQL.Text := 'INSERT INTO CartItems (product_id, quantite, prix_unitaire) VALUES (:pid, :qty, :price)'; // Attribue une nouvelle valeur a la variable indiquee.
      Q.ParamByName('pid').AsInteger := AItem.ProductID; // Attribue une nouvelle valeur a la variable indiquee.
      Q.ParamByName('qty').AsInteger := AItem.Quantity; // Attribue une nouvelle valeur a la variable indiquee.
      Q.ParamByName('price').AsFloat := AItem.UnitPrice; // Attribue une nouvelle valeur a la variable indiquee.
      Q.ExecSQL; // Execute cette instruction dans le flux courant.
    end; // Ferme le bloc ou la declaration en cours.
    Result := True; // Affecte la valeur de retour de la fonction.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Q.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

function TDatabaseService.UpdateCartItemQuantity(AProductID, AQty: Integer): Boolean; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Q: TFDQuery; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Met à jour la quantité ou supprime la ligne si la quantité demandée est nulle.
  Result := False; // Affecte la valeur de retour de la fonction.
  if FConnection = nil then Exit; // Verifie la condition avant de poursuivre.

  Q := TFDQuery.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Q.Connection := FConnection; // Attribue une nouvelle valeur a la variable indiquee.
    if AQty <= 0 then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      Q.SQL.Text := 'DELETE FROM CartItems WHERE product_id = :pid'; // Attribue une nouvelle valeur a la variable indiquee.
      Q.ParamByName('pid').AsInteger := AProductID; // Attribue une nouvelle valeur a la variable indiquee.
      Q.ExecSQL; // Execute cette instruction dans le flux courant.
    end // Ferme le bloc ou la declaration en cours.
    else // Execute la branche alternative de la condition precedente.
    begin // Ouvre le bloc d instructions correspondant.
      Q.SQL.Text := 'UPDATE CartItems SET quantite = :qty WHERE product_id = :pid'; // Attribue une nouvelle valeur a la variable indiquee.
      Q.ParamByName('qty').AsInteger := AQty; // Attribue une nouvelle valeur a la variable indiquee.
      Q.ParamByName('pid').AsInteger := AProductID; // Attribue une nouvelle valeur a la variable indiquee.
      Q.ExecSQL; // Execute cette instruction dans le flux courant.
    end; // Ferme le bloc ou la declaration en cours.
    Result := True; // Affecte la valeur de retour de la fonction.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Q.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

function TDatabaseService.DeleteCartItem(AProductID: Integer): Boolean; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Q: TFDQuery; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Supprime une ligne du panier en utilisant l'identifiant du produit.
  Result := False; // Affecte la valeur de retour de la fonction.
  if FConnection = nil then Exit; // Verifie la condition avant de poursuivre.

  Q := TFDQuery.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Q.Connection := FConnection; // Attribue une nouvelle valeur a la variable indiquee.
    Q.SQL.Text := 'DELETE FROM CartItems WHERE product_id = :pid'; // Attribue une nouvelle valeur a la variable indiquee.
    Q.ParamByName('pid').AsInteger := AProductID; // Attribue une nouvelle valeur a la variable indiquee.
    Q.ExecSQL; // Execute cette instruction dans le flux courant.
    Result := True; // Affecte la valeur de retour de la fonction.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Q.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TDatabaseService.ClearCart; // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  Q: TFDQuery; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Efface les articles du panier sans modifier le catalogue ni l'historique.
  if FConnection = nil then Exit; // Verifie la condition avant de poursuivre.
  Q := TFDQuery.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Q.Connection := FConnection; // Attribue une nouvelle valeur a la variable indiquee.
    Q.SQL.Text := 'DELETE FROM CartItems'; // Attribue une nouvelle valeur a la variable indiquee.
    Q.ExecSQL; // Execute cette instruction dans le flux courant.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Q.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

function TDatabaseService.GetQuotes(AList: TQuoteList): Boolean; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Q, QI: TFDQuery; // Execute cette instruction dans le flux courant.
  QuoteObj: TQuote; // Execute cette instruction dans le flux courant.
  QuoteItemObj: TQuoteItem; // Execute cette instruction dans le flux courant.
  DTVal: TDateTime; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Charge l'historique local des devis ainsi que les lignes de chaque devis.
  Result := False; // Affecte la valeur de retour de la fonction.
  if (FConnection = nil) or (AList = nil) then Exit; // Verifie la condition avant de poursuivre.

  AList.Clear; // Execute cette instruction dans le flux courant.
  Q := TFDQuery.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  QI := TFDQuery.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Q.Connection := FConnection; // Attribue une nouvelle valeur a la variable indiquee.
    QI.Connection := FConnection; // Attribue une nouvelle valeur a la variable indiquee.

    Q.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
      'SELECT id, numero, date_creation, statut, customer_name, company_name, customer_phone, ' + // Complete la declaration ou instruction en cours.
      'customer_email, address, notes FROM Quotes ORDER BY id DESC'; // Execute cette instruction dans le flux courant.
    Q.Open; // Execute cette instruction dans le flux courant.

    while not Q.Eof do // Repete le bloc tant que la condition reste vraie.
    begin // Ouvre le bloc d instructions correspondant.
      QuoteObj := TQuote.Create; // Attribue une nouvelle valeur a la variable indiquee.
      QuoteObj.ID := Q.FieldByName('id').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      QuoteObj.Number := Q.FieldByName('numero').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      if TryStrToDateTime(Q.FieldByName('date_creation').AsString, DTVal) then // Verifie la condition avant de poursuivre.
        QuoteObj.CreatedAt := DTVal; // Attribue une nouvelle valeur a la variable indiquee.
      QuoteObj.StatusText := Q.FieldByName('statut').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      QuoteObj.Notes := Q.FieldByName('notes').AsString; // Attribue une nouvelle valeur a la variable indiquee.

      QuoteObj.Customer.FullName := Q.FieldByName('customer_name').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      QuoteObj.Customer.CompanyName := Q.FieldByName('company_name').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      QuoteObj.Customer.Phone := Q.FieldByName('customer_phone').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      QuoteObj.Customer.Email := Q.FieldByName('customer_email').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      QuoteObj.Customer.Address := Q.FieldByName('address').AsString; // Attribue une nouvelle valeur a la variable indiquee.

      // Load items
      QI.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
        'SELECT id, quote_id, product_id, product_name, product_ref, quantite, prix_unitaire ' + // Complete la declaration ou instruction en cours.
        'FROM QuoteItems WHERE quote_id = :qid'; // Execute cette instruction dans le flux courant.
      QI.ParamByName('qid').AsInteger := QuoteObj.ID; // Attribue une nouvelle valeur a la variable indiquee.
      QI.Open; // Execute cette instruction dans le flux courant.

      while not QI.Eof do // Repete le bloc tant que la condition reste vraie.
      begin // Ouvre le bloc d instructions correspondant.
        QuoteItemObj := TQuoteItem.Create; // Attribue une nouvelle valeur a la variable indiquee.
        QuoteItemObj.ID := QI.FieldByName('id').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
        QuoteItemObj.QuoteID := QI.FieldByName('quote_id').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
        QuoteItemObj.ProductID := QI.FieldByName('product_id').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
        QuoteItemObj.ProductName := QI.FieldByName('product_name').AsString; // Attribue une nouvelle valeur a la variable indiquee.
        QuoteItemObj.ProductRef := QI.FieldByName('product_ref').AsString; // Attribue une nouvelle valeur a la variable indiquee.
        QuoteItemObj.Quantity := QI.FieldByName('quantite').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
        QuoteItemObj.UnitPrice := QI.FieldByName('prix_unitaire').AsFloat; // Attribue une nouvelle valeur a la variable indiquee.
        QuoteObj.Items.Add(QuoteItemObj); // Appelle la methode ou fonction avec les parametres indiques.
        QI.Next; // Execute cette instruction dans le flux courant.
      end; // Ferme le bloc ou la declaration en cours.
      QI.Close; // Execute cette instruction dans le flux courant.

      AList.Add(QuoteObj); // Appelle la methode ou fonction avec les parametres indiques.
      Q.Next; // Execute cette instruction dans le flux courant.
    end; // Ferme le bloc ou la declaration en cours.
    Result := True; // Affecte la valeur de retour de la fonction.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Q.Free; // Execute cette instruction dans le flux courant.
    QI.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

function TDatabaseService.GetQuoteByID(AID: Integer; AQuote: TQuote): Boolean; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Q, QI: TFDQuery; // Execute cette instruction dans le flux courant.
  QuoteItemObj: TQuoteItem; // Execute cette instruction dans le flux courant.
  DTVal: TDateTime; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Remplit un devis existant, ses coordonnées client et ses articles.
  Result := False; // Affecte la valeur de retour de la fonction.
  if (FConnection = nil) or (AQuote = nil) then Exit; // Verifie la condition avant de poursuivre.

  Q := TFDQuery.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  QI := TFDQuery.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Q.Connection := FConnection; // Attribue une nouvelle valeur a la variable indiquee.
    QI.Connection := FConnection; // Attribue une nouvelle valeur a la variable indiquee.

    Q.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
      'SELECT id, numero, date_creation, statut, customer_name, company_name, customer_phone, ' + // Complete la declaration ou instruction en cours.
      'customer_email, address, notes FROM Quotes WHERE id = :id'; // Execute cette instruction dans le flux courant.
    Q.ParamByName('id').AsInteger := AID; // Attribue une nouvelle valeur a la variable indiquee.
    Q.Open; // Execute cette instruction dans le flux courant.

    if not Q.IsEmpty then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      AQuote.ID := Q.FieldByName('id').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
      AQuote.Number := Q.FieldByName('numero').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      if TryStrToDateTime(Q.FieldByName('date_creation').AsString, DTVal) then // Verifie la condition avant de poursuivre.
        AQuote.CreatedAt := DTVal; // Attribue une nouvelle valeur a la variable indiquee.
      AQuote.StatusText := Q.FieldByName('statut').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      AQuote.Notes := Q.FieldByName('notes').AsString; // Attribue une nouvelle valeur a la variable indiquee.

      AQuote.Customer.FullName := Q.FieldByName('customer_name').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      AQuote.Customer.CompanyName := Q.FieldByName('company_name').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      AQuote.Customer.Phone := Q.FieldByName('customer_phone').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      AQuote.Customer.Email := Q.FieldByName('customer_email').AsString; // Attribue une nouvelle valeur a la variable indiquee.
      AQuote.Customer.Address := Q.FieldByName('address').AsString; // Attribue une nouvelle valeur a la variable indiquee.

      AQuote.Items.Clear; // Execute cette instruction dans le flux courant.
      QI.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
        'SELECT id, quote_id, product_id, product_name, product_ref, quantite, prix_unitaire ' + // Complete la declaration ou instruction en cours.
        'FROM QuoteItems WHERE quote_id = :qid'; // Execute cette instruction dans le flux courant.
      QI.ParamByName('qid').AsInteger := AQuote.ID; // Attribue une nouvelle valeur a la variable indiquee.
      QI.Open; // Execute cette instruction dans le flux courant.

      while not QI.Eof do // Repete le bloc tant que la condition reste vraie.
      begin // Ouvre le bloc d instructions correspondant.
        QuoteItemObj := TQuoteItem.Create; // Attribue une nouvelle valeur a la variable indiquee.
        QuoteItemObj.ID := QI.FieldByName('id').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
        QuoteItemObj.QuoteID := QI.FieldByName('quote_id').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
        QuoteItemObj.ProductID := QI.FieldByName('product_id').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
        QuoteItemObj.ProductName := QI.FieldByName('product_name').AsString; // Attribue une nouvelle valeur a la variable indiquee.
        QuoteItemObj.ProductRef := QI.FieldByName('product_ref').AsString; // Attribue une nouvelle valeur a la variable indiquee.
        QuoteItemObj.Quantity := QI.FieldByName('quantite').AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
        QuoteItemObj.UnitPrice := QI.FieldByName('prix_unitaire').AsFloat; // Attribue une nouvelle valeur a la variable indiquee.
        AQuote.Items.Add(QuoteItemObj); // Appelle la methode ou fonction avec les parametres indiques.
        QI.Next; // Execute cette instruction dans le flux courant.
      end; // Ferme le bloc ou la declaration en cours.
      Result := True; // Affecte la valeur de retour de la fonction.
    end; // Ferme le bloc ou la declaration en cours.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Q.Free; // Execute cette instruction dans le flux courant.
    QI.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

function TDatabaseService.SaveQuote(AQuote: TQuote): Boolean; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Q: TFDQuery; // Execute cette instruction dans le flux courant.
  QuoteID: Integer; // Execute cette instruction dans le flux courant.
  Item: TQuoteItem; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Enregistre le devis et ses articles dans une transaction SQLite unique.
  Result := False; // Affecte la valeur de retour de la fonction.
  if (FConnection = nil) or (AQuote = nil) then Exit; // Verifie la condition avant de poursuivre.

  FConnection.StartTransaction; // Execute cette instruction dans le flux courant.
  Q := TFDQuery.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Q.Connection := FConnection; // Attribue une nouvelle valeur a la variable indiquee.

    Q.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
      'INSERT INTO Quotes (numero, date_creation, statut, customer_name, company_name, ' + // Complete la declaration ou instruction en cours.
      'customer_phone, customer_email, address, notes) VALUES ' + // Complete la declaration ou instruction en cours.
      '(:num, :dt, :stat, :cname, :comp, :phone, :email, :addr, :notes)'; // Execute cette instruction dans le flux courant.
    Q.ParamByName('num').AsString := AQuote.Number; // Attribue une nouvelle valeur a la variable indiquee.
    Q.ParamByName('dt').AsString := FormatDateTime('yyyy-mm-dd hh:nn:ss', AQuote.CreatedAt); // Attribue une nouvelle valeur a la variable indiquee.
    Q.ParamByName('stat').AsString := AQuote.StatusText; // Attribue une nouvelle valeur a la variable indiquee.
    Q.ParamByName('cname').AsString := AQuote.Customer.FullName; // Attribue une nouvelle valeur a la variable indiquee.
    Q.ParamByName('comp').AsString := AQuote.Customer.CompanyName; // Attribue une nouvelle valeur a la variable indiquee.
    Q.ParamByName('phone').AsString := AQuote.Customer.Phone; // Attribue une nouvelle valeur a la variable indiquee.
    Q.ParamByName('email').AsString := AQuote.Customer.Email; // Attribue une nouvelle valeur a la variable indiquee.
    Q.ParamByName('addr').AsString := AQuote.Customer.Address; // Attribue une nouvelle valeur a la variable indiquee.
    Q.ParamByName('notes').AsString := AQuote.Notes; // Attribue une nouvelle valeur a la variable indiquee.
    Q.ExecSQL; // Execute cette instruction dans le flux courant.

    Q.SQL.Text := 'SELECT last_insert_rowid()'; // Attribue une nouvelle valeur a la variable indiquee.
    Q.Open; // Execute cette instruction dans le flux courant.
    QuoteID := Q.Fields[0].AsInteger; // Attribue une nouvelle valeur a la variable indiquee.
    AQuote.ID := QuoteID; // Attribue une nouvelle valeur a la variable indiquee.
    Q.Close; // Execute cette instruction dans le flux courant.

    for Item in AQuote.Items do // Parcourt les elements ou valeurs de cette boucle.
    begin // Ouvre le bloc d instructions correspondant.
      Q.SQL.Text := // Attribue une nouvelle valeur a la variable indiquee.
        'INSERT INTO QuoteItems (quote_id, product_id, product_name, product_ref, quantite, prix_unitaire) ' + // Complete la declaration ou instruction en cours.
        'VALUES (:qid, :pid, :pname, :pref, :qty, :price)'; // Execute cette instruction dans le flux courant.
      Q.ParamByName('qid').AsInteger := QuoteID; // Attribue une nouvelle valeur a la variable indiquee.
      Q.ParamByName('pid').AsInteger := Item.ProductID; // Attribue une nouvelle valeur a la variable indiquee.
      Q.ParamByName('pname').AsString := Item.ProductName; // Attribue une nouvelle valeur a la variable indiquee.
      Q.ParamByName('pref').AsString := Item.ProductRef; // Attribue une nouvelle valeur a la variable indiquee.
      Q.ParamByName('qty').AsInteger := Item.Quantity; // Attribue une nouvelle valeur a la variable indiquee.
      Q.ParamByName('price').AsFloat := Item.UnitPrice; // Attribue une nouvelle valeur a la variable indiquee.
      Q.ExecSQL; // Execute cette instruction dans le flux courant.
    end; // Ferme le bloc ou la declaration en cours.

    FConnection.Commit; // Execute cette instruction dans le flux courant.
    Result := True; // Affecte la valeur de retour de la fonction.
  except // Ouvre le traitement des exceptions du bloc protege.
    FConnection.Rollback; // Execute cette instruction dans le flux courant.
    raise; // Propage une exception pour signaler l echec.
  end; // Ferme le bloc ou la declaration en cours.
  Q.Free; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

function TDatabaseService.UpdateQuoteStatus(AQuoteID: Integer; const AStatus: string): Boolean; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Q: TFDQuery; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Met à jour uniquement l'état du devis local.
  Result := False; // Affecte la valeur de retour de la fonction.
  if FConnection = nil then Exit; // Verifie la condition avant de poursuivre.

  Q := TFDQuery.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Q.Connection := FConnection; // Attribue une nouvelle valeur a la variable indiquee.
    Q.SQL.Text := 'UPDATE Quotes SET statut = :stat WHERE id = :id'; // Attribue une nouvelle valeur a la variable indiquee.
    Q.ParamByName('stat').AsString := AStatus; // Attribue une nouvelle valeur a la variable indiquee.
    Q.ParamByName('id').AsInteger := AQuoteID; // Attribue une nouvelle valeur a la variable indiquee.
    Q.ExecSQL; // Execute cette instruction dans le flux courant.
    Result := True; // Affecte la valeur de retour de la fonction.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Q.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TDatabaseService.ResetDatabase; // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  Q: TFDQuery; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Supprime les tables applicatives puis relance la création et l'initialisation.
  if FConnection = nil then Exit; // Verifie la condition avant de poursuivre.
  Q := TFDQuery.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Q.Connection := FConnection; // Attribue une nouvelle valeur a la variable indiquee.
    Q.SQL.Text := 'DROP TABLE IF EXISTS QuoteItems; DROP TABLE IF EXISTS Quotes; DROP TABLE IF EXISTS CartItems; DROP TABLE IF EXISTS Products; DROP TABLE IF EXISTS Categories;'; // Attribue une nouvelle valeur a la variable indiquee.
    Q.ExecSQL; // Execute cette instruction dans le flux courant.
    InitializeDatabase; // Execute cette instruction dans le flux courant.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Q.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
