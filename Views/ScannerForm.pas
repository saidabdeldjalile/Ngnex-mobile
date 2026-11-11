unit ScannerForm; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, // Complete la declaration ou instruction en cours.
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, // Complete la declaration ou instruction en cours.
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, FMX.Edit, FMX.Media, // Complete la declaration ou instruction en cours.
  Product, ProductService, AppTheme; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Retourne le produit trouvé au formulaire principal pour afficher son détail.
  TOnScannerProductFoundEvent = reference to procedure(AProduct: TProduct); // Execute cette instruction dans le flux courant.

  // Écran de lecture caméra et de recherche manuelle par code-barres/référence.
  TFrameScanner = class(TFrame) // Complete la declaration ou instruction en cours.
    VertScrollBox: TVertScrollBox; // Execute cette instruction dans le flux courant.
    layTitle: TLayout; // Execute cette instruction dans le flux courant.
    lblHeader: TLabel; // Execute cette instruction dans le flux courant.
    rectCameraBox: TRectangle; // Execute cette instruction dans le flux courant.
    lblCameraHint: TLabel; // Execute cette instruction dans le flux courant.
    layManualInput: TLayout; // Execute cette instruction dans le flux courant.
    lblManualTitle: TLabel; // Execute cette instruction dans le flux courant.
    edtBarcodeManual: TEdit; // Execute cette instruction dans le flux courant.
    btnSearchManual: TButton; // Execute cette instruction dans le flux courant.
    btnStartCamera: TButton; // Execute cette instruction dans le flux courant.
    btnStopCamera: TButton; // Execute cette instruction dans le flux courant.
    lblStatus: TLabel; // Execute cette instruction dans le flux courant.
    procedure btnStartCameraClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure btnStopCameraClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure btnSearchManualClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
  private // Complete la declaration ou instruction en cours.
    FOnProductFound: TOnScannerProductFoundEvent; // Execute cette instruction dans le flux courant.
    procedure ProcessBarcode(const ABarcode: string); // Declare une procedure de cette unite ou classe.
  public // Complete la declaration ou instruction en cours.
    constructor Create(AOwner: TComponent); override; // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.

    property OnProductFound: TOnScannerProductFoundEvent read FOnProductFound write FOnProductFound; // Expose une propriete de la classe.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

uses // Declare les unites dont ce code depend.
  DataModule; // Execute cette instruction dans le flux courant.

{$R *.fmx} // Inclut la ressource FMX de cette unite.

constructor TFrameScanner.Create(AOwner: TComponent); // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Affiche l'état initial sans activer la caméra.
  inherited Create(AOwner); // Appelle le comportement correspondant de la classe parente.

  // Titre et cadre caméra alignés sur le design system.
  lblHeader.StyledSettings := [];
  lblHeader.TextSettings.FontColor := COLOR_TEXT_PRIMARY;
  lblHeader.TextSettings.Font.Size := FONT_SIZE_PAGE_TITLE + 1;
  lblHeader.TextSettings.Font.Style := [TFontStyle.fsBold];
  rectCameraBox.XRadius := RADIUS_CARD;
  rectCameraBox.YRadius := RADIUS_CARD;
  rectCameraBox.Stroke.Color := COLOR_BORDER_LIGHT;
  rectCameraBox.Stroke.Thickness := 1;

  // Boutons et libellés secondaires alignés sur le design system.
  btnStartCamera.StyledSettings := [];
  btnStartCamera.TextSettings.FontColor := COLOR_PRIMARY;
  btnStartCamera.TextSettings.Font.Style := [TFontStyle.fsBold];

  btnStopCamera.StyledSettings := [];
  btnStopCamera.TextSettings.FontColor := COLOR_TEXT_SECONDARY;

  btnSearchManual.StyledSettings := [];
  btnSearchManual.TextSettings.FontColor := COLOR_PRIMARY;
  btnSearchManual.TextSettings.Font.Style := [TFontStyle.fsBold];

  lblCameraHint.StyledSettings := [];
  lblCameraHint.TextSettings.FontColor := COLOR_TEXT_MUTED;

  lblManualTitle.StyledSettings := [];
  lblManualTitle.TextSettings.FontColor := COLOR_TEXT_PRIMARY;
  lblManualTitle.TextSettings.Font.Style := [TFontStyle.fsBold];

  lblStatus.StyledSettings := [];
  lblStatus.TextSettings.FontColor := COLOR_TEXT_SECONDARY;
  lblStatus.TextSettings.HorzAlign := TTextAlign.Center;

  lblStatus.Text := 'Prêt à scanner un code-barres'; // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

destructor TFrameScanner.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Libère la caméra même si l'utilisateur quitte l'écran pendant un scan.
  if (DM <> nil) and (DM.BarcodeService <> nil) then // Verifie la condition avant de poursuivre.
    DM.BarcodeService.StopScanning; // Execute cette instruction dans le flux courant.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameScanner.btnStartCameraClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Demande l'activation du service caméra et affiche explicitement tout échec.
  if (DM = nil) or (DM.BarcodeService = nil) then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    lblStatus.Text := 'Le service de scan est indisponible.'; // Attribue une nouvelle valeur a la variable indiquee.
    Exit; // Quitte la procedure ou fonction a cet endroit.
  end; // Ferme le bloc ou la declaration en cours.

  lblStatus.Text := 'Demande d''accès à la caméra…'; // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    DM.BarcodeService.StartScanning( // Appelle la methode ou fonction avec les parametres indiques.
      procedure(Sender: TObject; const ABarcode: string) // Appelle la methode ou fonction avec les parametres indiques.
      begin // Ouvre le bloc d instructions correspondant.
        ProcessBarcode(ABarcode); // Appelle la methode ou fonction avec les parametres indiques.
      end); // Ferme le bloc ou la declaration en cours.
    lblStatus.Text := 'Visez le code-barres avec la caméra.'; // Attribue une nouvelle valeur a la variable indiquee.
  except // Ouvre le traitement des exceptions du bloc protege.
    on E: Exception do // Associe ce cas au traitement d exception indique.
    begin // Ouvre le bloc d instructions correspondant.
      lblStatus.Text := 'Impossible d''activer la caméra.'; // Attribue une nouvelle valeur a la variable indiquee.
      ShowMessage('Impossible d''activer la caméra : ' + E.Message); // Appelle la methode ou fonction avec les parametres indiques.
    end; // Ferme le bloc ou la declaration en cours.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameScanner.btnStopCameraClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Arrête le capteur et met à jour le statut de l'écran.
  if DM <> nil then // Verifie la condition avant de poursuivre.
    DM.BarcodeService.StopScanning; // Execute cette instruction dans le flux courant.
  lblStatus.Text := 'Caméra arrêtée.'; // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameScanner.btnSearchManualClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Valide le champ manuel avant de lancer la même recherche que le scan.
  if Trim(edtBarcodeManual.Text) = '' then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    ShowMessage('Veuillez saisir un code-barres ou une référence.'); // Appelle la methode ou fonction avec les parametres indiques.
    Exit; // Quitte la procedure ou fonction a cet endroit.
  end; // Ferme le bloc ou la declaration en cours.

  ProcessBarcode(Trim(edtBarcodeManual.Text)); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameScanner.ProcessBarcode(const ABarcode: string); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  Prod: TProduct; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Cherche d'abord dans SQLite, puis interroge l'API si le catalogue local
  // ne contient pas le code demandé.
  if DM = nil then Exit; // Verifie la condition avant de poursuivre.

  lblStatus.Text := 'Recherche du produit ' + ABarcode + '…'; // Attribue une nouvelle valeur a la variable indiquee.
  Prod := TProduct.Create; // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    // 1. Search locally in SQLite
    if DM.ProductService.FindByBarcode(ABarcode, Prod) then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      lblStatus.Text := 'Produit trouvé.'; // Attribue une nouvelle valeur a la variable indiquee.
      if Assigned(FOnProductFound) then // Verifie la condition avant de poursuivre.
        FOnProductFound(Prod); // Appelle la methode ou fonction avec les parametres indiques.
    end // Ferme le bloc ou la declaration en cours.
    else // Execute la branche alternative de la condition precedente.
    begin // Ouvre le bloc d instructions correspondant.
      lblStatus.Text := 'Recherche auprès du serveur NGNEX…'; // Attribue une nouvelle valeur a la variable indiquee.
      DM.ProductService.FetchRemoteBarcode(ABarcode, TBarcodeApiCallback( // Appelle la methode ou fonction avec les parametres indiques.
        procedure(const ASuccess: Boolean; const ARemoteProduct: TProduct; const AError: string) // Appelle la methode ou fonction avec les parametres indiques.
        begin // Ouvre le bloc d instructions correspondant.
          if ASuccess and (ARemoteProduct <> nil) then // Verifie la condition avant de poursuivre.
          begin // Ouvre le bloc d instructions correspondant.
            lblStatus.Text := 'Produit trouvé en ligne.'; // Attribue une nouvelle valeur a la variable indiquee.
            if Assigned(FOnProductFound) then // Verifie la condition avant de poursuivre.
              FOnProductFound(ARemoteProduct); // Appelle la methode ou fonction avec les parametres indiques.
            ARemoteProduct.Free; // Execute cette instruction dans le flux courant.
          end // Ferme le bloc ou la declaration en cours.
          else // Execute la branche alternative de la condition precedente.
          begin // Ouvre le bloc d instructions correspondant.
            lblStatus.Text := 'Aucun produit correspondant au code : ' + ABarcode; // Attribue une nouvelle valeur a la variable indiquee.
            ShowMessage('Code-barres non reconnu : ' + ABarcode + #13#10 + // Appelle la methode ou fonction avec les parametres indiques.
              'Aucun produit correspondant n''a été trouvé dans la base locale.'); // Execute cette instruction dans le flux courant.
          end; // Ferme le bloc ou la declaration en cours.
        end)); // Ferme le bloc ou la declaration en cours.
    end; // Ferme le bloc ou la declaration en cours.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Prod.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
