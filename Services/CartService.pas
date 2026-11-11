unit CartService; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Classes, // Complete la declaration ou instruction en cours.
  Product, CartItem, DatabaseService; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Façade métier du panier : maintient la liste en mémoire et persiste les
  // changements via DatabaseService.
  TCartService = class // Complete la declaration ou instruction en cours.
  private // Complete la declaration ou instruction en cours.
    FDatabaseService: TDatabaseService; // Execute cette instruction dans le flux courant.
    FCartItems: TCartItemList; // Execute cette instruction dans le flux courant.
    function GetGrandTotal: Double; // Declare une fonction qui renvoie un resultat.
    function GetTotalQuantity: Integer; // Declare une fonction qui renvoie un resultat.
  public // Complete la declaration ou instruction en cours.
    constructor Create(ADatabaseService: TDatabaseService); // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.

    function RefreshCart: Boolean; // Declare une fonction qui renvoie un resultat.
    function AddProduct(AProduct: TProduct; AQuantity: Integer = 1): Boolean; // Declare une fonction qui renvoie un resultat.
    function AddToCart(AProductID: Integer; AQuantity: Integer = 1; APrice: Double = 0.0): Boolean; // Declare une fonction qui renvoie un resultat.
    function UpdateQuantity(AProductID, AQuantity: Integer): Boolean; // Declare une fonction qui renvoie un resultat.
    function RemoveProduct(AProductID: Integer): Boolean; // Declare une fonction qui renvoie un resultat.
    function RemoveFromCart(AProductID: Integer): Boolean; // Declare une fonction qui renvoie un resultat.
    function GetQuantity(AProductID: Integer): Integer; // Declare une fonction qui renvoie un resultat.
    procedure ClearCart; // Declare une procedure de cette unite ou classe.

    property Items: TCartItemList read FCartItems; // Expose une propriete de la classe.
    property GrandTotal: Double read GetGrandTotal; // Expose une propriete de la classe.
    property TotalQuantity: Integer read GetTotalQuantity; // Expose une propriete de la classe.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

{ TCartService }

constructor TCartService.Create(ADatabaseService: TDatabaseService); // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // La liste possède ses articles ; elle est remplie immédiatement depuis SQLite.
  inherited Create; // Appelle le comportement correspondant de la classe parente.
  FDatabaseService := ADatabaseService; // Attribue une nouvelle valeur a la variable indiquee.
  FCartItems := TCartItemList.Create(True); // Attribue une nouvelle valeur a la variable indiquee.
  RefreshCart; // Execute cette instruction dans le flux courant.
end; // Ferme le bloc ou la declaration en cours.

destructor TCartService.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Libère la liste et les articles qu'elle possède.
  FreeAndNil(FCartItems); // Appelle la methode ou fonction avec les parametres indiques.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

function TCartService.RefreshCart: Boolean; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Recharge l'état mémoire depuis la source persistante locale.
  if FDatabaseService <> nil then // Verifie la condition avant de poursuivre.
    Result := FDatabaseService.GetCartItems(FCartItems) // Affecte la valeur de retour de la fonction.
  else // Execute la branche alternative de la condition precedente.
    Result := False; // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

function TCartService.AddProduct(AProduct: TProduct; AQuantity: Integer): Boolean; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Item: TCartItem; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Crée une ligne temporaire, la sauvegarde, puis recharge le panier si réussi.
  Result := False; // Affecte la valeur de retour de la fonction.
  if (AProduct = nil) or (FDatabaseService = nil) then Exit; // Verifie la condition avant de poursuivre.

  Item := TCartItem.Create(AProduct, AQuantity); // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Result := FDatabaseService.SaveCartItem(Item); // Affecte la valeur de retour de la fonction.
    if Result then // Verifie la condition avant de poursuivre.
      RefreshCart; // Execute cette instruction dans le flux courant.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Item.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

function TCartService.AddToCart(AProductID: Integer; AQuantity: Integer; APrice: Double): Boolean; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Item: TCartItem; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Variante sans objet produit complet, utile lorsqu'on dispose seulement de l'ID.
  Result := False; // Affecte la valeur de retour de la fonction.
  if FDatabaseService = nil then Exit; // Verifie la condition avant de poursuivre.

  Item := TCartItem.Create; // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    Item.ProductID := AProductID; // Attribue une nouvelle valeur a la variable indiquee.
    Item.Quantity := AQuantity; // Attribue une nouvelle valeur a la variable indiquee.
    Item.UnitPrice := APrice; // Attribue une nouvelle valeur a la variable indiquee.
    Result := FDatabaseService.SaveCartItem(Item); // Affecte la valeur de retour de la fonction.
    if Result then // Verifie la condition avant de poursuivre.
      RefreshCart; // Execute cette instruction dans le flux courant.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    Item.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

function TCartService.UpdateQuantity(AProductID, AQuantity: Integer): Boolean; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Délègue la mise à jour à SQLite et synchronise la liste après réussite.
  if FDatabaseService <> nil then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    Result := FDatabaseService.UpdateCartItemQuantity(AProductID, AQuantity); // Affecte la valeur de retour de la fonction.
    if Result then // Verifie la condition avant de poursuivre.
      RefreshCart; // Execute cette instruction dans le flux courant.
  end // Ferme le bloc ou la declaration en cours.
  else // Execute la branche alternative de la condition precedente.
    Result := False; // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

function TCartService.RemoveProduct(AProductID: Integer): Boolean; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Supprime une ligne locale puis recharge la collection visible.
  if FDatabaseService <> nil then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    Result := FDatabaseService.DeleteCartItem(AProductID); // Affecte la valeur de retour de la fonction.
    if Result then // Verifie la condition avant de poursuivre.
      RefreshCart; // Execute cette instruction dans le flux courant.
  end // Ferme le bloc ou la declaration en cours.
  else // Execute la branche alternative de la condition precedente.
    Result := False; // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

function TCartService.RemoveFromCart(AProductID: Integer): Boolean; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Alias conservé pour les appels utilisant l'ancien nom métier.
  Result := RemoveProduct(AProductID); // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

function TCartService.GetQuantity(AProductID: Integer): Integer; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Item: TCartItem; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Renvoie zéro si le produit n'est pas présent dans la liste chargée.
  Result := 0; // Affecte la valeur de retour de la fonction.
  if FCartItems <> nil then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    Item := FCartItems.FindByProductID(AProductID); // Attribue une nouvelle valeur a la variable indiquee.
    if Item <> nil then // Verifie la condition avant de poursuivre.
      Result := Item.Quantity; // Affecte la valeur de retour de la fonction.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TCartService.ClearCart; // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Efface à la fois le stockage SQLite et sa représentation en mémoire.
  if FDatabaseService <> nil then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    FDatabaseService.ClearCart; // Execute cette instruction dans le flux courant.
    FCartItems.Clear; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

function TCartService.GetGrandTotal: Double; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Expose le total calculé par la collection courante.
  Result := FCartItems.GetGrandTotal; // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

function TCartService.GetTotalQuantity: Integer; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Expose le nombre total d'unités pour le badge et les résumés.
  Result := FCartItems.GetTotalQuantity; // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
