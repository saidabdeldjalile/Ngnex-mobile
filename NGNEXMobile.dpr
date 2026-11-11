program NGNEXMobile;

uses
  // Initialise les ressources de démarrage propres à chaque plateforme.
  System.StartUpCopy,
  // Fournit le cycle de vie FireMonkey et l'exécution de l'application.
  FMX.Forms,
  // Fournit les types d'exception capturés au démarrage.
  System.SysUtils,
  // Fournit les fonctions de journalisation des erreurs et du démarrage.
  StartupDiagnostics in 'StartupDiagnostics.pas',
  // Contient la fenêtre principale et son système de navigation.
  MainForm in 'MainForm.pas' {FrmMain},
  // Contient la connexion à la base et les services partagés par les écrans.
  DataModule in 'DataModule.pas' {DM: TDataModule},
  // Modèles de données manipulés par les services et les écrans.
  Product in 'Models\Product.pas',
  ProductPhotoCatalog in 'Models\ProductPhotoCatalog.pas',
  Category in 'Models\Category.pas',
  CartItem in 'Models\CartItem.pas',
  Quote in 'Models\Quote.pas',
  Customer in 'Models\Customer.pas',
  // Constantes visuelles communes aux différents écrans.
  AppTheme in 'Models\AppTheme.pas',
  // Services d'accès aux données, à l'API et aux fonctions métier.
  DatabaseService in 'Services\DatabaseService.pas',
  ApiService in 'Services\ApiService.pas',
  ProductService in 'Services\ProductService.pas',
  CategoryService in 'Services\CategoryService.pas',
  CartService in 'Services\CartService.pas',
  QuoteService in 'Services\QuoteService.pas',
  BarcodeService in 'Services\BarcodeService.pas',
  ImageService in 'Services\ImageService.pas',
  // Frames FireMonkey qui constituent les écrans de l'application.
  HomeForm in 'Views\HomeForm.pas' {FrameHome: TFrame},
  CategoriesForm in 'Views\CategoriesForm.pas' {FrameCategories: TFrame},
  ProductsForm in 'Views\ProductsForm.pas' {FrameProducts: TFrame},
  ProductDetailsForm in 'Views\ProductDetailsForm.pas' {FrameProductDetails: TFrame},
  ScannerForm in 'Views\ScannerForm.pas' {FrameScanner: TFrame},
  CompareForm in 'Views\CompareForm.pas' {FrameCompare: TFrame},
  CalculatorForm in 'Views\CalculatorForm.pas' {FrameCalculator: TFrame},
  CartForm in 'Views\CartForm.pas' {FrameCart: TFrame},
  QuoteForm in 'Views\QuoteForm.pas' {FrameQuote: TFrame},
  QuoteHistoryForm in 'Views\QuoteHistoryForm.pas' {FrameQuoteHistory: TFrame},
  SettingsForm in 'Views\SettingsForm.pas' {FrameSettings: TFrame};

{$R *.res}

begin
  // Prépare FireMonkey avant de créer les objets globaux de l'application.
  Application.Initialize;
  // Branche le journal de diagnostic avant toute initialisation susceptible d'échouer.
  InitializeStartupDiagnostics;
  try
    // Le module de données doit être créé avant le formulaire, car les écrans
    // consultent ses services pendant leur initialisation.
    LogStartup('NGNEX startup: registering data module');
    Application.CreateForm(TDM, DM);
    // Crée l'interface principale après l'initialisation des services.
    LogStartup('NGNEX startup: registering main form');
    Application.CreateForm(TFrmMain, FrmMain);
    // Sur Android, FireMonkey termine la création visuelle à l'activation native.
    LogStartup('NGNEX startup: forms registered; Android creates them on activity start');
  except
    on E: Exception do
    begin
      // Consigne l'erreur de démarrage puis la relance pour ne pas masquer l'échec.
      LogStartupException('NGNEX startup registration failed', E);
      raise;
    end;
  end;
  // Passe le contrôle à la boucle d'événements FireMonkey.
  LogStartup('NGNEX startup: entering application loop');
  Application.Run;
end.
