unit ProductsForm; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, // Complete la declaration ou instruction en cours.
  System.Math, // Complete la declaration ou instruction en cours.
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, // Complete la declaration ou instruction en cours.
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, FMX.Edit, FMX.ListBox, // Complete la declaration ou instruction en cours.
  Product, AppTheme; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Callback de sélection renvoyant l'identifiant produit au formulaire principal.
  TOnProductSelectEvent = reference to procedure(AProductID: Integer); // Execute cette instruction dans le flux courant.

  // Catalogue filtrable et triable avec actions d'ouverture et d'ajout au panier.
  TFrameProducts = class(TFrame) // Complete la declaration ou instruction en cours.
    VertScrollBox: TVertScrollBox; // Execute cette instruction dans le flux courant.
    layFilterHeader: TLayout; // Execute cette instruction dans le flux courant.
    edtSearch: TEdit; // Execute cette instruction dans le flux courant.
    cmbSort: TComboBox; // Execute cette instruction dans le flux courant.
    lblFilterStatus: TLabel; // Execute cette instruction dans le flux courant.
    layProductsList: TLayout; // Execute cette instruction dans le flux courant.
    procedure edtSearchChange(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure cmbSortChange(Sender: TObject); // Declare une procedure de cette unite ou classe.
  private // Complete la declaration ou instruction en cours.
    FProductList: TProductList; // Execute cette instruction dans le flux courant.
    FCurrentCategoryID: Integer; // Execute cette instruction dans le flux courant.
    FSearchText: string; // Execute cette instruction dans le flux courant.
    FOnProductSelect: TOnProductSelectEvent; // Execute cette instruction dans le flux courant.
    FOnCartChanged: TNotifyEvent; // Execute cette instruction dans le flux courant.
    procedure LoadData; // Declare une procedure de cette unite ou classe.
    procedure RenderProducts; // Declare une procedure de cette unite ou classe.
    procedure OnProductCardClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure OnAddToCartClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
  public // Complete la declaration ou instruction en cours.
    constructor Create(AOwner: TComponent); override; // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.
    procedure RefreshView; // Declare une procedure de cette unite ou classe.
    procedure SetCategoryFilter(ACategoryID: Integer); // Declare une procedure de cette unite ou classe.
    procedure SetSearchFilter(const ASearch: string); // Declare une procedure de cette unite ou classe.

    property OnProductSelect: TOnProductSelectEvent read FOnProductSelect write FOnProductSelect; // Expose une propriete de la classe.
    property OnCartChanged: TNotifyEvent read FOnCartChanged write FOnCartChanged; // Expose une propriete de la classe.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

uses // Declare les unites dont ce code depend.
  DataModule; // Execute cette instruction dans le flux courant.

{$R *.fmx} // Inclut la ressource FMX de cette unite.

constructor TFrameProducts.Create(AOwner: TComponent); // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Initialise les filtres et la collection propriétaire avant le premier affichage.
  inherited Create(AOwner); // Appelle le comportement correspondant de la classe parente.
  FProductList := TProductList.Create(True); // Attribue une nouvelle valeur a la variable indiquee.
  FCurrentCategoryID := 0; // Attribue une nouvelle valeur a la variable indiquee.
  FSearchText := ''; // Attribue une nouvelle valeur a la variable indiquee.

  // --- Thème moderne de la liste produits ---
  // Le tri par défaut doit être visible dans la liste déroulante.
  cmbSort.ItemIndex := 0;
  edtSearch.StyledSettings := [];
  edtSearch.TextSettings.Font.Size := FONT_SIZE_BODY;
  edtSearch.TextSettings.FontColor := COLOR_TEXT_PRIMARY;
  lblFilterStatus.StyledSettings := [];
  lblFilterStatus.TextSettings.Font.Size := FONT_SIZE_BODY;
  lblFilterStatus.TextSettings.FontColor := COLOR_TEXT_SECONDARY;

  RefreshView; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

destructor TFrameProducts.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Libère les produits chargés par ce cadre.
  FreeAndNil(FProductList); // Appelle la methode ou fonction avec les parametres indiques.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameProducts.SetCategoryFilter(ACategoryID: Integer); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Applique une catégorie et retire l'éventuel filtre texte précédent.
  FCurrentCategoryID := ACategoryID; // Attribue une nouvelle valeur a la variable indiquee.
  FSearchText := ''; // Attribue une nouvelle valeur a la variable indiquee.
  edtSearch.Text := ''; // Attribue une nouvelle valeur a la variable indiquee.
  RefreshView; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameProducts.SetSearchFilter(const ASearch: string); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Applique une recherche globale et désactive le filtre de catégorie.
  FCurrentCategoryID := 0; // Attribue une nouvelle valeur a la variable indiquee.
  FSearchText := ASearch; // Attribue une nouvelle valeur a la variable indiquee.
  edtSearch.Text := ASearch; // Attribue une nouvelle valeur a la variable indiquee.
  RefreshView; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameProducts.RefreshView; // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Recharge les données avec les filtres actuels puis reconstruit les cartes.
  LoadData; // Execute cette instruction dans le flux courant.
  RenderProducts; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameProducts.LoadData; // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  SortParam: string; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Traduit le choix de tri en paramètre métier et charge les produits depuis SQLite.
  if DM = nil then Exit; // Verifie la condition avant de poursuivre.

  case cmbSort.ItemIndex of // Choisit une branche selon la valeur de l expression.
    1: SortParam := 'price_asc'; // Attribue une nouvelle valeur a la variable indiquee.
    2: SortParam := 'price_desc'; // Attribue une nouvelle valeur a la variable indiquee.
    3: SortParam := 'newest'; // Attribue une nouvelle valeur a la variable indiquee.
  else // Execute la branche alternative de la condition precedente.
    SortParam := 'name_asc'; // Attribue une nouvelle valeur a la variable indiquee.
  end; // Ferme le bloc ou la declaration en cours.

  DM.ProductService.FetchProducts(FProductList, FCurrentCategoryID, FSearchText, SortParam); // Appelle la methode ou fonction avec les parametres indiques.

  // Compteur compact pour rester sur une seule ligne dans l'en-tête de liste.
  if not FSearchText.Trim.IsEmpty then // Verifie la condition avant de poursuivre.
    lblFilterStatus.Text := Format('%d résultat(s)', [FProductList.Count]) // Attribue une nouvelle valeur a la variable indiquee.
  else if FCurrentCategoryID > 0 then // Execute la branche alternative de la condition precedente.
    lblFilterStatus.Text := Format('%d équipement(s)', [FProductList.Count]) // Attribue une nouvelle valeur a la variable indiquee.
  else // Execute la branche alternative de la condition precedente.
    lblFilterStatus.Text := Format('%d équipement(s)', [FProductList.Count]); // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameProducts.RenderProducts; // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  I: Integer; // Execute cette instruction dans le flux courant.
  Prod: TProduct; // Execute cette instruction dans le flux courant.
  Card: TRectangle; // Execute cette instruction dans le flux courant.
  LayImgContainer: TLayout; // Execute cette instruction dans le flux courant.
  RectImgBg: TRectangle; // Execute cette instruction dans le flux courant.
  ImgProd: TImage; // Execute cette instruction dans le flux courant.
  LayInfo: TLayout; // Execute cette instruction dans le flux courant.
  LblCat, LblName, LblRef, LblPrice, LblStock: TLabel; // Execute cette instruction dans le flux courant.
  LayRight: TLayout; // Execute cette instruction dans le flux courant.
  BtnCart, BtnDetails: TButton; // Execute cette instruction dans le flux courant.
  EmptyLbl: TLabel; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Reconstruit la liste de cartes produit ou le message d'absence de résultats.
  while layProductsList.ControlsCount > 0 do // Repete le bloc tant que la condition reste vraie.
    layProductsList.Controls[0].Free; // Execute cette instruction dans le flux courant.

  if FProductList.Count = 0 then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    layProductsList.Height := 140; // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl := TLabel.Create(layProductsList); // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl.Parent := layProductsList; // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl.Height := 80; // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl.Margins.Left := 16; // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl.Margins.Top := 30; // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl.Margins.Right := 16; // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl.TextSettings.Font.Size := 13; // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl.TextSettings.FontColor := COLOR_TEXT_SECONDARY; // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl.TextSettings.HorzAlign := TTextAlign.Center; // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl.TextSettings.VertAlign := TTextAlign.Center; // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl.TextSettings.WordWrap := True; // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl.Text := '🔍 Aucun équipement trouvé.'#13#10'Modifiez votre recherche ou sélectionnez une autre catégorie.'; // Attribue une nouvelle valeur a la variable indiquee.
    Exit; // Quitte la procedure ou fonction a cet endroit.
  end; // Ferme le bloc ou la declaration en cours.

  layProductsList.Height := FProductList.Count * 145; // Attribue une nouvelle valeur a la variable indiquee.

  for I := 0 to FProductList.Count - 1 do // Parcourt les elements ou valeurs de cette boucle.
  begin // Ouvre le bloc d instructions correspondant.
    Prod := FProductList[I]; // Attribue une nouvelle valeur a la variable indiquee.

    Card := TRectangle.Create(layProductsList); // Attribue une nouvelle valeur a la variable indiquee.
    Card.Parent := layProductsList; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Height := 135; // Attribue une nouvelle valeur a la variable indiquee.
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

    // Image à gauche
    LayImgContainer := TLayout.Create(Card); // Attribue une nouvelle valeur a la variable indiquee.
    LayImgContainer.Parent := Card; // Attribue une nouvelle valeur a la variable indiquee.
    LayImgContainer.Align := TAlignLayout.Left; // Attribue une nouvelle valeur a la variable indiquee.
    LayImgContainer.Width := 100; // Attribue une nouvelle valeur a la variable indiquee.
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

    // Bloc droite (Boutons)
    LayRight := TLayout.Create(Card); // Attribue une nouvelle valeur a la variable indiquee.
    LayRight.Parent := Card; // Attribue une nouvelle valeur a la variable indiquee.
    LayRight.Align := TAlignLayout.Right; // Attribue une nouvelle valeur a la variable indiquee.
    LayRight.Width := 85; // Attribue une nouvelle valeur a la variable indiquee.
    LayRight.Margins.Right := 8; // Attribue une nouvelle valeur a la variable indiquee.
    LayRight.Margins.Top := 16; // Attribue une nouvelle valeur a la variable indiquee.
    LayRight.Margins.Bottom := 16; // Attribue une nouvelle valeur a la variable indiquee.

    BtnDetails := TButton.Create(LayRight); // Attribue une nouvelle valeur a la variable indiquee.
    BtnDetails.Parent := LayRight; // Attribue une nouvelle valeur a la variable indiquee.
    BtnDetails.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    BtnDetails.Height := 34; // Attribue une nouvelle valeur a la variable indiquee.
    BtnDetails.Text := 'Détails'; // Attribue une nouvelle valeur a la variable indiquee.
    BtnDetails.Tag := Prod.ID; // Attribue une nouvelle valeur a la variable indiquee.
    BtnDetails.OnClick := OnProductCardClick; // Attribue une nouvelle valeur a la variable indiquee.

    BtnCart := TButton.Create(LayRight); // Attribue une nouvelle valeur a la variable indiquee.
    BtnCart.Parent := LayRight; // Attribue une nouvelle valeur a la variable indiquee.
    BtnCart.Align := TAlignLayout.Bottom; // Attribue une nouvelle valeur a la variable indiquee.
    BtnCart.Height := 36; // Attribue une nouvelle valeur a la variable indiquee.
    BtnCart.StyledSettings := [];
    BtnCart.TextSettings.FontColor := COLOR_ACCENT; // Action d'ajout mise en avant.
    BtnCart.TextSettings.Font.Style := [TFontStyle.fsBold];
    BtnCart.Text := '+ Panier'; // Attribue une nouvelle valeur a la variable indiquee.
    BtnCart.Tag := Prod.ID; // Attribue une nouvelle valeur a la variable indiquee.
    BtnCart.OnClick := OnAddToCartClick; // Attribue une nouvelle valeur a la variable indiquee.

    // Informations au centre
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
    LblCat.Height := 16; // Attribue une nouvelle valeur a la variable indiquee.
    LblCat.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblCat.TextSettings.Font.Size := FONT_SIZE_CAPTION; // Attribue une nouvelle valeur a la variable indiquee.
    LblCat.TextSettings.Font.Style := [TFontStyle.fsBold]; // Attribue une nouvelle valeur a la variable indiquee.
    LblCat.TextSettings.FontColor := COLOR_PRIMARY_LIGHT; // Attribue une nouvelle valeur a la variable indiquee.
    LblCat.Text := UpperCase(Prod.CategoryName); // Attribue une nouvelle valeur a la variable indiquee.
    LblCat.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    LblName := TLabel.Create(LayInfo); // Attribue une nouvelle valeur a la variable indiquee.
    LblName.Parent := LayInfo; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.Height := 36; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.TextSettings.Font.Size := FONT_SIZE_CARD_TITLE; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.TextSettings.Font.Style := [TFontStyle.fsBold]; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.TextSettings.FontColor := COLOR_TEXT_PRIMARY; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.TextSettings.WordWrap := True; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.Text := Prod.Name; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    LblRef := TLabel.Create(LayInfo); // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.Parent := LayInfo; // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.Height := 16; // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.TextSettings.Font.Size := FONT_SIZE_CAPTION; // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.TextSettings.FontColor := COLOR_TEXT_SECONDARY; // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.Text := 'Réf. : ' + Prod.Reference; // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    LblPrice := TLabel.Create(LayInfo); // Attribue une nouvelle valeur a la variable indiquee.
    LblPrice.Parent := LayInfo; // Attribue une nouvelle valeur a la variable indiquee.
    LblPrice.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LblPrice.Height := 24; // Attribue une nouvelle valeur a la variable indiquee.
    LblPrice.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblPrice.TextSettings.Font.Size := 14; // Prix mis en avant.
    LblPrice.TextSettings.Font.Style := [TFontStyle.fsBold]; // Attribue une nouvelle valeur a la variable indiquee.
    LblPrice.TextSettings.FontColor := COLOR_PRIMARY; // Attribue une nouvelle valeur a la variable indiquee.
    if Prod.Price > 0 then // Verifie la condition avant de poursuivre.
      LblPrice.Text := FormatFloat('#,##0.00 DA', Prod.Price) // Attribue une nouvelle valeur a la variable indiquee.
    else // Execute la branche alternative de la condition precedente.
      LblPrice.Text := 'Sur devis'; // Libellé court pour éviter la troncature.
    LblPrice.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    LblStock := TLabel.Create(LayInfo); // Attribue une nouvelle valeur a la variable indiquee.
    LblStock.Parent := LayInfo; // Attribue une nouvelle valeur a la variable indiquee.
    LblStock.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LblStock.Height := 16; // Attribue une nouvelle valeur a la variable indiquee.
    LblStock.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblStock.TextSettings.Font.Size := FONT_SIZE_CAPTION; // Attribue une nouvelle valeur a la variable indiquee.
    if Prod.Price <= 0 then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      LblStock.TextSettings.FontColor := COLOR_WARNING; // Attribue une nouvelle valeur a la variable indiquee.
      LblStock.Text := 'Stock à confirmer'; // Attribue une nouvelle valeur a la variable indiquee.
    end // Ferme le bloc ou la declaration en cours.
    else if Prod.IsAvailable then // Execute la branche alternative de la condition precedente.
    begin // Ouvre le bloc d instructions correspondant.
      LblStock.TextSettings.FontColor := COLOR_SUCCESS; // Attribue une nouvelle valeur a la variable indiquee.
      LblStock.Text := Format('● En Stock (%d)', [Prod.Stock]); // Attribue une nouvelle valeur a la variable indiquee.
    end // Ferme le bloc ou la declaration en cours.
    else // Execute la branche alternative de la condition precedente.
    begin // Ouvre le bloc d instructions correspondant.
      LblStock.TextSettings.FontColor := COLOR_WARNING; // Attribue une nouvelle valeur a la variable indiquee.
      LblStock.Text := '● Sur Commande'; // Attribue une nouvelle valeur a la variable indiquee.
    end; // Ferme le bloc ou la declaration en cours.
    LblStock.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameProducts.OnProductCardClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  ProdID: Integer; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Transmet l'identifiant de la carte sélectionnée pour ouvrir son détail.
  ProdID := TComponent(Sender).Tag; // Attribue une nouvelle valeur a la variable indiquee.
  if Assigned(FOnProductSelect) then // Verifie la condition avant de poursuivre.
    FOnProductSelect(ProdID); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameProducts.OnAddToCartClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  ProdID: Integer; // Execute cette instruction dans le flux courant.
  Prod: TProduct; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Charge le produit associé au bouton, l'ajoute au panier et notifie l'écran.
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

procedure TFrameProducts.edtSearchChange(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Actualise le filtre texte à partir du champ de recherche.
  FSearchText := Trim(edtSearch.Text); // Attribue une nouvelle valeur a la variable indiquee.
  RefreshView; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameProducts.cmbSortChange(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Recharge les résultats selon le nouvel ordre sélectionné.
  RefreshView; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
