## Boutique IUT – Frontend Flutter pour l’ERP

Application Flutter (desktop/web/mobile possible) qui consomme les **webservices de l’ERP pédagogique** pour :

- **Lister les articles** d’un fournisseur (nom, code, prix, description, image).
- **Afficher le détail d’un article** dans une page dédiée.
- **Choisir un fournisseur** (étudiant) via une liste déroulante et charger dynamiquement ses articles.

Pensée pour fonctionner en **Linux** et **Windows** (Flutter desktop), avec un simple `flutter run`.

---

### 1. Prérequis

- **Flutter 3.11+** installé (canal `stable`).
- Git installé si clonage via Git.
- Accès réseau à l’ERP (`polyedre.eu`).

Pour vérifier Flutter :

```bash
flutter doctor
```

Assure‑toi d’avoir au moins un device desktop disponible (`Linux` ou `Windows`).

---

### 2. Installation (Linux ou Windows)

Dans un terminal :

```bash
git clone https://github.com/<ton-pseudo>/front_erp.git
cd front_erp
flutter pub get
```

Puis lancement en desktop :

```bash
flutter run -d linux   # sous Linux
flutter run -d windows # sous Windows
```

Si tu utilises VS Code, tu peux aussi ouvrir le dossier et faire **F5** en choisissant le device `Linux` ou `Windows`.

---

### 3. Configuration spécifique au TD

Dans `lib/api.dart` :

- L’URL des **articles** pour un fournisseur est :
  - `http://polyedre.eu:8000/polyfx/cgi/getart.cgi?frs=<NUM_FRS>`
- L’URL des **fournisseurs (étudiants)** dépend du TD :
  - TD1 : `getfrstd1.cgi`
  - TD2 : `getfrstd2.cgi` (configurée par défaut dans ce projet)

Dans `lib/main.dart` :

- La variable `_currentFrs` contient le **numéro de fournisseur par défaut** (celui de l’étudiant) :

```dart
String _currentFrs = '401000394'; // à adapter avec ton numéro
```

Pense à la modifier avant de lancer si besoin.

---

### 4. Fonctionnement de l’application

- **Écran principal**
  - AppBar avec le titre **“Boutique IUT”**.
  - En haut : un **menu déroulant** “Choisir un fournisseur” alimenté par l’API `getfrstdX.cgi`.
  - En dessous : la **liste des articles** du fournisseur choisi, affichés dans des `Card` avec :
    - image (ou icône `image_not_supported` si absente),
    - nom (`name`),
    - code (`id`),
    - prix (`price`),
    - description (`description`).

- **Page détail article**
  - S’ouvre au clic sur une carte.
  - Affiche une grande image (ou icône par défaut), le nom, le code, le prix et la description.

Les données sont lues **dynamiquement** depuis l’ERP : si un libellé ou une image est modifié côté ERP, un **Hot restart** (`R` dans le terminal `flutter run`) rafraîchit l’affichage.

---

### 5. Mise sur GitHub (rappel rapide)

Dans le dossier du projet :

```bash
git init
git add .
git commit -m "Initial commit - Boutique IUT Flutter ERP frontend"
git branch -M main
git remote add origin https://github.com/<ton-pseudo>/front_erp.git
git push -u origin main
```

Ensuite, tes camarades peuvent simplement :

```bash
git clone https://github.com/<ton-pseudo>/front_erp.git
cd front_erp
flutter pub get
flutter run -d linux   # ou -d windows
```
