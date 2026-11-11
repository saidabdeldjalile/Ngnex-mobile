unit ApiService; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Classes, System.JSON, System.Net.HttpClient, // Complete la declaration ou instruction en cours.
  REST.Client, REST.Types, System.Net.URLClient; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Résultat commun des appels asynchrones : succès, corps de réponse et erreur.
  TApiCallback = reference to procedure(const ASuccess: Boolean; const AResponseContent: string; const AErrorMessage: string); // Execute cette instruction dans le flux courant.

  // Client HTTP qui centralise l'URL de base, les délais et le traitement JSON.
  TApiService = class // Complete la declaration ou instruction en cours.
  private // Complete la declaration ou instruction en cours.
    FBaseURL: string; // Execute cette instruction dans le flux courant.
    FTimeout: Integer; // Execute cette instruction dans le flux courant.
    FRESTClient: TRESTClient; // Execute cette instruction dans le flux courant.
    FRESTRequest: TRESTRequest; // Execute cette instruction dans le flux courant.
    FRESTResponse: TRESTResponse; // Execute cette instruction dans le flux courant.
  public // Complete la declaration ou instruction en cours.
    constructor Create(const ABaseURL: string = 'https://api.ngnex08.dz/api'); // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.

    function IsNetworkAvailable: Boolean; // Declare une fonction qui renvoie un resultat.

    // Synchronous calls
    function Get(const AEndpoint: string; out AResponseJSON: string; out AError: string): Boolean; // Declare une fonction qui renvoie un resultat.
    function Post(const AEndpoint: string; const ABodyJSON: string; out AResponseJSON: string; out AError: string): Boolean; // Declare une fonction qui renvoie un resultat.

    // Asynchronous REST calls
    procedure GetAsync(const AEndpoint: string; ACallback: TApiCallback); // Declare une procedure de cette unite ou classe.
    procedure PostAsync(const AEndpoint, ABodyJSON: string; ACallback: TApiCallback); // Declare une procedure de cette unite ou classe.

    property BaseURL: string read FBaseURL write FBaseURL; // Expose une propriete de la classe.
    property Timeout: Integer read FTimeout write FTimeout; // Expose une propriete de la classe.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

{ TApiService }

constructor TApiService.Create(const ABaseURL: string); // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Construit une seule pile REST réutilisée par les requêtes du service.
  inherited Create; // Appelle le comportement correspondant de la classe parente.
  FBaseURL := ABaseURL; // Attribue une nouvelle valeur a la variable indiquee.
  FTimeout := 10000; // 10s timeout

  FRESTClient := TRESTClient.Create(FBaseURL); // Attribue une nouvelle valeur a la variable indiquee.
  FRESTResponse := TRESTResponse.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  FRESTRequest := TRESTRequest.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
  FRESTRequest.Client := FRESTClient; // Attribue une nouvelle valeur a la variable indiquee.
  FRESTRequest.Response := FRESTResponse; // Attribue une nouvelle valeur a la variable indiquee.
  FRESTRequest.Timeout := FTimeout; // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

destructor TApiService.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Libère les composants dans l'ordre inverse de leur création.
  FreeAndNil(FRESTRequest); // Appelle la methode ou fonction avec les parametres indiques.
  FreeAndNil(FRESTResponse); // Appelle la methode ou fonction avec les parametres indiques.
  FreeAndNil(FRESTClient); // Appelle la methode ou fonction avec les parametres indiques.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

function TApiService.IsNetworkAvailable: Boolean; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  HTTP: THTTPClient; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Effectue une requête HEAD courte pour vérifier l'accès à l'hôte configuré.
  if FBaseURL.Trim.IsEmpty then // Verifie la condition avant de poursuivre.
    Exit(False); // Quitte la procedure ou fonction a cet endroit.

  // Quick connectivity test
  HTTP := THTTPClient.Create; // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    HTTP.ConnectionTimeout := 2000; // Attribue une nouvelle valeur a la variable indiquee.
    HTTP.ResponseTimeout := 2000; // Attribue une nouvelle valeur a la variable indiquee.
    try // Ouvre le bloc d instructions correspondant.
      Result := HTTP.Head(FBaseURL).StatusCode < 500; // Affecte la valeur de retour de la fonction.
    except // Ouvre le traitement des exceptions du bloc protege.
      Result := False; // Affecte la valeur de retour de la fonction.
    end; // Ferme le bloc ou la declaration en cours.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    HTTP.Free; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

function TApiService.Get(const AEndpoint: string; out AResponseJSON, AError: string): Boolean; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Retourne le corps seulement pour une réponse HTTP réussie ; les autres
  // statuts et exceptions sont exposés dans AError.
  Result := False; // Affecte la valeur de retour de la fonction.
  AResponseJSON := ''; // Attribue une nouvelle valeur a la variable indiquee.
  AError := ''; // Attribue une nouvelle valeur a la variable indiquee.

  if FBaseURL.Trim.IsEmpty then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    AError := 'API non configurée. Le mode local reste disponible.'; // Attribue une nouvelle valeur a la variable indiquee.
    Exit; // Quitte la procedure ou fonction a cet endroit.
  end; // Ferme le bloc ou la declaration en cours.

  try // Ouvre le bloc d instructions correspondant.
    FRESTClient.BaseURL := FBaseURL; // Attribue une nouvelle valeur a la variable indiquee.
    FRESTRequest.Resource := AEndpoint; // Attribue une nouvelle valeur a la variable indiquee.
    FRESTRequest.Method := rmGET; // Attribue une nouvelle valeur a la variable indiquee.
    FRESTRequest.Execute; // Execute cette instruction dans le flux courant.

    if FRESTResponse.StatusCode = 200 then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      AResponseJSON := FRESTResponse.Content; // Attribue une nouvelle valeur a la variable indiquee.
      Result := True; // Affecte la valeur de retour de la fonction.
    end // Ferme le bloc ou la declaration en cours.
    else // Execute la branche alternative de la condition precedente.
    begin // Ouvre le bloc d instructions correspondant.
      AError := Format('Erreur HTTP %d : %s', [FRESTResponse.StatusCode, FRESTResponse.StatusText]); // Attribue une nouvelle valeur a la variable indiquee.
    end; // Ferme le bloc ou la declaration en cours.
  except // Ouvre le traitement des exceptions du bloc protege.
    on E: Exception do // Associe ce cas au traitement d exception indique.
      AError := 'Erreur de connexion REST : ' + E.Message; // Attribue une nouvelle valeur a la variable indiquee.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

function TApiService.Post(const AEndpoint, ABodyJSON: string; out AResponseJSON, AError: string): Boolean; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Envoie un objet JSON et considère HTTP 200 ou 201 comme succès.
  Result := False; // Affecte la valeur de retour de la fonction.
  AResponseJSON := ''; // Attribue une nouvelle valeur a la variable indiquee.
  AError := ''; // Attribue une nouvelle valeur a la variable indiquee.

  if FBaseURL.Trim.IsEmpty then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    AError := 'API non configurée. Le devis reste enregistré localement.'; // Attribue une nouvelle valeur a la variable indiquee.
    Exit; // Quitte la procedure ou fonction a cet endroit.
  end; // Ferme le bloc ou la declaration en cours.

  try // Ouvre le bloc d instructions correspondant.
    FRESTClient.BaseURL := FBaseURL; // Attribue une nouvelle valeur a la variable indiquee.
    FRESTRequest.Resource := AEndpoint; // Attribue une nouvelle valeur a la variable indiquee.
    FRESTRequest.Method := rmPOST; // Attribue une nouvelle valeur a la variable indiquee.
    FRESTRequest.ClearBody; // Execute cette instruction dans le flux courant.
    FRESTRequest.AddBody(ABodyJSON, ContentTypeFromString('application/json')); // Appelle la methode ou fonction avec les parametres indiques.
    FRESTRequest.Execute; // Execute cette instruction dans le flux courant.

    if (FRESTResponse.StatusCode = 200) or (FRESTResponse.StatusCode = 201) then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      AResponseJSON := FRESTResponse.Content; // Attribue une nouvelle valeur a la variable indiquee.
      Result := True; // Affecte la valeur de retour de la fonction.
    end // Ferme le bloc ou la declaration en cours.
    else // Execute la branche alternative de la condition precedente.
    begin // Ouvre le bloc d instructions correspondant.
      AError := Format('Erreur HTTP %d : %s', [FRESTResponse.StatusCode, FRESTResponse.StatusText]); // Attribue une nouvelle valeur a la variable indiquee.
    end; // Ferme le bloc ou la declaration en cours.
  except // Ouvre le traitement des exceptions du bloc protege.
    on E: Exception do // Associe ce cas au traitement d exception indique.
      AError := 'Erreur d''envoi REST : ' + E.Message; // Attribue une nouvelle valeur a la variable indiquee.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TApiService.GetAsync(const AEndpoint: string; ACallback: TApiCallback); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Exécute le GET hors du thread UI puis invoque le callback dans la file UI.
  TThread.CreateAnonymousThread( // Appelle la methode ou fonction avec les parametres indiques.
    procedure // Complete la declaration ou instruction en cours.
    var // Ouvre la section de declarations correspondante.
      Res, Err: string; // Execute cette instruction dans le flux courant.
      Success: Boolean; // Execute cette instruction dans le flux courant.
    begin // Ouvre le bloc d instructions correspondant.
      Success := Get(AEndpoint, Res, Err); // Attribue une nouvelle valeur a la variable indiquee.
      TThread.Queue(nil, // Appelle la methode ou fonction avec les parametres indiques.
        procedure // Complete la declaration ou instruction en cours.
        begin // Ouvre le bloc d instructions correspondant.
          if Assigned(ACallback) then // Verifie la condition avant de poursuivre.
            ACallback(Success, Res, Err); // Appelle la methode ou fonction avec les parametres indiques.
        end); // Ferme le bloc ou la declaration en cours.
    end).Start; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TApiService.PostAsync(const AEndpoint, ABodyJSON: string; ACallback: TApiCallback); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Exécute le POST hors du thread UI puis restitue le résultat sur le thread UI.
  TThread.CreateAnonymousThread( // Appelle la methode ou fonction avec les parametres indiques.
    procedure // Complete la declaration ou instruction en cours.
    var // Ouvre la section de declarations correspondante.
      Res, Err: string; // Execute cette instruction dans le flux courant.
      Success: Boolean; // Execute cette instruction dans le flux courant.
    begin // Ouvre le bloc d instructions correspondant.
      Success := Post(AEndpoint, ABodyJSON, Res, Err); // Attribue une nouvelle valeur a la variable indiquee.
      TThread.Queue(nil, // Appelle la methode ou fonction avec les parametres indiques.
        procedure // Complete la declaration ou instruction en cours.
        begin // Ouvre le bloc d instructions correspondant.
          if Assigned(ACallback) then // Verifie la condition avant de poursuivre.
            ACallback(Success, Res, Err); // Appelle la methode ou fonction avec les parametres indiques.
        end); // Ferme le bloc ou la declaration en cours.
    end).Start; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
