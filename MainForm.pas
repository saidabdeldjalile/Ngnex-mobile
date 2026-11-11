unit MainForm; // Declare le nom de cette unite Delphi.

{ Fiche principale : barre d'en-tête, conteneur de vues (frames) et
  navigation du bas. Une seule frame est affichée à la fois. }

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, // Complete la declaration ou instruction en cours.
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls, // Complete la declaration ou instruction en cours.
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, // Complete la declaration ou instruction en cours.
  AppTheme, HomeForm, ProductsForm, CategoriesForm, ProductDetailsForm, // Complete la declaration ou instruction en cours.
  ScannerForm, CompareForm, CalculatorForm, CartForm, QuoteForm, // Complete la declaration ou instruction en cours.
  QuoteHistoryForm, SettingsForm, Product; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Fenêtre conteneur : les écrans métier sont affichés comme des frames.
  TFrmMain = class(TForm) // Complete la declaration ou instruction en cours.
    tbHeader: TLayout; // Execute cette instruction dans le flux courant.
    rectHeaderBackground: TRectangle; // Execute cette instruction dans le flux courant.
    rectHeaderDivider: TRectangle; // Filet de séparation sous l'en-tête.
    rectHeaderBrand: TRectangle; // Execute cette instruction dans le flux courant.
    imgHeaderLogo: TImage; // Execute cette instruction dans le flux courant.
    lblHeaderTitle: TLabel; // Execute cette instruction dans le flux courant.
    btnBack: TSpeedButton; // Execute cette instruction dans le flux courant.
    btnCartHeader: TSpeedButton; // Execute cette instruction dans le flux courant.
    btnSettingsHeader: TSpeedButton; // Execute cette instruction dans le flux courant.
    layViewContainer: TLayout; // Execute cette instruction dans le flux courant.
    rectBottomNav: TRectangle; // Execute cette instruction dans le flux courant.
    rectNavDivider: TRectangle; // Filet de séparation au-dessus de la navigation.
    gridNavButtons: TGridPanelLayout; // Execute cette instruction dans le flux courant.
    btnTabHome: TSpeedButton; // Execute cette instruction dans le flux courant.
    btnTabProducts: TSpeedButton; // Execute cette instruction dans le flux courant.
    btnTabScanner: TSpeedButton; // Execute cette instruction dans le flux courant.
    btnTabCart: TSpeedButton; // Execute cette instruction dans le flux courant.
    btnTabQuote: TSpeedButton; // Execute cette instruction dans le flux courant.
    procedure FormCreate(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure FormDestroy(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure btnTabHomeClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure btnTabProductsClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure btnTabScannerClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure btnTabCartClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure btnTabQuoteClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure btnBackClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure btnCartHeaderClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure btnSettingsHeaderClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
  private // Complete la declaration ou instruction en cours.
    // Référence vers l'unique frame affichée à un instant donné.
    FCurrentFrame: TFrame; // Execute cette instruction dans le flux courant.
    // Informations nécessaires pour restaurer la vue précédente.
    FCurrentView: string; // Execute cette instruction dans le flux courant.
    FCurrentDataInt: NativeInt; // Execute cette instruction dans le flux courant.
    FLogoAvailable: Boolean; // Execute cette instruction dans le flux courant.
    FViewHistory: TStringList;   // entrées "NomVue|Donnée"
    FPendingSearch: string;      // texte de recherche venant de l'accueil

    procedure ClearCurrentFrame; // Declare une procedure de cette unite ou classe.
    procedure UpdateCartBadge; // Declare une procedure de cette unite ou classe.
    procedure HighlightTab(ActiveButton: TSpeedButton); // Declare une procedure de cette unite ou classe.
    function IsTabView(const AViewName: string): Boolean; // Declare une fonction qui renvoie un resultat.
    procedure ShowView(const AViewName: string; AData: TObject; // Declare une procedure de cette unite ou classe.
      ARecordHistory: Boolean); // Execute cette instruction dans le flux courant.

    // Gestionnaires d'événements des frames
    procedure HandleHomeNavigate(const ATargetView: string; ANavData: TObject); // Declare une procedure de cette unite ou classe.
    procedure HandleCategorySelect(ACatID: Integer); // Declare une procedure de cette unite ou classe.
    procedure HandleProductSelect(AProdID: Integer); // Declare une procedure de cette unite ou classe.
    procedure HandleDetailAction(const AAction: string; AProdID: Integer); // Declare une procedure de cette unite ou classe.
    procedure HandleProductFound(AFoundProduct: TProduct); // Declare une procedure de cette unite ou classe.
    procedure HandleCartAction(const AAction: string); // Declare une procedure de cette unite ou classe.
    procedure HandleCartChanged(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure HandleQuoteSubmitted(const ANum: string); // Declare une procedure de cette unite ou classe.
    procedure HandleQuoteBackHome(Sender: TObject); // Declare une procedure de cette unite ou classe.
  public // Complete la declaration ou instruction en cours.
    // Point d'entrée unique pour demander l'affichage d'une vue depuis un écran.
    procedure SwitchToView(const AViewName: string; AData: TObject = nil); // Declare une procedure de cette unite ou classe.
  end; // Ferme le bloc ou la declaration en cours.

var // Ouvre la section de declarations correspondante.
  FrmMain: TFrmMain; // Execute cette instruction dans le flux courant.

implementation // Ouvre la partie contenant les implementations privees.

uses // Declare les unites dont ce code depend.
  DataModule, StartupDiagnostics; // Execute cette instruction dans le flux courant.

{$R *.fmx} // Inclut la ressource FMX de cette unite.

{ ---------- Cycle de vie ---------- }

procedure TFrmMain.FormCreate(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Vérifie que le module de données est prêt avant d'accéder à ses services.
  LogStartup('NGNEX startup: MainForm FormCreate entered'); // Appelle la methode ou fonction avec les parametres indiques.
  try // Ouvre le bloc d instructions correspondant.
  if (DM = nil) or (DM.DatabaseService = nil) or (DM.ImageService = nil) then // Verifie la condition avant de poursuivre.
    raise EInvalidOp.Create('Les services locaux de NGNEX ne sont pas initialisés.'); // Propage une exception pour signaler l echec.

  // Construit l'historique de navigation et applique le thème à l'en-tête.
  FViewHistory := TStringList.Create; // Attribue une nouvelle valeur a la variable indiquee.
  Fill.Color := COLOR_BG_PAGE; // Fond de page off-white moderne.
  rectHeaderBackground.Fill.Color := COLOR_SURFACE; // En-tête blanc pur.
  rectHeaderBackground.Stroke.Kind := TBrushKind.None; // Attribue une nouvelle valeur a la variable indiquee.
  rectHeaderBackground.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.
  rectHeaderDivider.Fill.Color := COLOR_BORDER_LIGHT; // Filet discret sous l'en-tête.
  rectHeaderDivider.Stroke.Kind := TBrushKind.None; // Attribue une nouvelle valeur a la variable indiquee.
  rectHeaderBrand.Fill.Color := COLOR_SURFACE; // Attribue une nouvelle valeur a la variable indiquee.
  rectHeaderBrand.Stroke.Kind := TBrushKind.None; // Attribue une nouvelle valeur a la variable indiquee.
  rectHeaderBrand.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.
  imgHeaderLogo.WrapMode := TImageWrapMode.Fit; // Attribue une nouvelle valeur a la variable indiquee.
  imgHeaderLogo.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.
  // Le logo est masqué si son fichier n'est pas disponible dans les ressources.
  FLogoAvailable := (DM <> nil) and // Attribue une nouvelle valeur a la variable indiquee.
    DM.ImageService.LoadIntoImage('logo_wordmark.png', imgHeaderLogo); // Appelle la methode ou fonction avec les parametres indiques.


  rectBottomNav.Fill.Color := COLOR_SURFACE; // Barre de navigation blanche.
  rectBottomNav.Stroke.Kind := TBrushKind.None; // Attribue une nouvelle valeur a la variable indiquee.
  rectNavDivider.Fill.Color := COLOR_BORDER_LIGHT; // Filet discret au-dessus de la navigation.
  rectNavDivider.Stroke.Kind := TBrushKind.None; // Attribue une nouvelle valeur a la variable indiquee.
  lblHeaderTitle.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
  lblHeaderTitle.TextSettings.FontColor := COLOR_PRIMARY_DARK; // Attribue une nouvelle valeur a la variable indiquee.
  lblHeaderTitle.TextSettings.Font.Size := FONT_SIZE_PAGE_TITLE; // Attribue une nouvelle valeur a la variable indiquee.
  lblHeaderTitle.TextSettings.Font.Style := [TFontStyle.fsBold]; // Attribue une nouvelle valeur a la variable indiquee.
  lblHeaderTitle.TextSettings.HorzAlign := TTextAlign.Leading; // Attribue une nouvelle valeur a la variable indiquee.
  btnBack.TextSettings.FontColor := COLOR_PRIMARY_DARK; // Attribue une nouvelle valeur a la variable indiquee.
  btnBack.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
  btnBack.TextSettings.Font.Size := 24; // Attribue une nouvelle valeur a la variable indiquee.
  btnSettingsHeader.TextSettings.FontColor := COLOR_PRIMARY_DARK; // Attribue une nouvelle valeur a la variable indiquee.
  btnSettingsHeader.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
  btnSettingsHeader.TextSettings.Font.Size := 19; // Attribue une nouvelle valeur a la variable indiquee.
  btnCartHeader.TextSettings.FontColor := COLOR_ACCENT; // Le panier reste l'action la plus visible.
  btnCartHeader.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
  btnCartHeader.TextSettings.Font.Size := 14; // Attribue une nouvelle valeur a la variable indiquee.
  btnTabHome.TextSettings.Font.Size := 10; // Attribue une nouvelle valeur a la variable indiquee.
  btnTabProducts.TextSettings.Font.Size := 10; // Attribue une nouvelle valeur a la variable indiquee.
  btnTabScanner.TextSettings.Font.Size := 10; // Attribue une nouvelle valeur a la variable indiquee.
  btnTabCart.TextSettings.Font.Size := 10; // Attribue une nouvelle valeur a la variable indiquee.
  btnTabQuote.TextSettings.Font.Size := 10; // Attribue une nouvelle valeur a la variable indiquee.
  btnTabHome.Text := '🏠 Accueil'; // Attribue une nouvelle valeur a la variable indiquee.
  btnTabProducts.Text := '📦 Produits'; // Attribue une nouvelle valeur a la variable indiquee.
  btnTabScanner.Text := '📷 Scan'; // Attribue une nouvelle valeur a la variable indiquee.
  btnTabCart.Text := '🛒 Panier'; // Attribue une nouvelle valeur a la variable indiquee.
  btnTabQuote.Text := '📋 Devis'; // Attribue une nouvelle valeur a la variable indiquee.
  // Affiche la vue d'accueil après la configuration des contrôles partagés.
  UpdateCartBadge; // Execute cette instruction dans le flux courant.
  LogStartup('NGNEX startup: creating initial home view'); // Appelle la methode ou fonction avec les parametres indiques.
  ShowView('Home', nil, True); // Appelle la methode ou fonction avec les parametres indiques.
  LogStartup('NGNEX startup: initial home view created'); // Appelle la methode ou fonction avec les parametres indiques.
  except // Ouvre le traitement des exceptions du bloc protege.
    on E: Exception do
    begin
  
      LogStartupException('NGNEX MainForm FormCreate failed', E); // Appelle la methode ou fonction avec les parametres indiques.
      raise; // Propage une exception pour signaler l echec.
    end; // Ferme le bloc ou la declaration en cours.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrmMain.FormDestroy(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // La frame appartient à la fenêtre et doit disparaître avant l'historique.
  ClearCurrentFrame; // Execute cette instruction dans le flux courant.
  FreeAndNil(FViewHistory); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrmMain.ClearCurrentFrame; // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  if Assigned(FCurrentFrame) then // Verifie la condition avant de poursuivre.
  begin

    // Détache la frame du parent avant de la libérer.
    FCurrentFrame.Parent := nil; // Attribue une nouvelle valeur a la variable indiquee.
    FreeAndNil(FCurrentFrame); // Appelle la methode ou fonction avec les parametres indiques.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

{ ---------- Interface ---------- }

procedure TFrmMain.UpdateCartBadge; // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  Qty: Integer; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Le badge reflète la quantité totale calculée par le service de panier.
  if DM <> nil then // Verifie la condition avant de poursuivre.
  begin

    Qty := DM.CartService.TotalQuantity; // Attribue une nouvelle valeur a la variable indiquee.
    if Qty > 0 then // Verifie la condition avant de poursuivre.
      btnCartHeader.Text := Format('🛒 (%d)', [Qty]) // Attribue une nouvelle valeur a la variable indiquee.
  
    else
      btnCartHeader.Text := '🛒';
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrmMain.HighlightTab(ActiveButton: TSpeedButton); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Réinitialise l'apparence de tous les onglets avant de marquer l'actif.
  btnTabHome.TextSettings.FontColor := COLOR_TEXT_SECONDARY; // Attribue une nouvelle valeur a la variable indiquee.
  btnTabProducts.TextSettings.FontColor := COLOR_TEXT_SECONDARY; // Attribue une nouvelle valeur a la variable indiquee.
  btnTabScanner.TextSettings.FontColor := COLOR_TEXT_SECONDARY; // Attribue une nouvelle valeur a la variable indiquee.
  btnTabCart.TextSettings.FontColor := COLOR_TEXT_SECONDARY; // Attribue une nouvelle valeur a la variable indiquee.
  btnTabQuote.TextSettings.FontColor := COLOR_TEXT_SECONDARY; // Attribue une nouvelle valeur a la variable indiquee.

  btnTabHome.Font.Style := []; // Attribue une nouvelle valeur a la variable indiquee.
  btnTabProducts.Font.Style := []; // Attribue une nouvelle valeur a la variable indiquee.
  btnTabScanner.Font.Style := []; // Attribue une nouvelle valeur a la variable indiquee.
  btnTabCart.Font.Style := []; // Attribue une nouvelle valeur a la variable indiquee.
  btnTabQuote.Font.Style := [];
  btnTabHome.TextSettings.Font.Size := 10;
  btnTabProducts.TextSettings.Font.Size := 10;
  btnTabScanner.TextSettings.Font.Size := 10;
  btnTabCart.TextSettings.Font.Size := 10;
  btnTabQuote.TextSettings.Font.Size := 10;

  if ActiveButton <> nil then // Verifie la condition avant de poursuivre.
  begin

    ActiveButton.TextSettings.FontColor := COLOR_PRIMARY; // Attribue une nouvelle valeur a la variable indiquee.
    ActiveButton.Font.Style := [TFontStyle.fsBold];
    ActiveButton.TextSettings.Font.Size := 11;
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

{ Vues principales (onglets du bas) : elles remettent l'historique à zéro. }
function TFrmMain.IsTabView(const AViewName: string): Boolean; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Les onglets racine démarrent une nouvelle navigation au lieu d'empiler
  // toute l'historique précédente.
  Result := SameText(AViewName, 'Home') // Affecte la valeur de retour de la fonction.
    or SameText(AViewName, 'Categories') // Complete la declaration ou instruction en cours.
    or SameText(AViewName, 'Products') // Complete la declaration ou instruction en cours.
    or SameText(AViewName, 'ProductsSearch') // Complete la declaration ou instruction en cours.
    or SameText(AViewName, 'Scanner') // Complete la declaration ou instruction en cours.
    or SameText(AViewName, 'Cart') // Complete la declaration ou instruction en cours.
    or SameText(AViewName, 'Quote'); // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

{ ---------- Gestionnaires d'événements ---------- }

procedure TFrmMain.HandleHomeNavigate(const ATargetView: string;
  ANavData: TObject);
begin // Ouvre le bloc d instructions correspondant.
  // La recherche transporte son texte dans le nom d'action ; il est séparé
  // ici pour le conserver avant d'ouvrir la vue Catalogue.
  if Pos('ProductsSearch:', ATargetView) = 1 then // Verifie la condition avant de poursuivre.
  begin

    // Le texte est gardé dans un champ de la fiche (pas de pointeur vers
    // une variable locale, qui serait déjà libérée).
    FPendingSearch := Copy(ATargetView, 16, Length(ATargetView)); // Attribue une nouvelle valeur a la variable indiquee.
    SwitchToView('ProductsSearch'); // Appelle la methode ou fonction avec les parametres indiques.
  end // Ferme le bloc ou la declaration en cours.

  else
    SwitchToView(ATargetView, ANavData);
end; // Ferme le bloc ou la declaration en cours.

procedure TFrmMain.HandleCategorySelect(ACatID: Integer); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Les identifiants sont passés comme données de navigation sans créer
  // d'objet temporaire à gérer.
  SwitchToView('Products', TObject(IntPtr(ACatID))); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrmMain.HandleProductSelect(AProdID: Integer); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Ouvre la fiche du produit choisi dans le catalogue.
  SwitchToView('ProductDetails', TObject(IntPtr(AProdID))); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrmMain.HandleDetailAction(const AAction: string; AProdID: Integer); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Le panier peut avoir changé depuis la fiche ; actualise son badge avant
  // d'éventuellement naviguer vers Comparaison ou Devis.
  UpdateCartBadge; // Execute cette instruction dans le flux courant.
  if SameText(AAction, 'Compare') then // Verifie la condition avant de poursuivre.
    SwitchToView('Compare', TObject(IntPtr(AProdID))) // Appelle la methode ou fonction avec les parametres indiques.
  else if SameText(AAction, 'RequestQuote') then // Execute la branche alternative de la condition precedente.
    SwitchToView('Quote'); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrmMain.HandleProductFound(AFoundProduct: TProduct); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // N'ouvre une fiche que si le scanner a réellement fourni un produit.
  if AFoundProduct <> nil then // Verifie la condition avant de poursuivre.
    SwitchToView('ProductDetails', TObject(IntPtr(AFoundProduct.ID))); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrmMain.HandleCartAction(const AAction: string); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Actualise le compteur après les actions effectuées dans le panier.
  UpdateCartBadge; // Execute cette instruction dans le flux courant.
  if SameText(AAction, 'GoQuote') then // Verifie la condition avant de poursuivre.
    SwitchToView('Quote'); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrmMain.HandleCartChanged(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Callback partagé par les vues qui ajoutent un article au panier.
  UpdateCartBadge; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrmMain.HandleQuoteSubmitted(const ANum: string); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Après l'enregistrement local d'un devis, affiche l'historique actualisé.
  UpdateCartBadge; // Execute cette instruction dans le flux courant.
  SwitchToView('QuoteHistory'); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrmMain.HandleQuoteBackHome(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Retour explicite à l'accueil depuis le formulaire de devis.
  SwitchToView('Home'); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

{ ---------- Navigation ---------- }

procedure TFrmMain.SwitchToView(const AViewName: string; AData: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Diffère le remplacement de frame jusqu'à la fin du clic courant : ainsi,
  // le gestionnaire qui a déclenché la navigation n'est pas détruit en cours
  // d'exécution.
  TThread.ForceQueue(nil, // Appelle la methode ou fonction avec les parametres indiques.
    procedure // Complete la declaration ou instruction en cours.
    begin // Ouvre le bloc d instructions correspondant.
      ShowView(AViewName, AData, True); // Appelle la methode ou fonction avec les parametres indiques.
    end); // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrmMain.ShowView(const AViewName: string; AData: TObject; // Declare une procedure de cette unite ou classe.
  ARecordHistory: Boolean); // Execute cette instruction dans le flux courant.
var // Ouvre la section de declarations correspondante.
  FrameHomeObj: TFrameHome; // Execute cette instruction dans le flux courant.
  FrameCatsObj: TFrameCategories; // Execute cette instruction dans le flux courant.
  FrameProdsObj: TFrameProducts; // Execute cette instruction dans le flux courant.
  FrameDetailsObj: TFrameProductDetails; // Execute cette instruction dans le flux courant.
  FrameScannerObj: TFrameScanner; // Execute cette instruction dans le flux courant.
  FrameCompareObj: TFrameCompare; // Execute cette instruction dans le flux courant.
  FrameCalcObj: TFrameCalculator; // Execute cette instruction dans le flux courant.
  FrameCartObj: TFrameCart; // Execute cette instruction dans le flux courant.
  FrameQuoteObj: TFrameQuote; // Execute cette instruction dans le flux courant.
  FrameQuoteHistObj: TFrameQuoteHistory; // Execute cette instruction dans le flux courant.
  FrameSettingsObj: TFrameSettings; // Execute cette instruction dans le flux courant.
  ProdID: Integer; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Enregistre la vue précédente, sauf lorsque l'utilisateur choisit un onglet
  // racine qui réinitialise son parcours.
  if ARecordHistory then // Verifie la condition avant de poursuivre.
  begin

    if IsTabView(AViewName) then // Verifie la condition avant de poursuivre.
      FViewHistory.Clear // Complete la declaration ou instruction en cours.
    else if FCurrentView <> '' then // Execute la branche alternative de la condition precedente.
      FViewHistory.Add(FCurrentView + '|' + IntToStr(FCurrentDataInt)); // Appelle la methode ou fonction avec les parametres indiques.
  end; // Ferme le bloc ou la declaration en cours.
  FCurrentView := AViewName; // Attribue une nouvelle valeur a la variable indiquee.
  FCurrentDataInt := IntPtr(AData); // Attribue une nouvelle valeur a la variable indiquee.

  // Détruit l'ancien écran et met à jour les éléments communs de l'en-tête.
  ClearCurrentFrame; // Execute cette instruction dans le flux courant.
  UpdateCartBadge; // Execute cette instruction dans le flux courant.
  btnBack.Visible := FViewHistory.Count > 0;
  rectHeaderBrand.Visible := FLogoAvailable and SameText(AViewName, 'Home');
  rectHeaderBrand.Width := 120;
  lblHeaderTitle.Visible := not rectHeaderBrand.Visible;







  if SameText(AViewName, 'Home') then // Verifie la condition avant de poursuivre.
  begin

    // Chaque branche crée une frame, lui affecte le parent et connecte
    // les événements nécessaires à la navigation.
    lblHeaderTitle.Text := 'Accueil'; // Attribue une nouvelle valeur a la variable indiquee.
    HighlightTab(btnTabHome); // Appelle la methode ou fonction avec les parametres indiques.

    LogStartup('NGNEX startup: creating home frame'); // Appelle la methode ou fonction avec les parametres indiques.
    FrameHomeObj := TFrameHome.Create(Self); // Attribue une nouvelle valeur a la variable indiquee.
    LogStartup('NGNEX startup: home frame created'); // Appelle la methode ou fonction avec les parametres indiques.
    FrameHomeObj.Parent := layViewContainer; // Attribue une nouvelle valeur a la variable indiquee.
    FrameHomeObj.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    FrameHomeObj.OnNavigateTo := HandleHomeNavigate; // Attribue une nouvelle valeur a la variable indiquee.
    FrameHomeObj.OnCartChanged := HandleCartChanged; // Attribue une nouvelle valeur a la variable indiquee.
    FCurrentFrame := FrameHomeObj; // Attribue une nouvelle valeur a la variable indiquee.
  end // Ferme le bloc ou la declaration en cours.
  else if SameText(AViewName, 'Categories') then // Execute la branche alternative de la condition precedente.
  begin

    lblHeaderTitle.Text := 'Catégories'; // Attribue une nouvelle valeur a la variable indiquee.
    HighlightTab(btnTabProducts); // Appelle la methode ou fonction avec les parametres indiques.

    FrameCatsObj := TFrameCategories.Create(Self); // Attribue une nouvelle valeur a la variable indiquee.
    FrameCatsObj.Parent := layViewContainer; // Attribue une nouvelle valeur a la variable indiquee.
    FrameCatsObj.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    FrameCatsObj.OnCategorySelect := HandleCategorySelect; // Attribue une nouvelle valeur a la variable indiquee.
    FCurrentFrame := FrameCatsObj; // Attribue une nouvelle valeur a la variable indiquee.
  end // Ferme le bloc ou la declaration en cours.
  else if SameText(AViewName, 'Products') // Execute la branche alternative de la condition precedente.
       or SameText(AViewName, 'ProductsSearch') then // Complete la declaration ou instruction en cours.
  begin

    lblHeaderTitle.Text := 'Catalogue'; // Attribue une nouvelle valeur a la variable indiquee.
    HighlightTab(btnTabProducts); // Appelle la methode ou fonction avec les parametres indiques.

    FrameProdsObj := TFrameProducts.Create(Self); // Attribue une nouvelle valeur a la variable indiquee.
    FrameProdsObj.Parent := layViewContainer; // Attribue une nouvelle valeur a la variable indiquee.
    FrameProdsObj.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    FrameProdsObj.OnCartChanged := HandleCartChanged; // Attribue une nouvelle valeur a la variable indiquee.

    // Applique le filtre de catégorie ou le texte de recherche avant d'afficher
    // les résultats.
    if SameText(AViewName, 'Products') and (AData <> nil) then // Verifie la condition avant de poursuivre.
      FrameProdsObj.SetCategoryFilter(Integer(IntPtr(AData))) // Appelle la methode ou fonction avec les parametres indiques.
    else if SameText(AViewName, 'ProductsSearch') then // Execute la branche alternative de la condition precedente.
      FrameProdsObj.SetSearchFilter(FPendingSearch); // Appelle la methode ou fonction avec les parametres indiques.

    FrameProdsObj.OnProductSelect := HandleProductSelect; // Attribue une nouvelle valeur a la variable indiquee.
    FCurrentFrame := FrameProdsObj; // Attribue une nouvelle valeur a la variable indiquee.
  end // Ferme le bloc ou la declaration en cours.
  else if SameText(AViewName, 'ProductDetails') then // Execute la branche alternative de la condition precedente.
  begin

    lblHeaderTitle.Text := 'Produit'; // Titre court pour tenir sur une ligne.

    FrameDetailsObj := TFrameProductDetails.Create(Self); // Attribue une nouvelle valeur a la variable indiquee.
    FrameDetailsObj.Parent := layViewContainer; // Attribue une nouvelle valeur a la variable indiquee.
    FrameDetailsObj.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.

    // La donnée de navigation contient l'identifiant du produit à charger.
    if AData <> nil then // Verifie la condition avant de poursuivre.
  begin
  
      ProdID := Integer(IntPtr(AData)); // Attribue une nouvelle valeur a la variable indiquee.
      FrameDetailsObj.LoadProduct(ProdID); // Appelle la methode ou fonction avec les parametres indiques.
    end; // Ferme le bloc ou la declaration en cours.

    FrameDetailsObj.OnDetailAction := HandleDetailAction; // Attribue une nouvelle valeur a la variable indiquee.
    FCurrentFrame := FrameDetailsObj; // Attribue une nouvelle valeur a la variable indiquee.
  end // Ferme le bloc ou la declaration en cours.
  else if SameText(AViewName, 'Scanner') then // Execute la branche alternative de la condition precedente.
  begin

    lblHeaderTitle.Text := 'Scanner'; // Titre court pour tenir sur une ligne.
    HighlightTab(btnTabScanner); // Appelle la methode ou fonction avec les parametres indiques.

    FrameScannerObj := TFrameScanner.Create(Self); // Attribue une nouvelle valeur a la variable indiquee.
    FrameScannerObj.Parent := layViewContainer; // Attribue une nouvelle valeur a la variable indiquee.
    FrameScannerObj.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    FrameScannerObj.OnProductFound := HandleProductFound; // Attribue une nouvelle valeur a la variable indiquee.
    FCurrentFrame := FrameScannerObj; // Attribue une nouvelle valeur a la variable indiquee.
  end // Ferme le bloc ou la declaration en cours.
  else if SameText(AViewName, 'Compare') then // Execute la branche alternative de la condition precedente.
  begin

    lblHeaderTitle.Text := 'Comparer'; // Titre court pour tenir sur une ligne.

    FrameCompareObj := TFrameCompare.Create(Self); // Attribue une nouvelle valeur a la variable indiquee.
    FrameCompareObj.Parent := layViewContainer; // Attribue une nouvelle valeur a la variable indiquee.
    FrameCompareObj.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    // Une comparaison provenant d'une fiche commence avec ce produit en premier.
    if AData <> nil then // Verifie la condition avant de poursuivre.
  begin
  
      ProdID := Integer(IntPtr(AData)); // Attribue une nouvelle valeur a la variable indiquee.
      FrameCompareObj.SetProductsToCompare(ProdID, 1); // Appelle la methode ou fonction avec les parametres indiques.
    end; // Ferme le bloc ou la declaration en cours.
    FCurrentFrame := FrameCompareObj; // Attribue une nouvelle valeur a la variable indiquee.
  end // Ferme le bloc ou la declaration en cours.
  else if SameText(AViewName, 'Calculator') then // Execute la branche alternative de la condition precedente.
  begin

    lblHeaderTitle.Text := 'Calculer'; // Titre court pour tenir sur une ligne.

    FrameCalcObj := TFrameCalculator.Create(Self); // Attribue une nouvelle valeur a la variable indiquee.
    FrameCalcObj.Parent := layViewContainer; // Attribue une nouvelle valeur a la variable indiquee.
    FrameCalcObj.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    FCurrentFrame := FrameCalcObj; // Attribue une nouvelle valeur a la variable indiquee.
  end // Ferme le bloc ou la declaration en cours.
  else if SameText(AViewName, 'Cart') then // Execute la branche alternative de la condition precedente.
  begin

    lblHeaderTitle.Text := 'Mon Panier'; // Attribue une nouvelle valeur a la variable indiquee.
    HighlightTab(btnTabCart); // Appelle la methode ou fonction avec les parametres indiques.

    FrameCartObj := TFrameCart.Create(Self); // Attribue une nouvelle valeur a la variable indiquee.
    FrameCartObj.Parent := layViewContainer; // Attribue une nouvelle valeur a la variable indiquee.
    FrameCartObj.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    FrameCartObj.OnCartAction := HandleCartAction; // Attribue une nouvelle valeur a la variable indiquee.
    FCurrentFrame := FrameCartObj; // Attribue une nouvelle valeur a la variable indiquee.
  end // Ferme le bloc ou la declaration en cours.
  else if SameText(AViewName, 'Quote') then // Execute la branche alternative de la condition precedente.
  begin

    lblHeaderTitle.Text := 'Devis'; // Titre court pour tenir sur une ligne.
    HighlightTab(btnTabQuote); // Appelle la methode ou fonction avec les parametres indiques.

    FrameQuoteObj := TFrameQuote.Create(Self); // Attribue une nouvelle valeur a la variable indiquee.
    FrameQuoteObj.Parent := layViewContainer; // Attribue une nouvelle valeur a la variable indiquee.
    FrameQuoteObj.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    FrameQuoteObj.OnQuoteSubmitted := HandleQuoteSubmitted; // Attribue une nouvelle valeur a la variable indiquee.
    FrameQuoteObj.OnBackHome := HandleQuoteBackHome; // Attribue une nouvelle valeur a la variable indiquee.
    FCurrentFrame := FrameQuoteObj; // Attribue une nouvelle valeur a la variable indiquee.
  end // Ferme le bloc ou la declaration en cours.
  else if SameText(AViewName, 'QuoteHistory') then // Execute la branche alternative de la condition precedente.
  begin

    lblHeaderTitle.Text := 'Historique'; // Titre court pour tenir sur une ligne.

    FrameQuoteHistObj := TFrameQuoteHistory.Create(Self); // Attribue une nouvelle valeur a la variable indiquee.
    FrameQuoteHistObj.Parent := layViewContainer; // Attribue une nouvelle valeur a la variable indiquee.
    FrameQuoteHistObj.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    FCurrentFrame := FrameQuoteHistObj; // Attribue une nouvelle valeur a la variable indiquee.
  end // Ferme le bloc ou la declaration en cours.
  else if SameText(AViewName, 'Settings') then // Execute la branche alternative de la condition precedente.
  begin

    lblHeaderTitle.Text := 'Paramètres'; // Attribue une nouvelle valeur a la variable indiquee.

    FrameSettingsObj := TFrameSettings.Create(Self); // Attribue une nouvelle valeur a la variable indiquee.
    FrameSettingsObj.Parent := layViewContainer; // Attribue une nouvelle valeur a la variable indiquee.
    FrameSettingsObj.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    FCurrentFrame := FrameSettingsObj; // Attribue une nouvelle valeur a la variable indiquee.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

{ ---------- Clics des boutons ---------- }

procedure TFrmMain.btnTabHomeClick(Sender: TObject);
begin
  SwitchToView('Home');
end;

procedure TFrmMain.btnTabProductsClick(Sender: TObject);
begin
  SwitchToView('Products');
end;

procedure TFrmMain.btnTabScannerClick(Sender: TObject);
begin
  SwitchToView('Scanner');
end;

procedure TFrmMain.btnTabCartClick(Sender: TObject);
begin
  SwitchToView('Cart');
end;

procedure TFrmMain.btnTabQuoteClick(Sender: TObject);
begin
  SwitchToView('Quote');
end;

procedure TFrmMain.btnBackClick(Sender: TObject);
var
  Entry, ViewName: string;
  P: Integer;
  DataInt: NativeInt;
  Data: TObject;
begin
  if FViewHistory.Count = 0 then
  begin
    SwitchToView('Home');
    Exit;
  end;

  Entry := FViewHistory[FViewHistory.Count - 1];
  FViewHistory.Delete(FViewHistory.Count - 1);

  P := Pos('|', Entry);
  if P > 0 then
  begin
    ViewName := Copy(Entry, 1, P - 1);
    DataInt := StrToIntDef(Copy(Entry, P + 1, Length(Entry)), 0);
  end
  else
  begin
    ViewName := Entry;
    DataInt := 0;
  end;

  if DataInt = 0 then
    Data := nil
  else
    Data := TObject(IntPtr(DataInt));

  ShowView(ViewName, Data, False);
end;

procedure TFrmMain.btnCartHeaderClick(Sender: TObject);
begin
  SwitchToView('Cart');
end;

procedure TFrmMain.btnSettingsHeaderClick(Sender: TObject);
begin
  SwitchToView('Settings');
end;

end.
