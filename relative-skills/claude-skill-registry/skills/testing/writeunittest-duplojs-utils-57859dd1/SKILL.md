---
name: writeUnitTest
description: Créer ou mettre à jour un fichier de test unitaire Vitest pour une fonction TypeScript donnée, namespacée via @scripts (namespace.function), en respectant les conventions de test du projet (ExpectType strict, compatibilité pipe, pas de helpers partagés).
---

# writeUnitTest — Skill de tests unitaires du projet

## Objectif
Générer (ou mettre à jour) un fichier de test Vitest pour **une** fonction de la librairie, en garantissant :
- des tests de comportement à l’exécution corrects
- des **tests de type** avec `ExpectType` en mode **strict**
- un test de **compatibilité pipe**
- une **intention de couverture à 100%** : exercer toutes les branches et cas limites significatifs

La fonction testée est toujours appelée via son **namespace** (ex. `DArray.copyWithin`).

## Entrées (ce qu’il faut déduire de la tâche ou du codebase)
Le prompt utilisateur fournira généralement :
- Namespace et nom de fonction : ex. `DArray.copyWithin`

Vous DEVEZ déduire le reste en inspectant le repository :
- chemin du fichier source dans `scripts/<domain>/<function>.ts`
- tests existants (s’il y en a) dans `tests/<domain>/<function>.test.ts`
- signatures/overloads exportées et comportement runtime
- si la fonction :
  1) **est un prédicat/type guard** (retourne `value is ...`)
  2) **accepte un prédicat** en paramètre (et peut supporter des prédicats type guard)

## Sortie
Créer ou mettre à jour :
- `tests/<domain>/<function>.test.ts`

Règle de mapping (cas standard) :
- `scripts/array/copyWithin.ts` → `tests/array/copyWithin.test.ts`

:warning: Certains tests rares couvrent plusieurs fonctions dans un seul fichier. NE PAS reproduire ce pattern sauf demande explicite de l’utilisateur.

## Règles non négociables
### Imports
- Une seule ligne d’import.
- Tous les imports depuis `@scripts`.
- Importer uniquement ce qui est utilisé (mais inclure `pipe` toujours car le test pipe est obligatoire).
- Si vous avez besoin de `when` (tests de prédicat dans pipe), importez-le aussi depuis `@scripts`.

Exemple :
```ts
import { DArray, type ExpectType, pipe } from "@scripts";
```

### Structure
- Un `describe("<functionName>", () => { ... })`
- Chaque message de `it` doit être :
	- écrit en anglais
	- descriptif : il doit indiquer clairement ce qui est testé
- Ne pas ajouter de helpers partagés :
	- AUCUNE fonction helper
	- AUCUNE fixture partagée hors d’un `it`
	- chaque test est autonome

### Namespacing
- Toujours appeler la fonction via son namespace :
	- ✅ `DArray.copyWithin(...)`
	- ❌ `copyWithin(...)`

### Compatibilité pipe (obligatoire)
Chaque fonction doit avoir au moins un test qui vérifie qu’elle fonctionne dans :
- `pipe(input, Namespace.fn(...), ...)`
Utiliser la surcharge currifiée si nécessaire pour qu’elle puisse être utilisée dans pipe.

### Tests de type (obligatoires dans presque tous les tests)
- Inclure au moins un test `ExpectType` dans le fichier (souvent plus).
- Toujours utiliser `"strict"` et rien d’autre.

Exemple :
```ts
type check = ExpectType<
	typeof result,
	number[],
	"strict"
>;
```

### Intention de couverture
Les tests doivent viser à couvrir :
- usage normal
- limites (vide, singleton, index début/fin, etc. selon le cas)
- immutabilité (si la fonction ne doit pas muter)
- branches d’erreur/exception (si applicable)
- différences de surcharge (classique vs currifiée; surcharges de prédicat si présentes)

### Cas spéciaux
### A) Cas standard (défaut)
Si la fonction n’est ni :
- un prédicat/type guard, ni
- une fonction qui accepte un prédicat en paramètre,
Template à utiliser :
- `assets/standard.md`

#### B) Fonction prédicat / type guard
Vous DEVEZ inclure :
1. Un appel classique qui vérifie le narrowing via un bloc `if (result)` avec `ExpectType`.
2. Un test pipe qui utilise `when(predicate, (value) => { type check ... })`.
Template à utiliser :
- `assets/predicate-function.md`

#### C) Fonction qui accepte un prédicat en paramètre
Vous DEVEZ inclure :
1. Un test montrant que les prédicats type guard sont supportés (si la signature le permet).
2. Un test pipe utilisant la forme currifiée.
Vous POUVEZ utiliser des prédicats existants de la librairie (ex. `isType`, `equal`, etc.) comme entrée.
Template à utiliser :
- `assets/takes-predicate.md`

### Checklist d’implémentation
1. Localiser la fonction source dans scripts/**/<function>.ts et lire :
	- comportement
	- cas limites
	- conditions de throw
	- surcharges et signatures predicate/type-guard
2. Déterminer le chemin du fichier de test et le créer/mettre à jour.
3) Choisir le template :
   - défaut : `assets/standard.md`
   - prédicat/type guard : `assets/predicate-function.md`
   - accepte un prédicat : `assets/takes-predicate.md`
4. Écrire les tests :
	- garder chaque `it` indépendant (pas d’état partagé)
	- assurer au moins un test pipe
	- assurer des vérifications de type strictes
	- s’assurer que tous les messages de `it` sont en anglais et explicites
5. Exécuter / valider mentalement :
	- imports corrects et minimaux
	- respect du namespace
	- pas de helpers partagés ni de fixtures partagées
	- le fichier de test cible uniquement cette fonction
6) Lancer le test unitaire via les scripts Vitest du projet :
   - Commande par défaut :
     - `npm run test:tu`
   - Préférer l’exécution du fichier cible en passant le chemin en argument :
     - `npm run test:tu -- tests/<domain>/<function>.test.ts`
   - Si besoin de se concentrer sur un seul cas, vous pouvez filtrer par nom :
     - `npm run test:tu -- -t "<describe or it text>"`
   - NE PAS utiliser `test:tu:update`, `test:tu:bench`, ou `test:tu:watch` sauf demande explicite.
   - Si le test échoue, mettre à jour le test jusqu’à ce qu’il passe.
   - :warning: Ne pas relancer la suite complète répétitivement; itérer en ciblant uniquement le fichier.

### Notes de style
- Utiliser des tabulations pour l’indentation (cohérent avec les tests existants).
- Préférer des entrées explicites dans chaque test plutôt qu’une réutilisation maligne.
- Le but est la correction et la maintenabilité, pas DRY.
