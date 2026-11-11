unit QuoteForm; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, // Complete la declaration ou instruction en cours.
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, // Complete la declaration ou instruction en cours.
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, FMX.Edit, FMX.Memo, // Complete la declaration ou instruction en cours.
  Customer, Quote, QuoteService, AppTheme, FMX.Memo.Types, FMX.ScrollBox; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Callback signalant qu'un devis local a été créé et transmettant son numéro.
  TOnQuoteSubmittedEvent = reference to procedure(const AQuoteNumber: string); // Execute cette instruction dans le flux courant.

  // Formulaire de coordonnées client et de soumission d'une demande de devis.
  TFrameQuote = class(TFrame) // Complete la declaration ou instruction en cours.
    VertScrollBox: TVertScrollBox; // Execute cette instruction dans le flux courant.
    layTitle: TLayout; // Execute cette instruction dans le flux courant.
    lblHeader: TLabel; // Execute cette instruction dans le flux courant.
    layCustomerForm: TLayout; // Execute cette instruction dans le flux courant.
    lblFullName: TLabel; // Execute cette instruction dans le flux courant.
    edtFullName: TEdit; // Execute cette instruction dans le flux courant.
    lblCompanyName: TLabel; // Execute cette instruction dans le flux courant.
    edtCompanyName: TEdit; // Execute cette instruction dans le flux courant.
    lblPhone: TLabel; // Execute cette instruction dans le flux courant.
    edtPhone: TEdit; // Execute cette instruction dans le flux courant.
    lblEmail: TLabel; // Execute cette instruction dans le flux courant.
    edtEmail: TEdit; // Execute cette instruction dans le flux courant.
    lblAddress: TLabel; // Execute cette instruction dans le flux courant.
    edtAddress: TEdit; // Execute cette instruction dans le flux courant.
    lblNotes: TLabel; // Execute cette instruction dans le flux courant.
    mmoNotes: TMemo; // Execute cette instruction dans le flux courant.
    rectSubmitQuote: TRectangle; // Bouton principal d'envoi du devis.
    lblSubmitQuote: TLabel; // Libellé du bouton principal.
    rectBackHome: TRectangle; // Bouton secondaire de retour à l'accueil.
    lblBackHome: TLabel; // Libellé du bouton secondaire.
    rectSummaryCard: TRectangle; // Carte du récapitulatif de commande.
    lblSummaryTitle: TLabel; // Titre du récapitulatif.
    lblItemsCount: TLabel; // Nombre d'articles sélectionnés.
    lblTotalAmount: TLabel; // Montant estimé du devis.
    layCartSummary: TLayout; // Execute cette instruction dans le flux courant.
    procedure btnSubmitQuoteClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure btnBackHomeClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
  private // Complete la declaration ou instruction en cours.
    FOnQuoteSubmitted: TOnQuoteSubmittedEvent; // Execute cette instruction dans le flux courant.
    FOnBackHome: TNotifyEvent; // Execute cette instruction dans le flux courant.
    procedure LoadCartSummary; // Declare une procedure de cette unite ou classe.
    function ValidateForm: Boolean; // Declare une fonction qui renvoie un resultat.
    procedure ClearForm; // Declare une procedure de cette unite ou classe.
  public // Complete la declaration ou instruction en cours.
    constructor Create(AOwner: TComponent); override; // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.
    procedure RefreshView; // Declare une procedure de cette unite ou classe.

    property OnQuoteSubmitted: TOnQuoteSubmittedEvent // Expose une propriete de la classe.
      read FOnQuoteSubmitted write FOnQuoteSubmitted; // Execute cette instruction dans le flux courant.
    property OnBackHome: TNotifyEvent // Expose une propriete de la classe.
      read FOnBackHome write FOnBackHome; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

uses // Declare les unites dont ce code depend.
  DataModule; // Execute cette instruction dans le flux courant.

{$R *.fmx} // Inclut la ressource FMX de cette unite.

constructor TFrameQuote.Create(AOwner: TComponent); // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Initialise le récapitulatif du panier à l'ouverture du formulaire.
  inherited Create(AOwner); // Appelle le comportement correspondant de la classe parente.

  // --- Thème moderne du formulaire de devis ---
  lblHeader.StyledSettings := [];
  lblHeader.TextSettings.FontColor := COLOR_TEXT_PRIMARY;
  lblHeader.TextSettings.Font.Size := FONT_SIZE_PAGE_TITLE + 1;
  lblHeader.TextSettings.Font.Style := [TFontStyle.fsBold];

  // Carte de récapitulatif teintée, alignée sur le design system.
  rectSummaryCard.Fill.Color := COLOR_PRIMARY_TINT;
  rectSummaryCard.Stroke.Kind := TBrushKind.None;
  rectSummaryCard.XRadius := RADIUS_CARD;
  rectSummaryCard.YRadius := RADIUS_CARD;
  lblSummaryTitle.StyledSettings := [];
  lblSummaryTitle.TextSettings.FontColor := COLOR_TEXT_SECONDARY;
  lblSummaryTitle.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblItemsCount.StyledSettings := [];
  lblItemsCount.TextSettings.FontColor := COLOR_TEXT_SECONDARY;
  lblTotalAmount.StyledSettings := [];
  lblTotalAmount.TextSettings.FontColor := COLOR_PRIMARY;
  lblTotalAmount.TextSettings.Font.Size := 15;

  // Libellés de champs homogènes et discrets.
  lblFullName.StyledSettings := [];
  lblFullName.TextSettings.FontColor := COLOR_TEXT_SECONDARY;
  lblFullName.TextSettings.Font.Size := FONT_SIZE_BODY;
  lblCompanyName.StyledSettings := [];
  lblCompanyName.TextSettings.FontColor := COLOR_TEXT_SECONDARY;
  lblCompanyName.TextSettings.Font.Size := FONT_SIZE_BODY;
  lblPhone.StyledSettings := [];
  lblPhone.TextSettings.FontColor := COLOR_TEXT_SECONDARY;
  lblPhone.TextSettings.Font.Size := FONT_SIZE_BODY;
  lblEmail.StyledSettings := [];
  lblEmail.TextSettings.FontColor := COLOR_TEXT_SECONDARY;
  lblEmail.TextSettings.Font.Size := FONT_SIZE_BODY;
  lblAddress.StyledSettings := [];
  lblAddress.TextSettings.FontColor := COLOR_TEXT_SECONDARY;
  lblAddress.TextSettings.Font.Size := FONT_SIZE_BODY;
  lblNotes.StyledSettings := [];
  lblNotes.TextSettings.FontColor := COLOR_TEXT_SECONDARY;
  lblNotes.TextSettings.Font.Size := FONT_SIZE_BODY;

  // Bouton principal plein et retour discret.
  rectSubmitQuote.Fill.Color := COLOR_ACCENT;
  rectSubmitQuote.Stroke.Kind := TBrushKind.None;
  rectSubmitQuote.XRadius := RADIUS_BUTTON;
  rectSubmitQuote.YRadius := RADIUS_BUTTON;
  lblSubmitQuote.StyledSettings := [];
  lblSubmitQuote.TextSettings.FontColor := COLOR_TEXT_WHITE;
  lblSubmitQuote.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblSubmitQuote.TextSettings.Font.Size := FONT_SIZE_CARD_TITLE + 1;
  rectBackHome.Fill.Color := COLOR_SURFACE;
  rectBackHome.Stroke.Color := COLOR_BORDER_MEDIUM;
  rectBackHome.XRadius := RADIUS_BUTTON;
  rectBackHome.YRadius := RADIUS_BUTTON;
  lblBackHome.StyledSettings := [];
  lblBackHome.TextSettings.FontColor := COLOR_TEXT_SECONDARY;
  lblBackHome.TextSettings.Font.Size := FONT_SIZE_BODY;

  RefreshView; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

destructor TFrameQuote.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameQuote.RefreshView; // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Met à jour les éléments et le montant affichés depuis le panier local.
  LoadCartSummary; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

{ Affiche le nombre de produits et le montant estime du panier. }
procedure TFrameQuote.LoadCartSummary; // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  if DM <> nil then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    lblHeader.Text := 'Demander un devis'; // Attribue une nouvelle valeur a la variable indiquee.
    lblItemsCount.Text := Format('📦 %d article(s) dans votre sélection', // Attribue une nouvelle valeur a la variable indiquee.
      [DM.CartService.TotalQuantity]); // Execute cette instruction dans le flux courant.
    lblTotalAmount.TextSettings.FontColor := COLOR_PRIMARY; // Attribue une nouvelle valeur a la variable indiquee.
    if DM.CartService.Items.HasUnpricedItems then // Verifie la condition avant de poursuivre.
      lblTotalAmount.Text := 'Montant à confirmer après étude du devis' // Attribue une nouvelle valeur a la variable indiquee.
    else // Execute la branche alternative de la condition precedente.
      lblTotalAmount.Text := 'Montant total estimé : ' + // Attribue une nouvelle valeur a la variable indiquee.
        FormatFloat('#,##0.00 DA', DM.CartService.GrandTotal); // Appelle la methode ou fonction avec les parametres indiques.
    lblSubmitQuote.Text := 'Envoyer la demande de devis'; // Attribue une nouvelle valeur a la variable indiquee.
    lblBackHome.Text := 'Retour à l''accueil'; // Attribue une nouvelle valeur a la variable indiquee.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

{ Validation des champs obligatoires et du panier. }
function TFrameQuote.ValidateForm: Boolean; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  Result := False; // Affecte la valeur de retour de la fonction.

  if Trim(edtFullName.Text) = '' then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    ShowMessage('Veuillez saisir votre nom et prénom.'); // Appelle la methode ou fonction avec les parametres indiques.
    edtFullName.SetFocus; // Execute cette instruction dans le flux courant.
    Exit; // Quitte la procedure ou fonction a cet endroit.
  end; // Ferme le bloc ou la declaration en cours.

  if Trim(edtPhone.Text) = '' then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    ShowMessage('Veuillez saisir votre numéro de téléphone.'); // Appelle la methode ou fonction avec les parametres indiques.
    edtPhone.SetFocus; // Execute cette instruction dans le flux courant.
    Exit; // Quitte la procedure ou fonction a cet endroit.
  end; // Ferme le bloc ou la declaration en cours.

  // L’adresse e-mail est facultative, mais doit contenir « @ » si elle est renseignée.
  if (Trim(edtEmail.Text) <> '') and (Pos('@', edtEmail.Text) = 0) then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    ShowMessage('L''adresse e-mail saisie n''est pas valide.'); // Appelle la methode ou fonction avec les parametres indiques.
    edtEmail.SetFocus; // Execute cette instruction dans le flux courant.
    Exit; // Quitte la procedure ou fonction a cet endroit.
  end; // Ferme le bloc ou la declaration en cours.

  if (DM = nil) or (DM.CartService.Items.Count = 0) then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    ShowMessage('Votre panier est vide. ' + // Appelle la methode ou fonction avec les parametres indiques.
      'Veuillez ajouter des produits avant de demander un devis.'); // Execute cette instruction dans le flux courant.
    Exit; // Quitte la procedure ou fonction a cet endroit.
  end; // Ferme le bloc ou la declaration en cours.

  Result := True; // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

{ Vide le formulaire après un envoi réussi. }
procedure TFrameQuote.ClearForm; // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  edtFullName.Text := ''; // Attribue une nouvelle valeur a la variable indiquee.
  edtCompanyName.Text := ''; // Attribue une nouvelle valeur a la variable indiquee.
  edtPhone.Text := ''; // Attribue une nouvelle valeur a la variable indiquee.
  edtEmail.Text := ''; // Attribue une nouvelle valeur a la variable indiquee.
  edtAddress.Text := ''; // Attribue une nouvelle valeur a la variable indiquee.
  mmoNotes.Text := ''; // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameQuote.btnSubmitQuoteClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  Cust: TCustomer; // Execute cette instruction dans le flux courant.
  NewQuote: TQuote; // Execute cette instruction dans le flux courant.
  QuoteNumber: string; // Execute cette instruction dans le flux courant.
  Success: Boolean; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Valide la saisie, sauvegarde le devis sur l'appareil puis tente l'envoi API.
  if not ValidateForm then // Verifie la condition avant de poursuivre.
    Exit; // Quitte la procedure ou fonction a cet endroit.

  NewQuote := nil; // Attribue une nouvelle valeur a la variable indiquee.
  Cust := TCustomer.Create; // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Cust.FullName    := Trim(edtFullName.Text); // Attribue une nouvelle valeur a la variable indiquee.
    Cust.CompanyName := Trim(edtCompanyName.Text); // Attribue une nouvelle valeur a la variable indiquee.
    Cust.Phone       := Trim(edtPhone.Text); // Attribue une nouvelle valeur a la variable indiquee.
    Cust.Email       := Trim(edtEmail.Text); // Attribue une nouvelle valeur a la variable indiquee.
    Cust.Address     := Trim(edtAddress.Text); // Attribue une nouvelle valeur a la variable indiquee.

    // Enregistrement local du devis (SQLite)
    Success := DM.QuoteService.CreateQuoteFromCart( // Attribue une nouvelle valeur a la variable indiquee.
      Cust, DM.CartService.Items, Trim(mmoNotes.Text), NewQuote); // Execute cette instruction dans le flux courant.

    if Success and (NewQuote <> nil) then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      // On garde le numéro avant l'envoi asynchrone.
      QuoteNumber := NewQuote.Number; // Attribue une nouvelle valeur a la variable indiquee.

      // Envoi au serveur (asynchrone).
      // NewQuote est libéré dans le callback pour éviter de le détruire
      // pendant qu'il est encore utilise par le thread d'envoi.
      DM.QuoteService.SubmitQuoteToServer(NewQuote, // Appelle la methode ou fonction avec les parametres indiques.
        TQuoteApiCallback( // Appelle la methode ou fonction avec les parametres indiques.
          procedure(const ASuccess: Boolean; const AMessage: string) // Appelle la methode ou fonction avec les parametres indiques.
          begin // Ouvre le bloc d instructions correspondant.
            try // Ouvre le bloc d instructions correspondant.
              if ASuccess then // Verifie la condition avant de poursuivre.
                ShowMessage('Votre demande de devis n° ' + QuoteNumber + // Appelle la methode ou fonction avec les parametres indiques.
                  ' a été transmise au serveur.') // Complete la declaration ou instruction en cours.
              else // Execute la branche alternative de la condition precedente.
                ShowMessage('Votre demande de devis n° ' + QuoteNumber + // Appelle la methode ou fonction avec les parametres indiques.
                  ' est enregistrée sur ce téléphone, mais le serveur ne l''a pas reçue.' + // Complete la declaration ou instruction en cours.
                  sLineBreak + AMessage); // Execute cette instruction dans le flux courant.
            finally // Ouvre le nettoyage garanti meme apres une exception.
              NewQuote.Free; // Execute cette instruction dans le flux courant.
            end; // Ferme le bloc ou la declaration en cours.
          end)); // Ferme le bloc ou la declaration en cours.

      ShowMessage('Demande de devis enregistrée sur ce téléphone. Envoi au serveur en cours...'); // Appelle la methode ou fonction avec les parametres indiques.

      DM.CartService.ClearCart; // Execute cette instruction dans le flux courant.
      ClearForm; // Execute cette instruction dans le flux courant.
      LoadCartSummary; // Execute cette instruction dans le flux courant.

      if Assigned(FOnQuoteSubmitted) then // Verifie la condition avant de poursuivre.
        FOnQuoteSubmitted(QuoteNumber); // Appelle la methode ou fonction avec les parametres indiques.
    end // Ferme le bloc ou la declaration en cours.
    else // Execute la branche alternative de la condition precedente.
      ShowMessage('Erreur lors de l''enregistrement de la demande de devis.'); // Appelle la methode ou fonction avec les parametres indiques.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Cust.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameQuote.btnBackHomeClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Délègue la navigation de retour au formulaire principal.
  if Assigned(FOnBackHome) then // Verifie la condition avant de poursuivre.
    FOnBackHome(Self); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
