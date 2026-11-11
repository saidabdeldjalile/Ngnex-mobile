unit StartupDiagnostics; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.SysUtils; // Execute cette instruction dans le flux courant.

procedure InitializeStartupDiagnostics; // Declare une procedure de cette unite ou classe.
procedure LogStartup(const AMessage: string); // Declare une procedure de cette unite ou classe.
procedure LogStartupException(const AContext: string; E: Exception); // Declare une procedure de cette unite ou classe.

implementation // Ouvre la partie contenant les implementations privees.

uses // Declare les unites dont ce code depend.
  FMX.Forms, // Complete la declaration ou instruction en cours.
  {$IFDEF ANDROID} // Active la compilation conditionnelle pour la configuration visee.
  Androidapi.Log, // Complete la declaration ou instruction en cours.
  {$ENDIF} // Termine la compilation conditionnelle ouverte plus haut.
  System.Classes; // Execute cette instruction dans le flux courant.

type // Ouvre la section de declarations correspondante.
  // Adaptateur reliant les exceptions non gérées de FMX au journal de démarrage.
  TStartupExceptionLogger = class // Complete la declaration ou instruction en cours.
  public // Complete la declaration ou instruction en cours.
    procedure HandleException(Sender: TObject; E: Exception); // Declare une procedure de cette unite ou classe.
  end; // Ferme le bloc ou la declaration en cours.

var // Ouvre la section de declarations correspondante.
  StartupExceptionLogger: TStartupExceptionLogger; // Execute cette instruction dans le flux courant.

procedure LogStartup(const AMessage: string); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Écrit les étapes de démarrage dans Logcat sur Android.
  {$IFDEF ANDROID} // Active la compilation conditionnelle pour la configuration visee.
  Androidapi.Log.LOGI(MarshaledAString(Utf8Encode(AMessage))); // Appelle la methode ou fonction avec les parametres indiques.
  {$ENDIF} // Termine la compilation conditionnelle ouverte plus haut.
end; // Ferme le bloc ou la declaration en cours.

procedure LogStartupException(const AContext: string; E: Exception); // Declare une procedure de cette unite ou classe.
var // Ouvre la section de declarations correspondante.
  Details: string; // Execute cette instruction dans le flux courant.
begin // Ouvre le bloc d instructions correspondant.
  // Ajoute le type, le message et la pile d'appels pour faciliter le diagnostic.
  if E = nil then // Verifie la condition avant de poursuivre.
    Exit; // Quitte la procedure ou fonction a cet endroit.
  Details := AContext + ': ' + E.ClassName + ': ' + E.Message; // Attribue une nouvelle valeur a la variable indiquee.
  if not E.StackTrace.IsEmpty then // Verifie la condition avant de poursuivre.
    Details := Details + sLineBreak + E.StackTrace; // Attribue une nouvelle valeur a la variable indiquee.
  {$IFDEF ANDROID} // Active la compilation conditionnelle pour la configuration visee.
  Androidapi.Log.LOGE(MarshaledAString( // Appelle la methode ou fonction avec les parametres indiques.
    Utf8Encode(Details))); // Appelle la methode ou fonction avec les parametres indiques.
  {$ENDIF} // Termine la compilation conditionnelle ouverte plus haut.
end; // Ferme le bloc ou la declaration en cours.

procedure TStartupExceptionLogger.HandleException(Sender: TObject; E: Exception); // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Journalise l'exception puis conserve l'affichage standard de FireMonkey.
  LogStartupException('NGNEX unhandled application exception', E); // Appelle la methode ou fonction avec les parametres indiques.
  Application.ShowException(E); // Appelle la methode ou fonction avec les parametres indiques.
end; // Ferme le bloc ou la declaration en cours.

procedure InitializeStartupDiagnostics; // Declare une procedure de cette unite ou classe.
begin // Ouvre le bloc d instructions correspondant.
  // Installe une seule instance du gestionnaire global d'exceptions de l'application.
  if StartupExceptionLogger = nil then // Verifie la condition avant de poursuivre.
    StartupExceptionLogger := TStartupExceptionLogger.Create; // Attribue une nouvelle valeur a la variable indiquee.
  Application.OnException := StartupExceptionLogger.HandleException; // Attribue une nouvelle valeur a la variable indiquee.
end; // Ferme le bloc ou la declaration en cours.

end. // Ferme le bloc ou la declaration en cours.
