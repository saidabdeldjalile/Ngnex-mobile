unit Quote; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections, Customer; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Etats métier du devis ; SetStatusText accepte aussi les libellés de l'API.
  TQuoteStatus = (qsEnAttente, qsEnTraitement, qsAccepte, qsRefuse); // Execute cette instruction dans le flux courant.

  // Une ligne de devis conserve l'identité et le prix du produit au moment
  // de la demande, même si le catalogue évolue par la suite.
  TQuoteItem = class // Complete la declaration ou instruction en cours.
  private // Complete la declaration ou instruction en cours.
    FID: Integer; // Execute cette instruction dans le flux courant.
    FQuoteID: Integer; // Execute cette instruction dans le flux courant.
    FProductID: Integer; // Execute cette instruction dans le flux courant.
    FProductName: string; // Execute cette instruction dans le flux courant.
    FProductRef: string; // Execute cette instruction dans le flux courant.
    FQuantity: Integer; // Execute cette instruction dans le flux courant.
    FUnitPrice: Double; // Execute cette instruction dans le flux courant.
    function GetTotalPrice: Double; // Declare une fonction qui renvoie un resultat.
  public // Complete la declaration ou instruction en cours.
    constructor Create; // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.

    function ToJSONObject: TJSONObject; // Declare une fonction qui renvoie un resultat.
    procedure FromJSONObject(AJSONObj: TJSONObject); // Declare une procedure de cette unite ou classe.

    property ID: Integer read FID write FID; // Expose une propriete de la classe.
    property QuoteID: Integer read FQuoteID write FQuoteID; // Expose une propriete de la classe.
    property ProductID: Integer read FProductID write FProductID; // Expose une propriete de la classe.
    property ProductName: string read FProductName write FProductName; // Expose une propriete de la classe.
    property ProductRef: string read FProductRef write FProductRef; // Expose une propriete de la classe.
    property Quantity: Integer read FQuantity write FQuantity; // Expose une propriete de la classe.
    property UnitPrice: Double read FUnitPrice write FUnitPrice; // Expose une propriete de la classe.
    property TotalPrice: Double read GetTotalPrice; // Expose une propriete de la classe.
  end; // Ferme le bloc ou la declaration en cours.

  TQuoteItemList = class(TObjectList<TQuoteItem>) // Complete la declaration ou instruction en cours.
  public // Complete la declaration ou instruction en cours.
    // Calculs et conversions JSON pour les articles d'un devis.
    function GetGrandTotal: Double; // Declare une fonction qui renvoie un resultat.
    function HasUnpricedItems: Boolean; // Declare une fonction qui renvoie un resultat.
    function ToJSONArray: TJSONArray; // Declare une fonction qui renvoie un resultat.
    procedure FromJSONArray(AJSONArray: TJSONArray); // Declare une procedure de cette unite ou classe.
  end; // Ferme le bloc ou la declaration en cours.

  TQuote = class // Complete la declaration ou instruction en cours.
  private // Complete la declaration ou instruction en cours.
    FID: Integer; // Execute cette instruction dans le flux courant.
    FNumber: string; // Execute cette instruction dans le flux courant.
    FCreatedAt: TDateTime; // Execute cette instruction dans le flux courant.
    FStatus: TQuoteStatus; // Execute cette instruction dans le flux courant.
    FCustomer: TCustomer; // Execute cette instruction dans le flux courant.
    FNotes: string; // Execute cette instruction dans le flux courant.
    FItems: TQuoteItemList; // Execute cette instruction dans le flux courant.
    function GetStatusText: string; // Declare une fonction qui renvoie un resultat.
    procedure SetStatusText(const Value: string); // Declare une procedure de cette unite ou classe.
    function GetTotalAmount: Double; // Declare une fonction qui renvoie un resultat.
  public // Complete la declaration ou instruction en cours.
    // Le devis possède ses coordonnées client et sa liste d'articles.
    constructor Create; // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.

    function ToJSONObject: TJSONObject; // Declare une fonction qui renvoie un resultat.
    procedure FromJSONObject(AJSONObj: TJSONObject); // Declare une procedure de cette unite ou classe.

    property ID: Integer read FID write FID; // Expose une propriete de la classe.
    property Number: string read FNumber write FNumber; // Expose une propriete de la classe.
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt; // Expose une propriete de la classe.
    property Status: TQuoteStatus read FStatus write FStatus; // Expose une propriete de la classe.
    property StatusText: string read GetStatusText write SetStatusText; // Expose une propriete de la classe.
    property Customer: TCustomer read FCustomer; // Expose une propriete de la classe.
    property Notes: string read FNotes write FNotes; // Expose une propriete de la classe.
    property Items: TQuoteItemList read FItems; // Expose une propriete de la classe.
    property TotalAmount: Double read GetTotalAmount; // Expose une propriete de la classe.
  end; // Ferme le bloc ou la declaration en cours.

  TQuoteList = class(TObjectList<TQuote>) // Complete la declaration ou instruction en cours.
  public // Complete la declaration ou instruction en cours.
    // Conversion de l'historique complet au format JSON.
    function ToJSONArray: TJSONArray; // Declare une fonction qui renvoie un resultat.
    procedure FromJSONArray(AJSONArray: TJSONArray); // Declare une procedure de cette unite ou classe.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

{ TQuoteItem }

constructor TQuoteItem.Create; // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Prépare une ligne vide avec une quantité initiale de un.
  inherited Create; // Appelle le comportement correspondant de la classe parente.
  FID := 0; // Attribue une nouvelle valeur a la variable indiquee.
  FQuoteID := 0; // Attribue une nouvelle valeur a la variable indiquee.
  FProductID := 0; // Attribue une nouvelle valeur a la variable indiquee.
  FProductName := ''; // Attribue une nouvelle valeur a la variable indiquee.
  FProductRef := ''; // Attribue une nouvelle valeur a la variable indiquee.
  FQuantity := 1; // Attribue une nouvelle valeur a la variable indiquee.
  FUnitPrice := 0.0; // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

destructor TQuoteItem.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

function TQuoteItem.GetTotalPrice: Double; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Calcule le montant de la ligne à partir des valeurs mémorisées.
  Result := FUnitPrice * FQuantity; // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

function TQuoteItem.ToJSONObject: TJSONObject; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Sérialise la ligne avec les clés attendues par le serveur.
  Result := TJSONObject.Create; // Affecte la valeur de retour de la fonction.
  Result.AddPair('id', TJSONNumber.Create(FID)); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('quote_id', TJSONNumber.Create(FQuoteID)); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('product_id', TJSONNumber.Create(FProductID)); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('product_name', FProductName); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('product_ref', FProductRef); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('quantite', TJSONNumber.Create(FQuantity)); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('prix_unitaire', TJSONNumber.Create(FUnitPrice)); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('total_price', TJSONNumber.Create(TotalPrice)); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TQuoteItem.FromJSONObject(AJSONObj: TJSONObject); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  Val: TJSONValue; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Charge les champs connus de la ligne lorsque l'API les fournit.
  if AJSONObj = nil then Exit; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('id'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FID := Val.AsType<Integer>; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('quote_id'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FQuoteID := Val.AsType<Integer>; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('product_id'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FProductID := Val.AsType<Integer>; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('product_name'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FProductName := Val.Value; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('product_ref'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FProductRef := Val.Value; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('quantite'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FQuantity := Val.AsType<Integer>; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('prix_unitaire'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FUnitPrice := Val.AsType<Double>; // Verifie la condition avant de poursuivre.
end; // Ferme le bloc ou la declaration en cours.

{ TQuoteItemList }

function TQuoteItemList.GetGrandTotal: Double; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Item: TQuoteItem; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Additionne les montants de ligne pour calculer le total estimé du devis.
  Result := 0.0; // Affecte la valeur de retour de la fonction.
  for Item in Self do // Parcourt les elements ou valeurs de cette boucle.
    Result := Result + Item.TotalPrice; // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

function TQuoteItemList.HasUnpricedItems: Boolean; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Item: TQuoteItem; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Indique si au moins un article possède un prix à confirmer.
  Result := False; // Affecte la valeur de retour de la fonction.
  for Item in Self do // Parcourt les elements ou valeurs de cette boucle.
    if Item.UnitPrice <= 0 then // Verifie la condition avant de poursuivre.
      Exit(True); // Quitte la procedure ou fonction a cet endroit.
end; // Ferme le bloc ou la declaration en cours.

function TQuoteItemList.ToJSONArray: TJSONArray; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Item: TQuoteItem; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Sérialise les articles du devis dans un tableau JSON.
  Result := TJSONArray.Create; // Affecte la valeur de retour de la fonction.
  for Item in Self do // Parcourt les elements ou valeurs de cette boucle.
    Result.AddElement(Item.ToJSONObject); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TQuoteItemList.FromJSONArray(AJSONArray: TJSONArray); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  I: Integer; // Execute cette instruction dans le flux courant.
  Obj: TJSONObject; // Execute cette instruction dans le flux courant.
  Item: TQuoteItem; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Remplace la liste existante à partir des objets valides du tableau.
  Clear; // Execute cette instruction dans le flux courant.
  if AJSONArray = nil then Exit; // Verifie la condition avant de poursuivre.

  for I := 0 to AJSONArray.Count - 1 do // Parcourt les elements ou valeurs de cette boucle.
  begin // Ouvre le bloc d instructions correspondant.
    if AJSONArray.Items[I] is TJSONObject then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      Obj := TJSONObject(AJSONArray.Items[I]); // Attribue une nouvelle valeur a la variable indiquee.
      Item := TQuoteItem.Create; // Attribue une nouvelle valeur a la variable indiquee.
      Item.FromJSONObject(Obj); // Appelle la methode ou fonction avec les parametres indiques.
      Add(Item); // Appelle la methode ou fonction avec les parametres indiques.
    end; // Ferme le bloc ou la declaration en cours.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

{ TQuote }

constructor TQuote.Create; // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Crée un numéro provisoire, un état initial et les objets possédés par le devis.
  inherited Create; // Appelle le comportement correspondant de la classe parente.
  FID := 0; // Attribue une nouvelle valeur a la variable indiquee.
  FNumber := 'DEV-' + FormatDateTime('yyyymmddhhnnss', Now); // Attribue une nouvelle valeur a la variable indiquee.
  FCreatedAt := Now; // Attribue une nouvelle valeur a la variable indiquee.
  FStatus := qsEnAttente; // Attribue une nouvelle valeur a la variable indiquee.
  FCustomer := TCustomer.Create; // Attribue une nouvelle valeur a la variable indiquee.
  FNotes := ''; // Attribue une nouvelle valeur a la variable indiquee.
  FItems := TQuoteItemList.Create(True); // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

destructor TQuote.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Le devis possède ses coordonnées client et ses lignes : il les libère ici.
  FreeAndNil(FCustomer); // Appelle la methode ou fonction avec les parametres indiques.
  FreeAndNil(FItems); // Appelle la methode ou fonction avec les parametres indiques.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

function TQuote.GetStatusText: string; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Traduit l'énumération interne en libellé lisible et transmis dans l'API.
  case FStatus of // Choisit une branche selon la valeur de l expression.
    qsEnAttente: Result := 'En attente'; // Attribue une nouvelle valeur a la variable indiquee.
    qsEnTraitement: Result := 'En cours de traitement'; // Attribue une nouvelle valeur a la variable indiquee.
    qsAccepte: Result := 'Accepté'; // Attribue une nouvelle valeur a la variable indiquee.
    qsRefuse: Result := 'Refusé'; // Attribue une nouvelle valeur a la variable indiquee.
  else // Execute la branche alternative de la condition precedente.
    Result := 'Inconnu'; // Affecte la valeur de retour de la fonction.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TQuote.SetStatusText(const Value: string); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  S: string; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Accepte les libellés français ainsi que quelques valeurs anglaises
  // susceptibles d'être retournées par le serveur.
  S := LowerCase(Trim(Value)); // Attribue une nouvelle valeur a la variable indiquee.
  if (S = 'en attente') or (S = 'pending') then // Verifie la condition avant de poursuivre.
    FStatus := qsEnAttente // Attribue une nouvelle valeur a la variable indiquee.
  else if (S = 'en cours de traitement') or (S = 'en traitement') or (S = 'processing') then // Execute la branche alternative de la condition precedente.
    FStatus := qsEnTraitement // Attribue une nouvelle valeur a la variable indiquee.
  else if (S = 'accepte') or (S = 'accepté') or (S = 'accepted') then // Execute la branche alternative de la condition precedente.
    FStatus := qsAccepte // Attribue une nouvelle valeur a la variable indiquee.
  else if (S = 'refuse') or (S = 'refusé') or (S = 'rejected') then // Execute la branche alternative de la condition precedente.
    FStatus := qsRefuse // Attribue une nouvelle valeur a la variable indiquee.
  else // Execute la branche alternative de la condition precedente.
    FStatus := qsEnAttente; // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

function TQuote.GetTotalAmount: Double; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Délègue le calcul à la collection des lignes du devis.
  Result := FItems.GetGrandTotal; // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

function TQuote.ToJSONObject: TJSONObject; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Assemble les informations générales, le client et les articles du devis.
  Result := TJSONObject.Create; // Affecte la valeur de retour de la fonction.
  Result.AddPair('id', TJSONNumber.Create(FID)); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('numero', FNumber); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('date_creation', FormatDateTime('yyyy-mm-dd hh:nn:ss', FCreatedAt)); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('statut', StatusText); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('notes', FNotes); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('total_amount', TJSONNumber.Create(TotalAmount)); // Appelle la methode ou fonction avec les parametres indiques.
  if Assigned(FCustomer) then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    Result.AddPair('customer_name', FCustomer.FullName); // Appelle la methode ou fonction avec les parametres indiques.
    Result.AddPair('company_name', FCustomer.CompanyName); // Appelle la methode ou fonction avec les parametres indiques.
    Result.AddPair('customer_phone', FCustomer.Phone); // Appelle la methode ou fonction avec les parametres indiques.
    Result.AddPair('customer_email', FCustomer.Email); // Appelle la methode ou fonction avec les parametres indiques.
    Result.AddPair('address', FCustomer.Address); // Appelle la methode ou fonction avec les parametres indiques.
  end; // Ferme le bloc ou la declaration en cours.
  if Assigned(FItems) then // Verifie la condition avant de poursuivre.
    Result.AddPair('items', FItems.ToJSONArray); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TQuote.FromJSONObject(AJSONObj: TJSONObject); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  Val: TJSONValue; // Execute cette instruction dans le flux courant.
  ItemsArray: TJSONArray; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Met à jour le devis depuis une réponse JSON, en rechargeant aussi le client
  // et la liste d'articles si ces sections sont présentes.
  if AJSONObj = nil then Exit; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('id'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FID := Val.AsType<Integer>; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('numero'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FNumber := Val.Value; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('date_creation'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then TryStrToDateTime(Val.Value, FCreatedAt); // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('statut'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then StatusText := Val.Value; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('notes'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FNotes := Val.Value; // Verifie la condition avant de poursuivre.

  if Assigned(FCustomer) then // Verifie la condition avant de poursuivre.
    FCustomer.FromJSONObject(AJSONObj); // Appelle la methode ou fonction avec les parametres indiques.

  Val := AJSONObj.GetValue('items'); // Attribue une nouvelle valeur a la variable indiquee.
  if (Val <> nil) and (Val is TJSONArray) then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    ItemsArray := TJSONArray(Val); // Attribue une nouvelle valeur a la variable indiquee.
    FItems.FromJSONArray(ItemsArray); // Appelle la methode ou fonction avec les parametres indiques.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

{ TQuoteList }

function TQuoteList.ToJSONArray: TJSONArray; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  Item: TQuote; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Convertit l'historique en tableau d'objets JSON.
  Result := TJSONArray.Create; // Affecte la valeur de retour de la fonction.
  for Item in Self do // Parcourt les elements ou valeurs de cette boucle.
    Result.AddElement(Item.ToJSONObject); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TQuoteList.FromJSONArray(AJSONArray: TJSONArray); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  I: Integer; // Execute cette instruction dans le flux courant.
  Obj: TJSONObject; // Execute cette instruction dans le flux courant.
  Q: TQuote; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Remplace l'historique actuel par les devis représentés dans le tableau reçu.
  Clear; // Execute cette instruction dans le flux courant.
  if AJSONArray = nil then Exit; // Verifie la condition avant de poursuivre.

  for I := 0 to AJSONArray.Count - 1 do // Parcourt les elements ou valeurs de cette boucle.
  begin // Ouvre le bloc d instructions correspondant.
    if AJSONArray.Items[I] is TJSONObject then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      Obj := TJSONObject(AJSONArray.Items[I]); // Attribue une nouvelle valeur a la variable indiquee.
      Q := TQuote.Create; // Attribue une nouvelle valeur a la variable indiquee.
      Q.FromJSONObject(Obj); // Appelle la methode ou fonction avec les parametres indiques.
      Add(Q); // Appelle la methode ou fonction avec les parametres indiques.
    end; // Ferme le bloc ou la declaration en cours.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
