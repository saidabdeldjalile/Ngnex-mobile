unit Category; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Données d'une catégorie du catalogue, y compris son compteur de produits.
  TCategory = class // Complete la declaration ou instruction en cours.
  private // Complete la declaration ou instruction en cours.
    FID: Integer; // Execute cette instruction dans le flux courant.
    FName: string; // Execute cette instruction dans le flux courant.
    FDescription: string; // Execute cette instruction dans le flux courant.
    FImageURL: string; // Execute cette instruction dans le flux courant.
    FProductCount: Integer; // Execute cette instruction dans le flux courant.
  public // Complete la declaration ou instruction en cours.
    constructor Create; // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.

    function ToJSONObject: TJSONObject; // Declare une fonction qui renvoie un resultat.
    procedure FromJSONObject(AJSONObj: TJSONObject); // Declare une procedure de cette unite ou classe.

    property ID: Integer read FID write FID; // Expose une propriete de la classe.
    property Name: string read FName write FName; // Expose une propriete de la classe.
    property Description: string read FDescription write FDescription; // Expose une propriete de la classe.
    property ImageURL: string read FImageURL write FImageURL; // Expose une propriete de la classe.
    property ProductCount: Integer read FProductCount write FProductCount; // Expose une propriete de la classe.
  end; // Ferme le bloc ou la declaration en cours.

  TCategoryList = class(TObjectList<TCategory>) // Complete la declaration ou instruction en cours.
  public // Complete la declaration ou instruction en cours.
    // Conversion de la liste complète vers ou depuis le format JSON de l'API.
    function ToJSONArray: TJSONArray; // Declare une fonction qui renvoie un resultat.
    procedure FromJSONArray(AJSONArray: TJSONArray); // Declare une procedure de cette unite ou classe.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

{ TCategory }

constructor TCategory.Create; // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Initialise les valeurs de la catégorie avant son chargement depuis SQLite ou JSON.
  inherited Create; // Appelle le comportement correspondant de la classe parente.
  FID := 0; // Attribue une nouvelle valeur a la variable indiquee.
  FName := ''; // Attribue une nouvelle valeur a la variable indiquee.
  FDescription := ''; // Attribue une nouvelle valeur a la variable indiquee.
  FImageURL := ''; // Attribue une nouvelle valeur a la variable indiquee.
  FProductCount := 0; // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

destructor TCategory.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

function TCategory.ToJSONObject: TJSONObject; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Utilise les noms de champs attendus par les réponses du serveur.
  Result := TJSONObject.Create; // Affecte la valeur de retour de la fonction.
  Result.AddPair('id', TJSONNumber.Create(FID)); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('nom', FName); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('description', FDescription); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('image_url', FImageURL); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('product_count', TJSONNumber.Create(FProductCount)); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TCategory.FromJSONObject(AJSONObj: TJSONObject); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  Val: TJSONValue; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Lit uniquement les champs présents afin d'accepter des réponses partielles.
  if AJSONObj = nil then Exit; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('id'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FID := Val.AsType<Integer>; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('nom'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FName := Val.Value; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('description'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FDescription := Val.Value; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('image_url'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FImageURL := Val.Value; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('product_count'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FProductCount := Val.AsType<Integer>; // Verifie la condition avant de poursuivre.
end; // Ferme le bloc ou la declaration en cours.

{ TCategoryList }

function TCategoryList.ToJSONArray: TJSONArray; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Item: TCategory; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Construit un tableau JSON indépendant contenant chaque catégorie.
  Result := TJSONArray.Create; // Affecte la valeur de retour de la fonction.
  for Item in Self do // Parcourt les elements ou valeurs de cette boucle.
    Result.AddElement(Item.ToJSONObject); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TCategoryList.FromJSONArray(AJSONArray: TJSONArray); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  I: Integer; // Execute cette instruction dans le flux courant.
  Obj: TJSONObject; // Execute cette instruction dans le flux courant.
  Cat: TCategory; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Libère les anciennes catégories puis charge les objets du tableau reçu.
  Clear; // Execute cette instruction dans le flux courant.
  if AJSONArray = nil then Exit; // Verifie la condition avant de poursuivre.

  for I := 0 to AJSONArray.Count - 1 do // Parcourt les elements ou valeurs de cette boucle.
  begin // Ouvre le bloc d instructions correspondant.
    if AJSONArray.Items[I] is TJSONObject then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      Obj := TJSONObject(AJSONArray.Items[I]); // Attribue une nouvelle valeur a la variable indiquee.
      Cat := TCategory.Create; // Attribue une nouvelle valeur a la variable indiquee.
      Cat.FromJSONObject(Obj); // Appelle la methode ou fonction avec les parametres indiques.
      Add(Cat); // Appelle la methode ou fonction avec les parametres indiques.
    end; // Ferme le bloc ou la declaration en cours.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
