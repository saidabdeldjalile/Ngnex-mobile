unit HomeForm; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, // Complete la declaration ou instruction en cours.
  System.Math, // Complete la declaration ou instruction en cours.
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, // Complete la declaration ou instruction en cours.
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, FMX.Edit, FMX.ListBox, // Complete la declaration ou instruction en cours.
  Product, Category, AppTheme; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Événement de navigation partagé par les actions de l'écran d'accueil.
  TNavigateToEvent = reference to procedure(const ATargetView: string; AData: TObject = nil); // Execute cette instruction dans le flux courant.

  // Page d'accueil : charge catégories et produits populaires et propose les accès rapides.
  TFrameHome = class(TFrame) // Complete la declaration ou instruction en cours.
    VertScrollBox: TVertScrollBox; // Execute cette instruction dans le flux courant.
    layHeaderBanner: TLayout; // Execute cette instruction dans le flux courant.
    rectBanner: TRectangle; // Execute cette instruction dans le flux courant.
    imgBanner: TImage; // Execute cette instruction dans le flux courant.
    rectBannerOverlay: TRectangle; // Execute cette instruction dans le flux courant.
    lblBannerBadge: TLabel; // Execute cette instruction dans le flux courant.
    lblBannerTitle: TLabel; // Execute cette instruction dans le flux courant.
    lblBannerSubtitle: TLabel; // Execute cette instruction dans le flux courant.
    btnBannerExplore: TButton; // Execute cette instruction dans le flux courant.
    laySearch: TLayout; // Execute cette instruction dans le flux courant.
    rectSearchBg: TRectangle; // Execute cette instruction dans le flux courant.
    edtSearchHome: TEdit; // Execute cette instruction dans le flux courant.
    rectSearchBtn: TRectangle; // Bouton principal de recherche (rectangle stylé).
    lblSearchBtn: TLabel; // Libellé du bouton de recherche.
    layCategoriesHeader: TLayout; // Execute cette instruction dans le flux courant.
    lblCatTitle: TLabel; // Execute cette instruction dans le flux courant.
    btnAllCategories: TSpeedButton; // Execute cette instruction dans le flux courant.
    horzCategoriesScroll: THorzScrollBox; // Execute cette instruction dans le flux courant.
    layPopularHeader: TLayout; // Execute cette instruction dans le flux courant.
    lblPopularTitle: TLabel; // Execute cette instruction dans le flux courant.
    layPopularContainer: TLayout; // Execute cette instruction dans le flux courant.
    layQuickActions: TLayout; // Execute cette instruction dans le flux courant.
    lblQuickActionsTitle: TLabel; // Execute cette instruction dans le flux courant.
    gridQuickActions: TGridPanelLayout; // Execute cette instruction dans le flux courant.
    rectBtnScanner: TRectangle; // Execute cette instruction dans le flux courant.
    lblBtnScanner: TLabel; // Execute cette instruction dans le flux courant.
    rectBtnCompare: TRectangle; // Execute cette instruction dans le flux courant.
    lblBtnCompare: TLabel; // Execute cette instruction dans le flux courant.
    rectBtnCalc: TRectangle; // Execute cette instruction dans le flux courant.
    lblBtnCalc: TLabel; // Execute cette instruction dans le flux courant.
    rectBtnQuotesHistory: TRectangle; // Execute cette instruction dans le flux courant.
    lblBtnQuotesHistory: TLabel; // Execute cette instruction dans le flux courant.
    procedure btnSearchHomeClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure btnAllCategoriesClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure rectBtnScannerClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure rectBtnCompareClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure rectBtnCalcClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure rectBtnQuotesHistoryClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
  private // Complete la declaration ou instruction en cours.
    FOnNavigateTo: TNavigateToEvent; // Execute cette instruction dans le flux courant.
    FOnCartChanged: TNotifyEvent; // Execute cette instruction dans le flux courant.
    FPopularList: TProductList; // Execute cette instruction dans le flux courant.
    FCategoryList: TCategoryList; // Execute cette instruction dans le flux courant.
    procedure LoadData; // Declare une procedure de cette unite ou classe.
    procedure RenderCategories; // Declare une procedure de cette unite ou classe.
    procedure RenderPopularProducts; // Declare une procedure de cette unite ou classe.
    procedure OnCategoryCardClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure OnProductCardClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure OnAddToCartClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
  public // Complete la declaration ou instruction en cours.
    constructor Create(AOwner: TComponent); override; // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.
    procedure RefreshView; // Declare une procedure de cette unite ou classe.

    property OnNavigateTo: TNavigateToEvent read FOnNavigateTo write FOnNavigateTo; // Expose une propriete de la classe.
    property OnCartChanged: TNotifyEvent read FOnCartChanged write FOnCartChanged; // Expose une propriete de la classe.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

uses // Declare les unites dont ce code depend.
  DataModule, StartupDiagnostics; // Execute cette instruction dans le flux courant.

{$R *.fmx} // Inclut la ressource FMX de cette unite.

constructor TFrameHome.Create(AOwner: TComponent); // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Initialise les collections détenues par l'écran, charge la bannière et les données.
  inherited Create(AOwner); // Appelle le comportement correspondant de la classe parente.
  LogStartup('NGNEX startup: HomeFrame constructor entered'); // Appelle la methode ou fonction avec les parametres indiques.
  FPopularList := TProductList.Create(True); // Attribue une nouvelle valeur a la variable indiquee.
  FCategoryList := TCategoryList.Create(True); // Attribue une nouvelle valeur a la variable indiquee.

  // --- Thème moderne de l'écran d'accueil ---
  // Bannière et barre de recherche : coins plus doux et surfaces nettes.
  rectBanner.XRadius := RADIUS_CARD + 2;
  rectBanner.YRadius := RADIUS_CARD + 2;
  rectSearchBg.Fill.Color := COLOR_SURFACE;
  rectSearchBg.Stroke.Color := COLOR_BORDER_LIGHT;
  rectSearchBg.Stroke.Thickness := 1;
  rectSearchBg.XRadius := RADIUS_PILL;
  rectSearchBg.YRadius := RADIUS_PILL;
  rectSearchBtn.Fill.Color := COLOR_PRIMARY;
  rectSearchBtn.Stroke.Kind := TBrushKind.None;
  rectSearchBtn.XRadius := RADIUS_PILL;
  rectSearchBtn.YRadius := RADIUS_PILL;
  lblSearchBtn.StyledSettings := [];
  lblSearchBtn.TextSettings.FontColor := COLOR_TEXT_WHITE;
  lblSearchBtn.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblSearchBtn.TextSettings.Font.Size := FONT_SIZE_BODY;

  // Titres de sections : hiérarchie visuelle claire.
  lblCatTitle.StyledSettings := [];
  lblCatTitle.TextSettings.FontColor := COLOR_TEXT_PRIMARY;
  lblCatTitle.TextSettings.Font.Size := FONT_SIZE_SECTION;
  lblCatTitle.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblPopularTitle.StyledSettings := [];
  lblPopularTitle.TextSettings.FontColor := COLOR_TEXT_PRIMARY;
  lblPopularTitle.TextSettings.Font.Size := FONT_SIZE_SECTION;
  lblPopularTitle.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblQuickActionsTitle.StyledSettings := [];
  lblQuickActionsTitle.TextSettings.FontColor := COLOR_TEXT_PRIMARY;
  lblQuickActionsTitle.TextSettings.Font.Size := FONT_SIZE_SECTION;
  lblQuickActionsTitle.TextSettings.Font.Style := [TFontStyle.fsBold];
  btnAllCategories.StyledSettings := [];
  btnAllCategories.TextSettings.FontColor := COLOR_PRIMARY;

  // Actions rapides : tuiles teintées issues de la palette NGNEX.
  rectBtnScanner.Fill.Color := $FFEFF6FF;
  rectBtnScanner.Stroke.Color := $FFBFDBFE;
  rectBtnScanner.XRadius := RADIUS_BUTTON + 2;
  rectBtnScanner.YRadius := RADIUS_BUTTON + 2;
  lblBtnScanner.TextSettings.FontColor := $FF1D4ED8;
  lblBtnScanner.TextSettings.Font.Style := [TFontStyle.fsBold];

  rectBtnCompare.Fill.Color := $FFF5F3FF;
  rectBtnCompare.Stroke.Color := $FFDDD6FE;
  rectBtnCompare.XRadius := RADIUS_BUTTON + 2;
  rectBtnCompare.YRadius := RADIUS_BUTTON + 2;
  lblBtnCompare.TextSettings.FontColor := $FF7C3AED;
  lblBtnCompare.TextSettings.Font.Style := [TFontStyle.fsBold];

  rectBtnCalc.Fill.Color := $FFFFF7ED;
  rectBtnCalc.Stroke.Color := $FFFED7AA;
  rectBtnCalc.XRadius := RADIUS_BUTTON + 2;
  rectBtnCalc.YRadius := RADIUS_BUTTON + 2;
  lblBtnCalc.TextSettings.FontColor := $FFEA580C;
  lblBtnCalc.TextSettings.Font.Style := [TFontStyle.fsBold];

  rectBtnQuotesHistory.Fill.Color := $FFECFDF5;
  rectBtnQuotesHistory.Stroke.Color := $FFA7F3D0;
  rectBtnQuotesHistory.XRadius := RADIUS_BUTTON + 2;
  rectBtnQuotesHistory.YRadius := RADIUS_BUTTON + 2;
  lblBtnQuotesHistory.TextSettings.FontColor := $FF059669;
  lblBtnQuotesHistory.TextSettings.Font.Style := [TFontStyle.fsBold];

  // Chargement de l'image de bannière si disponible
  if DM <> nil then // Verifie la condition avant de poursuivre.
    DM.ImageService.LoadIntoImage('hero_commerce.jpg', imgBanner); // Appelle la methode ou fonction avec les parametres indiques.
  imgBanner.WrapMode := TImageWrapMode.Stretch; // Attribue une nouvelle valeur a la variable indiquee.

  LogStartup('NGNEX startup: refreshing home frame'); // Appelle la methode ou fonction avec les parametres indiques.
  RefreshView; // Execute cette instruction dans le flux courant.
  LogStartup('NGNEX startup: home frame refreshed'); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

destructor TFrameHome.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Libère les listes de produits et catégories possédées par ce cadre.
  FreeAndNil(FPopularList); // Appelle la methode ou fonction avec les parametres indiques.
  FreeAndNil(FCategoryList); // Appelle la methode ou fonction avec les parametres indiques.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameHome.RefreshView; // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Recharge le contenu puis régénère les cartes des sections de l'accueil.
  LogStartup('NGNEX startup: loading home data'); // Appelle la methode ou fonction avec les parametres indiques.
  LoadData; // Execute cette instruction dans le flux courant.
  LogStartup('NGNEX startup: rendering home categories'); // Appelle la methode ou fonction avec les parametres indiques.
  RenderCategories; // Execute cette instruction dans le flux courant.
  LogStartup('NGNEX startup: rendering popular products'); // Appelle la methode ou fonction avec les parametres indiques.
  RenderPopularProducts; // Execute cette instruction dans le flux courant.
  LogStartup('NGNEX startup: home content rendered'); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameHome.LoadData; // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Obtient le catalogue des catégories et les produits mis en avant depuis SQLite.
  if DM <> nil then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    DM.CategoryService.LoadCategories(FCategoryList); // Appelle la methode ou fonction avec les parametres indiques.
    DM.ProductService.GetPopularProducts(FPopularList, 6); // Appelle la methode ou fonction avec les parametres indiques.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameHome.RenderCategories; // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  I: Integer; // Execute cette instruction dans le flux courant.
  Cat: TCategory; // Execute cette instruction dans le flux courant.
  Card: TRectangle; // Execute cette instruction dans le flux courant.
  LayImg: TLayout; // Execute cette instruction dans le flux courant.
  ImgCat: TImage; // Execute cette instruction dans le flux courant.
  LayText: TLayout; // Execute cette instruction dans le flux courant.
  LblName, LblCount: TLabel; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Reconstruit le carrousel horizontal des catégories avec leurs compteurs.
  while horzCategoriesScroll.Content.ControlsCount > 0 do // Repete le bloc tant que la condition reste vraie.
    horzCategoriesScroll.Content.Controls[0].Free; // Execute cette instruction dans le flux courant.

  for I := 0 to FCategoryList.Count - 1 do // Parcourt les elements ou valeurs de cette boucle.
  begin // Ouvre le bloc d instructions correspondant.
    Cat := FCategoryList[I]; // Attribue une nouvelle valeur a la variable indiquee.

    // Carte de catégorie moderne
    Card := TRectangle.Create(horzCategoriesScroll); // Attribue une nouvelle valeur a la variable indiquee.
    Card.Parent := horzCategoriesScroll; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Width := 150; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Height := 150; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Position.X := 4 + I * 160; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Margins.Right := 10; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Margins.Left := 4; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Margins.Top := 2; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Margins.Bottom := 2; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Fill.Color := COLOR_SURFACE; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Stroke.Color := COLOR_BORDER_LIGHT; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Stroke.Thickness := 1; // Attribue une nouvelle valeur a la variable indiquee.
    Card.XRadius := RADIUS_CARD; // Coins modernes du design system.
    Card.YRadius := RADIUS_CARD; // Coins modernes du design system.
    Card.Tag := Cat.ID; // Attribue une nouvelle valeur a la variable indiquee.
    Card.HitTest := True; // Attribue une nouvelle valeur a la variable indiquee.
    Card.OnClick := OnCategoryCardClick; // Attribue une nouvelle valeur a la variable indiquee.

    // Conteneur de l'image
    LayImg := TLayout.Create(Card); // Attribue une nouvelle valeur a la variable indiquee.
    LayImg.Parent := Card; // Attribue une nouvelle valeur a la variable indiquee.
    LayImg.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LayImg.Height := 82; // Attribue une nouvelle valeur a la variable indiquee.
    LayImg.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    ImgCat := TImage.Create(LayImg); // Attribue une nouvelle valeur a la variable indiquee.
    ImgCat.Parent := LayImg; // Attribue une nouvelle valeur a la variable indiquee.
    ImgCat.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    ImgCat.Margins.Left := 6; // Attribue une nouvelle valeur a la variable indiquee.
    ImgCat.Margins.Top := 6; // Attribue une nouvelle valeur a la variable indiquee.
    ImgCat.Margins.Right := 6; // Attribue une nouvelle valeur a la variable indiquee.
    ImgCat.Margins.Bottom := 2; // Attribue une nouvelle valeur a la variable indiquee.
    ImgCat.WrapMode := TImageWrapMode.Fit; // Attribue une nouvelle valeur a la variable indiquee.
    ImgCat.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    if DM <> nil then // Verifie la condition avant de poursuivre.
      DM.ImageService.LoadIntoImage(Cat.ImageURL, ImgCat); // Appelle la methode ou fonction avec les parametres indiques.

    // Conteneur de texte
    LayText := TLayout.Create(Card); // Attribue une nouvelle valeur a la variable indiquee.
    LayText.Parent := Card; // Attribue une nouvelle valeur a la variable indiquee.
    LayText.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    LayText.Margins.Left := 6; // Attribue une nouvelle valeur a la variable indiquee.
    LayText.Margins.Right := 6; // Attribue une nouvelle valeur a la variable indiquee.
    LayText.Margins.Bottom := 4; // Attribue une nouvelle valeur a la variable indiquee.
    LayText.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    LblName := TLabel.Create(LayText); // Attribue une nouvelle valeur a la variable indiquee.
    LblName.Parent := LayText; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.Height := 38; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.TextSettings.Font.Size := FONT_SIZE_BODY; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.TextSettings.Font.Style := [TFontStyle.fsBold]; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.TextSettings.FontColor := COLOR_TEXT_PRIMARY; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.TextSettings.HorzAlign := TTextAlign.Center; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.TextSettings.WordWrap := True; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.Text := Cat.Name; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    LblCount := TLabel.Create(LayText); // Attribue une nouvelle valeur a la variable indiquee.
    LblCount.Parent := LayText; // Attribue une nouvelle valeur a la variable indiquee.
    LblCount.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LblCount.Height := 18; // Attribue une nouvelle valeur a la variable indiquee.
    LblCount.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblCount.TextSettings.Font.Size := 10; // Attribue une nouvelle valeur a la variable indiquee.
    LblCount.TextSettings.FontColor := COLOR_PRIMARY; // Attribue une nouvelle valeur a la variable indiquee.
    LblCount.TextSettings.HorzAlign := TTextAlign.Center; // Attribue une nouvelle valeur a la variable indiquee.
    LblCount.Text := Format('%d produits', [Cat.ProductCount]); // Attribue une nouvelle valeur a la variable indiquee.
    LblCount.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.
  end; // Ferme le bloc ou la declaration en cours.

  horzCategoriesScroll.Content.Width := // Attribue une nouvelle valeur a la variable indiquee.
    Max(horzCategoriesScroll.Width, FCategoryList.Count * 160 + 10); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameHome.RenderPopularProducts; // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  I: Integer; // Execute cette instruction dans le flux courant.
  Prod: TProduct; // Execute cette instruction dans le flux courant.
  Card: TRectangle; // Execute cette instruction dans le flux courant.
  LayImgContainer: TLayout; // Execute cette instruction dans le flux courant.
  RectImgBg: TRectangle; // Execute cette instruction dans le flux courant.
  ImgProd: TImage; // Execute cette instruction dans le flux courant.
  LayInfo: TLayout; // Execute cette instruction dans le flux courant.
  LblCat, LblName, LblRef, LblPrice, LblStock: TLabel; // Execute cette instruction dans le flux courant.
  BtnAdd: TButton; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Reconstruit les cartes des produits populaires, avec image, prix et action panier.
  while layPopularContainer.ControlsCount > 0 do // Repete le bloc tant que la condition reste vraie.
    layPopularContainer.Controls[0].Free; // Execute cette instruction dans le flux courant.

  layPopularContainer.Height := Max(160, FPopularList.Count * 160); // Attribue une nouvelle valeur a la variable indiquee.

  for I := 0 to FPopularList.Count - 1 do // Parcourt les elements ou valeurs de cette boucle.
  begin // Ouvre le bloc d instructions correspondant.
    Prod := FPopularList[I]; // Attribue une nouvelle valeur a la variable indiquee.

    // Carte produit façon e-commerce
    Card := TRectangle.Create(layPopularContainer); // Attribue une nouvelle valeur a la variable indiquee.
    Card.Parent := layPopularContainer; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Height := 150; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Margins.Left := 12; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Margins.Right := 12; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Margins.Bottom := 10; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Fill.Color := COLOR_SURFACE; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Stroke.Color := COLOR_BORDER_LIGHT; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Stroke.Thickness := 1; // Attribue une nouvelle valeur a la variable indiquee.
    Card.XRadius := RADIUS_CARD; // Coins modernes du design system.
    Card.YRadius := RADIUS_CARD; // Coins modernes du design system.
    Card.Tag := Prod.ID; // Attribue une nouvelle valeur a la variable indiquee.
    Card.HitTest := True; // Attribue une nouvelle valeur a la variable indiquee.
    Card.OnClick := OnProductCardClick; // Attribue une nouvelle valeur a la variable indiquee.

    // Miniature photo à gauche
    LayImgContainer := TLayout.Create(Card); // Attribue une nouvelle valeur a la variable indiquee.
    LayImgContainer.Parent := Card; // Attribue une nouvelle valeur a la variable indiquee.
    LayImgContainer.Align := TAlignLayout.Left; // Attribue une nouvelle valeur a la variable indiquee.
    LayImgContainer.Width := 105; // Attribue une nouvelle valeur a la variable indiquee.
    LayImgContainer.Margins.Left := 8; // Attribue une nouvelle valeur a la variable indiquee.
    LayImgContainer.Margins.Top := 8; // Attribue une nouvelle valeur a la variable indiquee.
    LayImgContainer.Margins.Bottom := 8; // Attribue une nouvelle valeur a la variable indiquee.
    LayImgContainer.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    RectImgBg := TRectangle.Create(LayImgContainer); // Attribue une nouvelle valeur a la variable indiquee.
    RectImgBg.Parent := LayImgContainer; // Attribue une nouvelle valeur a la variable indiquee.
    RectImgBg.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    RectImgBg.Fill.Color := COLOR_SURFACE_ALT; // Attribue une nouvelle valeur a la variable indiquee.
    RectImgBg.Stroke.Color := COLOR_BORDER_LIGHT; // Attribue une nouvelle valeur a la variable indiquee.
    RectImgBg.XRadius := RADIUS_SMALL; // Coins de la vignette produit.
    RectImgBg.YRadius := RADIUS_SMALL; // Coins de la vignette produit.
    RectImgBg.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    ImgProd := TImage.Create(RectImgBg); // Attribue une nouvelle valeur a la variable indiquee.
    ImgProd.Parent := RectImgBg; // Attribue une nouvelle valeur a la variable indiquee.
    ImgProd.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    ImgProd.Margins.Left := 4; // Attribue une nouvelle valeur a la variable indiquee.
    ImgProd.Margins.Top := 4; // Attribue une nouvelle valeur a la variable indiquee.
    ImgProd.Margins.Right := 4; // Attribue une nouvelle valeur a la variable indiquee.
    ImgProd.Margins.Bottom := 4; // Attribue une nouvelle valeur a la variable indiquee.
    ImgProd.WrapMode := TImageWrapMode.Fit; // Attribue une nouvelle valeur a la variable indiquee.
    ImgProd.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    if DM <> nil then // Verifie la condition avant de poursuivre.
      DM.ImageService.LoadIntoImage(Prod.ImageURL, ImgProd); // Appelle la methode ou fonction avec les parametres indiques.

    // Conteneur d'informations au centre
    LayInfo := TLayout.Create(Card); // Attribue une nouvelle valeur a la variable indiquee.
    LayInfo.Parent := Card; // Attribue une nouvelle valeur a la variable indiquee.
    LayInfo.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    LayInfo.Margins.Left := 10; // Attribue une nouvelle valeur a la variable indiquee.
    LayInfo.Margins.Top := 8; // Attribue une nouvelle valeur a la variable indiquee.
    LayInfo.Margins.Right := 8; // Attribue une nouvelle valeur a la variable indiquee.
    LayInfo.Margins.Bottom := 8; // Attribue une nouvelle valeur a la variable indiquee.
    LayInfo.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    LblCat := TLabel.Create(LayInfo); // Attribue une nouvelle valeur a la variable indiquee.
    LblCat.Parent := LayInfo; // Attribue une nouvelle valeur a la variable indiquee.
    LblCat.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LblCat.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblCat.Height := 16; // Attribue une nouvelle valeur a la variable indiquee.
    LblCat.TextSettings.Font.Size := FONT_SIZE_CAPTION; // Attribue une nouvelle valeur a la variable indiquee.
    LblCat.TextSettings.Font.Style := [TFontStyle.fsBold]; // Attribue une nouvelle valeur a la variable indiquee.
    LblCat.TextSettings.FontColor := COLOR_PRIMARY_LIGHT; // Attribue une nouvelle valeur a la variable indiquee.
    LblCat.Text := UpperCase(Prod.CategoryName); // Attribue une nouvelle valeur a la variable indiquee.
    LblCat.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    LblName := TLabel.Create(LayInfo); // Attribue une nouvelle valeur a la variable indiquee.
    LblName.Parent := LayInfo; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.Height := 38; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.TextSettings.Font.Size := FONT_SIZE_CARD_TITLE; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.TextSettings.Font.Style := [TFontStyle.fsBold]; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.TextSettings.FontColor := COLOR_TEXT_PRIMARY; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.TextSettings.WordWrap := True; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.Text := Prod.Name; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    LblRef := TLabel.Create(LayInfo); // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.Parent := LayInfo; // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.Height := 16; // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.TextSettings.Font.Size := 10; // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.TextSettings.FontColor := COLOR_TEXT_SECONDARY; // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.Text := 'Réf. : ' + Prod.Reference; // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    LblPrice := TLabel.Create(LayInfo); // Attribue une nouvelle valeur a la variable indiquee.
    LblPrice.Parent := LayInfo; // Attribue une nouvelle valeur a la variable indiquee.
    LblPrice.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LblPrice.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblPrice.Height := 24; // Attribue une nouvelle valeur a la variable indiquee.
    LblPrice.TextSettings.Font.Size := 14; // Prix mis en avant.
    LblPrice.TextSettings.Font.Style := [TFontStyle.fsBold]; // Attribue une nouvelle valeur a la variable indiquee.
    LblPrice.TextSettings.FontColor := COLOR_PRIMARY; // Attribue une nouvelle valeur a la variable indiquee.
    if Prod.Price > 0 then // Verifie la condition avant de poursuivre.
      LblPrice.Text := FormatFloat('#,##0.00 DA', Prod.Price) // Attribue une nouvelle valeur a la variable indiquee.
    else // Execute la branche alternative de la condition precedente.
      LblPrice.Text := 'Prix sur demande'; // Attribue une nouvelle valeur a la variable indiquee.
    LblPrice.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    LblStock := TLabel.Create(LayInfo); // Attribue une nouvelle valeur a la variable indiquee.
    LblStock.Parent := LayInfo; // Attribue une nouvelle valeur a la variable indiquee.
    LblStock.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LblStock.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblStock.Height := 16; // Attribue une nouvelle valeur a la variable indiquee.
    LblStock.TextSettings.Font.Size := FONT_SIZE_CAPTION; // Attribue une nouvelle valeur a la variable indiquee.
    if Prod.Price <= 0 then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      LblStock.TextSettings.FontColor := COLOR_WARNING; // Attribue une nouvelle valeur a la variable indiquee.
      LblStock.Text := 'Stock à confirmer'; // Attribue une nouvelle valeur a la variable indiquee.
    end // Ferme le bloc ou la declaration en cours.
    else if Prod.IsAvailable then // Execute la branche alternative de la condition precedente.
    begin // Ouvre le bloc d instructions correspondant.
      LblStock.TextSettings.FontColor := COLOR_SUCCESS; // Attribue une nouvelle valeur a la variable indiquee.
      LblStock.Text := '● En Stock'; // Attribue une nouvelle valeur a la variable indiquee.
    end // Ferme le bloc ou la declaration en cours.
    else // Execute la branche alternative de la condition precedente.
    begin // Ouvre le bloc d instructions correspondant.
      LblStock.TextSettings.FontColor := COLOR_WARNING; // Attribue une nouvelle valeur a la variable indiquee.
      LblStock.Text := '● Sur Commande'; // Attribue une nouvelle valeur a la variable indiquee.
    end; // Ferme le bloc ou la declaration en cours.
    LblStock.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    // Bouton Ajout Panier
    BtnAdd := TButton.Create(Card); // Attribue une nouvelle valeur a la variable indiquee.
    BtnAdd.Parent := Card; // Attribue une nouvelle valeur a la variable indiquee.
    BtnAdd.Align := TAlignLayout.Right; // Attribue une nouvelle valeur a la variable indiquee.
    BtnAdd.Width := 74; // Attribue une nouvelle valeur a la variable indiquee.
    BtnAdd.Margins.Right := 10; // Attribue une nouvelle valeur a la variable indiquee.
    BtnAdd.Margins.Top := 46; // Attribue une nouvelle valeur a la variable indiquee.
    BtnAdd.Margins.Bottom := 46; // Attribue une nouvelle valeur a la variable indiquee.
    BtnAdd.StyledSettings := [];
    BtnAdd.TextSettings.FontColor := COLOR_ACCENT; // Action d'ajout mise en avant.
    BtnAdd.TextSettings.Font.Style := [TFontStyle.fsBold];
    BtnAdd.Text := '+ Panier'; // Attribue une nouvelle valeur a la variable indiquee.
    BtnAdd.Tag := Prod.ID; // Attribue une nouvelle valeur a la variable indiquee.
    BtnAdd.OnClick := OnAddToCartClick; // Attribue une nouvelle valeur a la variable indiquee.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameHome.OnCategoryCardClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  CatID: Integer; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Navigue vers la liste des produits filtrée par la catégorie choisie.
  CatID := TComponent(Sender).Tag; // Attribue une nouvelle valeur a la variable indiquee.
  if Assigned(FOnNavigateTo) then // Verifie la condition avant de poursuivre.
    FOnNavigateTo('Products', TObject(IntPtr(CatID))); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameHome.OnProductCardClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  ProdID: Integer; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Ouvre le détail du produit sélectionné depuis l'accueil.
  ProdID := TComponent(Sender).Tag; // Attribue une nouvelle valeur a la variable indiquee.
  if Assigned(FOnNavigateTo) then // Verifie la condition avant de poursuivre.
    FOnNavigateTo('ProductDetails', TObject(IntPtr(ProdID))); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameHome.OnAddToCartClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  ProdID: Integer; // Execute cette instruction dans le flux courant.
  Prod: TProduct; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Charge le produit sélectionné, l'ajoute au panier et notifie le formulaire principal.
  ProdID := TComponent(Sender).Tag; // Attribue une nouvelle valeur a la variable indiquee.
  Prod := TProduct.Create; // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    if (DM <> nil) and (DM.ProductService.GetProductByID(ProdID, Prod)) then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      DM.CartService.AddProduct(Prod, 1); // Appelle la methode ou fonction avec les parametres indiques.
      if Assigned(FOnCartChanged) then // Verifie la condition avant de poursuivre.
        FOnCartChanged(Self); // Appelle la methode ou fonction avec les parametres indiques.
      ShowMessage(Format('« %s » a été ajouté à votre panier.', [Prod.Name])); // Appelle la methode ou fonction avec les parametres indiques.
    end; // Ferme le bloc ou la declaration en cours.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Prod.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameHome.btnSearchHomeClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  SearchText: string; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Transmet une recherche non vide à la page catalogue.
  SearchText := Trim(edtSearchHome.Text); // Attribue une nouvelle valeur a la variable indiquee.
  if SearchText.IsEmpty then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    ShowMessage('Veuillez saisir un terme à rechercher.'); // Appelle la methode ou fonction avec les parametres indiques.
    Exit; // Quitte la procedure ou fonction a cet endroit.
  end; // Ferme le bloc ou la declaration en cours.
  if Assigned(FOnNavigateTo) then // Verifie la condition avant de poursuivre.
    FOnNavigateTo('ProductsSearch:' + SearchText); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameHome.btnAllCategoriesClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Ouvre la page consacrée à toutes les catégories.
  if Assigned(FOnNavigateTo) then // Verifie la condition avant de poursuivre.
    FOnNavigateTo('Categories'); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameHome.rectBtnScannerClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Accès rapide au scanner de codes-barres.
  if Assigned(FOnNavigateTo) then // Verifie la condition avant de poursuivre.
    FOnNavigateTo('Scanner'); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameHome.rectBtnCompareClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Accès rapide à l'écran de comparaison.
  if Assigned(FOnNavigateTo) then // Verifie la condition avant de poursuivre.
    FOnNavigateTo('Compare'); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameHome.rectBtnCalcClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Accès rapide au calculateur de prix.
  if Assigned(FOnNavigateTo) then // Verifie la condition avant de poursuivre.
    FOnNavigateTo('Calculator'); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameHome.rectBtnQuotesHistoryClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Accès rapide à l'historique local des demandes de devis.
  if Assigned(FOnNavigateTo) then // Verifie la condition avant de poursuivre.
    FOnNavigateTo('QuoteHistory'); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
