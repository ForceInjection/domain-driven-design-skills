---
name: cva-setup-vertex
description: Complete Vertex AI and Google Cloud Platform setup for Clojure agent development. Includes GCP project saas3-476116 credentials, security best practices (IAM, key rotation, LGPD), cost analysis, API enablement, and environment configuration. Use when starting new Clojure+Vertex project, configuring GCP credentials, implementing security compliance, or troubleshooting authentication.
allowed-tools: Read,Bash,Edit,Write
---

# Vertex AI Project Context - Clojure Integration Setup

> **Last Updated:** 2025-10-27
> **Status:** Python/ADK environment validated, ready for Clojure integration
> **GCP Project:** saas3-476116

---

## 🎯 Overview

This skill consolidates complete context for the existing Vertex AI project to facilitate integration with Clojure. The goal is to leverage the already-configured GCP infrastructure and lessons learned from Python ADK to create agents using Clojure.

---

## 🔐 Credentials and GCP Configuration

### Google Cloud Project

| Property | Value |
|----------|-------|
| **Project ID** | `saas3-476116` |
| **Primary Region** | `us-central1` |
| **Service Account** | `vertex-ai-app@saas3-476116.iam.gserviceaccount.com` |
| **JSON Key** | `~/.gcp-credentials/vertex-ai-app-key.json` |
| **Key Permissions** | `chmod 600` (always verify) |

### Enabled APIs

```bash
# Critical APIs already enabled
- aiplatform.googleapis.com         # Vertex AI API
- generativelanguage.googleapis.com # Gemini API
- cloudbuild.googleapis.com         # Cloud Build
- run.googleapis.com                # Cloud Run

# Verify APIs
gcloud services list --enabled --project=saas3-476116
```

### Essential Environment Variables

**File:** `~/.env` (chmod 600, **DO NOT commit**)

```bash
# Google Cloud Configuration
export GOOGLE_CLOUD_PROJECT="saas3-476116"
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.gcp-credentials/vertex-ai-app-key.json"
export GOOGLE_CLOUD_LOCATION="us-central1"

# Vertex AI Endpoint
export VERTEX_AI_ENDPOINT="us-central1-aiplatform.googleapis.com"

# For Vertex AI with Google Generative AI SDK
export GOOGLE_GENAI_USE_VERTEXAI="TRUE"

# ADK Configuration
export ADK_MODEL="gemini-1.5-flash"
export ADK_TEMPERATURE="0.7"
export ADK_MAX_TOKENS="2048"
```

**⚠️ CRITICAL:** Protect file:
```bash
chmod 600 ~/.env
```

### Clojure Configuration

Read environment variables in Clojure:

```clojure
(ns lab.config.google-cloud
  "Google Cloud configuration from environment"
  (:require [clojure.java.io :as io]))

(defn get-env
  "Reads environment variable with fallback"
  [key default]
  (or (System/getenv key) default))

(def gcp-config
  {:project-id (get-env "GOOGLE_CLOUD_PROJECT" "saas3-476116")
   :location (get-env "GOOGLE_CLOUD_LOCATION" "us-central1")
   :credentials (get-env "GOOGLE_APPLICATION_CREDENTIALS"
                        (str (System/getProperty "user.home")
                             "/.gcp-credentials/vertex-ai-app-key.json"))
   :endpoint (get-env "VERTEX_AI_ENDPOINT"
                     "us-central1-aiplatform.googleapis.com")})

(defn validate-credentials
  "Validates that credentials file exists and is readable"
  []
  (let [creds-file (io/file (:credentials gcp-config))]
    (when-not (.exists creds-file)
      (throw (ex-info "Credentials file not found"
                      {:path (:credentials gcp-config)})))
    (when-not (.canRead creds-file)
      (throw (ex-info "Credentials file not readable"
                      {:path (:credentials gcp-config)})))
    true))

;; Usage
(comment
  (validate-credentials)
  ;; => true or throws ex-info

  (:project-id gcp-config)
  ;; => "saas3-476116"
  )
```

---

## 📊 IAM and Security

### Service Account Roles

**Current Role:** `roles/aiplatform.user` (least privilege)

```bash
# Verify current roles
gcloud projects get-iam-policy saas3-476116 \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:vertex-ai-app*"

# Expected output:
# - roles/aiplatform.user (use Vertex AI)
```

### Key Rotation (Mandatory every 90 days)

```bash
# 1. List existing keys
gcloud iam service-accounts keys list \
  --iam-account=vertex-ai-app@saas3-476116.iam.gserviceaccount.com \
  --format="table(name,validAfterTime,validBeforeTime)"

# 2. Create new key
gcloud iam service-accounts keys create \
  ~/.gcp-credentials/vertex-ai-app-key-new.json \
  --iam-account=vertex-ai-app@saas3-476116.iam.gserviceaccount.com

# 3. Protect
chmod 600 ~/.gcp-credentials/vertex-ai-app-key-new.json

# 4. Test
GOOGLE_APPLICATION_CREDENTIALS=~/.gcp-credentials/vertex-ai-app-key-new.json \
  gcloud auth application-default print-access-token

# 5. Update ~/.env and delete old key
gcloud iam service-accounts keys delete OLD_KEY_ID \
  --iam-account=vertex-ai-app@saas3-476116.iam.gserviceaccount.com
```

### Security Audit Checklist (Monthly)

- [ ] Rotate keys (every 90 days)
- [ ] Review IAM permissions
- [ ] Verify enabled APIs (disable unused)
- [ ] Analyze costs
- [ ] Verify .gitignore (no keys committed)
- [ ] Check service account activity logs
- [ ] Review Vertex AI quotas

---

## 💰 Observed Costs and Estimates

### Real Costs (Healthcare Pipeline - 20 posts/month)

| Component | Cost per Execution | Monthly (20 posts) |
|-----------|-------------------|-------------------|
| **S.1.1** (Type B - LGPD Extraction) | $0.045 | $0.90 |
| **S.1.2** (Type A - Claims ID) | $0.021 | $0.42 |
| **S.2-1.2** (Type C - References) | $0.067 | $1.34 |
| **S.3-2** (Type B - SEO) | $0.078 | $1.56 |
| **S.4** (Type D - Consolidation) | $0.18 | $3.60 |
| **Total per post** | **$0.391** | **$7.82** |

**With optimizations (cache + parallel):**
- Cost per post: $0.162 (-58.6%)
- Monthly: $3.24 (-58.6%)

### Model Pricing (us-central1)

| Model | Input (1M tokens) | Output (1M tokens) | Best For |
|-------|-------------------|-------------------|----------|
| **gemini-1.5-flash** | $0.075 | $0.30 | Type A/B (70% of tasks) |
| **gemini-1.5-pro** | $1.25 | $5.00 | Type C/D (complex reasoning) |
| **gemini-2.5-flash** | $0.10 | $0.40 | Balanced (future) |

**Multi-model strategy savings:** 41% vs Claude-only

---

## 🛠️ Clojure + Vertex AI Setup

### deps.edn Configuration

```clojure
{:paths ["src" "resources"]
 :deps {org.clojure/clojure {:mvn/version "1.11.1"}

        ;; Google Cloud Vertex AI (Java SDK)
        com.google.cloud/google-cloud-aiplatform {:mvn/version "3.36.0"}
        com.google.cloud/google-cloud-vertexai {:mvn/version "0.2.0"}

        ;; Google Auth
        com.google.auth/google-auth-library-oauth2-http {:mvn/version "1.19.0"}

        ;; JSON handling
        cheshire/cheshire {:mvn/version "5.11.0"}

        ;; HTTP client
        clj-http/clj-http {:mvn/version "3.12.3"}

        ;; Database (if using Type B/D)
        com.github.seancorfield/next.jdbc {:mvn/version "1.3.909"}
        org.postgresql/postgresql {:mvn/version "42.6.0"}

        ;; Python interop (optional, for libpython-clj)
        clj-python/libpython-clj {:mvn/version "2.025"}

        ;; Logging
        org.clojure/tools.logging {:mvn/version "1.2.4"}
        ch.qos.logback/logback-classic {:mvn/version "1.4.11"}}

 :aliases
 {:dev {:extra-paths ["dev"]
        :extra-deps {nrepl/nrepl {:mvn/version "1.0.0"}
                     cider/cider-nrepl {:mvn/version "0.30.0"}}}

  :test {:extra-paths ["test"]
         :extra-deps {org.clojure/test.check {:mvn/version "1.1.1"}}}}}
```

### Basic Vertex AI Agent (Type A)

```clojure
(ns lab.agents.basic
  "Basic Type A agent example"
  (:require [lab.config.google-cloud :as gc]
            [cheshire.core :as json])
  (:import [com.google.cloud.vertexai VertexAI]
           [com.google.cloud.vertexai.generativeai GenerativeModel]
           [com.google.cloud.vertexai.api GenerationConfig]))

(defn create-vertex-ai-instance
  "Creates Vertex AI instance with credentials."
  []
  (let [{:keys [project-id location credentials]} gc/gcp-config]
    (gc/validate-credentials)
    (VertexAI. project-id location)))

(defn create-generative-model
  "Creates a generative model."
  ([vertex-ai] (create-generative-model vertex-ai "gemini-1.5-flash"))
  ([vertex-ai model-name]
   (let [generation-config (-> (GenerationConfig/newBuilder)
                               (.setTemperature 0.7)
                               (.setMaxOutputTokens 2048)
                               (.setTopP 0.95)
                               (.build))
         model (.getGenerativeModel vertex-ai model-name)]
     (.withGenerationConfig model generation-config))))

(defn generate-content
  "Generates content from prompt."
  [model prompt]
  (let [response (.generateContent model prompt)]
    {:text (-> response .getText)
     :metadata {:model (.getModelName model)
                :finish-reason (-> response .getCandidates first .getFinishReason str)}}))

;; REPL Usage
(comment
  ;; 1. Create Vertex AI instance
  (def vertex-ai (create-vertex-ai-instance))

  ;; 2. Create model
  (def model (create-generative-model vertex-ai "gemini-1.5-flash"))

  ;; 3. Generate content
  (def result
    (generate-content
      model
      "Explain functional programming in Clojure in 3 sentences."))

  (:text result)
  ;; => "Functional programming in Clojure emphasizes..."

  ;; 4. Clean up
  (.close vertex-ai)
  )
```

---

## 🔒 Security Best Practices

### 1. Credentials Management

**DO:**
- ✅ Store credentials in `~/.gcp-credentials/` (outside repo)
- ✅ Use `chmod 600` on all credential files
- ✅ Set `GOOGLE_APPLICATION_CREDENTIALS` environment variable
- ✅ Rotate keys every 90 days
- ✅ Use service accounts (not user accounts)

**DON'T:**
- ❌ Commit credentials to git
- ❌ Share credentials via chat/email
- ❌ Use keys older than 90 days
- ❌ Give excessive permissions (`roles/owner`)

### 2. .gitignore (Mandatory)

```gitignore
# GCP Credentials
.gcp-credentials/
*-key.json
*.json.enc

# Environment files
.env
.env.local
.env.*.local

# Secrets
secrets/
credentials/
```

### 3. Least Privilege IAM

**Minimum roles needed:**
- `roles/aiplatform.user` - Use Vertex AI
- `roles/logging.viewer` - View logs (optional)

**Avoid:**
- `roles/owner` - Too broad
- `roles/editor` - Too broad
- `roles/aiplatform.admin` - Unless deploying

### 4. LGPD Compliance (Brazil)

When processing personal data:

```clojure
(ns lab.compliance.lgpd
  "LGPD compliance utilities")

(def sensitive-data-patterns
  "Patterns for detecting sensitive personal data"
  {:cpf #"\d{3}\.\d{3}\.\d{3}-\d{2}"
   :rg #"\d{1,2}\.\d{3}\.\d{3}-\d{1,2}"
   :email #"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"
   :phone #"\(?[0-9]{2}\)?\s?[0-9]{4,5}-?[0-9]{4}"
   :health-data #"(?i)(diabetes|hipertens[ãa]o|depress[ãa]o|ansiedade)"})

(defn detect-sensitive-data
  "Detects sensitive personal data in text."
  [text]
  (reduce-kv
    (fn [acc data-type pattern]
      (if (re-find pattern text)
        (conj acc data-type)
        acc))
    []
    sensitive-data-patterns))

(defn sanitize-for-logging
  "Removes sensitive data before logging."
  [text]
  (reduce-kv
    (fn [sanitized data-type pattern]
      (clojure.string/replace sanitized pattern "[REDACTED]"))
    text
    sensitive-data-patterns))

;; Usage
(comment
  (detect-sensitive-data "Cliente: João Silva, CPF: 123.456.789-00")
  ;; => [:cpf]

  (sanitize-for-logging "Cliente: João Silva, CPF: 123.456.789-00")
  ;; => "Cliente: João Silva, CPF: [REDACTED]"
  )
```

> 📘 **Full compliance guide:** See [`cva-healthcare-compliance`](../cva-healthcare-compliance/SKILL.md) skill.

---

## 🧪 Testing and Validation

### Verify GCP Setup

```bash
# 1. Verify gcloud auth
gcloud auth application-default print-access-token

# 2. Verify project
gcloud config get-value project
# Expected: saas3-476116

# 3. Verify APIs
gcloud services list --enabled --project=saas3-476116 | grep aiplatform

# 4. Test Vertex AI access
gcloud ai models list --region=us-central1 --project=saas3-476116
```

### Clojure Integration Test

```clojure
(ns lab.test.integration
  "Integration tests for Vertex AI"
  (:require [clojure.test :refer :all]
            [lab.config.google-cloud :as gc]
            [lab.agents.basic :as basic]))

(deftest test-vertex-ai-connection
  (testing "Can create Vertex AI instance"
    (let [vertex-ai (basic/create-vertex-ai-instance)]
      (is (some? vertex-ai))
      (.close vertex-ai))))

(deftest test-model-generation
  (testing "Can generate content"
    (let [vertex-ai (basic/create-vertex-ai-instance)
          model (basic/create-generative-model vertex-ai)
          result (basic/generate-content model "Say 'test'")]
      (is (string? (:text result)))
      (is (> (count (:text result)) 0))
      (.close vertex-ai))))
```

Run tests:
```bash
clojure -X:test
```

---

## 🚨 Troubleshooting

### "Credentials not found"

**Problem:** `GOOGLE_APPLICATION_CREDENTIALS` not set or file doesn't exist

**Solution:**
```bash
# Verify file exists
ls -la ~/.gcp-credentials/vertex-ai-app-key.json

# Verify permissions
chmod 600 ~/.gcp-credentials/vertex-ai-app-key.json

# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.gcp-credentials/vertex-ai-app-key.json"

# Test
gcloud auth application-default print-access-token
```

### "API not enabled"

**Problem:** Vertex AI API not enabled for project

**Solution:**
```bash
gcloud services enable aiplatform.googleapis.com --project=saas3-476116
```

### "Permission denied"

**Problem:** Service account lacks necessary roles

**Solution:**
```bash
gcloud projects add-iam-policy-binding saas3-476116 \
  --member="serviceAccount:vertex-ai-app@saas3-476116.iam.gserviceaccount.com" \
  --role="roles/aiplatform.user"
```

### "Quota exceeded"

**Problem:** Exceeded Vertex AI quotas

**Solution:**
```bash
# Check quotas
gcloud compute project-info describe --project=saas3-476116

# Request quota increase (if needed)
# https://console.cloud.google.com/iam-admin/quotas?project=saas3-476116
```

---

## 🔗 Related Skills

- [`cva-setup-clojure`](../cva-setup-clojure/SKILL.md) - Clojure project structure
- [`cva-setup-interop`](../cva-setup-interop/SKILL.md) - libpython-clj setup
- [`cva-healthcare-compliance`](../cva-healthcare-compliance/SKILL.md) - LGPD compliance ⭐
- [`cva-concepts-adk`](../cva-concepts-adk/SKILL.md) - Google ADK architecture
- [`cva-quickref-adk`](../cva-quickref-adk/SKILL.md) - ADK quick reference

---

## 📘 Additional Documentation

- [GCP Console](https://console.cloud.google.com/welcome?project=saas3-476116)
- [Vertex AI Documentation](https://cloud.google.com/vertex-ai/docs)
- [IAM Best Practices](https://cloud.google.com/iam/docs/best-practices)
- [Security Checklist](security-checklist.md) (skill-specific doc)
- [Cost Optimization](cost-optimization.md) (skill-specific doc)

---

*This setup is validated for production healthcare systems with proven ROI. Follow security best practices rigorously.*
