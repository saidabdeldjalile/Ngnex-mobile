unit BarcodeService; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Classes, FMX.Media, FMX.Types, // Complete la declaration ou instruction en cours.
  Product, ProductService; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Notifie l'écran du code détecté, sans imposer de dépendance visuelle au service.
  TOnBarcodeScanned = reference to procedure(Sender: TObject; const ABarcode: string); // Execute cette instruction dans le flux courant.

  // Gère le démarrage et l'arrêt paresseux de la caméra ainsi que la recherche produit.
  TBarcodeService = class // Complete la declaration ou instruction en cours.
  private // Complete la declaration ou instruction en cours.
    FProductService: TProductService; // Execute cette instruction dans le flux courant.
    FCameraComponent: TCameraComponent; // Execute cette instruction dans le flux courant.
    FIsScanning: Boolean; // Execute cette instruction dans le flux courant.
    FOnScanned: TOnBarcodeScanned; // Execute cette instruction dans le flux courant.
    procedure EnsureCameraComponent; // Declare une procedure de cette unite ou classe.
  public // Complete la declaration ou instruction en cours.
    constructor Create(AProductService: TProductService); // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.

    procedure StartScanning(AOnScannedEvent: TOnBarcodeScanned); // Declare une procedure de cette unite ou classe.
    procedure StopScanning; // Declare une procedure de cette unite ou classe.
    function SimulateBarcodeScan(const ABarcode: string; AProduct: TProduct): Boolean; // Declare une fonction qui renvoie un resultat.

    property CameraComponent: TCameraComponent read FCameraComponent; // Expose une propriete de la classe.
    property IsScanning: Boolean read FIsScanning; // Expose une propriete de la classe.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

{ TBarcodeService }

constructor TBarcodeService.Create(AProductService: TProductService); // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Conserve le service de recherche ; la caméra n'est pas créée ici pour
  // éviter de demander la permission avant l'ouverture du scanner.
  inherited Create; // Appelle le comportement correspondant de la classe parente.
  FProductService := AProductService; // Attribue une nouvelle valeur a la variable indiquee.
  FIsScanning := False; // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

destructor TBarcodeService.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Arrête le matériel avant de libérer le composant caméra.
  if FIsScanning then // Verifie la condition avant de poursuivre.
    StopScanning; // Execute cette instruction dans le flux courant.
  FreeAndNil(FCameraComponent); // Appelle la methode ou fonction avec les parametres indiques.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

procedure TBarcodeService.EnsureCameraComponent; // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Crée la caméra arrière seulement au moment où l'utilisateur démarre le scan.
  if FCameraComponent = nil then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    FCameraComponent := TCameraComponent.Create(nil); // Attribue une nouvelle valeur a la variable indiquee.
    FCameraComponent.Kind := TCameraKind.BackCamera; // Attribue une nouvelle valeur a la variable indiquee.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TBarcodeService.StartScanning(AOnScannedEvent: TOnBarcodeScanned); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Enregistre le callback puis active la caméra ; en cas d'échec, restaure
  // l'état inactif et laisse l'exception remonter à l'écran appelant.
  FOnScanned := AOnScannedEvent; // Attribue une nouvelle valeur a la variable indiquee.
  try // Ouvre le bloc d instructions correspondant.
    EnsureCameraComponent; // Execute cette instruction dans le flux courant.
    FCameraComponent.Active := True; // Attribue une nouvelle valeur a la variable indiquee.
    FIsScanning := True; // Attribue une nouvelle valeur a la variable indiquee.
  except // Ouvre le traitement des exceptions du bloc protege.
    FIsScanning := False; // Attribue une nouvelle valeur a la variable indiquee.
    FOnScanned := nil; // Attribue une nouvelle valeur a la variable indiquee.
    raise; // Propage une exception pour signaler l echec.
  end; // Ferme le bloc ou la declaration en cours.
end; // Ferme le bloc ou la declaration en cours.

procedure TBarcodeService.StopScanning; // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Désactive le capteur et remet le service dans son état initial.
  if FCameraComponent <> nil then // Verifie la condition avant de poursuivre.
    FCameraComponent.Active := False; // Attribue une nouvelle valeur a la variable indiquee.
  FIsScanning := False; // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

function TBarcodeService.SimulateBarcodeScan(const ABarcode: string; AProduct: TProduct): Boolean; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Permet de tester le flux de recherche sans dépendre d'une caméra réelle.
  Result := False; // Affecte la valeur de retour de la fonction.
  if FProductService <> nil then // Verifie la condition avant de poursuivre.
  begin // Ouvre le bloc d instructions correspondant.
    Result := FProductService.FindByBarcode(ABarcode, AProduct); // Affecte la valeur de retour de la fonction.
  end; // Ferme le bloc ou la declaration en cours.
  if Assigned(FOnScanned) then // Verifie la condition avant de poursuivre.
    FOnScanned(Self, ABarcode); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
