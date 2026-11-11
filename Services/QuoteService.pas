unit QuoteService; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Classes, System.JSON, // Complete la declaration ou instruction en cours.
  Quote, CartItem, Customer, DatabaseService, ApiService; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Retour d'envoi d'un devis : le booléen distingue réception serveur et échec réseau.
  TQuoteApiCallback = reference to procedure(const ASuccess: Boolean; const AMessage: string); // Execute cette instruction dans le flux courant.

  // Construit les devis à partir du panier, charge l'historique local et envoie à l'API.
  TQuoteService = class // Complete la declaration ou instruction en cours.
  private // Complete la declaration ou instruction en cours.
    FDatabaseService: TDatabaseService; // Execute cette instruction dans le flux courant.
    FApiService: TApiService; // Execute cette instruction dans le flux courant.
  public // Complete la declaration ou instruction en cours.
    constructor Create(ADatabaseService: TDatabaseService; AApiService: TApiService); // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.

    function CreateQuoteFromCart(ACustomer: TCustomer; ACartItems: TCartItemList; const ANotes: string; out AQuote: TQuote): Boolean; // Declare une fonction qui renvoie un resultat.
    function LoadQuotesHistory(AList: TQuoteList): Boolean; // Declare une fonction qui renvoie un resultat.
    function GetQuoteDetails(AID: Integer; AQuote: TQuote): Boolean; // Declare une fonction qui renvoie un resultat.
    procedure SubmitQuoteToServer(AQuote: TQuote; AOnComplete: TQuoteApiCallback); // Declare une procedure de cette unite ou classe.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

{ TQuoteService }

constructor TQuoteService.Create(ADatabaseService: TDatabaseService; AApiService: TApiService); // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Injecte le stockage local et le transport HTTP utilisés par le service.
  inherited Create; // Appelle le comportement correspondant de la classe parente.
  FDatabaseService := ADatabaseService; // Attribue une nouvelle valeur a la variable indiquee.
  FApiService := AApiService; // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

destructor TQuoteService.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

function TQuoteService.CreateQuoteFromCart(ACustomer: TCustomer; ACartItems: TCartItemList; const ANotes: string; out AQuote: TQuote): Boolean; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  CartItem: TCartItem; // Execute cette instruction dans le flux courant.
  QuoteItem: TQuoteItem; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Copie les coordonnées et les lignes du panier dans un devis autonome,
  // puis le persiste localement avant tout envoi réseau.
  Result := False; // Affecte la valeur de retour de la fonction.
  AQuote := nil; // Attribue une nouvelle valeur a la variable indiquee.
  if (ACustomer = nil) or (ACartItems = nil) or (ACartItems.Count = 0) or (FDatabaseService = nil) then Exit; // Verifie la condition avant de poursuivre.

  AQuote := TQuote.Create; // Attribue une nouvelle valeur a la variable indiquee.
  AQuote.Customer.FullName := ACustomer.FullName; // Attribue une nouvelle valeur a la variable indiquee.
  AQuote.Customer.CompanyName := ACustomer.CompanyName; // Attribue une nouvelle valeur a la variable indiquee.
  AQuote.Customer.Phone := ACustomer.Phone; // Attribue une nouvelle valeur a la variable indiquee.
  AQuote.Customer.Email := ACustomer.Email; // Attribue une nouvelle valeur a la variable indiquee.
  AQuote.Customer.Address := ACustomer.Address; // Attribue une nouvelle valeur a la variable indiquee.
  AQuote.Notes := ANotes; // Attribue une nouvelle valeur a la variable indiquee.
  AQuote.Status := qsEnAttente; // Attribue une nouvelle valeur a la variable indiquee.

  for CartItem in ACartItems do // Parcourt les elements ou valeurs de cette boucle.
  begin // Ouvre le bloc d instructions correspondant.
    QuoteItem := TQuoteItem.Create; // Attribue une nouvelle valeur a la variable indiquee.
    QuoteItem.ProductID := CartItem.ProductID; // Attribue une nouvelle valeur a la variable indiquee.
    if Assigned(CartItem.Product) then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      QuoteItem.ProductName := CartItem.Product.Name; // Attribue une nouvelle valeur a la variable indiquee.
      QuoteItem.ProductRef := CartItem.Product.Reference; // Attribue une nouvelle valeur a la variable indiquee.
    end; // Ferme le bloc ou la declaration en cours.
    QuoteItem.Quantity := CartItem.Quantity; // Attribue une nouvelle valeur a la variable indiquee.
    QuoteItem.UnitPrice := CartItem.UnitPrice; // Attribue une nouvelle valeur a la variable indiquee.
    AQuote.Items.Add(QuoteItem); // Appelle la methode ou fonction avec les parametres indiques.
  end; // Ferme le bloc ou la declaration en cours.

  Result := FDatabaseService.SaveQuote(AQuote); // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

function TQuoteService.LoadQuotesHistory(AList: TQuoteList): Boolean; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // L'historique affiché dans l'application provient de la base SQLite du téléphone.
  if FDatabaseService <> nil then // Verifie la condition avant de poursuivre.
    Result := FDatabaseService.GetQuotes(AList) // Affecte la valeur de retour de la fonction.
  else // Execute la branche alternative de la condition precedente.
    Result := False; // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

function TQuoteService.GetQuoteDetails(AID: Integer; AQuote: TQuote): Boolean; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Charge un devis précis et ses lignes depuis le stockage local.
  if FDatabaseService <> nil then // Verifie la condition avant de poursuivre.
    Result := FDatabaseService.GetQuoteByID(AID, AQuote) // Affecte la valeur de retour de la fonction.
  else // Execute la branche alternative de la condition precedente.
    Result := False; // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

procedure TQuoteService.SubmitQuoteToServer(AQuote: TQuote; AOnComplete: TQuoteApiCallback); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  JSONBody: string; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Sérialise le devis puis délègue le POST asynchrone au service API.
  // Un échec est rapporté comme échec : il ne signifie pas que le serveur l'a reçu.
  if (AQuote = nil) or (FApiService = nil) then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    if Assigned(AOnComplete) then AOnComplete(False, 'Paramètres invalides.'); // Verifie la condition avant de poursuivre.
    Exit; // Quitte la procedure ou fonction a cet endroit.
  end; // Ferme le bloc ou la declaration en cours.

  JSONBody := AQuote.ToJSONObject.ToJSON; // Attribue une nouvelle valeur a la variable indiquee.

  FApiService.PostAsync('/quotes', JSONBody, // Appelle la methode ou fonction avec les parametres indiques.
    procedure(const ASuccess: Boolean; const AResponseContent: string; const AErrorMessage: string) // Appelle la methode ou fonction avec les parametres indiques.
    begin // Ouvre le bloc d instructions correspondant.
      if ASuccess then // Verifie la condition avant de poursuivre.
      begin // Ouvre le bloc d instructions correspondant.
        if Assigned(AOnComplete) then // Verifie la condition avant de poursuivre.
          AOnComplete(True, 'Demande de devis transmise au serveur avec succès.'); // Appelle la methode ou fonction avec les parametres indiques.
      end // Ferme le bloc ou la declaration en cours.
      else // Execute la branche alternative de la condition precedente.
      begin // Ouvre le bloc d instructions correspondant.
        if Assigned(AOnComplete) then // Verifie la condition avant de poursuivre.
          AOnComplete(False, AErrorMessage); // Appelle la methode ou fonction avec les parametres indiques.
      end; // Ferme le bloc ou la declaration en cours.
    end); // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
