unit Product; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Modèle métier d'un produit du catalogue local ou distant.
  TProduct = class // Complete la declaration ou instruction en cours.
  private // Complete la declaration ou instruction en cours.
    FID: Integer; // Execute cette instruction dans le flux courant.
    FCategoryID: Integer; // Execute cette instruction dans le flux courant.
    FCategoryName: string; // Execute cette instruction dans le flux courant.
    FName: string; // Execute cette instruction dans le flux courant.
    FReference: string; // Execute cette instruction dans le flux courant.
    FBarcode: string; // Execute cette instruction dans le flux courant.
    FDescription: string; // Execute cette instruction dans le flux courant.
    FPrice: Double; // Execute cette instruction dans le flux courant.
    FStock: Integer; // Execute cette instruction dans le flux courant.
    FImageURL: string; // Execute cette instruction dans le flux courant.
    FTechnicalSpecs: string; // Execute cette instruction dans le flux courant.
    FUpdatedAt: TDateTime; // Execute cette instruction dans le flux courant.
    function GetIsAvailable: Boolean; // Declare une fonction qui renvoie un resultat.
  public // Complete la declaration ou instruction en cours.
    constructor Create; // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.

    function ToJSONObject: TJSONObject; // Declare une fonction qui renvoie un resultat.
    procedure FromJSONObject(AJSONObj: TJSONObject); // Declare une procedure de cette unite ou classe.
    function Clone: TProduct; // Declare une fonction qui renvoie un resultat.

    property ID: Integer read FID write FID; // Expose une propriete de la classe.
    property CategoryID: Integer read FCategoryID write FCategoryID; // Expose une propriete de la classe.
    property CategoryName: string read FCategoryName write FCategoryName; // Expose une propriete de la classe.
    property Name: string read FName write FName; // Expose une propriete de la classe.
    property Reference: string read FReference write FReference; // Expose une propriete de la classe.
    property Barcode: string read FBarcode write FBarcode; // Expose une propriete de la classe.
    property Description: string read FDescription write FDescription; // Expose une propriete de la classe.
    property Price: Double read FPrice write FPrice; // Expose une propriete de la classe.
    property Stock: Integer read FStock write FStock; // Expose une propriete de la classe.
    property ImageURL: string read FImageURL write FImageURL; // Expose une propriete de la classe.
    property TechnicalSpecs: string read FTechnicalSpecs write FTechnicalSpecs; // Expose une propriete de la classe.
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt; // Expose une propriete de la classe.
    property IsAvailable: Boolean read GetIsAvailable; // Expose une propriete de la classe.
  end; // Ferme le bloc ou la declaration en cours.

  TProductList = class(TObjectList<TProduct>) // Complete la declaration ou instruction en cours.
  public // Complete la declaration ou instruction en cours.
    // Outils de conversion des collections utilisées par les endpoints JSON.
    function ToJSONArray: TJSONArray; // Declare une fonction qui renvoie un resultat.
    procedure FromJSONArray(AJSONArray: TJSONArray); // Declare une procedure de cette unite ou classe.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

{ TProduct }

constructor TProduct.Create; // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Initialise les champs du produit à des valeurs sûres avant son chargement.
  inherited Create; // Appelle le comportement correspondant de la classe parente.
  FID := 0; // Attribue une nouvelle valeur a la variable indiquee.
  FCategoryID := 0; // Attribue une nouvelle valeur a la variable indiquee.
  FCategoryName := ''; // Attribue une nouvelle valeur a la variable indiquee.
  FName := ''; // Attribue une nouvelle valeur a la variable indiquee.
  FReference := ''; // Attribue une nouvelle valeur a la variable indiquee.
  FBarcode := ''; // Attribue une nouvelle valeur a la variable indiquee.
  FDescription := ''; // Attribue une nouvelle valeur a la variable indiquee.
  FPrice := 0.0; // Attribue une nouvelle valeur a la variable indiquee.
  FStock := 0; // Attribue une nouvelle valeur a la variable indiquee.
  FImageURL := ''; // Attribue une nouvelle valeur a la variable indiquee.
  FTechnicalSpecs := ''; // Attribue une nouvelle valeur a la variable indiquee.
  FUpdatedAt := Now; // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

destructor TProduct.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

function TProduct.GetIsAvailable: Boolean; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // L'application considère disponible un produit dont le stock est positif.
  Result := FStock > 0; // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

function TProduct.Clone: TProduct; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Crée une copie indépendante, notamment utilisée par les éléments du panier.
  Result := TProduct.Create; // Affecte la valeur de retour de la fonction.
  Result.FID := FID; // Attribue une nouvelle valeur a la variable indiquee.
  Result.FCategoryID := FCategoryID; // Attribue une nouvelle valeur a la variable indiquee.
  Result.FCategoryName := FCategoryName; // Attribue une nouvelle valeur a la variable indiquee.
  Result.FName := FName; // Attribue une nouvelle valeur a la variable indiquee.
  Result.FReference := FReference; // Attribue une nouvelle valeur a la variable indiquee.
  Result.FBarcode := FBarcode; // Attribue une nouvelle valeur a la variable indiquee.
  Result.FDescription := FDescription; // Attribue une nouvelle valeur a la variable indiquee.
  Result.FPrice := FPrice; // Attribue une nouvelle valeur a la variable indiquee.
  Result.FStock := FStock; // Attribue une nouvelle valeur a la variable indiquee.
  Result.FImageURL := FImageURL; // Attribue une nouvelle valeur a la variable indiquee.
  Result.FTechnicalSpecs := FTechnicalSpecs; // Attribue une nouvelle valeur a la variable indiquee.
  Result.FUpdatedAt := FUpdatedAt; // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

function TProduct.ToJSONObject: TJSONObject; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Produit la structure JSON partagée avec l'API.
  Result := TJSONObject.Create; // Affecte la valeur de retour de la fonction.
  Result.AddPair('id', TJSONNumber.Create(FID)); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('category_id', TJSONNumber.Create(FCategoryID)); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('category_name', FCategoryName); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('nom', FName); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('reference', FReference); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('barcode', FBarcode); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('description', FDescription); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('prix', TJSONNumber.Create(FPrice)); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('stock', TJSONNumber.Create(FStock)); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('image_url', FImageURL); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('caracteristiques', FTechnicalSpecs); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('updated_at', FormatDateTime('yyyy-mm-dd hh:nn:ss', FUpdatedAt)); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TProduct.FromJSONObject(AJSONObj: TJSONObject); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  Val: TJSONValue; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Copie les champs connus lorsqu'ils existent dans la réponse.
  if AJSONObj = nil then Exit; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('id'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FID := Val.AsType<Integer>; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('category_id'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FCategoryID := Val.AsType<Integer>; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('category_name'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FCategoryName := Val.Value; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('nom'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FName := Val.Value; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('reference'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FReference := Val.Value; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('barcode'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FBarcode := Val.Value; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('description'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FDescription := Val.Value; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('prix'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FPrice := Val.AsType<Double>; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('stock'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FStock := Val.AsType<Integer>; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('image_url'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FImageURL := Val.Value; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('caracteristiques'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FTechnicalSpecs := Val.Value; // Verifie la condition avant de poursuivre.
end; // Ferme le bloc ou la declaration en cours.

{ TProductList }

function TProductList.ToJSONArray: TJSONArray; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Item: TProduct; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Convertit chaque modèle produit en objet du tableau JSON retourné.
  Result := TJSONArray.Create; // Affecte la valeur de retour de la fonction.
  for Item in Self do // Parcourt les elements ou valeurs de cette boucle.
    Result.AddElement(Item.ToJSONObject); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TProductList.FromJSONArray(AJSONArray: TJSONArray); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  I: Integer; // Execute cette instruction dans le flux courant.
  Obj: TJSONObject; // Execute cette instruction dans le flux courant.
  Prod: TProduct; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Remplace le contenu de la liste et ignore les éléments JSON non objets.
  Clear; // Execute cette instruction dans le flux courant.
  if AJSONArray = nil then Exit; // Verifie la condition avant de poursuivre.

  for I := 0 to AJSONArray.Count - 1 do // Parcourt les elements ou valeurs de cette boucle.
  begin // Ouvre le bloc d instructions correspondant.
    if AJSONArray.Items[I] is TJSONObject then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      Obj := TJSONObject(AJSONArray.Items[I]); // Attribue une nouvelle valeur a la variable indiquee.
      Prod := TProduct.Create; // Attribue une nouvelle valeur a la variable indiquee.
      Prod.FromJSONObject(Obj); // Appelle la methode ou fonction avec les parametres indiques.
      Add(Prod); // Appelle la methode ou fonction avec les parametres indiques.
    end; // Ferme le bloc ou la declaration en cours.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
