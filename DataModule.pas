unit DataModule; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, // Complete la declaration ou instruction en cours.
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, // Complete la declaration ou instruction en cours.
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite, // Complete la declaration ou instruction en cours.
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLiteWrapper.Stat, // Complete la declaration ou instruction en cours.
  FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait, // Complete la declaration ou instruction en cours.
  FireDAC.Comp.Client, Data.DB, // Complete la declaration ou instruction en cours.
  DatabaseService, ApiService, ProductService, CategoryService, // Complete la declaration ou instruction en cours.
  CartService, QuoteService, BarcodeService, ImageService, StartupDiagnostics; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Point central de création et de durée de vie des services partagés.
  TDM = class(TDataModule) // Complete la declaration ou instruction en cours.
    // Connexion FireDAC utilisée par le service de base de données SQLite.
    FDConnection: TFDConnection; // Execute cette instruction dans le flux courant.
    // Enregistre le pilote FireDAC SQLite pour la connexion.
    FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink; // Execute cette instruction dans le flux courant.
    // Evénements de cycle de vie reliés au fichier FMX du module.
    procedure DataModuleCreate(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure DataModuleDestroy(Sender: TObject); // Declare une procedure de cette unite ou classe.
  private // Complete la declaration ou instruction en cours.
    // Services possédés par le module et libérés à sa destruction.
    FDatabaseService: TDatabaseService; // Execute cette instruction dans le flux courant.
    FApiService: TApiService; // Execute cette instruction dans le flux courant.
    FProductService: TProductService; // Execute cette instruction dans le flux courant.
    FCategoryService: TCategoryService; // Execute cette instruction dans le flux courant.
    FCartService: TCartService; // Execute cette instruction dans le flux courant.
    FQuoteService: TQuoteService; // Execute cette instruction dans le flux courant.
    FBarcodeService: TBarcodeService; // Execute cette instruction dans le flux courant.
    FImageService: TImageService; // Execute cette instruction dans le flux courant.
  public // Complete la declaration ou instruction en cours.
    // Propriétés en lecture seule utilisées par les formulaires via DM.
    property DatabaseService: TDatabaseService read FDatabaseService; // Expose une propriete de la classe.
    property ApiService: TApiService read FApiService; // Expose une propriete de la classe.
    property ProductService: TProductService read FProductService; // Expose une propriete de la classe.
    property CategoryService: TCategoryService read FCategoryService; // Expose une propriete de la classe.
    property CartService: TCartService read FCartService; // Expose une propriete de la classe.
    property QuoteService: TQuoteService read FQuoteService; // Expose une propriete de la classe.
    property BarcodeService: TBarcodeService read FBarcodeService; // Expose une propriete de la classe.
    property ImageService: TImageService read FImageService; // Expose une propriete de la classe.
  end; // Ferme le bloc ou la declaration en cours.

var // Ouvre la section de declarations correspondante.
  DM: TDM; // Execute cette instruction dans le flux courant.

implementation // Ouvre la partie contenant les implementations privees.

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.fmx} // Inclut la ressource FMX de cette unite.

const // Ouvre la section de declarations correspondante.
  // Adresse de l'API locale pour le développement avec transfert USB ADB.
  API_BASE_URL = 'http://192.168.100.176:8000/api'; // Execute cette instruction dans le flux courant.

procedure TDM.DataModuleCreate(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Initialise d'abord la base locale, afin que l'application reste utilisable
  // même si le serveur distant n'est pas disponible.
  LogStartup('NGNEX startup: DataModuleCreate entered'); // Appelle la methode ou fonction avec les parametres indiques.
  try // Ouvre le bloc d instructions correspondant.
    FDatabaseService := TDatabaseService.Create(FDConnection); // Attribue une nouvelle valeur a la variable indiquee.
    FDatabaseService.InitializeDatabase; // Execute cette instruction dans le flux courant.
    LogStartup('NGNEX startup: local database initialized'); // Appelle la methode ou fonction avec les parametres indiques.

    // Les services qui utilisent le réseau partagent la même configuration API.
    FApiService := TApiService.Create(API_BASE_URL); // Attribue une nouvelle valeur a la variable indiquee.
    FProductService := TProductService.Create(FDatabaseService, FApiService); // Attribue une nouvelle valeur a la variable indiquee.
    FCategoryService := TCategoryService.Create(FDatabaseService, FApiService); // Attribue une nouvelle valeur a la variable indiquee.
    // Le panier reste local ; les demandes de devis peuvent aussi être envoyées à l'API.
    FCartService := TCartService.Create(FDatabaseService); // Attribue une nouvelle valeur a la variable indiquee.
    FQuoteService := TQuoteService.Create(FDatabaseService, FApiService); // Attribue une nouvelle valeur a la variable indiquee.
    // Le scanner dépend du service produit pour rechercher un code reconnu.
    FBarcodeService := TBarcodeService.Create(FProductService); // Attribue une nouvelle valeur a la variable indiquee.
    // Le service d'images reçoit l'indication de l'accès distant selon l'URL configurée.
    FImageService := TImageService.Create; // Attribue une nouvelle valeur a la variable indiquee.
    FImageService.AllowRemoteImages := not FApiService.BaseURL.Trim.IsEmpty; // Attribue une nouvelle valeur a la variable indiquee.
    LogStartup('NGNEX startup: data services initialized'); // Appelle la methode ou fonction avec les parametres indiques.
  except // Ouvre le traitement des exceptions du bloc protege.
    on E: Exception do // Associe ce cas au traitement d exception indique.
    begin // Ouvre le bloc d instructions correspondant.
      // Conserve la cause exacte de l'échec pour les journaux Android.
      LogStartupException('NGNEX DataModuleCreate failed', E); // Appelle la methode ou fonction avec les parametres indiques.
      raise; // Propage une exception pour signaler l echec.
    end; // Ferme le bloc ou la declaration en cours.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TDM.DataModuleDestroy(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Libère les services avant leurs dépendances (les services métier utilisent
  // DatabaseService et ApiService).
  FreeAndNil(FImageService); // Appelle la methode ou fonction avec les parametres indiques.
  FreeAndNil(FBarcodeService); // Appelle la methode ou fonction avec les parametres indiques.
  FreeAndNil(FQuoteService); // Appelle la methode ou fonction avec les parametres indiques.
  FreeAndNil(FCartService); // Appelle la methode ou fonction avec les parametres indiques.
  FreeAndNil(FCategoryService); // Appelle la methode ou fonction avec les parametres indiques.
  FreeAndNil(FProductService); // Appelle la methode ou fonction avec les parametres indiques.
  FreeAndNil(FApiService); // Appelle la methode ou fonction avec les parametres indiques.
  FreeAndNil(FDatabaseService); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
