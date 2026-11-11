unit CartForm; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, // Complete la declaration ou instruction en cours.
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, // Complete la declaration ou instruction en cours.
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, // Complete la declaration ou instruction en cours.
  CartItem, AppTheme; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Signale au formulaire principal les opérations qui changent l'état du panier.
  TOnCartActionEvent = reference to procedure(const AAction: string); // Execute cette instruction dans le flux courant.

  // Écran du panier : affichage des lignes, modification des quantités et demande de devis.
  TFrameCart = class(TFrame) // Complete la declaration ou instruction en cours.
    VertScrollBox: TVertScrollBox; // Execute cette instruction dans le flux courant.
    layTitle: TLayout; // Execute cette instruction dans le flux courant.
    lblHeader: TLabel; // Execute cette instruction dans le flux courant.
    layCartItemsList: TLayout; // Execute cette instruction dans le flux courant.
    laySummaryBox: TLayout; // Execute cette instruction dans le flux courant.
    rectSummaryBg: TRectangle; // Execute cette instruction dans le flux courant.
    lblGrandTotalLabel: TLabel; // Execute cette instruction dans le flux courant.
    lblGrandTotalValue: TLabel; // Execute cette instruction dans le flux courant.
    lblTotalQtyValue: TLabel; // Execute cette instruction dans le flux courant.
    rectRequestQuote: TRectangle; // Bouton principal "Demander un devis".
    lblRequestQuote: TLabel; // Libellé du bouton principal.
    rectClearCart: TRectangle; // Bouton secondaire "Vider le panier".
    lblClearCart: TLabel; // Libellé du bouton secondaire.
    procedure btnClearCartClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure btnRequestQuoteClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
  private // Complete la declaration ou instruction en cours.
    FOnCartAction: TOnCartActionEvent; // Execute cette instruction dans le flux courant.
    procedure RenderCartItems; // Declare une procedure de cette unite ou classe.
    procedure OnQtyPlusClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure OnQtyMinusClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure OnRemoveItemClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
  public // Complete la declaration ou instruction en cours.
    constructor Create(AOwner: TComponent); override; // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.
    procedure RefreshView; // Declare une procedure de cette unite ou classe.

    property OnCartAction: TOnCartActionEvent read FOnCartAction write FOnCartAction; // Expose une propriete de la classe.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

uses // Declare les unites dont ce code depend.
  DataModule; // Execute cette instruction dans le flux courant.

{$R *.fmx} // Inclut la ressource FMX de cette unite.

constructor TFrameCart.Create(AOwner: TComponent); // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Affiche immédiatement l'état courant du panier local.
  inherited Create(AOwner); // Appelle le comportement correspondant de la classe parente.

  // --- Thème moderne de l'écran panier ---
  lblHeader.StyledSettings := [];
  lblHeader.TextSettings.FontColor := COLOR_TEXT_PRIMARY;
  lblHeader.TextSettings.Font.Size := FONT_SIZE_PAGE_TITLE + 1;
  lblHeader.TextSettings.Font.Style := [TFontStyle.fsBold];

  // Carte de synthèse : surface blanche, bord discret et coins du design system.
  rectSummaryBg.Fill.Color := COLOR_SURFACE;
  rectSummaryBg.Stroke.Color := COLOR_BORDER_LIGHT;
  rectSummaryBg.XRadius := RADIUS_CARD;
  rectSummaryBg.YRadius := RADIUS_CARD;

  lblGrandTotalLabel.StyledSettings := [];
  lblGrandTotalLabel.TextSettings.FontColor := COLOR_TEXT_SECONDARY;
  lblGrandTotalLabel.TextSettings.Font.Size := FONT_SIZE_BODY;
  lblGrandTotalValue.StyledSettings := [];
  lblGrandTotalValue.TextSettings.FontColor := COLOR_TEXT_PRIMARY;
  lblGrandTotalValue.TextSettings.Font.Size := 20;
  lblGrandTotalValue.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblTotalQtyValue.StyledSettings := [];
  lblTotalQtyValue.TextSettings.FontColor := COLOR_TEXT_SECONDARY;
  lblTotalQtyValue.TextSettings.Font.Size := FONT_SIZE_BODY;

  // Bouton principal plein et bouton secondaire discret.
  rectRequestQuote.Fill.Color := COLOR_ACCENT;
  rectRequestQuote.Stroke.Kind := TBrushKind.None;
  rectRequestQuote.XRadius := RADIUS_BUTTON;
  rectRequestQuote.YRadius := RADIUS_BUTTON;
  lblRequestQuote.StyledSettings := [];
  lblRequestQuote.TextSettings.FontColor := COLOR_TEXT_WHITE;
  lblRequestQuote.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblRequestQuote.TextSettings.Font.Size := FONT_SIZE_CARD_TITLE + 1;
  rectClearCart.Fill.Color := COLOR_SURFACE;
  rectClearCart.Stroke.Color := COLOR_BORDER_MEDIUM;
  rectClearCart.XRadius := RADIUS_BUTTON;
  rectClearCart.YRadius := RADIUS_BUTTON;
  lblClearCart.StyledSettings := [];
  lblClearCart.TextSettings.FontColor := COLOR_TEXT_SECONDARY;
  lblClearCart.TextSettings.Font.Size := FONT_SIZE_BODY;

  RefreshView; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

destructor TFrameCart.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameCart.RefreshView; // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Recharge SQLite, redessine les lignes et recalcule les indicateurs de total.
  if DM <> nil then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    DM.CartService.RefreshCart; // Execute cette instruction dans le flux courant.
    RenderCartItems; // Execute cette instruction dans le flux courant.
    if DM.CartService.Items.HasUnpricedItems then // Verifie la condition avant de poursuivre.
      lblGrandTotalValue.Text := 'Montant à confirmer' // Attribue une nouvelle valeur a la variable indiquee.
    else // Execute la branche alternative de la condition precedente.
      lblGrandTotalValue.Text := FormatFloat('#,##0.00 DA', DM.CartService.GrandTotal); // Attribue une nouvelle valeur a la variable indiquee.
    lblTotalQtyValue.Text := Format('📦 %d équipement(s) au total', [DM.CartService.TotalQuantity]); // Attribue une nouvelle valeur a la variable indiquee.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameCart.RenderCartItems; // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  I: Integer; // Execute cette instruction dans le flux courant.
  Item: TCartItem; // Execute cette instruction dans le flux courant.
  Card: TRectangle; // Execute cette instruction dans le flux courant.
  LayImgContainer: TLayout; // Execute cette instruction dans le flux courant.
  RectImgBg: TRectangle; // Execute cette instruction dans le flux courant.
  ImgProd: TImage; // Execute cette instruction dans le flux courant.
  LayInfo: TLayout; // Execute cette instruction dans le flux courant.
  LblName, LblRef, LblPrice, LblTotal, LblQty: TLabel; // Execute cette instruction dans le flux courant.
  BtnPlus, BtnMinus, BtnRemove: TButton; // Execute cette instruction dans le flux courant.
  EmptyLbl: TLabel; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Reconstruit les cartes du panier, ou affiche un état vide si aucune ligne n'existe.
  while layCartItemsList.ControlsCount > 0 do // Repete le bloc tant que la condition reste vraie.
    layCartItemsList.Controls[0].Free; // Execute cette instruction dans le flux courant.

  if (DM = nil) or (DM.CartService.Items.Count = 0) then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    // Panier vide : la zone centrale pousse la carte de synthèse vers le bas
    // sans dépasser la hauteur visible du cadre.
    layCartItemsList.Height := 300;
    EmptyLbl := TLabel.Create(layCartItemsList); // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl.Parent := layCartItemsList; // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl.Margins.Left := 24;
    EmptyLbl.Margins.Right := 24;
    EmptyLbl.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl.TextSettings.Font.Size := 13; // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl.TextSettings.FontColor := COLOR_TEXT_MUTED; // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl.TextSettings.HorzAlign := TTextAlign.Center; // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl.TextSettings.VertAlign := TTextAlign.Center; // Attribue une nouvelle valeur a la variable indiquee.
    EmptyLbl.Text := '🛒 Votre panier est vide.'#13#10'Explorez le catalogue pour ajouter des équipements POS.'; // Attribue une nouvelle valeur a la variable indiquee.
    Exit; // Quitte la procedure ou fonction a cet endroit.
  end; // Ferme le bloc ou la declaration en cours.
  layCartItemsList.Height := DM.CartService.Items.Count * 120; // Attribue une nouvelle valeur a la variable indiquee.

  for I := 0 to DM.CartService.Items.Count - 1 do // Parcourt les elements ou valeurs de cette boucle.
  begin // Ouvre le bloc d instructions correspondant.
    Item := DM.CartService.Items[I]; // Attribue une nouvelle valeur a la variable indiquee.

    Card := TRectangle.Create(layCartItemsList); // Attribue une nouvelle valeur a la variable indiquee.
    Card.Parent := layCartItemsList; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Height := 110; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Margins.Left := 12; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Margins.Right := 12; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Margins.Bottom := 10; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Fill.Color := COLOR_SURFACE; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Stroke.Color := COLOR_BORDER_LIGHT; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Stroke.Thickness := 1; // Attribue une nouvelle valeur a la variable indiquee.
    Card.XRadius := RADIUS_CARD; // Coins modernes du design system.
    Card.YRadius := RADIUS_CARD; // Coins modernes du design system.

    // Miniature photo du produit
    LayImgContainer := TLayout.Create(Card); // Attribue une nouvelle valeur a la variable indiquee.
    LayImgContainer.Parent := Card; // Attribue une nouvelle valeur a la variable indiquee.
    LayImgContainer.Align := TAlignLayout.Left; // Attribue une nouvelle valeur a la variable indiquee.
    LayImgContainer.Width := 75; // Attribue une nouvelle valeur a la variable indiquee.
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
    ImgProd.Margins.Left := 2; // Attribue une nouvelle valeur a la variable indiquee.
    ImgProd.Margins.Top := 2; // Attribue une nouvelle valeur a la variable indiquee.
    ImgProd.Margins.Right := 2; // Attribue une nouvelle valeur a la variable indiquee.
    ImgProd.Margins.Bottom := 2; // Attribue une nouvelle valeur a la variable indiquee.
    ImgProd.WrapMode := TImageWrapMode.Fit; // Attribue une nouvelle valeur a la variable indiquee.
    ImgProd.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    if (DM <> nil) and Assigned(Item.Product) then // Verifie la condition avant de poursuivre.
      DM.ImageService.LoadIntoImage(Item.Product.ImageURL, ImgProd); // Appelle la methode ou fonction avec les parametres indiques.

    // Contrôles à droite
    BtnRemove := TButton.Create(Card); // Attribue une nouvelle valeur a la variable indiquee.
    BtnRemove.Parent := Card; // Attribue une nouvelle valeur a la variable indiquee.
    BtnRemove.Align := TAlignLayout.Right; // Attribue une nouvelle valeur a la variable indiquee.
    BtnRemove.Width := 34; // Attribue une nouvelle valeur a la variable indiquee.
    BtnRemove.Margins.Right := 8; // Attribue une nouvelle valeur a la variable indiquee.
    BtnRemove.Margins.Top := 8; // Attribue une nouvelle valeur a la variable indiquee.
    BtnRemove.Margins.Bottom := 60; // Attribue une nouvelle valeur a la variable indiquee.
    BtnRemove.Text := '🗑'; // Attribue une nouvelle valeur a la variable indiquee.
    BtnRemove.Tag := Item.ProductID; // Attribue une nouvelle valeur a la variable indiquee.
    BtnRemove.OnClick := OnRemoveItemClick; // Attribue une nouvelle valeur a la variable indiquee.

    BtnPlus := TButton.Create(Card); // Attribue une nouvelle valeur a la variable indiquee.
    BtnPlus.Parent := Card; // Attribue une nouvelle valeur a la variable indiquee.
    BtnPlus.Align := TAlignLayout.Right; // Attribue une nouvelle valeur a la variable indiquee.
    BtnPlus.Width := 34; // Attribue une nouvelle valeur a la variable indiquee.
    BtnPlus.Margins.Right := 8; // Attribue une nouvelle valeur a la variable indiquee.
    BtnPlus.Margins.Top := 60; // Attribue une nouvelle valeur a la variable indiquee.
    BtnPlus.Margins.Bottom := 8; // Attribue une nouvelle valeur a la variable indiquee.
    BtnPlus.Text := '+'; // Attribue une nouvelle valeur a la variable indiquee.
    BtnPlus.Tag := Item.ProductID; // Attribue une nouvelle valeur a la variable indiquee.
    BtnPlus.OnClick := OnQtyPlusClick; // Attribue une nouvelle valeur a la variable indiquee.

    LblQty := TLabel.Create(Card); // Attribue une nouvelle valeur a la variable indiquee.
    LblQty.Parent := Card; // Attribue une nouvelle valeur a la variable indiquee.
    LblQty.Align := TAlignLayout.Right; // Attribue une nouvelle valeur a la variable indiquee.
    LblQty.Width := 32; // Attribue une nouvelle valeur a la variable indiquee.
    LblQty.Margins.Right := 4; // Attribue une nouvelle valeur a la variable indiquee.
    LblQty.Margins.Top := 60; // Attribue une nouvelle valeur a la variable indiquee.
    LblQty.Margins.Bottom := 8; // Attribue une nouvelle valeur a la variable indiquee.
    LblQty.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblQty.TextSettings.Font.Size := 12; // Attribue une nouvelle valeur a la variable indiquee.
    LblQty.TextSettings.Font.Style := [TFontStyle.fsBold]; // Attribue une nouvelle valeur a la variable indiquee.
    LblQty.TextSettings.FontColor := COLOR_TEXT_PRIMARY; // Attribue une nouvelle valeur a la variable indiquee.
    LblQty.TextSettings.HorzAlign := TTextAlign.Center; // Attribue une nouvelle valeur a la variable indiquee.
    LblQty.TextSettings.VertAlign := TTextAlign.Center; // Attribue une nouvelle valeur a la variable indiquee.
    LblQty.Text := IntToStr(Item.Quantity); // Attribue une nouvelle valeur a la variable indiquee.

    BtnMinus := TButton.Create(Card); // Attribue une nouvelle valeur a la variable indiquee.
    BtnMinus.Parent := Card; // Attribue une nouvelle valeur a la variable indiquee.
    BtnMinus.Align := TAlignLayout.Right; // Attribue une nouvelle valeur a la variable indiquee.
    BtnMinus.Width := 34; // Attribue une nouvelle valeur a la variable indiquee.
    BtnMinus.Margins.Right := 4; // Attribue une nouvelle valeur a la variable indiquee.
    BtnMinus.Margins.Top := 60; // Attribue une nouvelle valeur a la variable indiquee.
    BtnMinus.Margins.Bottom := 8; // Attribue une nouvelle valeur a la variable indiquee.
    BtnMinus.Text := '-'; // Attribue une nouvelle valeur a la variable indiquee.
    BtnMinus.Tag := Item.ProductID; // Attribue une nouvelle valeur a la variable indiquee.
    BtnMinus.OnClick := OnQtyMinusClick; // Attribue une nouvelle valeur a la variable indiquee.

    // Informations au centre
    LayInfo := TLayout.Create(Card); // Attribue une nouvelle valeur a la variable indiquee.
    LayInfo.Parent := Card; // Attribue une nouvelle valeur a la variable indiquee.
    LayInfo.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    LayInfo.Margins.Left := 8; // Attribue une nouvelle valeur a la variable indiquee.
    LayInfo.Margins.Top := 8; // Attribue une nouvelle valeur a la variable indiquee.
    LayInfo.Margins.Right := 4; // Attribue une nouvelle valeur a la variable indiquee.
    LayInfo.Margins.Bottom := 8; // Attribue une nouvelle valeur a la variable indiquee.
    LayInfo.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    LblName := TLabel.Create(LayInfo); // Attribue une nouvelle valeur a la variable indiquee.
    LblName.Parent := LayInfo; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.Height := 20; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.TextSettings.Font.Size := 11; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.TextSettings.Font.Style := [TFontStyle.fsBold]; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.TextSettings.FontColor := COLOR_TEXT_PRIMARY; // Attribue une nouvelle valeur a la variable indiquee.
    if Assigned(Item.Product) then LblName.Text := Item.Product.Name // Verifie la condition avant de poursuivre.
    else LblName.Text := Format('Équipement #%d', [Item.ProductID]); // Execute la branche alternative de la condition precedente.

    LblRef := TLabel.Create(LayInfo); // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.Parent := LayInfo; // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.Height := 16; // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.TextSettings.Font.Size := 10; // Attribue une nouvelle valeur a la variable indiquee.
    LblRef.TextSettings.FontColor := COLOR_TEXT_SECONDARY; // Attribue une nouvelle valeur a la variable indiquee.
    if Assigned(Item.Product) then LblRef.Text := 'Réf. : ' + Item.Product.Reference; // Verifie la condition avant de poursuivre.

    LblPrice := TLabel.Create(LayInfo); // Attribue une nouvelle valeur a la variable indiquee.
    LblPrice.Parent := LayInfo; // Attribue une nouvelle valeur a la variable indiquee.
    LblPrice.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LblPrice.Height := 18; // Attribue une nouvelle valeur a la variable indiquee.
    LblPrice.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblPrice.TextSettings.Font.Size := 10; // Attribue une nouvelle valeur a la variable indiquee.
    LblPrice.TextSettings.FontColor := COLOR_TEXT_SECONDARY; // Attribue une nouvelle valeur a la variable indiquee.
    if Item.UnitPrice > 0 then // Verifie la condition avant de poursuivre.
      LblPrice.Text := Format('Unité : %s', [FormatFloat('#,##0.00 DA', Item.UnitPrice)]) // Attribue une nouvelle valeur a la variable indiquee.
    else // Execute la branche alternative de la condition precedente.
      LblPrice.Text := 'Unité : prix sur demande'; // Attribue une nouvelle valeur a la variable indiquee.

    LblTotal := TLabel.Create(LayInfo); // Attribue une nouvelle valeur a la variable indiquee.
    LblTotal.Parent := LayInfo; // Attribue une nouvelle valeur a la variable indiquee.
    LblTotal.Align := TAlignLayout.Bottom; // Attribue une nouvelle valeur a la variable indiquee.
    LblTotal.Height := 22; // Attribue une nouvelle valeur a la variable indiquee.
    LblTotal.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblTotal.TextSettings.Font.Size := 12; // Attribue une nouvelle valeur a la variable indiquee.
    LblTotal.TextSettings.Font.Style := [TFontStyle.fsBold]; // Attribue une nouvelle valeur a la variable indiquee.
    LblTotal.TextSettings.FontColor := COLOR_PRIMARY; // Attribue une nouvelle valeur a la variable indiquee.
    if Item.UnitPrice > 0 then // Verifie la condition avant de poursuivre.
      LblTotal.Text := Format('Total : %s', [FormatFloat('#,##0.00 DA', Item.TotalPrice)]) // Attribue une nouvelle valeur a la variable indiquee.
    else // Execute la branche alternative de la condition precedente.
      LblTotal.Text := 'Sous-total à confirmer'; // Attribue une nouvelle valeur a la variable indiquee.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameCart.OnQtyPlusClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  ProdID: Integer; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Augmente la quantité du produit et propage le changement aux autres vues.
  ProdID := TComponent(Sender).Tag; // Attribue une nouvelle valeur a la variable indiquee.
  if DM <> nil then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    DM.CartService.UpdateQuantity(ProdID, DM.CartService.GetQuantity(ProdID) + 1); // Appelle la methode ou fonction avec les parametres indiques.
    RefreshView; // Execute cette instruction dans le flux courant.
    if Assigned(FOnCartAction) then // Verifie la condition avant de poursuivre.
      FOnCartAction('CartUpdated'); // Appelle la methode ou fonction avec les parametres indiques.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameCart.OnQtyMinusClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  ProdID: Integer; // Execute cette instruction dans le flux courant.
  CurrentQty: Integer; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Diminue la quantité ; la dernière unité retirée supprime la ligne.
  ProdID := TComponent(Sender).Tag; // Attribue une nouvelle valeur a la variable indiquee.
  if DM <> nil then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    CurrentQty := DM.CartService.GetQuantity(ProdID); // Attribue une nouvelle valeur a la variable indiquee.
    if CurrentQty > 1 then // Verifie la condition avant de poursuivre.
      DM.CartService.UpdateQuantity(ProdID, CurrentQty - 1) // Appelle la methode ou fonction avec les parametres indiques.
    else // Execute la branche alternative de la condition precedente.
      DM.CartService.RemoveFromCart(ProdID); // Appelle la methode ou fonction avec les parametres indiques.
    RefreshView; // Execute cette instruction dans le flux courant.
    if Assigned(FOnCartAction) then // Verifie la condition avant de poursuivre.
      FOnCartAction('CartUpdated'); // Appelle la methode ou fonction avec les parametres indiques.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameCart.OnRemoveItemClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  ProdID: Integer; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Supprime explicitement la ligne sélectionnée et actualise l'écran.
  ProdID := TComponent(Sender).Tag; // Attribue une nouvelle valeur a la variable indiquee.
  if DM <> nil then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    DM.CartService.RemoveFromCart(ProdID); // Appelle la methode ou fonction avec les parametres indiques.
    RefreshView; // Execute cette instruction dans le flux courant.
    if Assigned(FOnCartAction) then // Verifie la condition avant de poursuivre.
      FOnCartAction('CartUpdated'); // Appelle la methode ou fonction avec les parametres indiques.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameCart.btnClearCartClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Vide entièrement le panier et notifie le formulaire principal.
  if DM <> nil then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    DM.CartService.ClearCart; // Execute cette instruction dans le flux courant.
    RefreshView; // Execute cette instruction dans le flux courant.
    if Assigned(FOnCartAction) then // Verifie la condition avant de poursuivre.
      FOnCartAction('CartUpdated'); // Appelle la methode ou fonction avec les parametres indiques.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameCart.btnRequestQuoteClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Ouvre le formulaire de devis uniquement si le panier contient des produits.
  if (DM <> nil) and (DM.CartService.Items.Count > 0) then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    if Assigned(FOnCartAction) then // Verifie la condition avant de poursuivre.
      FOnCartAction('GoQuote'); // Appelle la methode ou fonction avec les parametres indiques.
  end // Ferme le bloc ou la declaration en cours.
  else // Execute la branche alternative de la condition precedente.
    ShowMessage('Votre panier est vide. Veuillez ajouter des produits avant de demander un devis.'); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
