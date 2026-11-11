# API locale NGNEX

Cette API Python utilise SQLite et reprend les données initiales de
`Database/database.sql`. Elle est conçue pour les essais locaux de l'application,
pas pour être publiée telle quelle sur Internet : elle ne comporte pas
d'authentification et n'écoute que sur `127.0.0.1`.

## Démarrer sur Windows

Depuis le dossier du projet :

```powershell
python api\server.py
```

Le serveur écoute sur `http://127.0.0.1:8000`. La base est créée dans
`api\data\ngnex_api.sqlite3` au premier démarrage. Arrête le serveur avec
`Ctrl+C`.

Vérifier le serveur dans PowerShell :

```powershell
Invoke-RestMethod http://127.0.0.1:8000/health
Invoke-RestMethod http://127.0.0.1:8000/api/categories
```

Pour consulter les devis sans installer DB Browser, double-clique sur
`Voir les devis.bat` à la racine du projet. Python doit être installé.

## Connecter le téléphone en USB

Avec le téléphone connecté et le débogage USB autorisé, exécuter dans une
deuxième fenêtre PowerShell :

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" reverse tcp:8000 tcp:8000
```

Le transfert USB permet à `127.0.0.1:8000` sur le téléphone d'atteindre le
serveur local du PC. Il faut garder le serveur lancé et reconstruire
l'application Android après le changement de `DataModule.pas`.

L'URL de développement est définie dans `DataModule.pas` :

```pascal
FApiService := TApiService.Create('http://127.0.0.1:8000/api');
```

Le manifeste Android autorise HTTP uniquement pour ces essais locaux. Ne publie
pas l'application avec cette URL : pour la production, il faut héberger l'API
derrière HTTPS, ajouter l'authentification, puis utiliser l'URL HTTPS du serveur
et désactiver le trafic HTTP en clair.

## Routes

- `GET /health`
- `GET /api/categories`
- `GET /api/products`
- `GET /api/products/{id}`
- `GET /api/products/search?query=...`
- `GET /api/products/barcode/{barcode}`
- `POST /api/quotes`

Les demandes de devis sont sauvegardées dans la base SQLite serveur. Les
produits et leurs prix sont lus depuis le catalogue serveur lors de
l'enregistrement.

## Tests

```powershell
python -m unittest discover -s api\tests -v
```
