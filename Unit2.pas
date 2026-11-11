unit Unit2; // Declare le nom de cette unite Delphi.

{ Constantes historiques globales de NGNEX Mobile.
  Les écrans actifs utilisent principalement les constantes de AppTheme. }

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.UITypes; // Execute cette instruction dans le flux courant.

const // Ouvre la section de declarations correspondante.
  // Métadonnées de l'application et nom historique du fichier de base locale.
  APP_NAME    = 'NGNEX Mobile'; // Execute cette instruction dans le flux courant.
  APP_VERSION = '1.0.0'; // Execute cette instruction dans le flux courant.
  DB_FILENAME = 'ngnex.db'; // Execute cette instruction dans le flux courant.
  CURRENCY    = 'DA'; // Execute cette instruction dans le flux courant.

  // Palette historique au format $AARRGGBB, conservée pour compatibilité.
  COLOR_PRIMARY_DARK : TAlphaColor = $FF0A1F44;  // bleu foncé
  COLOR_PRIMARY      : TAlphaColor = $FF1E6BFF;  // bleu électrique
  COLOR_WHITE        : TAlphaColor = $FFFFFFFF; // Execute cette instruction dans le flux courant.
  COLOR_BACKGROUND   : TAlphaColor = $FFF4F7FC;  // fond clair
  COLOR_TEXT         : TAlphaColor = $FF1B2433; // Execute cette instruction dans le flux courant.
  COLOR_TEXT_MUTED   : TAlphaColor = $FF6B7A90; // Execute cette instruction dans le flux courant.
  COLOR_SUCCESS      : TAlphaColor = $FF22A06B; // Execute cette instruction dans le flux courant.
  COLOR_DANGER       : TAlphaColor = $FFD64545; // Execute cette instruction dans le flux courant.

implementation // Ouvre la partie contenant les implementations privees.

end. // Ferme le bloc ou la declaration en cours.
