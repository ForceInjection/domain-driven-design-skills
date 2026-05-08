---
name: image-processor-guidelines
description: Development guidelines for Quantum Skincare's Python FastAPI image processor microservice. Covers FastAPI patterns, Perfect Corp API integration, MediaPipe FaceMesh validation, correlation headers, access control (CIDR + X-Internal-Secret), error handling, Pydantic models, structured logging, mock mode, provider normalization, and testing strategies. Use when working with image-processor code, routes, validation pipeline, Perfect Corp integration, or Python/FastAPI patterns.
---

# Image Processor Guidelines - Quantum Skincare

## Purpose

Quick reference for Quantum Skincare's Python FastAPI image processor microservice, emphasizing FastAPI patterns, Perfect Corp API integration, MediaPipe FaceMesh validation, and structured error handling.

## When to Use This Skill

- Creating or modifying image processor routes
- Working with Perfect Corp API integration
- Implementing face validation logic
- Adding validation pipeline checks
- Configuring access control and security
- Handling correlation headers (X-Request-Id, X-Analysis-Session, X-Frame-Seq)
- Writing Pydantic models
- Implementing error handling
- Adding structured logging
- Working with mock mode
- Testing image processor endpoints
- Python/FastAPI best practices

---

## Quick Start

### New Route Checklist

- [ ] Route under `/v1` prefix (NEVER unversioned)
- [ ] Use `Depends(ensure_valid_upload)` for file uploads
- [ ] Add correlation headers support (X-Request-Id, X-Analysis-Session, X-Frame-Seq)
- [ ] Implement proper error handling with `AppError` or `_http_exc()`
- [ ] Use Pydantic models with `response_model_exclude_none=True`
- [ ] Add structured logging with `request_id` context
- [ ] Test with both mock and real modes
- [ ] Verify access control (CIDR + X-Internal-Secret)
- [ ] Document in docstring

### New Validation Check Checklist

- [ ] Add to validation pipeline (`validation/pipeline.py`)
- [ ] Return structured result with `success`, `reason`, `details`
- [ ] Add to diagnosis response
- [ ] Test with various failure cases
- [ ] Document thresholds and behavior

---

## Service Architecture

### Tech Stack

- **Framework**: FastAPI (ASGI via uvicorn)
- **Models**: Pydantic v2 with `BaseModel`
- **Logging**: Structured JSON logging with contextual `requestId`, route, latency
- **Face Detection**: MediaPipe FaceMesh with concurrency gate
- **Provider**: Perfect Corp API with mock/real modes
- **Image Processing**: PIL (Pillow) for JPEG normalization and resize
- **Access Control**: CIDR allowlist + `X-Internal-Secret` header
- **Deployment**: Dockerized with `/livez` and `/readyz` probes

### Directory Structure

```
apps/image-processor/src/
├── app_http/
│   ├── routes/              # API route handlers
│   │   ├── analyze.py       # POST /v1/perfect-corp/analyze
│   │   ├── validate.py      # POST /v1/validate/face
│   │   └── health.py        # GET /livez, /readyz
│   ├── middleware_access.py # CIDR + secret validation
│   ├── middleware_request_id.py # X-Request-Id propagation
│   ├── headers.py           # Header extraction utilities
│   └── upload_utils.py      # File upload validation
├── config/
│   └── settings.py          # Pydantic settings (env vars)
├── providers/
│   ├── perfect_corp/        # Perfect Corp API client
│   │   ├── client.py        # Main API client
│   │   ├── auth.py          # RSA token authentication
│   │   ├── files.py         # File upload
│   │   ├── tasks.py         # Task polling
│   │   ├── normalizer.py    # Result normalization
│   │   └── http_client.py   # HTTP client with retries
│   └── storage/             # S3 uploader (optional)
├── validation/
│   ├── pipeline.py          # Main validation pipeline
│   ├── mesh_runtime.py      # FaceMesh singleton
│   ├── geometry.py          # Pose, ratio, centering
│   ├── lighting.py          # Lighting analysis
│   └── serialization.py     # Mesh data serialization
├── main.py                  # FastAPI app factory
├── entrypoint.py            # Uvicorn entrypoint
├── errors.py                # Error models and handlers
├── schemas.py               # Pydantic response models
├── perfect_corp_types.py    # Provider type definitions
└── logging_setup.py         # Logging configuration
```

---

## Key Endpoints

### POST /v1/perfect-corp/analyze

Full skin analysis via Perfect Corp API:

```python
@router_v1.post(
    "/perfect-corp/analyze",
    response_model=PerfectCorpAnalysisResponse,
    response_model_exclude_none=True,
)
async def analyze_skin(
    request: Request,
    file: UploadFile = Depends(ensure_valid_upload),
):
    """
    Upload image for full skin analysis.
    Returns: { success, data: { analysisId, skinType, skinAge, programCode, ... }, meta }
    """
    # 1. Extract correlation headers
    request_id = request.state.request_id
    session_id = extract_analysis_session_id(request)

    # 2. Process image (resize to 1024px width JPEG)
    image_bytes = process_image_for_provider(file)

    # 3. Call Perfect Corp API or return mock data
    result = await client.analyze(image_bytes)

    # 4. Attach correlation under `meta`
    return PerfectCorpAnalysisResponse(
        success=True,
        data=result,
        meta=CorrelationMeta(
            requestId=request_id,
            analysisSessionId=session_id
        )
    )
```

**Contract:**
- Correlation in `meta` (not top-level)
- Resize to 1024px width, max height 1920, min width 480
- Re-encode if > 10MB after resize

### POST /v1/validate/face

Face detection and validation:

```python
@router_v1.post(
    "/validate/face",
    response_model=ValidateFaceResponse,
    response_model_exclude_none=True,
)
async def validate_face(
    request: Request,
    file: UploadFile = Depends(ensure_valid_upload),
    yaw_deg: float = Query(...),
    pitch_deg: float = Query(...),
    # ... other thresholds
    include_mesh: bool = Query(False),
):
    """
    Validate face geometry and lighting.
    Returns: { ok, reason?, diagnosis, mesh?, requestId, analysisSessionId }
    """
    # 1. Extract correlation headers
    request_id = request.state.request_id
    session_id = extract_analysis_session_id(request)

    # 2. Downscale to 512px for performance
    image = downscale_image(file, max_size=512)

    # 3. Run validation pipeline
    result = await validate_face_pipeline(image, thresholds)

    # 4. Attach correlation at TOP LEVEL (not meta)
    return ValidateFaceResponse(
        ok=result.ok,
        reason=result.reason,
        diagnosis=result.diagnosis,
        mesh=result.mesh if include_mesh else None,
        requestId=request_id,
        analysisSessionId=session_id,
    )
```

**Contract:**
- Correlation at TOP LEVEL (different from analyze endpoint)
- Downscale to 512px max
- All 8 threshold params required

### GET /livez, /readyz

Health probes:

```python
@router.get("/livez")
async def liveness():
    """Always returns 200 if process is running."""
    return {"status": "ok"}

@router.get("/readyz")
async def readiness():
    """Returns 200 after FaceMesh warmup, else 503."""
    if not is_ready():
        raise _http_exc(503, "SERVICE_UNAVAILABLE", "Service not ready")
    return {"status": "ready"}
```

---

## Core Patterns

### 1. Correlation Headers

**Extract and propagate correlation headers:**

```python
from app_http.headers import (
    extract_request_id,
    extract_analysis_session_id,
    extract_frame_seq,
)

# In route handler
request_id = request.state.request_id  # Set by middleware
session_id = extract_analysis_session_id(request)
frame_seq = extract_frame_seq(request)

# Log with correlation
logger.info({
    "event": "processing_image",
    "requestId": request_id,
    "analysisSessionId": session_id,
    "frameSeq": frame_seq,
})

# Return in response (placement depends on endpoint)
# For /v1/validate/face: top-level
return ValidateFaceResponse(
    ok=True,
    requestId=request_id,
    analysisSessionId=session_id,
)

# For /v1/perfect-corp/analyze: under meta
return PerfectCorpAnalysisResponse(
    success=True,
    data=result,
    meta=CorrelationMeta(
        requestId=request_id,
        analysisSessionId=session_id,
    )
)
```

### 2. Error Handling

**Use standardized error models:**

```python
from errors import AppError, _http_exc, ERROR_CODES

# Option 1: Raise HTTPException with error envelope
if not valid_format:
    raise _http_exc(
        status_code=400,
        error_code="VALIDATION_ERROR",
        message="Invalid image format",
        request_id=request_id,
        frame_seq=frame_seq,
    )

# Option 2: Raise AppError (will be caught by error handler)
if timeout:
    raise AppError(
        error_code="TIMEOUT_ERROR",
        message="Request timed out",
        status_code=408,
        request_id=request_id,
    )

# All errors return:
# { "detail": { "errorCode": "...", "message": "...", "requestId": "...", "frameSeq": "..." } }
```

**Common error codes:**
- `VALIDATION_ERROR` (400)
- `UNAUTHORIZED` (401)
- `FORBIDDEN` (403)
- `TIMEOUT_ERROR` (408)
- `IMAGE_PROCESSING_ERROR` (500)
- `SKIN_ANALYSIS_FAILED` (500)
- `SERVICE_UNAVAILABLE` (503)

### 3. Access Control

**Middleware validates CIDR and shared secret:**

```python
# Automatic via middleware_access.py
# Validates:
# 1. Client IP against IMAGE_PROCESSOR_ALLOWED_CIDRS
# 2. X-Internal-Secret header matches IMAGE_PROCESSOR_SHARED_SECRET

# In production, both are required
# In dev/test with mock mode, can be relaxed
```

**Configuration:**
```bash
IMAGE_PROCESSOR_ALLOWED_CIDRS="10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,127.0.0.1/32"
IMAGE_PROCESSOR_SHARED_SECRET="your-secret-here"
```

### 4. Pydantic Models

**Define response models with proper nesting:**

```python
from pydantic import BaseModel, Field
from typing import Optional

class DiagnosisData(BaseModel):
    pose: PoseResult
    faceRatio: FaceRatioResult
    centering: CenteringResult
    lighting: LightingResult

class ValidateFaceResponse(BaseModel):
    ok: bool
    reason: Optional[str] = None
    diagnosis: DiagnosisData
    mesh: Optional[MeshData] = None
    # Correlation at top-level for this endpoint
    requestId: Optional[str] = Field(None, alias="requestId")
    analysisSessionId: Optional[str] = Field(None, alias="analysisSessionId")

# Use with response_model_exclude_none=True
@router.post("/validate/face", response_model=ValidateFaceResponse, response_model_exclude_none=True)
```

### 5. Structured Logging

**Use structured JSON logging with context:**

```python
import logging

logger = logging.getLogger("image_processor.routes.validate")

# Always include requestId from request.state
logger.info({
    "event": "validation_started",
    "requestId": request.state.request_id,
    "analysisSessionId": session_id,
    "frameSeq": frame_seq,
    "imageSize": len(image_bytes),
})

# On error
logger.error({
    "event": "validation_failed",
    "requestId": request.state.request_id,
    "error": str(e),
    "errorType": type(e).__name__,
})

# Never log secrets
settings = get_settings()
logger.info({
    "event": "config_loaded",
    "mockMode": settings.image_processor_use_mock,
    # ❌ Don't log: settings.image_processor_shared_secret
})
```

### 6. Mock Mode

**Support mock mode for development:**

```python
from config.settings import get_settings

settings = get_settings()

if settings.image_processor_use_mock:
    # Return normalized mock data
    with open(settings.perfect_corp_mock_score_info_path) as f:
        mock_data = json.load(f)
    return normalize_provider_response(mock_data)
else:
    # Call real Perfect Corp API
    result = await client.analyze(image_bytes)
    return result
```

**Configuration:**
```bash
IMAGE_PROCESSOR_USE_MOCK=true
PERFECT_CORP_MOCK_SCORE_INFO_PATH=score_info.json
```

### 7. Image Processing

**Resize and normalize images:**

```python
from PIL import Image
import io

def process_image_for_provider(file: UploadFile) -> bytes:
    """
    Resize to 1024px width JPEG, cap height at 1920, min width 480.
    Re-encode if > 10MB.
    """
    image = Image.open(file.file)

    # Resize to 1024px width, maintain aspect ratio
    width, height = image.size
    if width > 1024:
        ratio = 1024 / width
        new_height = int(height * ratio)
        # Cap height at 1920
        if new_height > 1920:
            ratio = 1920 / height
            new_height = 1920
            width = int(width * ratio)
        image = image.resize((1024, new_height), Image.Resampling.LANCZOS)

    # Convert to JPEG
    buffer = io.BytesIO()
    image.save(buffer, format="JPEG", quality=95)
    image_bytes = buffer.getvalue()

    # Re-encode if > 10MB
    if len(image_bytes) > 10 * 1024 * 1024:
        buffer = io.BytesIO()
        image.save(buffer, format="JPEG", quality=85)
        image_bytes = buffer.getvalue()

    return image_bytes
```

### 8. Validation Pipeline

**Run face validation checks:**

```python
from validation.pipeline import validate_face_pipeline
from validation.mesh_runtime import get_face_mesh

async def validate_face(image: Image.Image, thresholds: dict) -> dict:
    """
    1. Downscale to 512px
    2. MediaPipe FaceMesh detection
    3. Pose estimation (PnP solver)
    4. Face ratio check
    5. Centering validation
    6. Lighting analysis
    7. Side-lighting gating
    """
    # Downscale for performance
    image = downscale_to_max(image, 512)

    # Run FaceMesh (with concurrency gate)
    mesh = get_face_mesh(static_mode=True)
    results = mesh.process(np.array(image))

    if not results.multi_face_landmarks:
        return {"ok": False, "reason": "NO_FACE_DETECTED"}

    # Run validation checks
    pose_result = check_pose(results, thresholds)
    ratio_result = check_face_ratio(results, image.size, thresholds)
    centering_result = check_centering(results, image.size, thresholds)
    lighting_result = check_lighting(image, thresholds)

    # Overall success
    ok = all([
        pose_result["success"],
        ratio_result["success"],
        centering_result["success"],
        lighting_result["success"],
    ])

    return {
        "ok": ok,
        "diagnosis": {
            "pose": pose_result,
            "faceRatio": ratio_result,
            "centering": centering_result,
            "lighting": lighting_result,
        }
    }
```

---

## Perfect Corp Integration

### Authentication Flow

```python
# 1. Generate RSA-encrypted token
token = generate_rsa_token(api_key, secret_key, timestamp)

# 2. Cache token and refresh on 401
if response.status_code == 401:
    token = generate_rsa_token(api_key, secret_key, time.time())
    retry_request()
```

### Full Analysis Flow

```python
# 1. Create file
file_id = await client.create_file(image_bytes, metadata)

# 2. Run task (all 14 conditions by default)
task_id = await client.run_task(file_id)

# 3. Poll status (immediate + retry with backoff)
status = await client.poll_task_status(task_id)

# 4. Download ZIP and extract score_info.json
result = await client.download_and_parse_results(task_id)

# 5. Normalize vendor keys to internal format
normalized = normalize_provider_response(result)

# Program code: (acne_decile - 1) + ((wrinkle_decile - 1) * 10) + 1
# Severity: ≥95 none, ≥80 mild, ≥60 moderate, <60 severe
```

---

## Configuration & Environment

All config via `config/settings.py` using Pydantic `BaseSettings`:

```python
from pydantic_settings import BaseSettings
from pydantic import SecretStr

class Settings(BaseSettings):
    # Environment
    image_processor_env: str = "dev"

    # Mock mode
    image_processor_use_mock: bool = False
    perfect_corp_mock_score_info_path: str = "score_info.json"

    # Perfect Corp API
    perfect_corp_api_url: str
    perfect_corp_api_key: str
    perfect_corp_api_secret_key: SecretStr

    # Access control
    image_processor_shared_secret: SecretStr | None = None
    image_processor_allowed_cidrs: str = "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,127.0.0.1/32"

    # Face Mesh
    face_mesh_concurrency: int = 2
    face_mesh_refine: bool = False

    class Config:
        env_file = ".env"
```

---

## Testing Strategy

### Unit Tests

```python
# Test upload validation
def test_upload_validation():
    assert validate_file_size(10 * 1024 * 1024) == True  # 10MB OK
    assert validate_file_size(11 * 1024 * 1024) == False  # > 10MB

# Test normalization
def test_normalize_provider_response():
    result = normalize_provider_response(mock_score_info)
    assert result["programCode"] == expected_code
    assert result["conditions"]["acne"]["severity"] == "mild"
```

### Integration Tests

```python
# Test mock mode
async def test_analyze_mock_mode():
    response = await client.post("/v1/perfect-corp/analyze", files={"file": image})
    assert response.status_code == 200
    assert response.json()["success"] == True

# Test access control
async def test_access_control_missing_secret():
    response = await client.post("/v1/validate/face", files={"file": image})
    assert response.status_code == 401
```

---

## Common Contracts (DO NOT BREAK)

1. **Versioning**: All new routes under `/v1` only
2. **Correlation placement**:
   - `/v1/validate/face`: TOP LEVEL (`requestId`, `analysisSessionId`)
   - `/v1/perfect-corp/analyze`: Under `meta`
3. **Error envelope**: `{ "detail": { "errorCode", "message", "requestId?", "frameSeq?" } }`
4. **Upload limits**: 10MB max, JPEG/PNG only
5. **Shared secret**: Mandatory in production
6. **Validation params**: All 8 threshold params required for `/v1/validate/face`
7. **Image resize**: 1024px width for analyze, 512px max for validate

---

## Reference Files

For detailed information:

- **Comprehensive docs**: `apps/image-processor/README.md`
- **Routes**: `app_http/routes/*.py`
- **Provider**: `providers/perfect_corp/*.py`
- **Validation**: `validation/*.py`
- **Cursor rules**: `.cursor/rules/image-processor.mdc` (may be outdated)
- **CLAUDE.md**: Image Processor Service section

---

## Related Skills

- **backend-dev-guidelines** - Backend integration patterns
- **frontend-dev-guidelines** - Frontend camera integration

---

**Skill Status**: Created for Quantum Skincare ✅
**Stack**: Python 3.11+, FastAPI, Pydantic v2, MediaPipe, PIL
**Provider**: Perfect Corp API with mock mode support
**Line Count**: Under 500 lines (following Anthropic best practices) ✅
