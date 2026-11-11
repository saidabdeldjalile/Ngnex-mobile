unit Customer; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils, System.Classes, System.JSON; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Coordonnées saisies par le client pour une demande de devis.
  TCustomer = class // Complete la declaration ou instruction en cours.
  private // Complete la declaration ou instruction en cours.
    FFullName: string; // Execute cette instruction dans le flux courant.
    FCompanyName: string; // Execute cette instruction dans le flux courant.
    FPhone: string; // Execute cette instruction dans le flux courant.
    FEmail: string; // Execute cette instruction dans le flux courant.
    FAddress: string; // Execute cette instruction dans le flux courant.
  public // Complete la declaration ou instruction en cours.
    constructor Create; // Declare le constructeur de cet objet.
    destructor Destroy; override; // Declare le destructeur de cet objet.

    function ToJSONObject: TJSONObject; // Declare une fonction qui renvoie un resultat.
    procedure FromJSONObject(AJSONObj: TJSONObject); // Declare une procedure de cette unite ou classe.

    property FullName: string read FFullName write FFullName; // Expose une propriete de la classe.
    property CompanyName: string read FCompanyName write FCompanyName; // Expose une propriete de la classe.
    property Phone: string read FPhone write FPhone; // Expose une propriete de la classe.
    property Email: string read FEmail write FEmail; // Expose une propriete de la classe.
    property Address: string read FAddress write FAddress; // Expose une propriete de la classe.
  end; // Ferme le bloc ou la declaration en cours.

implementation // Ouvre la partie contenant les implementations privees.

{ TCustomer }

constructor TCustomer.Create; // Declare le constructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  // Garantit que les champs facultatifs disposent d'une chaîne vide par défaut.
  inherited Create; // Appelle le comportement correspondant de la classe parente.
  FFullName := ''; // Attribue une nouvelle valeur a la variable indiquee.
  FCompanyName := ''; // Attribue une nouvelle valeur a la variable indiquee.
  FPhone := ''; // Attribue une nouvelle valeur a la variable indiquee.
  FEmail := ''; // Attribue une nouvelle valeur a la variable indiquee.
  FAddress := ''; // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

destructor TCustomer.Destroy; // Declare le destructeur de cet objet.
begin // Ouvre le bloc d instructions correspondant.
  inherited Destroy; // Appelle le comportement correspondant de la classe parente.
end; // Ferme le bloc ou la declaration en cours.

function TCustomer.ToJSONObject: TJSONObject; // Declare une fonction qui renvoie un resultat.
begin // Ouvre le bloc d instructions correspondant.
  // Sérialise les coordonnées avec les noms de champs utilisés par l'API.
  Result := TJSONObject.Create; // Affecte la valeur de retour de la fonction.
  Result.AddPair('customer_name', FFullName); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('company_name', FCompanyName); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('customer_phone', FPhone); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('customer_email', FEmail); // Appelle la methode ou fonction avec les parametres indiques.
  Result.AddPair('address', FAddress); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure TCustomer.FromJSONObject(AJSONObj: TJSONObject); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  Val: TJSONValue; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Met à jour les champs présents dans l'objet JSON.
  if AJSONObj = nil then Exit; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('customer_name'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FFullName := Val.Value; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('company_name'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FCompanyName := Val.Value; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('customer_phone'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FPhone := Val.Value; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('customer_email'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FEmail := Val.Value; // Verifie la condition avant de poursuivre.

  Val := AJSONObj.GetValue('address'); // Attribue une nouvelle valeur a la variable indiquee.
  if Val <> nil then FAddress := Val.Value; // Verifie la condition avant de poursuivre.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
