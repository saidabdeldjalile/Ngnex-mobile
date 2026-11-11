unit AppTheme; // Declare le nom de cette unite Delphi.

{ Charte graphique moderne et palette de couleurs pour NGNEX Mobile.
  Style Modern High-Tech Commercial & Retail POS :
  - Bleu Saphir & Nuit d'Obsidienne (Tech, Fiabilite & POS Professionnel)
  - Orange Ambre Energetique (Conversion, Boutons d'action & Panier)
  - Vert Emeraude Vif (Disponibilite Stock & Validation)
  - Gris Slate Ultra-clair & Blanc Pur (Arriere-plans epures & Cartes en relief) }

interface // Ouvre la partie publique de cette unite.

uses // Declare les unites dont ce code depend.
  System.UITypes; // Execute cette instruction dans le flux courant.

const // Ouvre la section de declarations correspondante.
  // Couleurs Primaires (Brand NGNEX)
  COLOR_PRIMARY         = $FF1D4ED8; // Bleu Saphir Royal (plus profond et moderne)
  COLOR_PRIMARY_DARK    = $FF090D16; // Bleu Nuit Obsidienne (contraste maximal)
  COLOR_PRIMARY_LIGHT   = $FF3B82F6; // Bleu Cobalt vif
  COLOR_PRIMARY_TINT    = $FFEFF6FF; // Bleu glacier tres doux (chips et badges)

  // Couleurs d'Accentuation & Actions (Haute conversion)
  COLOR_ACCENT          = $FFF97316; // Orange Ambre Vif (Panier & Devis)
  COLOR_ACCENT_HOVER    = $FFEA580C; // Orange soutenu au survol
  COLOR_ACCENT_TINT     = $FFFFF7ED; // Fond ambre tres doux

  // Couleurs de Statut
  COLOR_SUCCESS         = $FF10B981; // Vert Emeraude (En stock, Valide)
  COLOR_SUCCESS_TINT    = $FFECFDF5; // Fond vert doux
  COLOR_DANGER          = $FFEF4444; // Rouge Corail (Rupture, Supprimer)
  COLOR_DANGER_TINT     = $FFFEF2F2; // Fond rouge doux
  COLOR_WARNING         = $FFF59E0B; // Ambre / Attention
  COLOR_WARNING_TINT    = $FFFFFBEB; // Fond ambre doux

  // Couleurs des Cartes d'Actions Rapides
  COLOR_QUICK_SCAN      = $FF0EA5E9; // Cyan / Bleu Ciel
  COLOR_QUICK_COMPARE   = $FF8B5CF6; // Violet Moderne
  COLOR_QUICK_CALC      = $FFF59E0B; // Ambre Dore
  COLOR_QUICK_QUOTE     = $FF10B981; // Vert Emeraude

  // Arriere-plans & Surfaces (Design System epure)
  COLOR_BG_PAGE         = $FFF8FAFC; // Fond de page Slate-50 ultra net et lumineux
  COLOR_SURFACE         = $FFFFFFFF; // Blanc pur pour cartes et conteneurs
  COLOR_SURFACE_ALT     = $FFF1F5F9; // Gris Slate-100 doux pour vignettes et conteneurs secondaires

  // Bordures & Separateurs
  COLOR_BORDER_LIGHT    = $FFE2E8F0; // Bordure subtile de carte 1px
  COLOR_BORDER_MEDIUM   = $FFCBD5E1; // Bordure de champ active

  // Typographie & Textes (Hierarchie optimisee)
  COLOR_TEXT_PRIMARY    = $FF0F172A; // Texte principal fonce Slate-900
  COLOR_TEXT_SECONDARY  = $FF64748B; // Texte secondaire Slate-500
  COLOR_TEXT_MUTED      = $FF94A3B8; // Textes desactives / placeholder Slate-400
  COLOR_TEXT_WHITE      = $FFFFFFFF; // Blanc pur sur fond colore

  // Rayons, espacements et tailles de police du design system (Standard Mobile Pro)
  RADIUS_CARD           = 16;        // Cartes de contenu (courbures douces modernes)
  RADIUS_BUTTON         = 12;        // Boutons et champs tactiles
  RADIUS_SMALL          = 10;        // Vignettes d'images et petits blocs
  RADIUS_PILL           = 24;        // Badges et pilules de statut
  SPACING_PAGE          = 14;        // Marge laterale des ecrans
  SPACING_CARD          = 12;        // Espace entre deux cartes

  FONT_SIZE_PAGE_TITLE  = 18;        // Titre d'ecran principal
  FONT_SIZE_SECTION     = 16;        // Titre de section
  FONT_SIZE_CARD_TITLE  = 13;        // Titre de carte produit
  FONT_SIZE_BODY        = 12;        // Texte courant
  FONT_SIZE_CAPTION     = 11;        // Legendes et references

implementation // Ouvre la partie contenant les implementations privees.

end. // Ferme le bloc ou la declaration en cours.
