unit ImageService; // Declare le nom de cette unite Delphi.

{ Service de chargement et gestion des images, photos et visuels
  pour l'application NGNEX Mobile (Windows & Android FMX). }

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Classes, System.IOUtils, System.Types, // Complete la declaration ou instruction en cours.
  System.UITypes, FMX.Types, FMX.Graphics, FMX.Objects, // Complete la declaration ou instruction en cours.
  System.Net.HttpClient; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Centralise le chargement d'images locales ou distantes et fournit un
  // visuel de remplacement lorsque nécessaire.
  TImageService = class // Complete la declaration ou instruction en cours.
  private // Complete la declaration ou instruction en cours.
    FAssetsPath: string; // Execute cette instruction dans le flux courant.
    FHttp: THTTPClient; // Execute cette instruction dans le flux courant.
    FAllowRemoteImages: Boolean; // Execute cette instruction dans le flux courant.
    function FindLocalImagePath(const AFileName: string): string; // Declare une fonction qui renvoie un resultat.
  public // Complete la declaration ou instruction en cours.
    constructor Create; // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.

    function LoadBitmap(const AFileNameOrUrl: string; ABitmap: TBitmap): Boolean; // Declare une fonction qui renvoie un resultat.
    function LoadIntoImage(const AFileNameOrUrl: string; AImage: TImage): Boolean; // Declare une fonction qui renvoie un resultat.
    procedure LoadIntoImageAsync(const AFileNameOrUrl: string; AImage: TImage); // Declare une procedure de cette unite ou classe.

    // Dessin de secours vectoriel dynamique
    procedure RenderFallback(ABitmap: TBitmap; const ATitle: string; // Declare une procedure de cette unite ou classe.
      const ABgColor: TAlphaColor); // Execute cette instruction dans le flux courant.

    property AssetsPath: string read FAssetsPath; // Expose une propriete de la classe.
    property AllowRemoteImages: Boolean read FAllowRemoteImages write FAllowRemoteImages; // Expose une propriete de la classe.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

{ TImageService }

constructor TImageService.Create; // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Configure les délais réseau puis choisit le répertoire d'assets selon
  // la plateforme d'exécution.
  inherited Create; // Appelle le comportement correspondant de la classe parente.
  FAllowRemoteImages := True; // Attribue une nouvelle valeur a la variable indiquee.
  FHttp := THTTPClient.Create; // Attribue une nouvelle valeur a la variable indiquee.
  FHttp.ConnectionTimeout := 5000; // Attribue une nouvelle valeur a la variable indiquee.
  FHttp.ResponseTimeout := 8000; // Attribue une nouvelle valeur a la variable indiquee.

  // Détection du chemin des assets selon la plateforme
  {$IFDEF ANDROID} // Active la compilation conditionnelle pour la configuration visee.
  FAssetsPath := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'Assets/Images'); // Attribue une nouvelle valeur a la variable indiquee.
  if not TDirectory.Exists(FAssetsPath) then // Verifie la condition avant de poursuivre.
    FAssetsPath := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetHomePath, 'assets/internal'); // Attribue une nouvelle valeur a la variable indiquee.
  {$ELSE} // Selectionne la branche alternative de compilation conditionnelle.
  // Windows / Desktop
  FAssetsPath := System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), 'Assets\Images'); // Attribue une nouvelle valeur a la variable indiquee.
  if not TDirectory.Exists(FAssetsPath) then // Verifie la condition avant de poursuivre.
    FAssetsPath := System.IOUtils.TPath.Combine(GetCurrentDir, 'Assets\Images'); // Attribue une nouvelle valeur a la variable indiquee.
  {$ENDIF} // Termine la compilation conditionnelle ouverte plus haut.
end; // Ferme le bloc ou la declaration en cours.

destructor TImageService.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Libère le client HTTP partagé par les téléchargements d'images.
  FreeAndNil(FHttp); // Appelle la methode ou fonction avec les parametres indiques.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

function TImageService.FindLocalImagePath(const AFileName: string): string; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  CleanName: string; // Execute cette instruction dans le flux courant.
  Candidates: TArray<string>; // Execute cette instruction dans le flux courant.
  Candidate: string; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Essaie les emplacements de déploiement connus avant d'ouvrir le fichier.
  Result := ''; // Affecte la valeur de retour de la fonction.
  if AFileName.Trim.IsEmpty then Exit; // Verifie la condition avant de poursuivre.

  CleanName := ExtractFileName(AFileName); // Attribue une nouvelle valeur a la variable indiquee.

  Candidates := [ // Attribue une nouvelle valeur a la variable indiquee.
    System.IOUtils.TPath.Combine(FAssetsPath, CleanName), // Appelle la methode ou fonction avec les parametres indiques.
    System.IOUtils.TPath.Combine(GetCurrentDir, 'Assets\Images\' + CleanName), // Appelle la methode ou fonction avec les parametres indiques.
    System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), 'Assets\Images\' + CleanName), // Appelle la methode ou fonction avec les parametres indiques.
    System.IOUtils.TPath.GetFullPath( // Appelle la methode ou fonction avec les parametres indiques.
      System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), // Appelle la methode ou fonction avec les parametres indiques.
        '..\..\Assets\Images\' + CleanName)), // Complete la declaration ou instruction en cours.
    System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), CleanName), // Appelle la methode ou fonction avec les parametres indiques.
    {$IFDEF ANDROID} // Active la compilation conditionnelle pour la configuration visee.
    System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, CleanName), // Appelle la methode ou fonction avec les parametres indiques.
    System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetHomePath, CleanName), // Appelle la methode ou fonction avec les parametres indiques.
    System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetHomePath, 'assets/internal/' + CleanName), // Appelle la methode ou fonction avec les parametres indiques.
    {$ENDIF} // Termine la compilation conditionnelle ouverte plus haut.
    AFileName // Complete la declaration ou instruction en cours.
  ]; // Execute cette instruction dans le flux courant.

  for Candidate in Candidates do // Parcourt les elements ou valeurs de cette boucle.
  begin // Ouvre le bloc d instructions correspondant.
    if TFile.Exists(Candidate) then // Verifie la condition avant de poursuivre.
    begin // Ouvre le bloc d instructions correspondant.
      Result := Candidate; // Affecte la valeur de retour de la fonction.
      Exit; // Quitte la procedure ou fonction a cet endroit.
    end; // Ferme le bloc ou la declaration en cours.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

function TImageService.LoadBitmap(const AFileNameOrUrl: string; ABitmap: TBitmap): Boolean; // Declare une fonction qui renvoie un resultat.
var // Ouvre la section de declarations correspondante.
  LocalPath: string; // Execute cette instruction dans le flux courant.
  MemStream: TMemoryStream; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Priorise les assets locaux ; une requête HTTP n'est faite que si les images
  // distantes sont autorisées et que l'entrée est une URL.
  Result := False; // Affecte la valeur de retour de la fonction.
  if (ABitmap = nil) or (AFileNameOrUrl.Trim.IsEmpty) then Exit; // Verifie la condition avant de poursuivre.

  // 1. Recherche en local
  LocalPath := FindLocalImagePath(AFileNameOrUrl); // Attribue une nouvelle valeur a la variable indiquee.
  if not LocalPath.IsEmpty then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    try // Ouvre le bloc d instructions correspondant.
      ABitmap.LoadFromFile(LocalPath); // Appelle la methode ou fonction avec les parametres indiques.
      Result := True; // Affecte la valeur de retour de la fonction.
      Exit; // Quitte la procedure ou fonction a cet endroit.
    except // Ouvre le traitement des exceptions du bloc protege.
      Result := False; // Affecte la valeur de retour de la fonction.
    end; // Ferme le bloc ou la declaration en cours.
  end; // Ferme le bloc ou la declaration en cours.

  // 2. Si c'est une URL HTTP/HTTPS
  if FAllowRemoteImages and // Verifie la condition avant de poursuivre.
    (AFileNameOrUrl.ToLower.StartsWith('http://') or // Complete la declaration ou instruction en cours.
     AFileNameOrUrl.ToLower.StartsWith('https://')) then // Appelle la methode ou fonction avec les parametres indiques.
  begin // Ouvre le bloc d instructions correspondant.
    MemStream := TMemoryStream.Create; // Attribue une nouvelle valeur a la variable indiquee.
    try // Ouvre le bloc d instructions correspondant.
      try // Ouvre le bloc d instructions correspondant.
        if FHttp.Get(AFileNameOrUrl, MemStream).StatusCode = 200 then // Verifie la condition avant de poursuivre.
        begin // Ouvre le bloc d instructions correspondant.
          MemStream.Position := 0; // Attribue une nouvelle valeur a la variable indiquee.
          ABitmap.LoadFromStream(MemStream); // Appelle la methode ou fonction avec les parametres indiques.
          Result := True; // Affecte la valeur de retour de la fonction.
        end; // Ferme le bloc ou la declaration en cours.
      except // Ouvre le traitement des exceptions du bloc protege.
        Result := False; // Affecte la valeur de retour de la fonction.
      end; // Ferme le bloc ou la declaration en cours.
    finally // Ouvre le nettoyage garanti meme apres une exception.
      MemStream.Free; // Execute cette instruction dans le flux courant.
    end; // Ferme le bloc ou la declaration en cours.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

function TImageService.LoadIntoImage(const AFileNameOrUrl: string; AImage: TImage): Boolean; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Charge directement dans le bitmap visuel du contrôle FireMonkey.
  Result := False; // Affecte la valeur de retour de la fonction.
  if AImage = nil then Exit; // Verifie la condition avant de poursuivre.

  AImage.WrapMode := TImageWrapMode.Fit; // Attribue une nouvelle valeur a la variable indiquee.
  Result := LoadBitmap(AFileNameOrUrl, AImage.Bitmap); // Affecte la valeur de retour de la fonction.
end; // Ferme le bloc ou la declaration en cours.

procedure TImageService.LoadIntoImageAsync(const AFileNameOrUrl: string; AImage: TImage); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Déplace le chargement hors du thread UI, puis applique le bitmap sur le
  // thread principal si le contrôle existe encore.
  if (AImage = nil) or (AFileNameOrUrl.Trim.IsEmpty) then Exit; // Verifie la condition avant de poursuivre.

  TThread.CreateAnonymousThread( // Appelle la methode ou fonction avec les parametres indiques.
    procedure // Complete la declaration ou instruction en cours.
    var // Ouvre la section de declarations correspondante.
      Bmp: TBitmap; // Execute cette instruction dans le flux courant.
      Success: Boolean; // Execute cette instruction dans le flux courant.
    begin // Ouvre le bloc d instructions correspondant.
      Bmp := TBitmap.Create; // Attribue une nouvelle valeur a la variable indiquee.
      try // Ouvre le bloc d instructions correspondant.
        Success := LoadBitmap(AFileNameOrUrl, Bmp); // Attribue une nouvelle valeur a la variable indiquee.
        if Success then // Verifie la condition avant de poursuivre.
        begin // Ouvre le bloc d instructions correspondant.
          TThread.Synchronize(nil, // Appelle la methode ou fonction avec les parametres indiques.
            TThreadProcedure( // Appelle la methode ou fonction avec les parametres indiques.
              procedure // Complete la declaration ou instruction en cours.
              begin // Ouvre le bloc d instructions correspondant.
                if (AImage <> nil) and not (csDestroying in AImage.ComponentState) then // Verifie la condition avant de poursuivre.
                begin // Ouvre le bloc d instructions correspondant.
                  AImage.Bitmap.Assign(Bmp); // Appelle la methode ou fonction avec les parametres indiques.
                  AImage.WrapMode := TImageWrapMode.Fit; // Attribue une nouvelle valeur a la variable indiquee.
                  AImage.Repaint; // Execute cette instruction dans le flux courant.
                end; // Ferme le bloc ou la declaration en cours.
              end)); // Ferme le bloc ou la declaration en cours.
        end; // Ferme le bloc ou la declaration en cours.
      finally // Ouvre le nettoyage garanti meme apres une exception.
        Bmp.Free; // Execute cette instruction dans le flux courant.
      end; // Ferme le bloc ou la declaration en cours.
    end).Start; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TImageService.RenderFallback(ABitmap: TBitmap; const ATitle: string; // Declare une procedure de cette unite ou classe.
  const ABgColor: TAlphaColor); // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Dessine un visuel simple contenant le titre quand aucune image n'est disponible.
  if ABitmap = nil then Exit; // Verifie la condition avant de poursuivre.
  ABitmap.SetSize(300, 200); // Appelle la methode ou fonction avec les parametres indiques.
  ABitmap.Clear(ABgColor); // Appelle la methode ou fonction avec les parametres indiques.
  if ABitmap.Canvas.BeginScene then // Verifie la condition avant de poursuivre.
  try // Ouvre le bloc d instructions correspondant.
    ABitmap.Canvas.Fill.Color := $FFFFFFFF; // Attribue une nouvelle valeur a la variable indiquee.
    ABitmap.Canvas.Font.Size := 14; // Attribue une nouvelle valeur a la variable indiquee.
    ABitmap.Canvas.Font.Style := [TFontStyle.fsBold]; // Attribue une nouvelle valeur a la variable indiquee.
    ABitmap.Canvas.FillText( // Appelle la methode ou fonction avec les parametres indiques.
      TRectF.Create(10, 10, 290, 190), // Appelle la methode ou fonction avec les parametres indiques.
      ATitle, // Complete la declaration ou instruction en cours.
      True, // Complete la declaration ou instruction en cours.
      1.0, // Complete la declaration ou instruction en cours.
      [], // Complete la declaration ou instruction en cours.
      TTextAlign.Center, // Complete la declaration ou instruction en cours.
      TTextAlign.Center // Complete la declaration ou instruction en cours.
    ); // Execute cette instruction dans le flux courant.
  finally // Ouvre le nettoyage garanti meme apres une exception.
    ABitmap.Canvas.EndScene; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
