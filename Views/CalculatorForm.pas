unit CalculatorForm; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, // Complete la declaration ou instruction en cours.
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, // Complete la declaration ou instruction en cours.
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, FMX.Edit, AppTheme; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Écran de calcul rapide du montant HT, de la remise et du total.
  TFrameCalculator = class(TFrame) // Complete la declaration ou instruction en cours.
    VertScrollBox: TVertScrollBox; // Execute cette instruction dans le flux courant.
    layTitle: TLayout; // Execute cette instruction dans le flux courant.
    lblHeader: TLabel; // Execute cette instruction dans le flux courant.
    layInputContainer: TLayout; // Execute cette instruction dans le flux courant.
    lblPriceHT: TLabel; // Execute cette instruction dans le flux courant.
    edtUnitPrice: TEdit; // Execute cette instruction dans le flux courant.
    lblQty: TLabel; // Execute cette instruction dans le flux courant.
    edtQuantity: TEdit; // Execute cette instruction dans le flux courant.
    lblDiscountPercent: TLabel; // Execute cette instruction dans le flux courant.
    edtDiscountPercent: TEdit; // Execute cette instruction dans le flux courant.
    btnCalculate: TButton; // Execute cette instruction dans le flux courant.
    btnClear: TButton; // Execute cette instruction dans le flux courant.
    rectResultsBox: TRectangle; // Execute cette instruction dans le flux courant.
    lblSubtotalTitle: TLabel; // Execute cette instruction dans le flux courant.
    lblSubtotalValue: TLabel; // Execute cette instruction dans le flux courant.
    lblDiscountTitle: TLabel; // Execute cette instruction dans le flux courant.
    lblDiscountValue: TLabel; // Execute cette instruction dans le flux courant.
    lblTotalTitle: TLabel; // Execute cette instruction dans le flux courant.
    lblTotalValue: TLabel; // Execute cette instruction dans le flux courant.
    procedure btnCalculateClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure btnClearClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
    procedure edtUnitPriceChangeTracking(Sender: TObject); // Declare une procedure de cette unite ou classe.
  private // Complete la declaration ou instruction en cours.
    procedure CalculateTotal; // Declare une procedure de cette unite ou classe.
  public // Complete la declaration ou instruction en cours.
    constructor Create(AOwner: TComponent); override; // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.
    procedure ResetFields; // Declare une procedure de cette unite ou classe.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

{$R *.fmx} // Inclut la ressource FMX de cette unite.

constructor TFrameCalculator.Create(AOwner: TComponent); // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Initialise les valeurs affichées dès la création de l'écran.
  inherited Create(AOwner); // Appelle le comportement correspondant de la classe parente.

  // Titre d'écran aligné sur le design system.
  lblHeader.StyledSettings := [];
  lblHeader.TextSettings.FontColor := COLOR_TEXT_PRIMARY;
  lblHeader.TextSettings.Font.Size := FONT_SIZE_PAGE_TITLE + 1;
  lblHeader.TextSettings.Font.Style := [TFontStyle.fsBold];

  // Libellés de champs discrets et boutons cohérents avec le thème.
  lblPriceHT.StyledSettings := [];
  lblPriceHT.TextSettings.FontColor := COLOR_TEXT_SECONDARY;
  lblQty.StyledSettings := [];
  lblQty.TextSettings.FontColor := COLOR_TEXT_SECONDARY;
  lblDiscountPercent.StyledSettings := [];
  lblDiscountPercent.TextSettings.FontColor := COLOR_TEXT_SECONDARY;

  btnCalculate.StyledSettings := [];
  btnCalculate.TextSettings.FontColor := COLOR_PRIMARY;
  btnCalculate.TextSettings.Font.Style := [TFontStyle.fsBold];

  btnClear.StyledSettings := [];
  btnClear.TextSettings.FontColor := COLOR_TEXT_SECONDARY;

  // Carte de résultats teintée avec le total mis en avant.
  rectResultsBox.Fill.Color := COLOR_PRIMARY_TINT;
  rectResultsBox.Stroke.Color := COLOR_BORDER_LIGHT;
  rectResultsBox.Stroke.Thickness := 1;
  rectResultsBox.XRadius := RADIUS_CARD;
  rectResultsBox.YRadius := RADIUS_CARD;

  lblSubtotalTitle.StyledSettings := [];
  lblSubtotalTitle.TextSettings.FontColor := COLOR_TEXT_SECONDARY;
  lblDiscountTitle.StyledSettings := [];
  lblDiscountTitle.TextSettings.FontColor := COLOR_TEXT_SECONDARY;
  lblSubtotalValue.StyledSettings := [];
  lblSubtotalValue.TextSettings.FontColor := COLOR_TEXT_PRIMARY;
  lblDiscountValue.StyledSettings := [];
  lblDiscountValue.TextSettings.FontColor := COLOR_TEXT_PRIMARY;
  lblTotalTitle.StyledSettings := [];
  lblTotalTitle.TextSettings.FontColor := COLOR_TEXT_PRIMARY;
  lblTotalTitle.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblTotalValue.StyledSettings := [];
  lblTotalValue.TextSettings.FontColor := COLOR_PRIMARY;
  lblTotalValue.TextSettings.Font.Size := 18;
  lblTotalValue.TextSettings.Font.Style := [TFontStyle.fsBold];

  ResetFields; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

destructor TFrameCalculator.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameCalculator.ResetFields; // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Restaure les valeurs par défaut et remet les résultats à zéro.
  edtUnitPrice.Text := '0'; // Attribue une nouvelle valeur a la variable indiquee.
  edtQuantity.Text := '1'; // Attribue une nouvelle valeur a la variable indiquee.
  edtDiscountPercent.Text := '0'; // Attribue une nouvelle valeur a la variable indiquee.
  lblSubtotalValue.Text := '0.00 DA'; // Attribue une nouvelle valeur a la variable indiquee.
  lblDiscountValue.Text := '0.00 DA'; // Attribue une nouvelle valeur a la variable indiquee.
  lblTotalValue.Text := '0.00 DA'; // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameCalculator.btnCalculateClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Recalcule les montants à la demande de l'utilisateur.
  CalculateTotal; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameCalculator.btnClearClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Le bouton Effacer restaure le formulaire à son état initial.
  ResetFields; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameCalculator.edtUnitPriceChangeTracking(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Met à jour les résultats pendant la saisie du prix.
  CalculateTotal; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameCalculator.CalculateTotal; // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  UnitPrice, DiscountPercent, Subtotal, DiscountAmt, Total: Double; // Execute cette instruction dans le flux courant.
  Qty: Integer; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Convertit les champs, borne quantité/remise puis calcule sous-total,
  // économie et total avant de formater les valeurs affichées.
  UnitPrice := StrToFloatDef(Trim(edtUnitPrice.Text), 0.0); // Attribue une nouvelle valeur a la variable indiquee.
  Qty := StrToIntDef(Trim(edtQuantity.Text), 1); // Attribue une nouvelle valeur a la variable indiquee.
  DiscountPercent := StrToFloatDef(Trim(edtDiscountPercent.Text), 0.0); // Attribue une nouvelle valeur a la variable indiquee.

  if Qty < 1 then Qty := 1; // Verifie la condition avant de poursuivre.
  if DiscountPercent < 0 then DiscountPercent := 0; // Verifie la condition avant de poursuivre.
  if DiscountPercent > 100 then DiscountPercent := 100; // Verifie la condition avant de poursuivre.

  Subtotal := UnitPrice * Qty; // Attribue une nouvelle valeur a la variable indiquee.
  DiscountAmt := Subtotal * (DiscountPercent / 100.0); // Attribue une nouvelle valeur a la variable indiquee.
  Total := Subtotal - DiscountAmt; // Attribue une nouvelle valeur a la variable indiquee.

  lblSubtotalValue.Text := FormatFloat('#,##0.00 DA', Subtotal); // Attribue une nouvelle valeur a la variable indiquee.
  lblDiscountValue.Text := FormatFloat('-#,##0.00 DA', DiscountAmt); // Attribue une nouvelle valeur a la variable indiquee.
  lblTotalValue.Text := FormatFloat('#,##0.00 DA', Total); // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
