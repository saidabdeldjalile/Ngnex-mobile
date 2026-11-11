unit CartItem; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections, Product; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Article du panier : conserve l'identifiant du produit, sa quantité et une
  // copie des informations produit nécessaires à l'affichage du panier.
  TCartItem = class // Complete la declaration ou instruction en cours.
  private // Complete la declaration ou instruction en cours.
    FID: Integer; // Execute cette instruction dans le flux courant.
    FProductID: Integer; // Execute cette instruction dans le flux courant.
    FProduct: TProduct; // Execute cette instruction dans le flux courant.
    FQuantity: Integer; // Execute cette instruction dans le flux courant.
    FUnitPrice: Double; // Execute cette instruction dans le flux courant.
    function GetTotalPrice: Double; // Declare une fonction qui renvoie un resultat.
  public // Complete la declaration ou instruction en cours.
    constructor Create; overload; // Declare le constructeur de cet objet.
    constructor Create(AProduct: TProduct; AQty: Integer = 1); overload; // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.

    function ToJSONObject: TJSONObject; // Declare une fonction qui renvoie un resultat.
    procedure FromJSONObject(AJSONObj: TJSONObject); // Declare une procedure de cette unite ou classe.

    property ID: Integer read FID write FID; // Expose une propriete de la classe.
    property ProductID: Integer read FProductID write FProductID; // Expose une propriete de la classe.
    property Product: TProduct read FProduct write FProduct; // Expose une propriete de la classe.
    property Quantity: Integer read FQuantity write FQuantity; // Expose une propriete de la classe.
    property UnitPrice: Double read FUnitPrice write FUnitPrice; // Expose une propriete de la classe.
    property TotalPrice: Double read GetTotalPrice; // Expose une propriete de la classe.
  end; // Ferme le bloc ou la declaration en cours.

  TCartItemList = class(TObjectList<TCartItem>) // Complete la declaration ou instruction en cours.
  public // Complete la declaration ou instruction en cours.
    // Agrégats utilisés par les écrans du panier et du devis.
    function GetGrandTotal: Double; // Declare une fonction qui renvoie un resultat.
    function GetTotalQuantity: Integer; // Declare une fonction qui renvoie un resultat.
    function HasUnpricedItems: Boolean; // Declare une fonction qui renvoie un resultat.
    function ToJSONArray: TJSONArray; // Declare une fonction qui renvoie un resultat.
    procedure FromJSONArray(AJSONArray: TJSONArray); // Declare une procedure de cette unite ou classe.
    function FindByProductID(AProductID: Integer): TCartItem; // Declare une fonction qui renvoie un resultat.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

{ TCartItem }

constructor TCartItem.Create; // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Initialise un article vide avec une quantité par défaut de un.
  inherited Create; // Appelle le comportement correspondant de la classe parente.
  FID := 0; // Attribue une nouvelle valeur a la variable indiquee.
  FProductID := 0; // Attribue une nouvelle valeur a la variable indiquee.
  FProduct := nil; // Attribue une nouvelle valeur a la variable indiquee.
  FQuantity := 1; // Attribue une nouvelle valeur a la variable indiquee.
  FUnitPrice := 0.0; // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

constructor TCartItem.Create(AProduct: TProduct; AQty: Integer); // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Copie le produit pour que l'article ne dépende pas de la durée de vie
  // de l'objet reçu en paramètre.
  Create; // Execute cette instruction dans le flux courant.
  if AProduct <> nil then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    FProduct := AProduct.Clone; // Attribue une nouvelle valeur a la variable indiquee.
    FProductID := AProduct.ID; // Attribue une nouvelle valeur a la variable indiquee.
    FUnitPrice := AProduct.Price; // Attribue une nouvelle valeur a la variable indiquee.
  end; // Ferme le bloc ou la declaration en cours.
  FQuantity := AQty; // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

destructor TCartItem.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // L'article possède sa copie du produit et en est donc responsable.
  if Assigned(FProduct) then // Verifie la condition avant de poursuivre.
    FreeAndNil(FProduct); // Appelle la methode ou fonction avec les parametres indiques.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

function TCartItem.GetTotalPrice: Double; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Le montant de ligne est le prix unitaire multiplié par la quantité.
  Result := FUnitPrice * FQuantity; // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

function TCartItem.ToJSONObject: TJSONObject; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Produit la représentation JSON consommée par les échanges API.
  Result := TJSONObject.Create; // Affecte la valeur de retour de la fonction.
  Result.AddPair('id', TJSONNumber.Create(FID)); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('product_id', TJSONNumber.Create(FProductID)); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('quantite', TJSONNumber.Create(FQuantity)); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('prix_unitaire', TJSONNumber.Create(FUnitPrice)); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('total_price', TJSONNumber.Create(TotalPrice)); // Appelle la methode ou fonction avec les parametres indiques.
  if Assigned(FProduct) then // Verifie la condition avant de poursuivre.
    Result.AddPair('product', FProduct.ToJSONObject); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TCartItem.FromJSONObject(AJSONObj: TJSONObject); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  Val: TJSONValue; // Execute cette instruction dans le flux courant.
  ProdObj: TJSONObject; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Ignore une entrée absente ; les champs manquants conservent leurs valeurs
  // par défaut pour permettre les réponses JSON partielles.
  if AJSONObj = nil then Exit; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('id'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FID := Val.AsType<Integer>; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('product_id'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FProductID := Val.AsType<Integer>; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('quantite'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FQuantity := Val.AsType<Integer>; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('prix_unitaire'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FUnitPrice := Val.AsType<Double>; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('product'); // Attribue une nouvelle valeur a la variable indiquee.
  if (Val <> nil) and (Val is TJSONObject) then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    ProdObj := TJSONObject(Val); // Attribue une nouvelle valeur a la variable indiquee.
    if not Assigned(FProduct) then // Verifie la condition avant de poursuivre.
      FProduct := TProduct.Create; // Attribue une nouvelle valeur a la variable indiquee.
    FProduct.FromJSONObject(ProdObj); // Appelle la methode ou fonction avec les parametres indiques.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

{ TCartItemList }

function TCartItemList.GetGrandTotal: Double; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Item: TCartItem; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Additionne le montant de toutes les lignes du panier.
  Result := 0.0; // Affecte la valeur de retour de la fonction.
  for Item in Self do // Parcourt les elements ou valeurs de cette boucle.
    Result := Result + Item.TotalPrice; // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

function TCartItemList.GetTotalQuantity: Integer; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Item: TCartItem; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Calcule le nombre total d'unités, pas le nombre de lignes.
  Result := 0; // Affecte la valeur de retour de la fonction.
  for Item in Self do // Parcourt les elements ou valeurs de cette boucle.
    Result := Result + Item.Quantity; // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

function TCartItemList.HasUnpricedItems: Boolean; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Item: TCartItem; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Un article sans prix rend le montant global seulement indicatif.
  Result := False; // Affecte la valeur de retour de la fonction.
  for Item in Self do // Parcourt les elements ou valeurs de cette boucle.
    if Item.UnitPrice <= 0 then // Verifie la condition avant de poursuivre.
      Exit(True); // Quitte la procedure ou fonction a cet endroit.
end; // Ferme le bloc ou la declaration en cours.

function TCartItemList.FindByProductID(AProductID: Integer): TCartItem; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Item: TCartItem; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Recherche une ligne existante pour éviter de traiter deux entrées séparées.
  Result := nil; // Affecte la valeur de retour de la fonction.
  for Item in Self do // Parcourt les elements ou valeurs de cette boucle.
  begin // Ouvre le bloc d instructions correspondant.
    if Item.ProductID = AProductID then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      Exit(Item); // Quitte la procedure ou fonction a cet endroit.
    end; // Ferme le bloc ou la declaration en cours.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

function TCartItemList.ToJSONArray: TJSONArray; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Item: TCartItem; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Sérialise chaque article en élément d'un tableau JSON.
  Result := TJSONArray.Create; // Affecte la valeur de retour de la fonction.
  for Item in Self do // Parcourt les elements ou valeurs de cette boucle.
    Result.AddElement(Item.ToJSONObject); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TCartItemList.FromJSONArray(AJSONArray: TJSONArray); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  I: Integer; // Execute cette instruction dans le flux courant.
  Obj: TJSONObject; // Execute cette instruction dans le flux courant.
  Item: TCartItem; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Remplace le contenu actuel par les objets valides du tableau fourni.
  Clear; // Execute cette instruction dans le flux courant.
  if AJSONArray = nil then Exit; // Verifie la condition avant de poursuivre.

  for I := 0 to AJSONArray.Count - 1 do // Parcourt les elements ou valeurs de cette boucle.
  begin // Ouvre le bloc d instructions correspondant.
    if AJSONArray.Items[I] is TJSONObject then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      Obj := TJSONObject(AJSONArray.Items[I]); // Attribue une nouvelle valeur a la variable indiquee.
      Item := TCartItem.Create; // Attribue une nouvelle valeur a la variable indiquee.
      Item.FromJSONObject(Obj); // Appelle la methode ou fonction avec les parametres indiques.
      Add(Item); // Appelle la methode ou fonction avec les parametres indiques.
    end; // Ferme le bloc ou la declaration en cours.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
