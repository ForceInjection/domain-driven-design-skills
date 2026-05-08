---
name: project-architecture-patterns
description: Architecture patterns for rRNA-Phylo project including FastAPI backend design, service organization, async task processing with Celery, Pydantic schemas, testing with pytest, Biopython integration, and API design conventions. Covers project structure, dependency injection, error handling, and configuration management.
---

# Project Architecture Patterns

## Purpose

Establish consistent architecture patterns for the rRNA-Phylo project, covering backend design, service organization, API conventions, and testing strategies.

## When to Use

This skill activates when:
- Setting up new services or modules
- Designing API endpoints
- Implementing background tasks
- Working with configuration or dependencies
- Writing tests
- Integrating external tools (HMMER, BLAST, alignment tools)

## Tech Stack

### Core Backend
- **FastAPI**: Modern async web framework
- **Pydantic**: Data validation and settings
- **SQLAlchemy**: ORM for database operations
- **Celery**: Distributed task queue for long-running jobs
- **Redis**: Message broker and cache
- **PostgreSQL**: Primary database (SQLite for dev)

### Scientific Computing
- **Biopython**: Sequence parsing and analysis
- **NumPy/Pandas**: Numerical computing and data manipulation
- **scikit-learn**: ML baseline models
- **PyTorch**: Deep learning (Phase 2+)

### Testing & Quality
- **pytest**: Testing framework
- **pytest-asyncio**: Async test support
- **pytest-cov**: Coverage reporting
- **httpx**: Async HTTP client for API tests
- **ruff**: Fast linter
- **black**: Code formatter

---

## Project Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py                    # FastAPI application
│   ├── config.py                  # Settings (via Pydantic)
│   │
│   ├── models/                    # SQLAlchemy ORM models
│   │   ├── __init__.py
│   │   ├── base.py               # Base model class
│   │   ├── job.py                # Job model
│   │   ├── sequence.py           # Sequence model
│   │   └── tree.py               # Phylogenetic tree model
│   │
│   ├── schemas/                   # Pydantic schemas (API contracts)
│   │   ├── __init__.py
│   │   ├── common.py             # Shared schemas
│   │   ├── rrna.py               # rRNA detection schemas
│   │   ├── phylo.py              # Phylogenetics schemas
│   │   └── job.py                # Job status schemas
│   │
│   ├── api/                       # API routes
│   │   ├── __init__.py
│   │   ├── deps.py               # Dependency injection
│   │   └── v1/
│   │       ├── __init__.py
│   │       ├── router.py         # Main router
│   │       ├── rrna.py           # rRNA endpoints
│   │       ├── phylo.py          # Phylogenetics endpoints
│   │       └── jobs.py           # Job management
│   │
│   ├── services/                  # Business logic layer
│   │   ├── rrna/                 # rRNA detection service
│   │   ├── phylo/                # Phylogenetics service
│   │   └── sequences/            # Sequence processing
│   │
│   ├── workers/                   # Celery tasks
│   │   ├── __init__.py
│   │   ├── celery_app.py         # Celery config
│   │   └── tasks.py              # Task definitions
│   │
│   ├── core/                      # Core utilities
│   │   ├── __init__.py
│   │   ├── errors.py             # Custom exceptions
│   │   └── logging.py            # Logging setup
│   │
│   └── db/                        # Database utilities
│       ├── __init__.py
│       ├── session.py            # DB session management
│       └── migrations/           # Alembic migrations
│
├── tests/
│   ├── conftest.py               # Pytest fixtures
│   ├── unit/                     # Unit tests
│   ├── integration/              # Integration tests
│   └── fixtures/                 # Test data
│
├── requirements.txt
├── pyproject.toml
└── Dockerfile
```

---

## Core Patterns

### 1. Configuration Management

**Pattern**: Use Pydantic Settings for type-safe configuration.

```python
# app/config.py
from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    """Application settings."""

    # API Settings
    api_v1_prefix: str = "/api/v1"
    project_name: str = "rRNA-Phylo"
    debug: bool = False

    # Database
    database_url: str = "sqlite:///./rrna_phylo.db"

    # Celery
    celery_broker_url: str = "redis://localhost:6379/0"
    celery_result_backend: str = "redis://localhost:6379/0"

    # External Tools
    hmmer_path: str = "/usr/local/bin/hmmsearch"
    blast_path: str = "/usr/local/bin/blastn"

    # Data Paths
    hmm_profiles_dir: str = "./data/hmm_profiles"
    blast_db_dir: str = "./data/blast_dbs"

    # ML Models
    ml_models_dir: str = "./models"

    class Config:
        env_file = ".env"
        case_sensitive = False

@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()
```

**Usage in dependencies:**
```python
# app/api/deps.py
from fastapi import Depends
from app.config import Settings, get_settings

async def get_config() -> Settings:
    return get_settings()
```

### 2. Service Layer Pattern

**Pattern**: Encapsulate business logic in service classes.

```python
# app/services/rrna/detector.py
from typing import List, Optional
from app.schemas.rrna import RRNADetectionResult, RRNAType
from app.config import Settings

class RRNADetectorService:
    """Service for detecting rRNA in sequences."""

    def __init__(self, settings: Settings):
        self.settings = settings
        self.hmm_detector = HMMDetector(settings.hmm_profiles_dir)
        self.pattern_detector = PatternDetector()

    async def detect(
        self,
        sequence: str,
        methods: List[str] = ["hmm", "pattern"],
        min_confidence: float = 0.8
    ) -> List[RRNADetectionResult]:
        """
        Detect rRNA in sequence using multiple methods.

        Args:
            sequence: DNA/RNA sequence string
            methods: Detection methods to use
            min_confidence: Minimum confidence threshold

        Returns:
            List of detection results
        """
        results = []

        if "hmm" in methods:
            hmm_results = await self.hmm_detector.detect(sequence)
            results.extend(hmm_results)

        if "pattern" in methods:
            pattern_results = await self.pattern_detector.detect(sequence)
            results.extend(pattern_results)

        # Filter by confidence
        results = [r for r in results if r.confidence >= min_confidence]

        # Deduplicate and merge
        return self._merge_results(results)

    def _merge_results(
        self,
        results: List[RRNADetectionResult]
    ) -> List[RRNADetectionResult]:
        """Merge overlapping detections."""
        # Implementation here
        pass
```

**Usage in API:**
```python
# app/api/v1/rrna.py
from fastapi import APIRouter, Depends
from app.services.rrna.detector import RRNADetectorService
from app.api.deps import get_rrna_detector

router = APIRouter()

@router.post("/detect")
async def detect_rrna(
    sequence: str,
    detector: RRNADetectorService = Depends(get_rrna_detector)
):
    """Detect rRNA in sequence."""
    results = await detector.detect(sequence)
    return {"results": results}
```

### 3. Pydantic Schemas (API Contracts)

**Pattern**: Define clear input/output schemas with validation.

```python
# app/schemas/rrna.py
from pydantic import BaseModel, Field, validator
from typing import List, Optional
from enum import Enum

class RRNAType(str, Enum):
    """Supported rRNA types."""
    SSU_16S = "16S"
    SSU_18S = "18S"
    LSU_23S = "23S"
    LSU_28S = "28S"
    FIVE_S = "5S"
    FIVE_EIGHT_S = "5.8S"

class DetectionMethod(str, Enum):
    """Detection methods."""
    HMM = "hmm"
    BLAST = "blast"
    PATTERN = "pattern"
    ML = "ml"

class RRNADetectionRequest(BaseModel):
    """Request schema for rRNA detection."""

    sequence: str = Field(..., min_length=100, max_length=100000)
    methods: List[DetectionMethod] = Field(
        default=[DetectionMethod.HMM, DetectionMethod.PATTERN]
    )
    min_confidence: float = Field(default=0.8, ge=0.0, le=1.0)

    @validator("sequence")
    def validate_sequence(cls, v):
        """Ensure sequence contains only valid nucleotides."""
        valid_chars = set("ACGTUNacgtun-")
        if not set(v).issubset(valid_chars):
            raise ValueError("Sequence contains invalid characters")
        return v.upper()

class ConservedRegion(BaseModel):
    """Conserved region within detected rRNA."""
    name: str
    start: int
    end: int
    sequence: str
    confidence: float

class RRNADetectionResult(BaseModel):
    """Result schema for rRNA detection."""

    rrna_type: RRNAType
    start: int
    end: int
    length: int
    confidence: float
    method: DetectionMethod
    score: float

    # Quality metrics
    completeness: float = Field(..., ge=0.0, le=1.0)
    quality: str = Field(..., pattern="^(high|medium|low|very_low)$")

    # Optional details
    conserved_regions: Optional[List[ConservedRegion]] = None
    secondary_structure: Optional[str] = None

    class Config:
        json_schema_extra = {
            "example": {
                "rrna_type": "16S",
                "start": 0,
                "end": 1542,
                "length": 1542,
                "confidence": 0.95,
                "method": "hmm",
                "score": 1250.5,
                "completeness": 0.98,
                "quality": "high"
            }
        }
```

### 4. Dependency Injection

**Pattern**: Use FastAPI's dependency injection for services.

```python
# app/api/deps.py
from typing import Generator
from fastapi import Depends
from sqlalchemy.orm import Session

from app.db.session import SessionLocal
from app.config import Settings, get_settings
from app.services.rrna.detector import RRNADetectorService

# Database dependency
def get_db() -> Generator:
    """Get database session."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Service dependencies
def get_rrna_detector(
    settings: Settings = Depends(get_settings)
) -> RRNADetectorService:
    """Get rRNA detector service."""
    return RRNADetectorService(settings)

def get_phylo_service(
    settings: Settings = Depends(get_settings),
    db: Session = Depends(get_db)
):
    """Get phylogenetic analysis service."""
    from app.services.phylo.tree_builder import PhyloService
    return PhyloService(settings, db)
```

### 5. Error Handling

**Pattern**: Use custom exceptions and FastAPI exception handlers.

```python
# app/core/errors.py
class RRNAPhyloException(Exception):
    """Base exception for rRNA-Phylo."""
    pass

class SequenceValidationError(RRNAPhyloException):
    """Raised when sequence validation fails."""
    pass

class DetectionError(RRNAPhyloException):
    """Raised when rRNA detection fails."""
    pass

class AlignmentError(RRNAPhyloException):
    """Raised when sequence alignment fails."""
    pass

class TreeBuildingError(RRNAPhyloException):
    """Raised when tree building fails."""
    pass

# app/main.py
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from app.core.errors import RRNAPhyloException

app = FastAPI()

@app.exception_handler(RRNAPhyloException)
async def rrna_phylo_exception_handler(
    request: Request,
    exc: RRNAPhyloException
):
    """Handle custom exceptions."""
    return JSONResponse(
        status_code=400,
        content={
            "error": exc.__class__.__name__,
            "message": str(exc)
        }
    )
```

### 6. Async Task Processing (Celery)

**Pattern**: Use Celery for long-running tasks.

```python
# app/workers/celery_app.py
from celery import Celery
from app.config import get_settings

settings = get_settings()

celery_app = Celery(
    "rrna_phylo",
    broker=settings.celery_broker_url,
    backend=settings.celery_result_backend
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    task_track_started=True,
    task_time_limit=3600,  # 1 hour max
)

# app/workers/tasks.py
from app.workers.celery_app import celery_app
from app.services.phylo.tree_builder import PhyloService

@celery_app.task(bind=True)
def build_phylogenetic_tree(
    self,
    sequences: List[dict],
    method: str,
    parameters: dict
):
    """
    Build phylogenetic tree (long-running task).

    Args:
        self: Task instance (for progress updates)
        sequences: List of sequences
        method: Tree building method
        parameters: Method parameters
    """
    try:
        # Update progress
        self.update_state(state="PROGRESS", meta={"stage": "alignment"})

        service = PhyloService()

        # Align sequences
        alignment = service.align_sequences(sequences)

        self.update_state(state="PROGRESS", meta={"stage": "tree_building"})

        # Build tree
        tree = service.build_tree(alignment, method, parameters)

        return {"tree": tree, "status": "completed"}

    except Exception as e:
        self.update_state(state="FAILURE", meta={"error": str(e)})
        raise
```

**API integration:**
```python
# app/api/v1/phylo.py
from fastapi import APIRouter, BackgroundTasks
from app.workers.tasks import build_phylogenetic_tree

router = APIRouter()

@router.post("/tree")
async def create_tree(request: TreeBuildRequest):
    """Submit tree building job."""

    # Submit Celery task
    task = build_phylogenetic_tree.delay(
        sequences=request.sequences,
        method=request.method,
        parameters=request.parameters
    )

    return {
        "job_id": task.id,
        "status": "submitted"
    }

@router.get("/tree/{job_id}")
async def get_tree_status(job_id: str):
    """Get tree building job status."""
    task = build_phylogenetic_tree.AsyncResult(job_id)

    return {
        "job_id": job_id,
        "status": task.state,
        "result": task.result if task.ready() else None
    }
```

---

## Testing Patterns

### 1. Test Structure

```python
# tests/conftest.py
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.main import app
from app.db.session import Base, get_db

# Test database
SQLALCHEMY_TEST_URL = "sqlite:///./test.db"

@pytest.fixture(scope="session")
def test_engine():
    """Create test database engine."""
    engine = create_engine(SQLALCHEMY_TEST_URL)
    Base.metadata.create_all(bind=engine)
    yield engine
    Base.metadata.drop_all(bind=engine)

@pytest.fixture(scope="function")
def test_db(test_engine):
    """Create test database session."""
    TestSessionLocal = sessionmaker(bind=test_engine)
    db = TestSessionLocal()
    try:
        yield db
    finally:
        db.close()

@pytest.fixture
def client(test_db):
    """Create test client."""
    def override_get_db():
        yield test_db

    app.dependency_overrides[get_db] = override_get_db
    yield TestClient(app)
    app.dependency_overrides.clear()

@pytest.fixture
def sample_16s_sequence():
    """Sample 16S rRNA sequence for testing."""
    return "AGAGTTTGATCCTGGCTCAG..."  # Truncated
```

### 2. Unit Test Example

```python
# tests/unit/test_rrna_detector.py
import pytest
from app.services.rrna.detector import RRNADetectorService

@pytest.mark.asyncio
async def test_detect_16s_rrna(sample_16s_sequence, get_settings):
    """Test 16S rRNA detection."""
    detector = RRNADetectorService(get_settings())

    results = await detector.detect(sample_16s_sequence)

    assert len(results) > 0
    assert results[0].rrna_type == "16S"
    assert results[0].confidence >= 0.8
```

### 3. Integration Test Example

```python
# tests/integration/test_api.py
def test_detect_rrna_endpoint(client, sample_16s_sequence):
    """Test rRNA detection API endpoint."""
    response = client.post(
        "/api/v1/rrna/detect",
        json={
            "sequence": sample_16s_sequence,
            "methods": ["hmm", "pattern"],
            "min_confidence": 0.8
        }
    )

    assert response.status_code == 200
    data = response.json()
    assert "results" in data
    assert len(data["results"]) > 0
```

---

## API Design Conventions

### 1. RESTful Endpoints

```
# rRNA Detection
POST   /api/v1/rrna/detect           # Detect rRNA
GET    /api/v1/rrna/types             # List supported types

# Phylogenetics
POST   /api/v1/phylo/align            # Align sequences
POST   /api/v1/phylo/tree             # Build tree
POST   /api/v1/phylo/bootstrap        # Bootstrap analysis
POST   /api/v1/phylo/consensus        # Consensus tree

# Jobs
GET    /api/v1/jobs                   # List jobs
GET    /api/v1/jobs/{id}              # Get job status
DELETE /api/v1/jobs/{id}              # Cancel job

# Health
GET    /health                        # Health check
GET    /metrics                       # Prometheus metrics
```

### 2. Response Format

```python
# Success response
{
    "success": true,
    "data": { ... },
    "metadata": {
        "timestamp": "2025-11-20T12:00:00Z",
        "version": "1.0.0"
    }
}

# Error response
{
    "success": false,
    "error": {
        "code": "VALIDATION_ERROR",
        "message": "Invalid sequence format",
        "details": { ... }
    }
}
```

---

## Best Practices

### ✅ DO
- Use type hints everywhere
- Write docstrings for public APIs
- Use Pydantic for validation
- Implement proper logging
- Write tests for new features
- Use async/await for I/O operations
- Separate concerns (routes, services, models)
- Use dependency injection
- Handle errors gracefully
- Document API with examples

### ❌ DON'T
- Mix business logic with API routes
- Use synchronous I/O in async functions
- Hardcode configuration values
- Skip input validation
- Ignore exceptions
- Write god classes
- Couple services tightly
- Skip tests
- Use global state
- Block the event loop

---

## External Tool Integration Pattern

```python
# app/services/rrna/hmm.py
import subprocess
from pathlib import Path
from typing import Optional

class HMMDetector:
    """HMM-based rRNA detection using HMMER."""

    def __init__(self, profiles_dir: str, hmmsearch_path: str = "hmmsearch"):
        self.profiles_dir = Path(profiles_dir)
        self.hmmsearch_path = hmmsearch_path

    async def detect(self, sequence: str, rrna_type: str) -> dict:
        """Run HMMER search."""

        # Create temp files
        with tempfile.NamedTemporaryFile(mode='w', suffix='.fasta') as seq_file:
            seq_file.write(f">query\n{sequence}\n")
            seq_file.flush()

            profile = self.profiles_dir / f"{rrna_type}.hmm"

            # Run HMMER
            result = subprocess.run(
                [
                    self.hmmsearch_path,
                    "--tblout", "/dev/stdout",
                    str(profile),
                    seq_file.name
                ],
                capture_output=True,
                text=True,
                timeout=300
            )

            if result.returncode != 0:
                raise DetectionError(f"HMMER failed: {result.stderr}")

            # Parse output
            return self._parse_hmmer_output(result.stdout)
```

---

**Related Skills**: [rRNA-prediction-patterns](../rrna-prediction-patterns/SKILL.md), [ml-integration-patterns](../ml-integration-patterns/SKILL.md)

**Line Count**: < 500 lines ✅
