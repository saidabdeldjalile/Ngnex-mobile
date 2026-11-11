unit CompareForm; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, // Complete la declaration ou instruction en cours.
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, // Complete la declaration ou instruction en cours.
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, FMX.ListBox, FMX.Memo, // Complete la declaration ou instruction en cours.
  Product, AppTheme, FMX.Memo.Types, FMX.ScrollBox; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Écran de comparaison de deux produits du catalogue.
  TFrameCompare = class(TFrame) // Complete la declaration ou instruction en cours.
    VertScrollBox: TVertScrollBox; // Execute cette instruction dans le flux courant.
    layTitle: TLayout; // Execute cette instruction dans le flux courant.
    lblHeader: TLabel; // Execute cette instruction dans le flux courant.
    laySelectors: TLayout; // Execute cette instruction dans le flux courant.
    cmbProd1: TComboBox; // Execute cette instruction dans le flux courant.
    cmbProd2: TComboBox; // Execute cette instruction dans le flux courant.
    btnCompare: TButton; // Execute cette instruction dans le flux courant.
    layImagesCompare: TGridPanelLayout; // Execute cette instruction dans le flux courant.
    imgCompareP1: TImage; // Execute cette instruction dans le flux courant.
    imgCompareP2: TImage; // Execute cette instruction dans le flux courant.
    layResultGrid: TGridPanelLayout; // Execute cette instruction dans le flux courant.
    lblHeaderP1: TLabel; // Execute cette instruction dans le flux courant.
    lblHeaderP2: TLabel; // Execute cette instruction dans le flux courant.
    lblPriceP1: TLabel; // Execute cette instruction dans le flux courant.
    lblPriceP2: TLabel; // Execute cette instruction dans le flux courant.
    lblRefP1: TLabel; // Execute cette instruction dans le flux courant.
    lblRefP2: TLabel; // Execute cette instruction dans le flux courant.
    lblStockP1: TLabel; // Execute cette instruction dans le flux courant.
    lblStockP2: TLabel; // Execute cette instruction dans le flux courant.
    mmoSpecsP1: TMemo; // Execute cette instruction dans le flux courant.
    mmoSpecsP2: TMemo; // Execute cette instruction dans le flux courant.
    procedure btnCompareClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
  private // Complete la declaration ou instruction en cours.
    FAllProducts: TProductList; // Execute cette instruction dans le flux courant.
    procedure LoadProductList; // Declare une procedure de cette unite ou classe.
    procedure DoCompare; // Declare une procedure de cette unite ou classe.
  public // Complete la declaration ou instruction en cours.
    constructor Create(AOwner: TComponent); override; // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.
    procedure SetProductsToCompare(AP1_ID, AP2_ID: Integer); // Declare une procedure de cette unite ou classe.
    procedure RefreshView; // Declare une procedure de cette unite ou classe.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

uses // Declare les unites dont ce code depend.
  DataModule; // Execute cette instruction dans le flux courant.

{$R *.fmx} // Inclut la ressource FMX de cette unite.

constructor TFrameCompare.Create(AOwner: TComponent); // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Prépare la liste possédée par le cadre puis charge les produits disponibles.
  inherited Create(AOwner); // Appelle le comportement correspondant de la classe parente.

  // Titre d'écran aligné sur le design system.
  lblHeader.StyledSettings := [];
  lblHeader.TextSettings.FontColor := COLOR_TEXT_PRIMARY;
  lblHeader.TextSettings.Font.Size := FONT_SIZE_PAGE_TITLE + 1;
  lblHeader.TextSettings.Font.Style := [TFontStyle.fsBold];

  // Bouton de comparaison et en-têtes de colonnes alignés sur le thème.
  btnCompare.StyledSettings := [];
  btnCompare.TextSettings.FontColor := COLOR_PRIMARY;
  btnCompare.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblHeaderP1.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblHeaderP2.TextSettings.Font.Style := [TFontStyle.fsBold];

  FAllProducts := TProductList.Create(True); // Attribue une nouvelle valeur a la variable indiquee.
  RefreshView; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

destructor TFrameCompare.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Libère les modèles produits utilisés par les sélecteurs.
  FreeAndNil(FAllProducts); // Appelle la methode ou fonction avec les parametres indiques.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameCompare.RefreshView; // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Actualise les options proposées dans les deux sélecteurs.
  LoadProductList; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameCompare.LoadProductList; // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  I: Integer; // Execute cette instruction dans le flux courant.
  Prod: TProduct; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Recharge le catalogue, remplit les sélecteurs et affiche une comparaison initiale.
  cmbProd1.Items.Clear; // Execute cette instruction dans le flux courant.
  cmbProd2.Items.Clear; // Execute cette instruction dans le flux courant.

  if DM <> nil then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    DM.ProductService.FetchProducts(FAllProducts); // Appelle la methode ou fonction avec les parametres indiques.
    for I := 0 to FAllProducts.Count - 1 do // Parcourt les elements ou valeurs de cette boucle.
    begin // Ouvre le bloc d instructions correspondant.
      Prod := FAllProducts[I]; // Attribue une nouvelle valeur a la variable indiquee.
      cmbProd1.Items.AddObject(Prod.Name, TObject(IntPtr(Prod.ID))); // Appelle la methode ou fonction avec les parametres indiques.
      cmbProd2.Items.AddObject(Prod.Name, TObject(IntPtr(Prod.ID))); // Appelle la methode ou fonction avec les parametres indiques.
    end; // Ferme le bloc ou la declaration en cours.
  end; // Ferme le bloc ou la declaration en cours.

  if cmbProd1.Items.Count > 0 then cmbProd1.ItemIndex := 0; // Verifie la condition avant de poursuivre.
  if cmbProd2.Items.Count > 1 then cmbProd2.ItemIndex := 1 // Verifie la condition avant de poursuivre.
  else if cmbProd2.Items.Count > 0 then cmbProd2.ItemIndex := 0; // Execute la branche alternative de la condition precedente.

  DoCompare; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameCompare.SetProductsToCompare(AP1_ID, AP2_ID: Integer); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  I: Integer; // Execute cette instruction dans le flux courant.
  ID: Integer; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Sélectionne les deux produits reçus en paramètre, puis actualise le résultat.
  for I := 0 to cmbProd1.Items.Count - 1 do // Parcourt les elements ou valeurs de cette boucle.
  begin // Ouvre le bloc d instructions correspondant.
    ID := Integer(IntPtr(cmbProd1.Items.Objects[I])); // Attribue une nouvelle valeur a la variable indiquee.
    if ID = AP1_ID then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      cmbProd1.ItemIndex := I; // Attribue une nouvelle valeur a la variable indiquee.
      Break; // Execute cette instruction dans le flux courant.
    end; // Ferme le bloc ou la declaration en cours.
  end; // Ferme le bloc ou la declaration en cours.

  for I := 0 to cmbProd2.Items.Count - 1 do // Parcourt les elements ou valeurs de cette boucle.
  begin // Ouvre le bloc d instructions correspondant.
    ID := Integer(IntPtr(cmbProd2.Items.Objects[I])); // Attribue une nouvelle valeur a la variable indiquee.
    if ID = AP2_ID then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      cmbProd2.ItemIndex := I; // Attribue une nouvelle valeur a la variable indiquee.
      Break; // Execute cette instruction dans le flux courant.
    end; // Ferme le bloc ou la declaration en cours.
  end; // Ferme le bloc ou la declaration en cours.

  DoCompare; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameCompare.btnCompareClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Le bouton relance l'affichage avec les sélections courantes.
  DoCompare; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameCompare.DoCompare; // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  P1_ID, P2_ID: Integer; // Execute cette instruction dans le flux courant.
  Prod1, Prod2: TProduct; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Charge les deux modèles sélectionnés et présente côte à côte leurs données.
  if (cmbProd1.ItemIndex < 0) or (cmbProd2.ItemIndex < 0) or (DM = nil) then Exit; // Verifie la condition avant de poursuivre.

  P1_ID := Integer(IntPtr(cmbProd1.Items.Objects[cmbProd1.ItemIndex])); // Attribue une nouvelle valeur a la variable indiquee.
  P2_ID := Integer(IntPtr(cmbProd2.Items.Objects[cmbProd2.ItemIndex])); // Attribue une nouvelle valeur a la variable indiquee.

  Prod1 := TProduct.Create; // Attribue une nouvelle valeur a la variable indiquee.
  Prod2 := TProduct.Create; // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    if DM.ProductService.GetProductByID(P1_ID, Prod1) then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      lblHeaderP1.Text := Prod1.Name; // Attribue une nouvelle valeur a la variable indiquee.
      if Prod1.Price > 0 then // Verifie la condition avant de poursuivre.
        lblPriceP1.Text := FormatFloat('#,##0.00 DA', Prod1.Price) // Attribue une nouvelle valeur a la variable indiquee.
      else // Execute la branche alternative de la condition precedente.
        lblPriceP1.Text := 'Sur devis'; // Libellé court et cohérent avec le catalogue.
      lblRefP1.Text := 'Réf. : ' + Prod1.Reference; // Attribue une nouvelle valeur a la variable indiquee.
      if Prod1.Price <= 0 then lblStockP1.Text := 'Stock à confirmer' // Verifie la condition avant de poursuivre.
      else if Prod1.IsAvailable then lblStockP1.Text := Format('✓ En Stock (%d)', [Prod1.Stock]) // Execute la branche alternative de la condition precedente.
      else lblStockP1.Text := '⚠ Sur commande'; // Execute la branche alternative de la condition precedente.
      mmoSpecsP1.Text := StringReplace(Prod1.TechnicalSpecs, '|', #13#10, [rfReplaceAll]); // Attribue une nouvelle valeur a la variable indiquee.
      DM.ImageService.LoadIntoImage(Prod1.ImageURL, imgCompareP1); // Appelle la methode ou fonction avec les parametres indiques.
    end; // Ferme le bloc ou la declaration en cours.

    if DM.ProductService.GetProductByID(P2_ID, Prod2) then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      lblHeaderP2.Text := Prod2.Name; // Attribue une nouvelle valeur a la variable indiquee.
      if Prod2.Price > 0 then // Verifie la condition avant de poursuivre.
        lblPriceP2.Text := FormatFloat('#,##0.00 DA', Prod2.Price) // Attribue une nouvelle valeur a la variable indiquee.
      else // Execute la branche alternative de la condition precedente.
        lblPriceP2.Text := 'Sur devis'; // Libellé court et cohérent avec le catalogue.
      lblRefP2.Text := 'Réf. : ' + Prod2.Reference; // Attribue une nouvelle valeur a la variable indiquee.
      if Prod2.Price <= 0 then lblStockP2.Text := 'Stock à confirmer' // Verifie la condition avant de poursuivre.
      else if Prod2.IsAvailable then lblStockP2.Text := Format('✓ En Stock (%d)', [Prod2.Stock]) // Execute la branche alternative de la condition precedente.
      else lblStockP2.Text := '⚠ Sur commande'; // Execute la branche alternative de la condition precedente.
      mmoSpecsP2.Text := StringReplace(Prod2.TechnicalSpecs, '|', #13#10, [rfReplaceAll]); // Attribue une nouvelle valeur a la variable indiquee.
      DM.ImageService.LoadIntoImage(Prod2.ImageURL, imgCompareP2); // Appelle la methode ou fonction avec les parametres indiques.
    end; // Ferme le bloc ou la declaration en cours.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Prod1.Free; // Execute cette instruction dans le flux courant.
    Prod2.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
