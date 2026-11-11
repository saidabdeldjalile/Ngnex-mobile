unit ProductService; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Classes, System.JSON, System.NetEncoding, // Complete la declaration ou instruction en cours.
  Product, DatabaseService, ApiService; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Résultats asynchrones de recherche distante et de résolution d'un code-barres.
  TProductSearchCallback = reference to procedure(const ASuccess: Boolean; const AProductList: TProductList; const AErrorMessage: string); // Execute cette instruction dans le flux courant.
  TBarcodeApiCallback = reference to procedure(const ASuccess: Boolean; const ARemoteProduct: TProduct; const AErrorMessage: string); // Execute cette instruction dans le flux courant.

  // Point d'accès métier aux produits locaux et aux recherches API distantes.
  TProductService = class // Complete la declaration ou instruction en cours.
  private // Complete la declaration ou instruction en cours.
    FDatabaseService: TDatabaseService; // Execute cette instruction dans le flux courant.
    FApiService: TApiService; // Execute cette instruction dans le flux courant.
  public // Complete la declaration ou instruction en cours.
    constructor Create(ADatabaseService: TDatabaseService; AApiService: TApiService); // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.

    function FetchProducts(AList: TProductList; ACategoryID: Integer = 0; const AQuery: string = ''; const ASortBy: string = ''): Boolean; // Declare une fonction qui renvoie un resultat.
    function GetProductByID(AID: Integer; AProduct: TProduct): Boolean; // Declare une fonction qui renvoie un resultat.
    function FindByBarcode(const ABarcode: string; AProduct: TProduct): Boolean; // Declare une fonction qui renvoie un resultat.
    function GetPopularProducts(AList: TProductList; ACount: Integer = 5): Boolean; // Declare une fonction qui renvoie un resultat.

    procedure SearchRemoteProducts(const AQuery: string; AOnComplete: TProductSearchCallback); // Declare une procedure de cette unite ou classe.
    procedure FetchRemoteBarcode(const ABarcode: string; AOnComplete: TBarcodeApiCallback); // Declare une procedure de cette unite ou classe.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

{ TProductService }

constructor TProductService.Create(ADatabaseService: TDatabaseService; AApiService: TApiService); // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Les services sont injectés pour séparer les règles métier du stockage et du réseau.
  inherited Create; // Appelle le comportement correspondant de la classe parente.
  FDatabaseService := ADatabaseService; // Attribue une nouvelle valeur a la variable indiquee.
  FApiService := AApiService; // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

destructor TProductService.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

function TProductService.FetchProducts(AList: TProductList; ACategoryID: Integer; const AQuery, ASortBy: string): Boolean; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Charge la liste locale avec les filtres et le tri demandés par l'écran.
  if FDatabaseService <> nil then // Verifie la condition avant de poursuivre.
    Result := FDatabaseService.GetProducts(AList, ACategoryID, AQuery, ASortBy) // Affecte la valeur de retour de la fonction.
  else // Execute la branche alternative de la condition precedente.
    Result := False; // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

function TProductService.GetProductByID(AID: Integer; AProduct: TProduct): Boolean; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Remplit le modèle fourni à partir de la base locale.
  if FDatabaseService <> nil then // Verifie la condition avant de poursuivre.
    Result := FDatabaseService.GetProductByID(AID, AProduct) // Affecte la valeur de retour de la fonction.
  else // Execute la branche alternative de la condition precedente.
    Result := False; // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

function TProductService.FindByBarcode(const ABarcode: string; AProduct: TProduct): Boolean; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Recherche localement par code-barres ou référence avant tout appel réseau.
  if FDatabaseService <> nil then // Verifie la condition avant de poursuivre.
    Result := FDatabaseService.GetProductByBarcode(ABarcode, AProduct) // Affecte la valeur de retour de la fonction.
  else // Execute la branche alternative de la condition precedente.
    Result := False; // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

function TProductService.GetPopularProducts(AList: TProductList; ACount: Integer): Boolean; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Fournit à l'accueil un petit sous-ensemble de produits à mettre en avant.
  if FDatabaseService <> nil then // Verifie la condition avant de poursuivre.
    Result := FDatabaseService.GetPopularProducts(AList, ACount) // Affecte la valeur de retour de la fonction.
  else // Execute la branche alternative de la condition precedente.
    Result := False; // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

procedure TProductService.SearchRemoteProducts(const AQuery: string; AOnComplete: TProductSearchCallback); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Encode le terme de recherche pour une URL et convertit la réponse JSON en modèles.
  if FApiService = nil then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    if Assigned(AOnComplete) then AOnComplete(False, nil, 'API indisponible'); // Verifie la condition avant de poursuivre.
    Exit; // Quitte la procedure ou fonction a cet endroit.
  end; // Ferme le bloc ou la declaration en cours.

  FApiService.GetAsync('/products/search?query=' + TNetEncoding.URL.Encode(AQuery), // Appelle la methode ou fonction avec les parametres indiques.
    procedure(const ASuccess: Boolean; const AResponseContent: string; const AErrorMessage: string) // Appelle la methode ou fonction avec les parametres indiques.
    var // Ouvre la section de declarations correspondante.
      JSONArr: TJSONArray; // Execute cette instruction dans le flux courant.
      List: TProductList; // Execute cette instruction dans le flux courant.
    begin // Ouvre le bloc d instructions correspondant.
      if ASuccess then // Verifie la condition avant de poursuivre.
      begin // Ouvre le bloc d instructions correspondant.
        List := TProductList.Create; // Attribue une nouvelle valeur a la variable indiquee.
        try // Ouvre le bloc d instructions correspondant.
          JSONArr := TJSONObject.ParseJSONValue(AResponseContent) as TJSONArray; // Attribue une nouvelle valeur a la variable indiquee.
          if JSONArr <> nil then // Verifie la condition avant de poursuivre.
          begin // Ouvre le bloc d instructions correspondant.
            List.FromJSONArray(JSONArr); // Appelle la methode ou fonction avec les parametres indiques.
            JSONArr.Free; // Execute cette instruction dans le flux courant.
          end; // Ferme le bloc ou la declaration en cours.
          if Assigned(AOnComplete) then // Verifie la condition avant de poursuivre.
            AOnComplete(True, List, ''); // Appelle la methode ou fonction avec les parametres indiques.
        except // Ouvre le traitement des exceptions du bloc protege.
          on E: Exception do // Associe ce cas au traitement d exception indique.
          begin // Ouvre le bloc d instructions correspondant.
            List.Free; // Execute cette instruction dans le flux courant.
            if Assigned(AOnComplete) then // Verifie la condition avant de poursuivre.
              AOnComplete(False, nil, 'Erreur de lecture JSON : ' + E.Message); // Appelle la methode ou fonction avec les parametres indiques.
          end; // Ferme le bloc ou la declaration en cours.
        end; // Ferme le bloc ou la declaration en cours.
      end // Ferme le bloc ou la declaration en cours.
      else // Execute la branche alternative de la condition precedente.
      begin // Ouvre le bloc d instructions correspondant.
        if Assigned(AOnComplete) then // Verifie la condition avant de poursuivre.
          AOnComplete(False, nil, AErrorMessage); // Appelle la methode ou fonction avec les parametres indiques.
      end; // Ferme le bloc ou la declaration en cours.
    end); // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TProductService.FetchRemoteBarcode(const ABarcode: string; AOnComplete: TBarcodeApiCallback); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Interroge le serveur lorsqu'un code scanné n'est pas trouvé localement.
  if FApiService = nil then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    if Assigned(AOnComplete) then AOnComplete(False, nil, 'API indisponible'); // Verifie la condition avant de poursuivre.
    Exit; // Quitte la procedure ou fonction a cet endroit.
  end; // Ferme le bloc ou la declaration en cours.

  FApiService.GetAsync('/products/barcode/' + Trim(ABarcode), // Appelle la methode ou fonction avec les parametres indiques.
    procedure(const ASuccess: Boolean; const AResponseContent: string; const AErrorMessage: string) // Appelle la methode ou fonction avec les parametres indiques.
    var // Ouvre la section de declarations correspondante.
      JSONObj: TJSONObject; // Execute cette instruction dans le flux courant.
      Prod: TProduct; // Execute cette instruction dans le flux courant.
    begin // Ouvre le bloc d instructions correspondant.
      if ASuccess then // Verifie la condition avant de poursuivre.
      begin // Ouvre le bloc d instructions correspondant.
        try // Ouvre le bloc d instructions correspondant.
          JSONObj := TJSONObject.ParseJSONValue(AResponseContent) as TJSONObject; // Attribue une nouvelle valeur a la variable indiquee.
          if JSONObj <> nil then // Verifie la condition avant de poursuivre.
          begin // Ouvre le bloc d instructions correspondant.
            Prod := TProduct.Create; // Attribue une nouvelle valeur a la variable indiquee.
            Prod.FromJSONObject(JSONObj); // Appelle la methode ou fonction avec les parametres indiques.
            JSONObj.Free; // Execute cette instruction dans le flux courant.
            if Assigned(AOnComplete) then // Verifie la condition avant de poursuivre.
              AOnComplete(True, Prod, ''); // Appelle la methode ou fonction avec les parametres indiques.
          end // Ferme le bloc ou la declaration en cours.
          else // Execute la branche alternative de la condition precedente.
          begin // Ouvre le bloc d instructions correspondant.
            if Assigned(AOnComplete) then // Verifie la condition avant de poursuivre.
              AOnComplete(False, nil, 'Produit introuvable dans l''API.'); // Appelle la methode ou fonction avec les parametres indiques.
          end; // Ferme le bloc ou la declaration en cours.
        except // Ouvre le traitement des exceptions du bloc protege.
          on E: Exception do // Associe ce cas au traitement d exception indique.
            if Assigned(AOnComplete) then // Verifie la condition avant de poursuivre.
              AOnComplete(False, nil, 'Erreur d''analyse du JSON : ' + E.Message); // Appelle la methode ou fonction avec les parametres indiques.
        end; // Ferme le bloc ou la declaration en cours.
      end // Ferme le bloc ou la declaration en cours.
      else // Execute la branche alternative de la condition precedente.
      begin // Ouvre le bloc d instructions correspondant.
        if Assigned(AOnComplete) then // Verifie la condition avant de poursuivre.
          AOnComplete(False, nil, AErrorMessage); // Appelle la methode ou fonction avec les parametres indiques.
      end; // Ferme le bloc ou la declaration en cours.
    end); // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
