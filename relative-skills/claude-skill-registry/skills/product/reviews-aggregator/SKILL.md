---
name: reviews-aggregator
description: "Aggregates user reviews from Amazon/Reddit and expert reviews from specialized sites with sentiment analysis. Use when user asks to 'get reviews', 'what do users say', 'aggregate reviews', 'user feedback', 'expert opinions', or when orchestrator needs sentiment analysis and pros/cons extraction. Synthesizes consensus patterns across sources."
---

# Reviews Aggregator

## Mission
Collecter et analyser avis utilisateurs (Amazon, Reddit) et reviews experts (sites spécialisés). Synthétiser pros/cons, sentiment général, consensus.

## Quick Summary
1. Scrape Amazon reviews (rating, avis vérifiés, pros/cons)
2. Search Reddit mentions (r/BuyItForLife, product-specific subs, category subs)
3. Collect expert reviews (2-3 sites selon catégorie)
4. Analyse sentiment + extract pros/cons patterns
5. Synthèse consensus + save JSON

## Inputs
- **product_name**: Nom produit
- **category**: Catégorie (pour sélectionner review sites appropriés)
- **amazon_url**: URL Amazon (optionnel)
- **cache_check**: Vérifier cache avant fetch (default: true)

## Outputs
- `reviews_user.json`: Avis users (Amazon + Reddit)
- `reviews_expert.json`: Reviews experts (sites spécialisés)
- `reviews_summary.json`: Synthèse (pros, cons, sentiment, consensus)
- Cache 7j

## Dependencies
- data/category_specs.yaml (review_sites par catégorie)
- Load `helpers/sentiment_analysis.md` when analyzing sentiment
- Load `helpers/sources.yaml` when scraping sites

## Workflow
Load `helpers/sentiment_analysis.md` when executing analysis for detailed sentiment analysis and synthesis.
