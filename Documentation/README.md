# NGNEX Mobile — Application Mobile Android (Delphi 13 Florence FMX)

**NGNEX Mobile** est l'application mobile officielle pour **NGNEX 08**, entreprise spécialisée dans la commercialisation et la distribution de matériel informatique professionnel, terminaux tactiles Point de Vente (POS / caisse), imprimantes tickets, lecteurs de codes-barres et balances commerciales.

Développée avec **Delphi 13 Florence Community Edition** et le framework **FireMonkey (FMX)**, l'application est 100% native pour **Android 64 bits**.

L'interface utilise une charte cohérente bleu nuit, bleu et ambre, avec un fond clair, des cartes harmonisées et des libellés français corrigés.

---

## 🚀 Fonctionnalités Principales

1. **🏠 Page d'Accueil Moderne**
   - Logo et bannière NGNEX 08.
   - Barre de recherche rapide.
   - Carousel des catégories de produits.
   - Sélection des produits populaires et offres spéciales.
   - Raccourcis d'outils rapides (Scanner, Comparateur, Calculateur, Historique Devis).

2. **📦 Catalogue & Catégories de Produits**
   - **PC All-in-One Tactiles** (Terminaux POS 15.6", Double écran client).
   - **Imprimantes Tickets** (80mm Thermique USB/LAN, Portable Bluetooth 58mm).
   - **Lecteurs de Codes-barres** (Scanners 1D/2D Omnidirectionnels, Douchettes sans fil).
   - **Tiroirs-caisses** (Modèles métalliques renforcés RJ11).
   - **Balances Professionnelles** (Balances commerciales avec impression ticket/étiquette).
   - **Papier et étiquettes** (consommables photographiés du catalogue).
   - Catalogue enrichi à partir des 79 photos locales. Les références `PHOTO-001` à `PHOTO-079` n’inventent ni prix ni stock : ceux-ci sont affichés comme « à confirmer ».
   - Filtrage dynamique, recherche multi-critères (Nom, Réf, Code-barres) et tri par prix (DA) / nom.

3. **📄 Fiche Produit Détaillée**
   - Informations techniques exhaustives.
   - Statut de disponibilité en stock temps réel.
   - Prix en dinars algériens (DA).
   - Boutons d'action rapide (+ Panier, Comparer, Demander un devis).

4. **📷 Scanner de Codes-Barres Camera Android**
   - Intégration `TCameraComponent` native FireMonkey.
   - Détection directe des codes EAN-13 / Code-128 / QR Code.
   - Fallback de saisie manuelle.
   - Recherche locale SQLite puis recherche REST API si le produit est inconnu en local.

5. **⚖️ Comparateur de Produits**
   - Sélection et comparaison côte à côte de 2 produits.
   - Comparaison visuelle des prix, références, caractéristiques techniques et stocks.

6. **🧮 Calculateur Commercial de Remises**
   - Saisie du prix unitaire en dinars algériens (DA).
   - Calcul des remises en pourcentage (%).
   - Calcul automatique du sous-total, du montant de la remise et du total net final.

7. **🛒 Panier d'Achat Persistant**
   - Gestion des quantités (+ / - / suppression).
   - Calcul automatique des sous-totaux et du total général en DA.
   - Persistence automatique dans la base SQLite locale.

8. **📝 Demande de Devis Sans Compte**
   - Formulaire client simplifié (Nom, Entreprise, Téléphone, Email, Adresse, Message).
   - Génération de numéro de devis unique (`DEV-YYYYMMDDHHNNSS`).
   - Transmission asynchrone vers le serveur REST API NGNEX.
   - Stockage automatique en mode hors connexion.

9. **📋 Historique des Demandes de Devis**
   - Liste des devis passés avec badge de statut coloré (*En attente*, *En cours de traitement*, *Accepté*, *Refusé*).
   - Détail des articles et montants estimés.

10. **⚙️ Paramètres & Synchronisation Hors Ligne**
    - Informations complètes sur l'entreprise NGNEX 08 (Bechar, Algérie).
    - Synchronisation manuelle du catalogue depuis l'API REST.
    - Réinitialisation et maintenance du cache SQLite local.

---

## 📂 Architecture du Projet

```
NGNEXMobile/
├── NGNEXMobile.dpr               # Fichier principal du programme Delphi
├── NGNEXMobile.dproj            # Projet Delphi 13 / RAD Studio
├── MainForm.pas / .fmx          # Formulaire principal & Navigation inférieure (5 Tabs)
├── DataModule.pas / .fmx        # TDataModule (FireDAC SQLite, REST API, Services)
├── Models/
│   ├── Product.pas              # Modèle Produit + TProductList
│   ├── Category.pas             # Modèle Catégorie + TCategoryList
│   ├── CartItem.pas             # Modèle Panier + TCartItemList
│   ├── Quote.pas                # Modèle Devis & Articles de Devis
│   └── Customer.pas             # Modèle Client & Entreprise
├── Services/
│   ├── DatabaseService.pas      # Gestionnaire SQLite FireDAC (Tables, Index, Seed)
│   ├── ApiService.pas           # Client REST HTTP asynchrone JSON
│   ├── ProductService.pas       # Logique métier Produits & Recherches
│   ├── CategoryService.pas      # Logique métier Catégories
│   ├── CartService.pas          # Gestion du Panier local
│   ├── QuoteService.pas         # Gestion des Demandes de Devis
│   └── BarcodeService.pas       # Gestion de la caméra & Scanner
├── Views/
│   ├── HomeForm.pas / .fmx      # Écran 1: Accueil
│   ├── CategoriesForm.pas / .fmx# Écran 3: Catégories
│   ├── ProductsForm.pas / .fmx  # Écran 2: Catalogue
│   ├── ProductDetailsForm.pas   # Écran 4: Détails Produit
│   ├── ScannerForm.pas / .fmx   # Écran 5: Scanner
│   ├── CompareForm.pas / .fmx   # Écran 6: Comparateur
│   ├── CalculatorForm.pas / .fmx# Écran 7: Calculateur
│   ├── CartForm.pas / .fmx      # Écran 8: Panier
│   ├── QuoteForm.pas / .fmx     # Écran 9: Demande de Devis
│   ├── QuoteHistoryForm.pas     # Écran 10: Historique
│   └── SettingsForm.pas / .fmx  # Écran 11: Paramètres
├── Database/
│   └── database.sql             # Script DD/DML SQLite avec données NGNEX 08
└── Documentation/
    └── README.md                # Guide complet d'installation et de compilation
```

---

## 🛠️ Configuration Requise & Prérequis

- **IDE :** Delphi 13 Florence (Community Edition, Professional, ou Enterprise).
- **Framework :** FireMonkey (FMX).
- **Cible :** Android 64 bits (`Android64`) - Compatible Android 8.0 (API 26) à Android 14+ (API 34).
- **SDK Android :** Configuré dans Delphi via *Tools > Options > Deployment > SDK Manager*.
  - Android SDK (API 33 ou 34)
  - Android NDK (r25b ou version gérée par RAD Studio 13)
  - Java Development Kit (JDK 17)

---

## 🛢️ Base de Données Locale SQLite

L'application initialise automatiquement la base de données SQLite `ngnex_mobile.db` dans le dossier sécurisé de l'application mobile (`TPath.GetDocumentsPath`).

Au premier démarrage, elle ajoute également les produits correspondant aux photos du catalogue. Les fichiers `catalog_product_001.jpg` à `catalog_product_079.jpg`, le logo et la bannière sont déployés depuis `Assets\Images`. Les changements du catalogue sont idempotents : les produits photo déjà ajoutés ne sont pas dupliqués.

### Schema des tables :
- `Categories` (id, nom, description, image_url)
- `Products` (id, category_id, nom, reference, barcode, description, prix, stock, image_url, caracteristiques, updated_at)
- `CartItems` (id, product_id, quantite, prix_unitaire)
- `Quotes` (id, numero, date_creation, statut, customer_name, company_name, customer_phone, customer_email, address, notes)
- `QuoteItems` (id, quote_id, product_id, product_name, product_ref, quantite, prix_unitaire)

---

## 🌐 Interconnexion REST API

Les endpoints pré-configurés dans `ApiService.pas` :
- `GET /api/categories` : Récupération des catégories
- `GET /api/products` : Récupération des produits
- `GET /api/products/{id}` : Fiche produit
- `GET /api/products/search?query=` : Recherche serveur
- `GET /api/products/barcode/{barcode}` : Recherche par code-barres
- `POST /api/quotes` : Envoi d'une demande de devis

Pour les essais USB locaux, l'application utilise `http://127.0.0.1:8000/api`, servi par l'API Python du dossier [`api`](../api/README.md). Démarrez le serveur sur le PC, puis exécutez `adb reverse tcp:8000 tcp:8000` avant de lancer l'application sur le téléphone. Les devis restent aussi enregistrés dans SQLite sur le téléphone.

Cette API est réservée au développement local : elle n'a pas d'authentification et n'écoute que sur `127.0.0.1`. Ne publiez pas l'application avec cette URL ou le trafic HTTP en clair. Une mise en production exige un hébergement HTTPS, une authentification et une configuration adaptée.

---

## 📑 Instructions de Compilation & Génération d'APK

### Étape 1 : Ouverture du projet dans Delphi 13
1. Lancez **Delphi 13 Florence Community Edition**.
2. Allez dans `File > Open Project...`
3. Sélectionnez le fichier `NGNEXMobile.dproj` présent dans le dossier racine.

### Étape 2 : Configuration de la cible Android
1. Dans la fenêtre **Project Manager** (à droite) :
   - Déroulez `Target Platforms`.
   - Double-cliquez sur **Android 64-bit**.
2. Assurez-vous qu'un appareil Android physique (mode Débogage USB activé) ou un émulateur est connecté.

### Étape 3 : Permissions Android
Les permissions requises sont pré-configurées dans `NGNEXMobile.dproj` :
- `CAMERA` (pour le scanner de codes-barres)
- `INTERNET` (pour la communication API REST)
- `READ_EXTERNAL_STORAGE` / `WRITE_EXTERNAL_STORAGE`

### Étape 4 : Compilation et Exécution
1. Cliquez sur **Project > Build NGNEXMobile** (`Shift + F9`).
2. Cliquez sur **Run > Run Without Debugging** (`Ctrl + Shift + F9`) ou **Run** (`F9`).
3. Delphi compilera le code Object Pascal, générera le package Android `.apk` (ou `.aab` pour le Play Store) et l'installera automatiquement sur le terminal.

---

## 👥 À propos de NGNEX 08

- **Société :** NGNEX 08
- **Domaine :** Vente et conseils en matériel informatique & équipement professionnel de caisse / POS.
- **Siège :** Bechar, Algérie
- **Contact :** contact@ngnex08.dz | Site web: [https://ngnex08.dz](https://ngnex08.dz)
