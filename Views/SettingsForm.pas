unit SettingsForm; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, // Complete la declaration ou instruction en cours.
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, // Complete la declaration ou instruction en cours.
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, FMX.Memo, // Complete la declaration ou instruction en cours.
  AppTheme; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Écran regroupant les informations de l'entreprise et les opérations locales.
  TFrameSettings = class(TFrame) // Complete la declaration ou instruction en cours.
    VertScrollBox: TVertScrollBox; // Execute cette instruction dans le flux courant.
    layLogo: TLayout; // Execute cette instruction dans le flux courant.
    imgLogo: TImage; // Execute cette instruction dans le flux courant.
    layTitle: TLayout; // Execute cette instruction dans le flux courant.
    lblHeader: TLabel; // Execute cette instruction dans le flux courant.
    rectCompanyCard: TRectangle; // Execute cette instruction dans le flux courant.
    lblCompanyName: TLabel; // Execute cette instruction dans le flux courant.
    lblCompanyAddress: TLabel; // Execute cette instruction dans le flux courant.
    lblCompanyPhone: TLabel; // Execute cette instruction dans le flux courant.
    lblCompanyEmail: TLabel; // Execute cette instruction dans le flux courant.
    lblCompanyWeb: TLabel; // Execute cette instruction dans le flux courant.
    layActions: TLayout; // Execute cette instruction dans le flux courant.
    btnSyncCatalog: TButton; // Execute cette instruction dans le flux courant.
    btnResetDB: TButton; // Execute cette instruction dans le flux courant.
    layAppInfo: TLayout; // Execute cette instruction dans le flux courant.
    lblVersion: TLabel; // Execute cette instruction dans le flux courant.
    lblCopyright: TLabel; // Execute cette instruction dans le flux courant.
    procedure btnSyncCatalogClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure btnResetDBClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
  public // Complete la declaration ou instruction en cours.
    constructor Create(AOwner: TComponent); override; // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

uses // Declare les unites dont ce code depend.
  DataModule; // Execute cette instruction dans le flux courant.

{$R *.fmx} // Inclut la ressource FMX de cette unite.

constructor TFrameSettings.Create(AOwner: TComponent); // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Charge le logo si disponible et renseigne les coordonnées affichées.
  inherited Create(AOwner); // Appelle le comportement correspondant de la classe parente.

  // Titre d'écran aligné sur le design system.
  lblHeader.StyledSettings := [];
  lblHeader.TextSettings.FontColor := COLOR_TEXT_PRIMARY;
  lblHeader.TextSettings.Font.Size := FONT_SIZE_PAGE_TITLE + 1;
  lblHeader.TextSettings.Font.Style := [TFontStyle.fsBold];

  // Carte d'entreprise et actions alignées sur le design system.
  rectCompanyCard.Fill.Color := COLOR_SURFACE;
  rectCompanyCard.Stroke.Color := COLOR_BORDER_LIGHT;
  rectCompanyCard.Stroke.Thickness := 1;
  rectCompanyCard.XRadius := RADIUS_CARD;
  rectCompanyCard.YRadius := RADIUS_CARD;

  btnSyncCatalog.StyledSettings := [];
  btnSyncCatalog.TextSettings.FontColor := COLOR_PRIMARY;
  btnSyncCatalog.TextSettings.Font.Style := [TFontStyle.fsBold];
  btnSyncCatalog.Text := '📶 Synchroniser le catalogue (Wi-Fi)';

  btnResetDB.StyledSettings := [];
  btnResetDB.TextSettings.FontColor := COLOR_TEXT_SECONDARY;

  lblCompanyName.StyledSettings := [];
  lblCompanyName.TextSettings.FontColor := COLOR_TEXT_PRIMARY;
  lblCompanyName.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblCompanyAddress.StyledSettings := [];
  lblCompanyAddress.TextSettings.FontColor := COLOR_TEXT_SECONDARY;
  lblCompanyPhone.StyledSettings := [];
  lblCompanyPhone.TextSettings.FontColor := COLOR_TEXT_SECONDARY;
  lblCompanyEmail.StyledSettings := [];
  lblCompanyEmail.TextSettings.FontColor := COLOR_TEXT_SECONDARY;
  lblCompanyWeb.StyledSettings := [];
  lblCompanyWeb.TextSettings.FontColor := COLOR_TEXT_SECONDARY;

  lblVersion.StyledSettings := [];
  lblVersion.TextSettings.FontColor := COLOR_TEXT_MUTED;
  lblCopyright.StyledSettings := [];
  lblCopyright.TextSettings.FontColor := COLOR_TEXT_MUTED;

  // Chargement du logo officiel
  if DM <> nil then // Verifie la condition avant de poursuivre.
    DM.ImageService.LoadIntoImage('logo_ngnex.png', imgLogo); // Appelle la methode ou fonction avec les parametres indiques.

  lblCompanyName.Text := 'NGNEX 08 — Matériel POS & Caisse'; // Attribue une nouvelle valeur a la variable indiquee.
  lblCompanyAddress.Text := '📍 Zone Industrielle, Béchar, Algérie'; // Attribue une nouvelle valeur a la variable indiquee.
  lblCompanyPhone.Text := '📞 +213 (0) 550 08 08 08 / +213 (0) 29 80 08 08'; // Attribue une nouvelle valeur a la variable indiquee.
  lblCompanyEmail.Text := '✉️ contact@ngnex08.dz / support@ngnex08.dz'; // Attribue une nouvelle valeur a la variable indiquee.
  lblCompanyWeb.Text := '🌐 https://ngnex08.dz'; // Attribue une nouvelle valeur a la variable indiquee.
  lblVersion.Text := 'Version : 1.0.0 (Delphi 13 Florence FMX)'; // Attribue une nouvelle valeur a la variable indiquee.
  lblCopyright.Text := '© 2025 NGNEX 08. Tous droits réservés.'; // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

destructor TFrameSettings.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameSettings.btnSyncCatalogClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Lance la requête de catégories et affiche le résultat retourné par le service.
  if DM = nil then Exit; // Verifie la condition avant de poursuivre.

  DM.CategoryService.SyncCategoriesWithServer( // Appelle la methode ou fonction avec les parametres indiques.
    procedure(const ASuccess: Boolean; const AMessage: string) // Appelle la methode ou fonction avec les parametres indiques.
    begin // Ouvre le bloc d instructions correspondant.
      ShowMessage(AMessage); // Appelle la methode ou fonction avec les parametres indiques.
    end); // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameSettings.btnResetDBClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Réinitialise les données de l'appareil après action explicite de l'utilisateur.
  if DM = nil then Exit; // Verifie la condition avant de poursuivre.

  DM.DatabaseService.ResetDatabase; // Execute cette instruction dans le flux courant.
  ShowMessage('Base de données locale réinitialisée avec succès.'); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
