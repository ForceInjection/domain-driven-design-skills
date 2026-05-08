---
name: sr-cardoso-backend
description: Backend Cloud Run/Express/Firestore do Sr Cardoso. Use quando criar ou alterar endpoints, auth JWT, regras de agenda, financeiro, branding, WhatsApp, cron jobs, ou modelagem Firestore.
---

# Sr Cardoso Backend

## Overview
Executar tarefas no backend Express/Cloud Run com Firestore, respeitando regras de negocio e contratos com o frontend.

## Entradas e estrutura
- Iniciar por `apps/server/src/index.ts` e `apps/server/src/app.ts`.
- Usar `apps/server/src/routes/public.ts` para rotas publicas.
- Usar `apps/server/src/routes/admin.ts` para rotas admin e RBAC.
- Usar `apps/server/src/lib/*` para auth, finance, branding e Evolution API.
- Usar `apps/server/src/services/whatsappNotifications.ts` para envios automaticos.

## Auth e RBAC
- Usar `requireAdmin` e `requireMaster` de `apps/server/src/lib/adminAuth.ts`.
- Manter claims: role, username, barberId.
- Manter token JWT HS256 com `ADMIN_JWT_SECRET`.

## Modelagem Firestore (resumo)
- `barbers`, `bookings`, `customers`, `adminUsers`.
- Subcolecao `barbers/{barberId}/slots`.
- Configs em `settings/finance`, `settings/branding`, `settings/whatsapp-notifications`.
- Filas em `whatsappMessageQueue` e `whatsappOutbound`.

## Regras de agenda
- Usar timezone `America/Sao_Paulo`.
- Validar slots em 30 minutos e domingo fechado.
- Respeitar schedule configurado do barbeiro.

## Quando criar/alterar endpoints
- Validar input com Zod (preferir schemas de `packages/shared`).
- Atualizar tipos/contratos em `packages/shared` se necessario.
- Atualizar `apps/web/src/lib/api.ts` para refletir novos endpoints.
- Verificar necessidade de index em `firebase/firestore.indexes.json`.

## Transacoes Firestore
- Ler documentos antes de escrever dentro da transacao.
- Usar `FieldValue.serverTimestamp()` para createdAt/updatedAt.

## Cron
- Proteger `/api/cron/*` com `CRON_SECRET`.
- Aceitar `x-cron-secret` ou `x-cron-key`.

## Branding e upload
- Usar `apps/server/src/lib/branding.ts`.
- Requer `GCP_STORAGE_BUCKET` e permissao da service account.

## Observacoes
- Evitar Firebase SDK no frontend; toda escrita deve passar pelo backend.
- `apps/functions` e legado; nao usar como fonte de verdade.
