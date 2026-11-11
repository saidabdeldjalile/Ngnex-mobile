unit ProductDetailsForm; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, // Complete la declaration ou instruction en cours.
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, // Complete la declaration ou instruction en cours.
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, FMX.Memo, // Complete la declaration ou instruction en cours.
  Product, AppTheme; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Événement d'action renvoyé au formulaire principal avec l'ID du produit.
  TOnDetailActionEvent = reference to procedure(const AAction: string; AProductID: Integer); // Execute cette instruction dans le flux courant.

  // Écran détaillé d'un produit avec actions panier, comparaison et devis.
  TFrameProductDetails = class(TFrame) // Complete la declaration ou instruction en cours.
    VertScrollBox: TVertScrollBox; // Execute cette instruction dans le flux courant.
    layImageHeader: TLayout; // Execute cette instruction dans le flux courant.
    rectImageBg: TRectangle; // Execute cette instruction dans le flux courant.
    imgProduct: TImage; // Execute cette instruction dans le flux courant.
    layMainInfo: TLayout; // Execute cette instruction dans le flux courant.
    lblCategory: TLabel; // Execute cette instruction dans le flux courant.
    lblName: TLabel; // Execute cette instruction dans le flux courant.
    lblRef: TLabel; // Execute cette instruction dans le flux courant.
    lblBarcode: TLabel; // Execute cette instruction dans le flux courant.
    lblPrice: TLabel; // Execute cette instruction dans le flux courant.
    rectStockStatus: TRectangle; // Execute cette instruction dans le flux courant.
    lblStockStatus: TLabel; // Execute cette instruction dans le flux courant.
    layActions: TLayout; // Execute cette instruction dans le flux courant.
    btnAddToCart: TButton; // Execute cette instruction dans le flux courant.
    btnCompare: TButton; // Execute cette instruction dans le flux courant.
    btnRequestQuote: TButton; // Execute cette instruction dans le flux courant.
    layDescriptionSection: TLayout; // Execute cette instruction dans le flux courant.
    lblDescTitle: TLabel; // Execute cette instruction dans le flux courant.
    lblDescription: TLabel; // Execute cette instruction dans le flux courant.
    laySpecsSection: TLayout; // Execute cette instruction dans le flux courant.
    lblSpecsTitle: TLabel; // Execute cette instruction dans le flux courant.
    mmoSpecs: TMemo; // Execute cette instruction dans le flux courant.
    procedure btnAddToCartClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure btnCompareClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure btnRequestQuoteClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
  private // Complete la declaration ou instruction en cours.
    FCurrentProductID: Integer; // Execute cette instruction dans le flux courant.
    FProduct: TProduct; // Execute cette instruction dans le flux courant.
    FOnDetailAction: TOnDetailActionEvent; // Execute cette instruction dans le flux courant.
    procedure FormatTechnicalSpecs(const ASpecsText: string); // Declare une procedure de cette unite ou classe.
  public // Complete la declaration ou instruction en cours.
    constructor Create(AOwner: TComponent); override; // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.
    procedure LoadProduct(AProductID: Integer); // Declare une procedure de cette unite ou classe.

    property OnDetailAction: TOnDetailActionEvent read FOnDetailAction write FOnDetailAction; // Expose une propriete de la classe.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

uses // Declare les unites dont ce code depend.
  DataModule; // Execute cette instruction dans le flux courant.

{$R *.fmx} // Inclut la ressource FMX de cette unite.

constructor TFrameProductDetails.Create(AOwner: TComponent); // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Prépare le modèle réutilisé pour le produit affiché.
  inherited Create(AOwner); // Appelle le comportement correspondant de la classe parente.
  FProduct := TProduct.Create; // Attribue une nouvelle valeur a la variable indiquee.
  FCurrentProductID := 0;

  // Modern UI styling
  rectImageBg.Fill.Color := COLOR_SURFACE;
  rectImageBg.Stroke.Color := COLOR_BORDER_LIGHT;
  rectImageBg.Stroke.Thickness := 1;
  rectImageBg.XRadius := RADIUS_CARD;
  rectImageBg.YRadius := RADIUS_CARD;
  rectStockStatus.XRadius := RADIUS_PILL;
  rectStockStatus.YRadius := RADIUS_PILL;
  lblName.StyledSettings := [];
  lblName.TextSettings.FontColor := COLOR_TEXT_PRIMARY;
  lblName.TextSettings.Font.Size := 18;
  lblName.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblPrice.StyledSettings := [];
  lblPrice.TextSettings.FontColor := COLOR_PRIMARY;
  lblPrice.TextSettings.Font.Size := 22;
  lblPrice.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblCategory.StyledSettings := [];
  lblCategory.TextSettings.FontColor := COLOR_PRIMARY_LIGHT;
  lblCategory.TextSettings.Font.Size := 11;
  lblCategory.TextSettings.Font.Style := [TFontStyle.fsBold];
  btnAddToCart.StyledSettings := [];
  btnAddToCart.TextSettings.FontColor := COLOR_ACCENT;
  btnAddToCart.TextSettings.Font.Style := [TFontStyle.fsBold];
end; // Ferme le bloc ou la declaration en cours.

destructor TFrameProductDetails.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Libère le modèle produit possédé par le cadre.
  FreeAndNil(FProduct); // Appelle la methode ou fonction avec les parametres indiques.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameProductDetails.LoadProduct(AProductID: Integer); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Récupère les données locales et remplit les informations et visuels de l'écran.
  FCurrentProductID := AProductID; // Attribue une nouvelle valeur a la variable indiquee.
  if (DM <> nil) and (DM.ProductService.GetProductByID(AProductID, FProduct)) then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    lblCategory.Text := UpperCase(FProduct.CategoryName); // Attribue une nouvelle valeur a la variable indiquee.
    lblName.Text := FProduct.Name; // Attribue une nouvelle valeur a la variable indiquee.
    lblRef.Text := 'Référence : ' + FProduct.Reference; // Attribue une nouvelle valeur a la variable indiquee.
    lblBarcode.Text := 'Code-barres : ' + FProduct.Barcode; // Attribue une nouvelle valeur a la variable indiquee.
    if FProduct.Price > 0 then // Verifie la condition avant de poursuivre.
      lblPrice.Text := FormatFloat('#,##0.00 DA', FProduct.Price) // Attribue une nouvelle valeur a la variable indiquee.
    else // Execute la branche alternative de la condition precedente.
      lblPrice.Text := 'Prix sur demande'; // Attribue une nouvelle valeur a la variable indiquee.
    lblDescription.Text := FProduct.Description; // Attribue une nouvelle valeur a la variable indiquee.

    // Chargement de la photo du produit
    DM.ImageService.LoadIntoImage(FProduct.ImageURL, imgProduct); // Appelle la methode ou fonction avec les parametres indiques.

    if FProduct.Price <= 0 then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      rectStockStatus.Fill.Color := COLOR_WARNING_TINT; // Attribue une nouvelle valeur a la variable indiquee.
      lblStockStatus.TextSettings.FontColor := COLOR_WARNING; // Attribue une nouvelle valeur a la variable indiquee.
      lblStockStatus.Text := 'Prix et disponibilité à confirmer'; // Attribue une nouvelle valeur a la variable indiquee.
    end // Ferme le bloc ou la declaration en cours.
    else if FProduct.IsAvailable then // Execute la branche alternative de la condition precedente.
    begin // Ouvre le bloc d instructions correspondant.
      rectStockStatus.Fill.Color := COLOR_SUCCESS_TINT; // Attribue une nouvelle valeur a la variable indiquee.
      lblStockStatus.TextSettings.FontColor := COLOR_SUCCESS; // Attribue une nouvelle valeur a la variable indiquee.
      lblStockStatus.Text := Format('✓ En Stock (%d unité(s) disponibles)', [FProduct.Stock]); // Attribue une nouvelle valeur a la variable indiquee.
    end // Ferme le bloc ou la declaration en cours.
    else // Execute la branche alternative de la condition precedente.
    begin // Ouvre le bloc d instructions correspondant.
      rectStockStatus.Fill.Color := COLOR_WARNING_TINT; // Attribue une nouvelle valeur a la variable indiquee.
      lblStockStatus.TextSettings.FontColor := COLOR_WARNING; // Attribue une nouvelle valeur a la variable indiquee.
      lblStockStatus.Text := '⚠ Sur commande — Réapprovisionnement en cours'; // Attribue une nouvelle valeur a la variable indiquee.
    end; // Ferme le bloc ou la declaration en cours.

    FormatTechnicalSpecs(FProduct.TechnicalSpecs); // Appelle la methode ou fonction avec les parametres indiques.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameProductDetails.FormatTechnicalSpecs(const ASpecsText: string); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  SpecsList: TArray<string>; // Execute cette instruction dans le flux courant.
  SpecItem: string; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Transforme les caractéristiques séparées par des barres en lignes lisibles.
  mmoSpecs.Lines.Clear; // Execute cette instruction dans le flux courant.
  if ASpecsText.Trim.IsEmpty then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    mmoSpecs.Lines.Add('Aucune caractéristique technique renseignée.'); // Appelle la methode ou fonction avec les parametres indiques.
    Exit; // Quitte la procedure ou fonction a cet endroit.
  end; // Ferme le bloc ou la declaration en cours.

  SpecsList := ASpecsText.Split(['|']); // Attribue une nouvelle valeur a la variable indiquee.
  for SpecItem in SpecsList do // Parcourt les elements ou valeurs de cette boucle.
  begin // Ouvre le bloc d instructions correspondant.
    if not SpecItem.Trim.IsEmpty then // Verifie la condition avant de poursuivre.
      mmoSpecs.Lines.Add('• ' + SpecItem.Trim); // Appelle la methode ou fonction avec les parametres indiques.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameProductDetails.btnAddToCartClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Ajoute une unité au panier puis informe les autres écrans du changement.
  if (DM <> nil) and (FProduct <> nil) and (FCurrentProductID > 0) then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    DM.CartService.AddProduct(FProduct, 1); // Appelle la methode ou fonction avec les parametres indiques.
    ShowMessage(Format('"%s" a été ajouté à votre panier !', [FProduct.Name])); // Appelle la methode ou fonction avec les parametres indiques.
    if Assigned(FOnDetailAction) then // Verifie la condition avant de poursuivre.
      FOnDetailAction('CartChanged', FCurrentProductID); // Appelle la methode ou fonction avec les parametres indiques.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameProductDetails.btnCompareClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Demande au formulaire principal d'ouvrir la comparaison avec ce produit.
  if Assigned(FOnDetailAction) and (FCurrentProductID > 0) then // Verifie la condition avant de poursuivre.
    FOnDetailAction('Compare', FCurrentProductID); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameProductDetails.btnRequestQuoteClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Ajoute le produit au panier avant de déléguer l'ouverture du formulaire de devis.
  if (DM <> nil) and (FProduct <> nil) and (FCurrentProductID > 0) then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    // Ajout automatique au panier avant devis si pas encore présent
    DM.CartService.AddProduct(FProduct, 1); // Appelle la methode ou fonction avec les parametres indiques.
    if Assigned(FOnDetailAction) then // Verifie la condition avant de poursuivre.
      FOnDetailAction('RequestQuote', FCurrentProductID); // Appelle la methode ou fonction avec les parametres indiques.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
