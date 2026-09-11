# FoodScanner — captures d'écran par parcours

Captures réelles (simulateur iPhone 17 Pro), classées par écran/état du parcours utilisateur, thème clair et sombre côte à côte. Chemins relatifs à `screenshots/`.

## 1 · Onboarding

Premier lancement, avant toute autorisation caméra (`OnboardingView`).

| Clair | Sombre |
|---|---|
| ![Onboarding clair](screenshots/onboarding-light.png) | ![Onboarding sombre](screenshots/onboarding-dark.png) |

## 2 · Scanner

Onglet par défaut au lancement suivant (`ScannerScreenView`). Un seul écran, plusieurs états superposés selon `model.banner` et `showsKeypad`.

### 2.1 — Repos (pas de bannière, pavé fermé)

| Clair | Sombre |
|---|---|
| ![Scanner repos clair](screenshots/scanner-idle-light.png) | ![Scanner repos sombre](screenshots/scanner-idle-dark.png) |

### 2.2 — Pavé numérique ouvert, champ vide

`FSBarcodeField` affiche un exemple de code en placeholder ; le bouton « Chercher ce produit » reste désactivé (opacité réduite) tant qu'aucun code n'est saisi.

| Clair | Sombre |
|---|---|
| ![Pavé vide clair](screenshots/scanner-keypad-empty-light.png) | ![Pavé vide sombre](screenshots/scanner-keypad-empty-dark.png) |

### 2.3 — Pavé numérique, code invalide

Code trop court (`65558`) : bouton d'effacement (×) dans le champ, message d'erreur inline (icône + texte accent) : « Un code-barres compte entre 8 et 14 chiffres. »

| Clair | Sombre |
|---|---|
| ![Pavé invalide clair](screenshots/scanner-keypad-invalid-light.png) | ![Pavé invalide sombre](screenshots/scanner-keypad-invalid-dark.png) |

### 2.4 — Pavé numérique, champ actif + bannière « introuvable »

Champ avec le focus (liseré épaissi + curseur), superposé à la bannière `FSScanStatusBanner(.notFound)` du scan précédent.

| Clair | Sombre |
|---|---|
| ![Pavé focus clair](screenshots/scanner-keypad-focused-light.png) | ![Pavé focus sombre](screenshots/scanner-keypad-focused-dark.png) |

### 2.5 — Bannière « produit introuvable »

`FSScanStatusBanner(.notFound)` — pastille orange « ? », liseré accent. « Ce code n'existe pas encore dans la base. Vous pouvez l'ajouter. »

| Clair | Sombre |
|---|---|
| ![Introuvable clair](screenshots/scanner-notfound-light.png) | ![Introuvable sombre](screenshots/scanner-notfound-dark.png) |

### 2.6 — Bannière « produit trouvé »

`FSScanStatusBanner(.found)` — pastille verte ✓, liseré `fsLeaf`. Tapable pour ouvrir la fiche produit.

| Clair | Sombre |
|---|---|
| ![Trouvé clair](screenshots/scanner-found-light.png) | ![Trouvé sombre](screenshots/scanner-found-dark.png) |

## 3 · Fiche produit (Nutriments)

Poussée depuis le Scanner ou l'Historique (`ProductDetailScreenView`). Deux captures par thème : le haut de l'écran, puis le bas après défilement (`FSSceneFooter(.laboratory)`, sous la barre d'onglets flottante).

### 3.1 — Haut : carte produit, échelle Nutri-Score, nutriments

| Clair | Sombre |
|---|---|
| ![Fiche produit haut clair](screenshots/product-detail-light-top.png) | ![Fiche produit haut sombre](screenshots/product-detail-dark-top.png) |

### 3.2 — Bas : saynète laboratoire + légende

| Clair | Sombre |
|---|---|
| ![Fiche produit bas clair](screenshots/product-detail-light-footer.png) | ![Fiche produit bas sombre](screenshots/product-detail-dark-footer.png) |

## 4 · Historique

`HistoryScreenView` — liste des produits déjà consultés + `FSSceneFooter(.picnic)`.

### 4.1 — Vide

| Clair |
|---|
| ![Historique vide](screenshots/history-empty.png) |

### 4.2 — Avec un produit consulté

| Clair | Sombre |
|---|---|
| ![Historique clair](screenshots/history-list-light.png) | ![Historique sombre](screenshots/history-list-dark.png) |

## 5 · Réglages

`SettingsScreenView` — contraste (statut système lecture seule), réduction des animations, taille du texte.

| Clair | Sombre |
|---|---|
| ![Réglages clair](screenshots/settings-light.png) | ![Réglages sombre](screenshots/settings-dark.png) |

---

`screenshots/settings-accessibility.png` (09/02) n'est pas repris ci-dessus : il montre une ancienne version de l'écran où « Contraste élevé » était un interrupteur actionnable, ce qui ne correspond plus au code actuel (statut système en lecture seule, voir §5). À supprimer ou reprendre si une nouvelle capture est faite dans cet état.
