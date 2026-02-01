---
name: orcheo-demos
description: Run and deploy Orcheo conversational search demos. Use when running demo scripts locally, deploying demos to Orcheo server, or exploring RAG, hybrid search, conversational search, and evaluation workflows from the examples.
---

# Orcheo Demos

## Overview

Run the conversational search demo suite from the Orcheo examples. These demos showcase progressive RAG workflows from basic retrieval to production-grade conversational search with evaluation. The demos can run locally for development or be deployed to an Orcheo server started via the `orcheo` skill.

**Prerequisite**: This skill requires the Orcheo packages to be installed. If not already installed, use the `orcheo` skill first to install `orcheo`, `orcheo-backend`, and `orcheo-sdk`.

## Demo Overview

| Demo | Name | Description | Credentials Required |
|------|------|-------------|---------------------|
| 1 | Basic RAG | Minimal ingestion and retrieval pipeline with in-memory vector store | `openai_api_key` |
| 2 | Hybrid Search | Dense + sparse retrieval with fusion | `openai_api_key`, `tavily_api_key` |
| 3 | Conversational Search | Stateful chat and query rewriting | `openai_api_key`, `pinecone_api_key` |
| 4 | Production | Caching, guardrails, and streaming hooks | `openai_api_key`, `pinecone_api_key` |
| 5 | Evaluation | Golden datasets, metrics, and feedback loops | `openai_api_key`, `pinecone_api_key` |

**Recommended starting point**: Demo 1 works entirely locally with no external vector database.

## Before Running Demos

> **Note on `${REPO_ROOT}`**: Throughout this section, `${REPO_ROOT}` is a placeholder representing the absolute path to the Orcheo repository root (the directory containing `examples/conversational_search/`). Agents should resolve this path before executing commands. If working within the Orcheo repo, this is typically the current working directory or can be determined by locating the `examples/` directory.

### Step 1: Verify Setup

Run the setup checker to verify all prerequisites:

```bash
python ${REPO_ROOT}/examples/conversational_search/check_setup.py
```

This checks:
- Python version (3.12+ required)
- `uv` package manager availability
- Orcheo CLI installation
- Sample data directory
- Required credentials for each demo

If checks fail, follow the guidance provided by the checker.

### Step 2: Install Dependencies

If dependencies are not installed:

```bash
cd ${REPO_ROOT} && uv sync --group examples
```

This installs the `examples` dependency group including `orcheo-backend` for credential vault access.

### Step 3: Configure Credentials

Credentials are stored in the Orcheo vault (`~/.orcheo/vault.sqlite`). Create credentials using the Orcheo CLI.

**For Demo 1 (minimum requirement)**:
```bash
orcheo credential create openai_api_key --secret sk-your-openai-key
```

**For Demo 2 (additional)**:
```bash
orcheo credential create tavily_api_key --secret tvly-your-tavily-key
```

**For Demos 3, 4, 5 (additional)**:
```bash
orcheo credential create pinecone_api_key --secret your-pinecone-api-key
```

**IMPORTANT**: Ask the user for their API keys before creating credentials. Never create credentials with placeholder values.

To check existing credentials:
```bash
orcheo credential get openai_api_key
orcheo credential get tavily_api_key
orcheo credential get pinecone_api_key
```

## Running Demos Locally

Each demo has a standalone script that can be run directly.

### Demo 1: Basic RAG (Recommended First Demo)

```bash
python ${REPO_ROOT}/examples/conversational_search/demo_1_basic_rag/demo_1.py
```

**What to expect**:
- Runs in two phases: non-RAG (direct generation) and RAG (with document ingestion)
- Uses an in-memory vector store (no external DB required)
- Output shows routing decisions, retrieval results, and generated responses with citations

### Demo 2: Hybrid Search

```bash
python ${REPO_ROOT}/examples/conversational_search/demo_2_hybrid_search/demo_2.py
```

**Requires**: `openai_api_key`, `tavily_api_key`

### Demo 3: Conversational Search

```bash
python ${REPO_ROOT}/examples/conversational_search/demo_3_conversational/demo_3.py
```

**Requires**: `openai_api_key`, `pinecone_api_key`, and indexed data in Pinecone

### Demo 4: Production

```bash
python ${REPO_ROOT}/examples/conversational_search/demo_4_production/demo_4.py
```

**Requires**: `openai_api_key`, `pinecone_api_key`, and indexed data in Pinecone

### Demo 5: Evaluation

```bash
python ${REPO_ROOT}/examples/conversational_search/demo_5_evaluation/demo_5.py
```

**Requires**: `openai_api_key`, `pinecone_api_key`, and indexed data in Pinecone

## Deploying Demos to Orcheo Server

Demos can be deployed to an Orcheo server for API access and UI interaction. This requires the Orcheo services to be running (use the `orcheo` skill to start them).

### Prerequisites

1. **Orcheo services running**: Use the `orcheo` skill to start services via `docker compose up -d`
2. **Server URL**: Default is `http://localhost:8000`

### Upload a Demo Workflow

Each demo exposes a `build_graph()` function and `DEFAULT_CONFIG` for server deployment. Upload the demo script to create a workflow:

```bash
orcheo workflow upload ${REPO_ROOT}/examples/conversational_search/demo_1_basic_rag/demo_1.py --name "Basic RAG Demo"
```

### Invoke via API

After uploading, invoke the workflow through the Orcheo API:

```bash
# RAG mode (with documents)
curl -X POST http://localhost:8000/api/v1/workflows/<workflow-id>/invoke \
  -H "Content-Type: application/json" \
  -d '{
    "inputs": {
      "documents": [
        {
          "storage_path": "/path/to/document.txt",
          "source": "document.txt",
          "metadata": {"category": "tech"}
        }
      ],
      "message": "What is this document about?"
    }
  }'

# Non-RAG mode (direct generation)
curl -X POST http://localhost:8000/api/v1/workflows/<workflow-id>/invoke \
  -H "Content-Type: application/json" \
  -d '{
    "inputs": {
      "message": "What is the capital of France?"
    }
  }'
```

## Sample Data

The demos include shared sample data located at `${REPO_ROOT}/examples/conversational_search/data/`:

- **docs/**: Sample knowledge base (Markdown files)
  - `authentication.md` - Authentication patterns
  - `product_overview.md` - Product architecture
  - `troubleshooting.md` - Common issues
- **queries.json**: Sample queries with intents
- **golden/**: Expected answers for evaluation
- **labels/**: Relevance labels for metrics

## Demo-Specific Documentation

Each demo has its own README with detailed information:

- `${REPO_ROOT}/examples/conversational_search/demo_1_basic_rag/README.md`
- `${REPO_ROOT}/examples/conversational_search/demo_2_hybrid_search/README.md`
- `${REPO_ROOT}/examples/conversational_search/demo_3_conversational/README.md`
- `${REPO_ROOT}/examples/conversational_search/demo_4_production/README.md`
- `${REPO_ROOT}/examples/conversational_search/demo_5_evaluation/README.md`

Read these files for workflow diagrams, configuration options, and expected outputs.

## Troubleshooting

### "Credential not found" errors

Create the missing credential:
```bash
orcheo credential create <credential_name> --secret <value>
```

### "Connection refused" when deploying

The Orcheo server is not running. Use the `orcheo` skill to start services:
```bash
docker compose -f path/to/docker-compose.yml up -d
```

### Import errors when running demos

Install the examples dependency group:
```bash
cd ${REPO_ROOT} && uv sync --group examples
```

### Demo script not found

Ensure you're in the correct directory and the path to the examples is correct. The demos are located at `examples/conversational_search/` relative to the Orcheo repository root.

## Resources

- Demo suite: `${REPO_ROOT}/examples/conversational_search/`
- Setup checker: `${REPO_ROOT}/examples/conversational_search/check_setup.py`
- Shared utilities: `${REPO_ROOT}/examples/conversational_search/utils.py`
- Sample data: `${REPO_ROOT}/examples/conversational_search/data/`
