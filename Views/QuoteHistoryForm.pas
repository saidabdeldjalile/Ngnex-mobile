unit QuoteHistoryForm; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, // Complete la declaration ou instruction en cours.
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, // Complete la declaration ou instruction en cours.
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, // Complete la declaration ou instruction en cours.
  Quote; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Historique des devis enregistrés localement sur cet appareil.
  TFrameQuoteHistory = class(TFrame) // Complete la declaration ou instruction en cours.
    VertScrollBox: TVertScrollBox; // Execute cette instruction dans le flux courant.
    layTitle: TLayout; // Execute cette instruction dans le flux courant.
    lblHeader: TLabel; // Execute cette instruction dans le flux courant.
    layHistoryList: TLayout; // Execute cette instruction dans le flux courant.
  private // Complete la declaration ou instruction en cours.
    FQuoteList: TQuoteList; // Execute cette instruction dans le flux courant.
    procedure RenderHistory; // Declare une procedure de cette unite ou classe.
  public // Complete la declaration ou instruction en cours.
    constructor Create(AOwner: TComponent); override; // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.
    procedure RefreshView; // Declare une procedure de cette unite ou classe.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

uses // Declare les unites dont ce code depend.
  DataModule, AppTheme; // Execute cette instruction dans le flux courant.

{$R *.fmx} // Inclut la ressource FMX de cette unite.

constructor TFrameQuoteHistory.Create(AOwner: TComponent); // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Crée la liste possédée par la vue et charge l'historique.
  inherited Create(AOwner); // Appelle le comportement correspondant de la classe parente.

  // Titre d'écran aligné sur le design system.
  lblHeader.StyledSettings := [];
  lblHeader.TextSettings.FontColor := COLOR_TEXT_PRIMARY;
  lblHeader.TextSettings.Font.Size := FONT_SIZE_PAGE_TITLE + 1;
  lblHeader.TextSettings.Font.Style := [TFontStyle.fsBold];

  FQuoteList := TQuoteList.Create(True); // Attribue une nouvelle valeur a la variable indiquee.
  RefreshView; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

destructor TFrameQuoteHistory.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Libère les devis et les lignes qui leur appartiennent.
  FreeAndNil(FQuoteList); // Appelle la methode ou fonction avec les parametres indiques.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameQuoteHistory.RefreshView; // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Recharge la base locale avant de redessiner l'historique.
  if DM <> nil then // Verifie la condition avant de poursuivre.
    DM.QuoteService.LoadQuotesHistory(FQuoteList); // Appelle la methode ou fonction avec les parametres indiques.
  RenderHistory; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameQuoteHistory.RenderHistory; // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  I, J: Integer; // Execute cette instruction dans le flux courant.
  ContentHeight: Single; // Execute cette instruction dans le flux courant.
  Q: TQuote; // Execute cette instruction dans le flux courant.
  Item: TQuoteItem; // Execute cette instruction dans le flux courant.
  Card, StatusTag: TRectangle; // Execute cette instruction dans le flux courant.
  LblNum, LblDate, LblStatus, LblCust, LblTotal, LblItem: TLabel; // Execute cette instruction dans le flux courant.
  LayInfo, LayItems: TLayout; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Construit une carte récapitulative par devis, avec ses lignes et son statut.
  while layHistoryList.ControlsCount > 0 do // Repete le bloc tant que la condition reste vraie.
    layHistoryList.Controls[0].Free; // Execute cette instruction dans le flux courant.

  if FQuoteList.Count = 0 then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    layHistoryList.Height := 100; // Attribue une nouvelle valeur a la variable indiquee.
    LblNum := TLabel.Create(layHistoryList); // Attribue une nouvelle valeur a la variable indiquee.
    LblNum.Parent := layHistoryList; // Attribue une nouvelle valeur a la variable indiquee.
    LblNum.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LblNum.Margins.Top := 40; // Attribue une nouvelle valeur a la variable indiquee.
    LblNum.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblNum.TextSettings.Font.Size := 14; // Attribue une nouvelle valeur a la variable indiquee.
    LblNum.TextSettings.FontColor := COLOR_TEXT_SECONDARY; // Attribue une nouvelle valeur a la variable indiquee.
    LblNum.TextSettings.HorzAlign := TTextAlign.Center; // Attribue une nouvelle valeur a la variable indiquee.
    LblNum.Text := 'Aucune demande de devis enregistrée.'; // Attribue une nouvelle valeur a la variable indiquee.
    Exit; // Quitte la procedure ou fonction a cet endroit.
  end; // Ferme le bloc ou la declaration en cours.

  ContentHeight := 0; // Attribue une nouvelle valeur a la variable indiquee.
  for I := 0 to FQuoteList.Count - 1 do // Parcourt les elements ou valeurs de cette boucle.
    ContentHeight := ContentHeight + 152 + FQuoteList[I].Items.Count * 18; // Attribue une nouvelle valeur a la variable indiquee.
  layHistoryList.Height := ContentHeight; // Attribue une nouvelle valeur a la variable indiquee.

  for I := 0 to FQuoteList.Count - 1 do // Parcourt les elements ou valeurs de cette boucle.
  begin // Ouvre le bloc d instructions correspondant.
    Q := FQuoteList[I]; // Attribue une nouvelle valeur a la variable indiquee.

    Card := TRectangle.Create(layHistoryList); // Attribue une nouvelle valeur a la variable indiquee.
    Card.Parent := layHistoryList; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Height := 140 + (Q.Items.Count * 18); // Attribue une nouvelle valeur a la variable indiquee.
    Card.Margins.Left := 12; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Margins.Right := 12; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Margins.Bottom := 12; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Fill.Color := COLOR_SURFACE; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Stroke.Color := COLOR_BORDER_LIGHT; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Stroke.Thickness := 1; // Attribue une nouvelle valeur a la variable indiquee.
    Card.XRadius := RADIUS_CARD; // Coins modernes du design system.
    Card.YRadius := RADIUS_CARD; // Coins modernes du design system.

    // Header info
    LayInfo := TLayout.Create(Card); // Attribue une nouvelle valeur a la variable indiquee.
    LayInfo.Parent := Card; // Attribue une nouvelle valeur a la variable indiquee.
    LayInfo.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LayInfo.Height := 75; // Attribue une nouvelle valeur a la variable indiquee.
    LayInfo.Margins.Left := 12; // Attribue une nouvelle valeur a la variable indiquee.
    LayInfo.Margins.Top := 10; // Attribue une nouvelle valeur a la variable indiquee.
    LayInfo.Margins.Right := 120; // Attribue une nouvelle valeur a la variable indiquee.

    LblNum := TLabel.Create(LayInfo); // Attribue une nouvelle valeur a la variable indiquee.
    LblNum.Parent := LayInfo; // Attribue une nouvelle valeur a la variable indiquee.
    LblNum.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LblNum.Height := 20; // Attribue une nouvelle valeur a la variable indiquee.
    LblNum.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblNum.TextSettings.Font.Size := 13; // Attribue une nouvelle valeur a la variable indiquee.
    LblNum.TextSettings.Font.Style := [TFontStyle.fsBold]; // Attribue une nouvelle valeur a la variable indiquee.
    LblNum.TextSettings.FontColor := COLOR_PRIMARY; // Attribue une nouvelle valeur a la variable indiquee.
    LblNum.Text := Q.Number; // Attribue une nouvelle valeur a la variable indiquee.

    LblDate := TLabel.Create(LayInfo); // Attribue une nouvelle valeur a la variable indiquee.
    LblDate.Parent := LayInfo; // Attribue une nouvelle valeur a la variable indiquee.
    LblDate.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LblDate.Height := 18; // Attribue une nouvelle valeur a la variable indiquee.
    LblDate.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblDate.TextSettings.Font.Size := 11; // Attribue une nouvelle valeur a la variable indiquee.
    LblDate.TextSettings.FontColor := COLOR_TEXT_SECONDARY; // Attribue une nouvelle valeur a la variable indiquee.
    LblDate.Text := 'Date : ' + FormatDateTime('dd/mm/yyyy hh:nn', Q.CreatedAt); // Attribue une nouvelle valeur a la variable indiquee.

    LblCust := TLabel.Create(LayInfo); // Attribue une nouvelle valeur a la variable indiquee.
    LblCust.Parent := LayInfo; // Attribue une nouvelle valeur a la variable indiquee.
    LblCust.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LblCust.Height := 18; // Attribue une nouvelle valeur a la variable indiquee.
    LblCust.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblCust.TextSettings.Font.Size := 11; // Attribue une nouvelle valeur a la variable indiquee.
    LblCust.TextSettings.FontColor := COLOR_TEXT_PRIMARY; // Attribue une nouvelle valeur a la variable indiquee.
    LblCust.Text := 'Client : ' + Q.Customer.FullName + ' (' + Q.Customer.Phone + ')'; // Attribue une nouvelle valeur a la variable indiquee.

    // Status Badge
    StatusTag := TRectangle.Create(Card); // Attribue une nouvelle valeur a la variable indiquee.
    StatusTag.Parent := Card; // Attribue une nouvelle valeur a la variable indiquee.
    StatusTag.Align := TAlignLayout.Right; // Attribue une nouvelle valeur a la variable indiquee.
    StatusTag.Width := 110; // Attribue une nouvelle valeur a la variable indiquee.
    StatusTag.Margins.Right := 10; // Attribue une nouvelle valeur a la variable indiquee.
    StatusTag.Margins.Top := 10; // Attribue une nouvelle valeur a la variable indiquee.
    StatusTag.Margins.Bottom := Card.Height - 40; // Attribue une nouvelle valeur a la variable indiquee.
    StatusTag.XRadius := 4; // Attribue une nouvelle valeur a la variable indiquee.
    StatusTag.YRadius := 4; // Attribue une nouvelle valeur a la variable indiquee.
    StatusTag.Stroke.Kind := TBrushKind.None; // Attribue une nouvelle valeur a la variable indiquee.

    LblStatus := TLabel.Create(StatusTag); // Attribue une nouvelle valeur a la variable indiquee.
    LblStatus.Parent := StatusTag; // Attribue une nouvelle valeur a la variable indiquee.
    LblStatus.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    LblStatus.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblStatus.TextSettings.Font.Size := 10; // Attribue une nouvelle valeur a la variable indiquee.
    LblStatus.TextSettings.Font.Style := [TFontStyle.fsBold]; // Attribue une nouvelle valeur a la variable indiquee.
    LblStatus.TextSettings.HorzAlign := TTextAlign.Center; // Attribue une nouvelle valeur a la variable indiquee.
    LblStatus.TextSettings.VertAlign := TTextAlign.Center; // Attribue une nouvelle valeur a la variable indiquee.

    case Q.Status of // Choisit une branche selon la valeur de l expression.
      qsEnAttente: // Complete la declaration ou instruction en cours.
        begin // Ouvre le bloc d instructions correspondant.
          StatusTag.Fill.Color := COLOR_WARNING_TINT; // Attribue une nouvelle valeur a la variable indiquee.
          LblStatus.TextSettings.FontColor := COLOR_ACCENT; // Attribue une nouvelle valeur a la variable indiquee.
        end; // Ferme le bloc ou la declaration en cours.
      qsEnTraitement: // Complete la declaration ou instruction en cours.
        begin // Ouvre le bloc d instructions correspondant.
          StatusTag.Fill.Color := COLOR_PRIMARY_TINT; // Attribue une nouvelle valeur a la variable indiquee.
          LblStatus.TextSettings.FontColor := COLOR_PRIMARY; // Attribue une nouvelle valeur a la variable indiquee.
        end; // Ferme le bloc ou la declaration en cours.
      qsAccepte: // Complete la declaration ou instruction en cours.
        begin // Ouvre le bloc d instructions correspondant.
          StatusTag.Fill.Color := COLOR_SUCCESS_TINT; // Attribue une nouvelle valeur a la variable indiquee.
          LblStatus.TextSettings.FontColor := COLOR_SUCCESS; // Attribue une nouvelle valeur a la variable indiquee.
        end; // Ferme le bloc ou la declaration en cours.
      qsRefuse: // Complete la declaration ou instruction en cours.
        begin // Ouvre le bloc d instructions correspondant.
          StatusTag.Fill.Color := COLOR_DANGER_TINT; // Attribue une nouvelle valeur a la variable indiquee.
          LblStatus.TextSettings.FontColor := COLOR_DANGER; // Attribue une nouvelle valeur a la variable indiquee.
        end; // Ferme le bloc ou la declaration en cours.
    end; // Ferme le bloc ou la declaration en cours.
    LblStatus.Text := Q.StatusText; // Attribue une nouvelle valeur a la variable indiquee.

    // Items List inside Card
    LayItems := TLayout.Create(Card); // Attribue une nouvelle valeur a la variable indiquee.
    LayItems.Parent := Card; // Attribue une nouvelle valeur a la variable indiquee.
    LayItems.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    LayItems.Margins.Left := 12; // Attribue une nouvelle valeur a la variable indiquee.
    LayItems.Margins.Top := 4; // Attribue une nouvelle valeur a la variable indiquee.
    LayItems.Margins.Right := 12; // Attribue une nouvelle valeur a la variable indiquee.
    LayItems.Margins.Bottom := 30; // Attribue une nouvelle valeur a la variable indiquee.

    for J := 0 to Q.Items.Count - 1 do // Parcourt les elements ou valeurs de cette boucle.
    begin // Ouvre le bloc d instructions correspondant.
      Item := Q.Items[J]; // Attribue une nouvelle valeur a la variable indiquee.
      LblItem := TLabel.Create(LayItems); // Attribue une nouvelle valeur a la variable indiquee.
      LblItem.Parent := LayItems; // Attribue une nouvelle valeur a la variable indiquee.
      LblItem.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
      LblItem.Height := 18; // Attribue une nouvelle valeur a la variable indiquee.
      LblItem.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
      LblItem.TextSettings.Font.Size := 11; // Attribue une nouvelle valeur a la variable indiquee.
      LblItem.TextSettings.FontColor := COLOR_TEXT_SECONDARY; // Attribue une nouvelle valeur a la variable indiquee.
      if Item.UnitPrice > 0 then // Verifie la condition avant de poursuivre.
        LblItem.Text := Format('• %d x %s (%s)', [Item.Quantity, Item.ProductName, FormatFloat('#,##0.00 DA', Item.UnitPrice)]) // Attribue une nouvelle valeur a la variable indiquee.
      else // Execute la branche alternative de la condition precedente.
        LblItem.Text := Format('• %d x %s (prix sur demande)', [Item.Quantity, Item.ProductName]); // Attribue une nouvelle valeur a la variable indiquee.
    end; // Ferme le bloc ou la declaration en cours.

    // Total Amount at bottom of card
    LblTotal := TLabel.Create(Card); // Attribue une nouvelle valeur a la variable indiquee.
    LblTotal.Parent := Card; // Attribue une nouvelle valeur a la variable indiquee.
    LblTotal.Align := TAlignLayout.Bottom; // Attribue une nouvelle valeur a la variable indiquee.
    LblTotal.Margins.Left := 12; // Attribue une nouvelle valeur a la variable indiquee.
    LblTotal.Margins.Bottom := 8; // Attribue une nouvelle valeur a la variable indiquee.
    LblTotal.Height := 22; // Attribue une nouvelle valeur a la variable indiquee.
    LblTotal.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblTotal.TextSettings.Font.Size := 13; // Attribue une nouvelle valeur a la variable indiquee.
    LblTotal.TextSettings.Font.Style := [TFontStyle.fsBold]; // Attribue une nouvelle valeur a la variable indiquee.
    LblTotal.TextSettings.FontColor := COLOR_PRIMARY; // Attribue une nouvelle valeur a la variable indiquee.
    if Q.Items.HasUnpricedItems then // Verifie la condition avant de poursuivre.
      LblTotal.Text := 'Montant à confirmer après étude du devis' // Attribue une nouvelle valeur a la variable indiquee.
    else // Execute la branche alternative de la condition precedente.
      LblTotal.Text := Format('Montant total estimé : %s', [FormatFloat('#,##0.00 DA', Q.TotalAmount)]); // Attribue une nouvelle valeur a la variable indiquee.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
