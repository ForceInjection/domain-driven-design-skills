---
name: framework:make:story
description: Génère Story Foundry pour fixtures de tests
license: MIT
version: 1.0.0
---

# Framework Make Story Skill

## Description
Génère une Story Foundry pour créer des fixtures de tests avec scénarios prédéfinis.

## Usage
```
Use skill framework:make:story
```

## Variables requises
- **{EntityName}** - Nom de l'entité en PascalCase (ex: Product)
- **{entityName}** - Nom de l'entité en camelCase (ex: product)
- **{namespace}** - Namespace du projet (défaut: App)

## Dépendances
- Entité dans `src/Entity/{EntityName}.php`
- Factory (appelle `framework:make:factory` si absente)
- Contracts (StoryInterface)

## Outputs
- `src/Story/{EntityName}Story.php`
- `src/Story/AppStory.php` (créé ou mis à jour)

## Workflow

1. Demander le nom de l'entité (EntityName)
2. Vérifier que l'entité existe
3. Vérifier/créer la Factory
4. Générer la Story depuis le template `templates/Story/`
5. Créer ou mettre à jour AppStory
6. Afficher les fichiers créés

## Patterns appliqués

### Story
- Extends Story, Implements StoryInterface
- Classe `final`
- Méthode `build()` créant les fixtures via Factory

### AppStory
- Extends Story, Implements StoryInterface
- Attribut #[AsFixture(name: 'main')]
- Point d'entrée unique pour toutes les fixtures

## References

- [Usage](references/usage.md) - Scénarios complexes, relations et états nommés

## Notes
- AppStory est le point d'entrée pour charger toutes les fixtures
- Stories peuvent avoir des dépendances (charger d'autres Stories)
- `addState()` pour nommer des instances réutilisables dans les tests
