unit CategoryService; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Classes, System.JSON, // Complete la declaration ou instruction en cours.
  Category, DatabaseService, ApiService; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Callback signalant le résultat de la synchronisation des catégories.
  TCategoryApiCallback = reference to procedure(const ASuccess: Boolean; const AMessage: string); // Execute cette instruction dans le flux courant.

  // Coordonne la lecture locale et la récupération distante des catégories.
  TCategoryService = class // Complete la declaration ou instruction en cours.
  private // Complete la declaration ou instruction en cours.
    FDatabaseService: TDatabaseService; // Execute cette instruction dans le flux courant.
    FApiService: TApiService; // Execute cette instruction dans le flux courant.
  public // Complete la declaration ou instruction en cours.
    constructor Create(ADatabaseService: TDatabaseService; AApiService: TApiService); // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.

    function LoadCategories(AList: TCategoryList): Boolean; // Declare une fonction qui renvoie un resultat.
    procedure SyncCategoriesWithServer(AOnComplete: TCategoryApiCallback); // Declare une procedure de cette unite ou classe.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

{ TCategoryService }

constructor TCategoryService.Create(ADatabaseService: TDatabaseService; AApiService: TApiService); // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Garde les dépendances partagées sans en prendre la propriété.
  inherited Create; // Appelle le comportement correspondant de la classe parente.
  FDatabaseService := ADatabaseService; // Attribue une nouvelle valeur a la variable indiquee.
  FApiService := AApiService; // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

destructor TCategoryService.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

function TCategoryService.LoadCategories(AList: TCategoryList): Boolean; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Les écrans utilisent le catalogue local pour rester disponibles hors ligne.
  if FDatabaseService <> nil then // Verifie la condition avant de poursuivre.
    Result := FDatabaseService.GetCategories(AList) // Affecte la valeur de retour de la fonction.
  else // Execute la branche alternative de la condition precedente.
    Result := False; // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

procedure TCategoryService.SyncCategoriesWithServer(AOnComplete: TCategoryApiCallback); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Demande les catégories au serveur ; le callback reçoit explicitement toute erreur.
  if FApiService = nil then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    if Assigned(AOnComplete) then AOnComplete(False, 'Service API non configuré.'); // Verifie la condition avant de poursuivre.
    Exit; // Quitte la procedure ou fonction a cet endroit.
  end; // Ferme le bloc ou la declaration en cours.

  FApiService.GetAsync('/categories', // Appelle la methode ou fonction avec les parametres indiques.
    procedure(const ASuccess: Boolean; const AResponseContent: string; const AErrorMessage: string) // Appelle la methode ou fonction avec les parametres indiques.
    var // Ouvre la section de declarations correspondante.
      JSONArr: TJSONArray; // Execute cette instruction dans le flux courant.
      CatList: TCategoryList; // Execute cette instruction dans le flux courant.
    begin // Ouvre le bloc d instructions correspondant.
      if ASuccess then // Verifie la condition avant de poursuivre.
      begin // Ouvre le bloc d instructions correspondant.
        CatList := TCategoryList.Create; // Attribue une nouvelle valeur a la variable indiquee.
        try // Ouvre le bloc d instructions correspondant.
          JSONArr := TJSONObject.ParseJSONValue(AResponseContent) as TJSONArray; // Attribue une nouvelle valeur a la variable indiquee.
          if JSONArr <> nil then // Verifie la condition avant de poursuivre.
          begin // Ouvre le bloc d instructions correspondant.
            try // Ouvre le bloc d instructions correspondant.
              CatList.FromJSONArray(JSONArr); // Appelle la methode ou fonction avec les parametres indiques.
            finally // Ouvre le nettoyage garanti meme apres une exception.
              JSONArr.Free; // Execute cette instruction dans le flux courant.
            end; // Ferme le bloc ou la declaration en cours.
          end; // Ferme le bloc ou la declaration en cours.
        finally // Ouvre le nettoyage garanti meme apres une exception.
          CatList.Free; // Execute cette instruction dans le flux courant.
        end; // Ferme le bloc ou la declaration en cours.

        if Assigned(AOnComplete) then // Verifie la condition avant de poursuivre.
          AOnComplete(True, 'Catégories synchronisées avec succès.'); // Appelle la methode ou fonction avec les parametres indiques.
      end // Ferme le bloc ou la declaration en cours.
      else // Execute la branche alternative de la condition precedente.
      begin // Ouvre le bloc d instructions correspondant.
        if Assigned(AOnComplete) then // Verifie la condition avant de poursuivre.
          AOnComplete(False, AErrorMessage); // Appelle la methode ou fonction avec les parametres indiques.
      end; // Ferme le bloc ou la declaration en cours.
    end); // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
