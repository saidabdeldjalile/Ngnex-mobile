unit ProductPhotoCatalog; // Declare le nom de cette unite Delphi.

interface // Ouvre la partie publique de cette unite.

type // Ouvre la section de declarations correspondante.
  // Données immuables permettant de créer un produit de catalogue illustré.
  // Le prix et le stock restent à confirmer et ne sont donc pas définis ici.
  TProductPhotoSeed = record // Complete la declaration ou instruction en cours.
    CategoryID: Integer; // Execute cette instruction dans le flux courant.
    Reference: string; // Execute cette instruction dans le flux courant.
    Name: string; // Execute cette instruction dans le flux courant.
    ImageFileName: string; // Execute cette instruction dans le flux courant.
  end; // Ferme le bloc ou la declaration en cours.

const // Ouvre la section de declarations correspondante.
  // Catalogue photo local, inséré de manière idempotente par DatabaseService.
  // Chaque entrée relie une catégorie, une référence, un libellé et une image.
  PHOTO_PRODUCT_CATALOG: array[0..78] of TProductPhotoSeed = ( // Complete la declaration ou instruction en cours.
    (CategoryID: 1; Reference: 'PHOTO-001'; Name: 'Tout-en-un MSI AE200 tactile 19,5 pouces, 8 Go, SSD 128 Go'; ImageFileName: 'catalog_product_001.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 1; Reference: 'PHOTO-002'; Name: 'Tout-en-un Enegma i3 4e génération, SSD 128 Go, batterie'; ImageFileName: 'catalog_product_002.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 1; Reference: 'PHOTO-003'; Name: 'Tout-en-un Enegma i3 4e génération avec imprimante et batterie'; ImageFileName: 'catalog_product_003.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 1; Reference: 'PHOTO-004'; Name: 'Tout-en-un Lenovo i3 4e génération, 4 Go, HDD 500 Go (occasion)'; ImageFileName: 'catalog_product_004.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 1; Reference: 'PHOTO-005'; Name: 'Tout-en-un MSI 21 pouces, processeur AMD'; ImageFileName: 'catalog_product_005.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 1; Reference: 'PHOTO-006'; Name: 'Tout-en-un SafePos Pro, i5 3e génération, 8 Go, SSD 128 Go'; ImageFileName: 'catalog_product_006.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 1; Reference: 'PHOTO-007'; Name: 'Tout-en-un SafePos, i5, 8 Go, SSD 128 Go'; ImageFileName: 'catalog_product_007.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 5; Reference: 'PHOTO-008'; Name: 'Balance ACLAS S6'; ImageFileName: 'catalog_product_008.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 5; Reference: 'PHOTO-009'; Name: 'Balance Rengta RLS 1000'; ImageFileName: 'catalog_product_009.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 4; Reference: 'PHOTO-010'; Name: 'Tiroir-caisse Smart RJ11, 415 mm'; ImageFileName: 'catalog_product_010.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 6; Reference: 'PHOTO-011'; Name: 'Carton d''étiquettes 2040, 20 unités'; ImageFileName: 'catalog_product_011.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 6; Reference: 'PHOTO-012'; Name: 'Étiquettes pour balance 45 x 58 mm, 20 rouleaux'; ImageFileName: 'catalog_product_012.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 6; Reference: 'PHOTO-013'; Name: 'Étiquettes pour balance 45 x 58 mm, 48 rouleaux'; ImageFileName: 'catalog_product_013.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 6; Reference: 'PHOTO-014'; Name: 'Étiquettes pour balance 45 x 58 mm, 60 rouleaux'; ImageFileName: 'catalog_product_014.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 4; Reference: 'PHOTO-015'; Name: 'Tiroir-caisse 410 mm'; ImageFileName: 'catalog_product_015.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 1; Reference: 'PHOTO-016'; Name: 'Écran HP 17 pouces'; ImageFileName: 'catalog_product_016.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 1; Reference: 'PHOTO-017'; Name: 'Écran HP 19 pouces'; ImageFileName: 'catalog_product_017.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 1; Reference: 'PHOTO-018'; Name: 'Écran Enegma 19 pouces HDMI'; ImageFileName: 'catalog_product_018.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 1; Reference: 'PHOTO-019'; Name: 'Écran tactile HFPOS 15 pouces'; ImageFileName: 'catalog_product_019.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 1; Reference: 'PHOTO-020'; Name: 'Écran tactile HFPOS 15,6 pouces'; ImageFileName: 'catalog_product_020.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 1; Reference: 'PHOTO-021'; Name: 'Terminal tactile HFPOS i5 avec afficheur N700'; ImageFileName: 'catalog_product_021.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-022'; Name: 'Imprimante tickets Smart POS 802 USB et Wi-Fi'; ImageFileName: 'catalog_product_022.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-023'; Name: 'Imprimante de bordereaux Smart SP9025D'; ImageFileName: 'catalog_product_023.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-024'; Name: 'Imprimante laser Canon LBP 6030'; ImageFileName: 'catalog_product_024.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-025'; Name: 'Imprimante multifonction Canon MF 3010'; ImageFileName: 'catalog_product_025.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-026'; Name: 'Imprimante tickets CB Smart 80VI USB série'; ImageFileName: 'catalog_product_026.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-027'; Name: 'Imprimante CB Smart POS RP411'; ImageFileName: 'catalog_product_027.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-028'; Name: 'Imprimante code-barres 2120 USB'; ImageFileName: 'catalog_product_028.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-029'; Name: 'Imprimante code-barres XP-233B'; ImageFileName: 'catalog_product_029.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-030'; Name: 'Imprimante tickets Exprinter XP-N160II'; ImageFileName: 'catalog_product_030.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-031'; Name: 'Imprimante tickets Smart 335'; ImageFileName: 'catalog_product_031.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-032'; Name: 'Imprimante thermique 80180'; ImageFileName: 'catalog_product_032.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-033'; Name: 'Imprimante tickets SafePos 80250'; ImageFileName: 'catalog_product_033.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-034'; Name: 'Imprimante tickets Smart RP-330'; ImageFileName: 'catalog_product_034.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-035'; Name: 'Imprimante tickets Smart RP-332 réseau'; ImageFileName: 'catalog_product_035.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-036'; Name: 'Imprimante tickets Smart SP331'; ImageFileName: 'catalog_product_036.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-037'; Name: 'Imprimante tickets Xprinter D200N USB et LAN'; ImageFileName: 'catalog_product_037.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-038'; Name: 'Imprimante tickets Xprinter XP-D260N'; ImageFileName: 'catalog_product_038.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-039'; Name: 'Imprimante Wi-Fi SP 300I'; ImageFileName: 'catalog_product_039.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-040'; Name: 'Imprimante Wi-Fi SP 300IW'; ImageFileName: 'catalog_product_040.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-041'; Name: 'Imprimante Xprinter XP-Q80K Wi-Fi'; ImageFileName: 'catalog_product_041.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-042'; Name: 'Imprimante Xprinter XP-Q302F'; ImageFileName: 'catalog_product_042.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 2; Reference: 'PHOTO-043'; Name: 'Imprimante Xprinter XP-Q371U'; ImageFileName: 'catalog_product_043.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 3; Reference: 'PHOTO-044'; Name: 'Lecteur code-barres Smart SP-6221 avec support'; ImageFileName: 'catalog_product_044.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 3; Reference: 'PHOTO-045'; Name: 'Lecteur code-barres carré SP-9608H'; ImageFileName: 'catalog_product_045.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 3; Reference: 'PHOTO-046'; Name: 'Lecteur code-barres fixe Smart XB-8602'; ImageFileName: 'catalog_product_046.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 3; Reference: 'PHOTO-047'; Name: 'Lecteur code-barres HENEX HC-3208R avec support'; ImageFileName: 'catalog_product_047.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 3; Reference: 'PHOTO-048'; Name: 'Lecteur code-barres anneau HENEX H-500 sans fil'; ImageFileName: 'catalog_product_048.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 3; Reference: 'PHOTO-049'; Name: 'Lecteur code-barres Smart 5066 sans fil'; ImageFileName: 'catalog_product_049.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 3; Reference: 'PHOTO-050'; Name: 'Lecteur code-barres Sunlux 6500A avec support'; ImageFileName: 'catalog_product_050.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 3; Reference: 'PHOTO-051'; Name: 'Lecteur code-barres LC-3000L'; ImageFileName: 'catalog_product_051.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 3; Reference: 'PHOTO-052'; Name: 'Lecteur code-barres 2D SP-X86'; ImageFileName: 'catalog_product_052.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 3; Reference: 'PHOTO-053'; Name: 'Lecteur code-barres Smart 1500U avec support'; ImageFileName: 'catalog_product_053.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 3; Reference: 'PHOTO-054'; Name: 'Lecteur code-barres Icon 4010 avec support'; ImageFileName: 'catalog_product_054.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 3; Reference: 'PHOTO-055'; Name: 'Lecteur code-barres Elitpos SC-5510'; ImageFileName: 'catalog_product_055.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 3; Reference: 'PHOTO-056'; Name: 'Lecteur code-barres fixe 2D SP-8608G'; ImageFileName: 'catalog_product_056.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 3; Reference: 'PHOTO-057'; Name: 'Lecteur code-barres Newland 2D'; ImageFileName: 'catalog_product_057.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 3; Reference: 'PHOTO-058'; Name: 'Lecteur code-barres Opticon'; ImageFileName: 'catalog_product_058.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 3; Reference: 'PHOTO-059'; Name: 'Lecteur code-barres Smart 1D 5066'; ImageFileName: 'catalog_product_059.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 3; Reference: 'PHOTO-060'; Name: 'Lecteur code-barres SafePos 2D 8860'; ImageFileName: 'catalog_product_060.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 3; Reference: 'PHOTO-061'; Name: 'Lecteur code-barres sans fil Smart SP-M40'; ImageFileName: 'catalog_product_061.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 3; Reference: 'PHOTO-062'; Name: 'Lecteur code-barres SP-8500'; ImageFileName: 'catalog_product_062.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 3; Reference: 'PHOTO-063'; Name: 'Lecteur code-barres Sunlux 3610 2D'; ImageFileName: 'catalog_product_063.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 3; Reference: 'PHOTO-064'; Name: 'Lecteur code-barres fixe SmartPOS SP 8602'; ImageFileName: 'catalog_product_064.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 1; Reference: 'PHOTO-065'; Name: 'Ordinateur Lenovo i5, 6 Go RAM, HDD 500 Go'; ImageFileName: 'catalog_product_065.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 6; Reference: 'PHOTO-066'; Name: 'Carton de papier thermique 80 x 80'; ImageFileName: 'catalog_product_066.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 1; Reference: 'PHOTO-067'; Name: 'PC tactile A3 i3, SSD 128 Go'; ImageFileName: 'catalog_product_067.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 1; Reference: 'PHOTO-068'; Name: 'PC tactile Smart P2 i5 4e génération, SSD 128 Go, 8 Go, Wi-Fi'; ImageFileName: 'catalog_product_068.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 1; Reference: 'PHOTO-069'; Name: 'PC tactile Smart i5 L150, SSD 128 Go, rouge'; ImageFileName: 'catalog_product_069.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 1; Reference: 'PHOTO-070'; Name: 'Vérificateur de prix tactile 10,1 pouces avec support'; ImageFileName: 'catalog_product_070.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 6; Reference: 'PHOTO-071'; Name: 'Rouleau de papier thermique 80 x 80'; ImageFileName: 'catalog_product_071.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 4; Reference: 'PHOTO-072'; Name: 'Tiroir-caisse SafePos 410'; ImageFileName: 'catalog_product_072.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 4; Reference: 'PHOTO-073'; Name: 'Tiroir-caisse BZ 6 kg'; ImageFileName: 'catalog_product_073.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 4; Reference: 'PHOTO-074'; Name: 'Tiroir-caisse Enegma 415 blanc'; ImageFileName: 'catalog_product_074.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 4; Reference: 'PHOTO-075'; Name: 'Tiroir-caisse en inox'; ImageFileName: 'catalog_product_075.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 4; Reference: 'PHOTO-076'; Name: 'Tiroir-caisse Smart 410 économique'; ImageFileName: 'catalog_product_076.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 4; Reference: 'PHOTO-077'; Name: 'Tiroir-caisse Smart 335 compact'; ImageFileName: 'catalog_product_077.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 1; Reference: 'PHOTO-078'; Name: 'Unité centrale HP i5 6e génération, SSD 256 Go'; ImageFileName: 'catalog_product_078.jpg'), // Complete la declaration ou instruction en cours.
    (CategoryID: 1; Reference: 'PHOTO-079'; Name: 'Vérificateur de prix SafePos'; ImageFileName: 'catalog_product_079.jpg') // Complete la declaration ou instruction en cours.
  ); // Execute cette instruction dans le flux courant.

implementation // Ouvre la partie contenant les implementations privees.

end. // Ferme le bloc ou la declaration en cours.
