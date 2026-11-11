unit CategoriesForm; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, // Complete la declaration ou instruction en cours.
  System.Math, // Complete la declaration ou instruction en cours.
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, // Complete la declaration ou instruction en cours.
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, // Complete la declaration ou instruction en cours.
  Category, AppTheme; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Callback transmis au formulaire principal lors du choix d'une catégorie.
  TOnCategorySelectEvent = reference to procedure(ACategoryID: Integer); // Execute cette instruction dans le flux courant.

  // Écran qui charge les catégories locales et les présente sous forme de cartes.
  TFrameCategories = class(TFrame) // Complete la declaration ou instruction en cours.
    VertScrollBox: TVertScrollBox; // Execute cette instruction dans le flux courant.
    layTitle: TLayout; // Execute cette instruction dans le flux courant.
    lblHeader: TLabel; // Execute cette instruction dans le flux courant.
    layListContainer: TLayout; // Execute cette instruction dans le flux courant.
  private // Complete la declaration ou instruction en cours.
    FCategoryList: TCategoryList; // Execute cette instruction dans le flux courant.
    FOnCategorySelect: TOnCategorySelectEvent; // Execute cette instruction dans le flux courant.
    procedure RenderCategories; // Declare une procedure de cette unite ou classe.
    procedure OnCardClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
  public // Complete la declaration ou instruction en cours.
    constructor Create(AOwner: TComponent); override; // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.
    procedure RefreshView; // Declare une procedure de cette unite ou classe.

    property OnCategorySelect: TOnCategorySelectEvent read FOnCategorySelect write FOnCategorySelect; // Expose une propriete de la classe.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

uses // Declare les unites dont ce code depend.
  DataModule; // Execute cette instruction dans le flux courant.

{$R *.fmx} // Inclut la ressource FMX de cette unite.

constructor TFrameCategories.Create(AOwner: TComponent); // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Crée une collection propriétaire et affiche immédiatement les données locales.
  inherited Create(AOwner); // Appelle le comportement correspondant de la classe parente.

  // Titre d'écran aligné sur le design system.
  lblHeader.StyledSettings := [];
  lblHeader.TextSettings.FontColor := COLOR_TEXT_PRIMARY;
  lblHeader.TextSettings.Font.Size := FONT_SIZE_PAGE_TITLE + 1;
  lblHeader.TextSettings.Font.Style := [TFontStyle.fsBold];

  FCategoryList := TCategoryList.Create(True); // Attribue une nouvelle valeur a la variable indiquee.
  RefreshView; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

destructor TFrameCategories.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Libère les catégories chargées avant la destruction du cadre.
  FreeAndNil(FCategoryList); // Appelle la methode ou fonction avec les parametres indiques.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameCategories.RefreshView; // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Recharge les catégories puis reconstruit leur représentation visuelle.
  if DM <> nil then // Verifie la condition avant de poursuivre.
    DM.CategoryService.LoadCategories(FCategoryList); // Appelle la methode ou fonction avec les parametres indiques.
  RenderCategories; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameCategories.RenderCategories; // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  I: Integer; // Execute cette instruction dans le flux courant.
  Cat: TCategory; // Execute cette instruction dans le flux courant.
  Card: TRectangle; // Execute cette instruction dans le flux courant.
  LayImgContainer: TLayout; // Execute cette instruction dans le flux courant.
  RectImgBg: TRectangle; // Execute cette instruction dans le flux courant.
  ImgCat: TImage; // Execute cette instruction dans le flux courant.
  LayText: TLayout; // Execute cette instruction dans le flux courant.
  LblName, LblDesc, LblCount, LblArrow: TLabel; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Remplace les contrôles dynamiques existants par une carte pour chaque catégorie.
  while layListContainer.ControlsCount > 0 do // Repete le bloc tant que la condition reste vraie.
    layListContainer.Controls[0].Free; // Execute cette instruction dans le flux courant.
  layListContainer.Height := Max(100, FCategoryList.Count * 115); // Attribue une nouvelle valeur a la variable indiquee.

  for I := 0 to FCategoryList.Count - 1 do // Parcourt les elements ou valeurs de cette boucle.
  begin // Ouvre le bloc d instructions correspondant.
    Cat := FCategoryList[I]; // Attribue une nouvelle valeur a la variable indiquee.

    Card := TRectangle.Create(layListContainer); // Attribue une nouvelle valeur a la variable indiquee.
    Card.Parent := layListContainer; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Height := 105; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Margins.Left := 12; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Margins.Right := 12; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Margins.Bottom := 10; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Fill.Color := COLOR_SURFACE; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Stroke.Color := COLOR_BORDER_LIGHT; // Attribue une nouvelle valeur a la variable indiquee.
    Card.Stroke.Thickness := 1; // Attribue une nouvelle valeur a la variable indiquee.
    Card.XRadius := RADIUS_CARD; // Coins modernes du design system.
    Card.YRadius := RADIUS_CARD; // Coins modernes du design system.
    Card.Tag := Cat.ID; // Attribue une nouvelle valeur a la variable indiquee.
    Card.HitTest := True; // Attribue une nouvelle valeur a la variable indiquee.
    Card.OnClick := OnCardClick; // Attribue une nouvelle valeur a la variable indiquee.

    // Image de la catégorie à gauche
    LayImgContainer := TLayout.Create(Card); // Attribue une nouvelle valeur a la variable indiquee.
    LayImgContainer.Parent := Card; // Attribue une nouvelle valeur a la variable indiquee.
    LayImgContainer.Align := TAlignLayout.Left; // Attribue une nouvelle valeur a la variable indiquee.
    LayImgContainer.Width := 90; // Attribue une nouvelle valeur a la variable indiquee.
    LayImgContainer.Margins.Left := 8; // Attribue une nouvelle valeur a la variable indiquee.
    LayImgContainer.Margins.Top := 8; // Attribue une nouvelle valeur a la variable indiquee.
    LayImgContainer.Margins.Bottom := 8; // Attribue une nouvelle valeur a la variable indiquee.
    LayImgContainer.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    RectImgBg := TRectangle.Create(LayImgContainer); // Attribue une nouvelle valeur a la variable indiquee.
    RectImgBg.Parent := LayImgContainer; // Attribue une nouvelle valeur a la variable indiquee.
    RectImgBg.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    RectImgBg.Fill.Color := COLOR_SURFACE_ALT; // Attribue une nouvelle valeur a la variable indiquee.
    RectImgBg.Stroke.Color := COLOR_BORDER_LIGHT; // Attribue une nouvelle valeur a la variable indiquee.
    RectImgBg.XRadius := RADIUS_SMALL; // Coins de la vignette catégorie.
    RectImgBg.YRadius := RADIUS_SMALL; // Coins de la vignette catégorie.
    RectImgBg.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    ImgCat := TImage.Create(RectImgBg); // Attribue une nouvelle valeur a la variable indiquee.
    ImgCat.Parent := RectImgBg; // Attribue une nouvelle valeur a la variable indiquee.
    ImgCat.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    ImgCat.Margins.Left := 4; // Attribue une nouvelle valeur a la variable indiquee.
    ImgCat.Margins.Top := 4; // Attribue une nouvelle valeur a la variable indiquee.
    ImgCat.Margins.Right := 4; // Attribue une nouvelle valeur a la variable indiquee.
    ImgCat.Margins.Bottom := 4; // Attribue une nouvelle valeur a la variable indiquee.
    ImgCat.WrapMode := TImageWrapMode.Fit; // Attribue une nouvelle valeur a la variable indiquee.
    ImgCat.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    if DM <> nil then // Verifie la condition avant de poursuivre.
      DM.ImageService.LoadIntoImage(Cat.ImageURL, ImgCat); // Appelle la methode ou fonction avec les parametres indiques.

    // Flèche d'accès à droite
    LblArrow := TLabel.Create(Card); // Attribue une nouvelle valeur a la variable indiquee.
    LblArrow.Parent := Card; // Attribue une nouvelle valeur a la variable indiquee.
    LblArrow.Align := TAlignLayout.Right; // Attribue une nouvelle valeur a la variable indiquee.
    LblArrow.Width := 30; // Attribue une nouvelle valeur a la variable indiquee.
    LblArrow.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblArrow.TextSettings.Font.Size := 22;
    LblArrow.TextSettings.Font.Style := [TFontStyle.fsBold]; // Attribue une nouvelle valeur a la variable indiquee.
    LblArrow.TextSettings.FontColor := COLOR_TEXT_MUTED;
    LblArrow.TextSettings.HorzAlign := TTextAlign.Center; // Attribue une nouvelle valeur a la variable indiquee.
    LblArrow.TextSettings.VertAlign := TTextAlign.Center; // Attribue une nouvelle valeur a la variable indiquee.
    LblArrow.Text := '›';
    LblArrow.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    // Zone de texte centrale
    LayText := TLayout.Create(Card); // Attribue une nouvelle valeur a la variable indiquee.
    LayText.Parent := Card; // Attribue une nouvelle valeur a la variable indiquee.
    LayText.Align := TAlignLayout.Client; // Attribue une nouvelle valeur a la variable indiquee.
    LayText.Margins.Left := 10; // Attribue une nouvelle valeur a la variable indiquee.
    LayText.Margins.Top := 10; // Attribue une nouvelle valeur a la variable indiquee.
    LayText.Margins.Right := 4; // Attribue une nouvelle valeur a la variable indiquee.
    LayText.Margins.Bottom := 10; // Attribue une nouvelle valeur a la variable indiquee.
    LayText.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    LblName := TLabel.Create(LayText); // Attribue une nouvelle valeur a la variable indiquee.
    LblName.Parent := LayText; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.Height := 22; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.TextSettings.Font.Size := 13; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.TextSettings.Font.Style := [TFontStyle.fsBold]; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.TextSettings.FontColor := COLOR_TEXT_PRIMARY; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.Text := Cat.Name; // Attribue une nouvelle valeur a la variable indiquee.
    LblName.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    LblDesc := TLabel.Create(LayText); // Attribue une nouvelle valeur a la variable indiquee.
    LblDesc.Parent := LayText; // Attribue une nouvelle valeur a la variable indiquee.
    LblDesc.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LblDesc.Height := 34; // Attribue une nouvelle valeur a la variable indiquee.
    LblDesc.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblDesc.TextSettings.Font.Size := 10; // Attribue une nouvelle valeur a la variable indiquee.
    LblDesc.TextSettings.FontColor := COLOR_TEXT_SECONDARY; // Attribue une nouvelle valeur a la variable indiquee.
    LblDesc.TextSettings.WordWrap := True; // Attribue une nouvelle valeur a la variable indiquee.
    LblDesc.Text := Cat.Description; // Attribue une nouvelle valeur a la variable indiquee.
    LblDesc.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.

    LblCount := TLabel.Create(LayText); // Attribue une nouvelle valeur a la variable indiquee.
    LblCount.Parent := LayText; // Attribue une nouvelle valeur a la variable indiquee.
    LblCount.Align := TAlignLayout.Top; // Attribue une nouvelle valeur a la variable indiquee.
    LblCount.Height := 18; // Attribue une nouvelle valeur a la variable indiquee.
    LblCount.StyledSettings := []; // Attribue une nouvelle valeur a la variable indiquee.
    LblCount.TextSettings.Font.Size := 10; // Attribue une nouvelle valeur a la variable indiquee.
    LblCount.TextSettings.Font.Style := [TFontStyle.fsBold]; // Attribue une nouvelle valeur a la variable indiquee.
    LblCount.TextSettings.FontColor := COLOR_PRIMARY; // Attribue une nouvelle valeur a la variable indiquee.
    LblCount.Text := Format('%d produit(s) disponible(s)', [Cat.ProductCount]); // Attribue une nouvelle valeur a la variable indiquee.
    LblCount.HitTest := False; // Attribue une nouvelle valeur a la variable indiquee.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TFrameCategories.OnCardClick(Sender: TObject); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  CatID: Integer; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Transmet l'identifiant de la carte sélectionnée au formulaire propriétaire.
  CatID := TComponent(Sender).Tag; // Attribue une nouvelle valeur a la variable indiquee.
  if Assigned(FOnCategorySelect) then // Verifie la condition avant de poursuivre.
    FOnCategorySelect(CatID); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
