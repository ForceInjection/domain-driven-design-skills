---
name: product-research-orchestrator
description: "Coordinates complete comparison of 2 products with parallel subagents and result aggregation. Use when user asks to 'compare X vs Y', 'compare two products', 'research products for comparison', mentions comparing items for purchase decision, or requests product analysis. Handles product validation, cache checking, parallel data collection (specs, reviews, pricing), and comprehensive report generation."
---

# Product Research Orchestrator

## Mission
Coordonner la comparaison complète de 2 produits en orchestrant subagents parallèles et agrégation des résultats.

## Quick Summary
1. Valide que les 2 produits existent (quick Google search)
2. Vérifie cache (7j) - si HIT complet → génère rapport directement
3. Spawn 2 subagents parallèles (1 par produit) pour recherche
4. Attend complétion et agrège résultats
5. Trigger report-generator pour synthèse finale

## Inputs
- **product1**: Nom produit 1 (ex: "Dyson V15")
- **product2**: Nom produit 2 (ex: "Shark Stratos")
- **category**: Catégorie optionnelle (auto-détectée si omise)

## Outputs
- `data/research_{timestamp}/orchestration_log.json`: Log complet workflow
- `data/research_{timestamp}/{product}/`: Dossiers par produit
- `reports/comparison_{product1}_vs_{product2}_{timestamp}.md`: Rapport final

## Dependencies
- subagents/product-researcher.md
- skills: specs-collector, reviews-aggregator, pricing-tracker, report-generator
- data/category_specs.yaml

## Workflow Details
Load `helpers/workflow.md` when executing orchestration for detailed step-by-step instructions.

## Error Handling
- Produit introuvable → Demande clarification user
- Subagent timeout → Continue avec données partielles, flag warning
- Cache partiel → Utilise cache disponible, fetch données manquantes
