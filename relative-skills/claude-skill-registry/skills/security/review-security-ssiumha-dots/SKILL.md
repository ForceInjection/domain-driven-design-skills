---
name: review-security
description: 보안 관점에서 코드를 검토합니다. OWASP Top 10, credential 노출, injection 공격 등을 체크합니다.
---

# Security Review

코드 변경사항을 보안 관점에서 체크하는 전문 리뷰 스킬입니다.

## Instructions

### 리뷰 범위 결정

사용자 요청에 따라 적절한 워크플로우 선택:

1. **변경된 파일만 리뷰** (기본, 가장 일반적)
   - Git diff 기반으로 수정된 파일 확인
   - 빠르고 집중적인 리뷰

2. **특정 파일/디렉토리 리뷰**
   - 사용자가 지정한 경로만 리뷰
   - 세밀한 검토 필요 시

3. **전체 프로젝트 스캔**
   - 전체 코드베이스 보안 점검
   - 초기 프로젝트 설정, 정기 감사 시

### Workflow 1: 변경된 파일 보안 리뷰 (기본)

가장 일반적인 워크플로우입니다.

1. **변경 파일 확인**
   ```bash
   git diff --name-only HEAD
   ```

2. **파일 타입 필터링**
   - 코드 파일만 대상: `.js`, `.ts`, `.py`, `.rb`, `.go`, `.java`, `.php` 등
   - 설정 파일도 포함: `.env`, `.yml`, `.json`, `.xml`
   - 제외: 이미지, 바이너리, lock 파일

3. **각 파일 보안 체크**
   - Read로 파일 내용 읽기
   - 보안 체크리스트 적용 (아래 참조)
   - 이슈 발견 시 기록

4. **리포트 생성**
   - Markdown 형식
   - 심각도별 분류 (Critical → High → Medium → Low)
   - 파일:라인 번호 참조
   - 구체적 수정 제안

### Workflow 2: 특정 파일/디렉토리 리뷰

1. **대상 확인**
   - 사용자가 지정한 경로 확인
   - Glob으로 파일 목록 확인

2. **파일 읽기 및 체크**
   - 각 파일 Read
   - 보안 체크리스트 적용

3. **리포트 생성**

### Workflow 3: 전체 프로젝트 스캔

1. **프로젝트 구조 파악**
   ```bash
   find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" \) | head -50
   ```

2. **우선순위 결정**
   - 인증/인가 관련: `auth*`, `login*`, `session*`
   - API 엔드포인트: `routes/`, `controllers/`, `api/`
   - 데이터 처리: `models/`, `db/`, `database/`
   - 설정 파일: `.env*`, `config/`

3. **순차 리뷰**
   - 우선순위 높은 디렉토리부터
   - 각 파일 체크
   - 심각한 이슈 발견 시 즉시 보고

4. **종합 리포트**

## 보안 체크리스트

각 파일을 읽을 때 다음 항목들을 체크합니다.

### Critical (즉시 수정 필요)

#### 1. Hardcoded Credentials
**검색 패턴:**
```regex
(password|passwd|pwd|secret|token|api[_-]?key|private[_-]?key)\s*=\s*['"]\w+['"]
```

**예시:**
```javascript
// ❌ Critical
const API_KEY = "sk-1234567890abcdef"
const password = "admin123"

// ✅ Good
const API_KEY = process.env.API_KEY
```

**수정 제안:**
- 환경 변수 사용 (`.env` 파일 + `.gitignore`)
- Secrets manager 사용 (AWS Secrets Manager, HashiCorp Vault)

#### 2. SQL Injection
**검색 패턴:**
```regex
(execute|query|exec)\s*\([^)]*\+[^)]*\)
(execute|query|exec)\s*\([^)]*\$\{[^}]*\}[^)]*\)
```

**예시:**
```javascript
// ❌ Critical - String concatenation
db.query("SELECT * FROM users WHERE id = " + userId)
db.query(`SELECT * FROM users WHERE name = '${userName}'`)

// ✅ Good - Parameterized query
db.query("SELECT * FROM users WHERE id = ?", [userId])
db.query("SELECT * FROM users WHERE name = $1", [userName])
```

**수정 제안:**
- Parameterized queries / Prepared statements 사용
- ORM 사용 (Sequelize, TypeORM, Prisma 등)

#### 3. XSS (Cross-Site Scripting)
**검색 패턴:**
```regex
innerHTML\s*=
dangerouslySetInnerHTML
eval\(
\.html\([^)]*\+
```

**예시:**
```javascript
// ❌ Critical
element.innerHTML = userInput
element.innerHTML = `<div>${data}</div>`

// ✅ Good
element.textContent = userInput
// React
<div>{data}</div>  // Auto-escaped
```

**수정 제안:**
- `textContent` 사용 (HTML이 아닌 경우)
- 프레임워크의 자동 escaping 활용
- DOMPurify 같은 sanitizer 사용 (HTML이 필요한 경우)

#### 4. 민감 정보 로깅
**검색 패턴:**
```regex
(console\.log|logger\.|print|echo)\s*\([^)]*\b(password|token|secret|key|credential)\b
```

**예시:**
```javascript
// ❌ Critical
console.log("User login:", { username, password })
logger.info("API Token:", apiToken)

// ✅ Good
console.log("User login:", { username })
logger.info("API Token:", "[REDACTED]")
```

**수정 제안:**
- 민감 정보는 로그에서 제외
- 필요 시 마스킹 (`***` 또는 `[REDACTED]`)

#### 5. 인증/인가 누락
**검색 패턴:**
```regex
(app\.|router\.|@)(get|post|put|delete|patch)\s*\(['"]/
```

**체크 사항:**
- Public endpoint인가?
- 인증 미들웨어가 있는가? (`auth`, `authenticate`, `requireAuth`)
- 권한 체크가 있는가? (`authorize`, `can`, `checkPermission`)

**예시:**
```javascript
// ❌ Critical - 인증 없음
app.get('/api/users/:id', async (req, res) => {
  const user = await User.findById(req.params.id)
  res.json(user)
})

// ✅ Good
app.get('/api/users/:id', authenticateJWT, async (req, res) => {
  if (req.user.id !== req.params.id && !req.user.isAdmin) {
    return res.status(403).json({ error: 'Forbidden' })
  }
  const user = await User.findById(req.params.id)
  res.json(user)
})
```

#### 6. Path Traversal
**검색 패턴:**
```regex
(readFile|writeFile|open|fs\.)\s*\([^)]*\+
path\.join\([^)]*req\.(query|params|body)
```

**예시:**
```javascript
// ❌ Critical
const filePath = path.join(__dirname, req.query.file)
fs.readFile(filePath)  // ../../../etc/passwd

// ✅ Good
const fileName = path.basename(req.query.file)  // Only filename
const filePath = path.join(__dirname, 'uploads', fileName)
if (!filePath.startsWith(path.join(__dirname, 'uploads'))) {
  throw new Error('Invalid path')
}
```

### High (신속히 수정)

#### 1. CSRF Protection 누락
**체크 사항:**
- POST/PUT/DELETE 요청에 CSRF 토큰 검증이 있는가?
- SameSite cookie 설정이 있는가?

**예시:**
```javascript
// ✅ Good
app.use(csrf())
app.post('/api/transfer', csrfProtection, handler)

// Cookie 설정
res.cookie('token', value, {
  httpOnly: true,
  sameSite: 'strict'
})
```

#### 2. 파일 업로드 검증 누락
**검색 패턴:**
```regex
(multer|upload|file)\s*\(
req\.(file|files)
```

**체크 사항:**
- 파일 타입 검증 (whitelist)
- 파일 크기 제한
- 파일명 sanitization

**예시:**
```javascript
// ❌ High
app.post('/upload', upload.single('file'), (req, res) => {
  fs.writeFile(req.file.originalname, req.file.buffer)
})

// ✅ Good
const upload = multer({
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'application/pdf']
    if (!allowedTypes.includes(file.mimetype)) {
      return cb(new Error('Invalid file type'))
    }
    cb(null, true)
  }
})
```

#### 3. Insecure Deserialization
**검색 패턴:**
```regex
(pickle\.loads|yaml\.load|JSON\.parse|eval|unserialize)
```

**예시:**
```python
# ❌ High
data = pickle.loads(user_input)

# ✅ Good
data = json.loads(user_input)  # JSON only
# Or use safe_load for YAML
data = yaml.safe_load(user_input)
```

#### 4. 약한 암호화
**검색 패턴:**
```regex
\b(md5|sha1|des)\b
```

**예시:**
```javascript
// ❌ High
const hash = crypto.createHash('md5').update(password).digest('hex')

// ✅ Good
const hash = await bcrypt.hash(password, 10)
// Or
const hash = crypto.pbkdf2Sync(password, salt, 100000, 64, 'sha512')
```

#### 5. 디버그 모드 프로덕션 노출
**검색 패턴:**
```regex
DEBUG\s*=\s*(true|1|"true")
app\.set\(['"]env['"],\s*['"]development['"]
```

**체크 사항:**
- 환경 변수로 제어되는가?
- 기본값이 production인가?

### Medium (검토 필요)

#### 1. HTTPS 미사용
**검색 패턴:**
```regex
http\.createServer
app\.listen
```

**체크 사항:**
- Production에서 HTTPS 사용?
- Reverse proxy (nginx, ALB) 뒤에 있는가?

#### 2. 에러 메시지 상세 노출
**검색 패턴:**
```regex
catch.*console\.log
res\.(json|send)\(.*error\.
```

**예시:**
```javascript
// ❌ Medium
catch (error) {
  res.status(500).json({ error: error.stack })
}

// ✅ Good
catch (error) {
  logger.error(error)  // 서버 로그
  res.status(500).json({ error: 'Internal server error' })  // 클라이언트
}
```

#### 3. Rate Limiting 없음
**체크 사항:**
- API 엔드포인트에 rate limiting이 있는가?
- Login, signup 등 민감한 endpoint 보호되는가?

**예시:**
```javascript
// ✅ Good
const rateLimit = require('express-rate-limit')
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
})
app.use('/api/', limiter)
```

### Low (권장 개선)

#### 1. CORS 설정
**체크 사항:**
- `Access-Control-Allow-Origin: *` 사용 중?
- Specific origin으로 제한할 수 있는가?

#### 2. Security Headers
**체크 사항:**
- Helmet.js 같은 보안 헤더 미들웨어 사용?
- CSP, X-Frame-Options 등 설정?

## 리포트 형식

리뷰 완료 후 다음 형식으로 리포트 생성:

```markdown
# Security Review Report

**Date:** YYYY-MM-DD
**Reviewed Files:** N files
**Issues Found:** X Critical, Y High, Z Medium, W Low

---

## Critical Issues (Immediate Action Required)

### 1. Hardcoded API Key
**File:** `src/config/api.ts:12`
**Severity:** Critical
**Description:** API key is hardcoded in source code
**Code:**
\`\`\`typescript
const API_KEY = "sk-1234567890abcdef"
\`\`\`
**Recommendation:**
- Move to environment variable
- Add `.env` to `.gitignore`
- Rotate the exposed key immediately
**Reference:** [OWASP: Use of Hard-coded Credentials](https://owasp.org/www-community/vulnerabilities/Use_of_hard-coded_password)

---

## High Issues

[...]

## Medium Issues

[...]

## Summary

- ✅ Good practices found: [list]
- ⚠️ Areas needing attention: [list]
- 📚 Recommended reading: [OWASP resources]
```

## Living Docs 통합

심각한 보안 이슈를 발견한 경우 living-docs에 기록 제안:

```markdown
💡 Consider documenting this in living-docs:

- **Decision:** Why we chose X over Y for security
- **Knowledge:** Security best practices for this project
- **TODO:** Remaining security improvements
```

## 중요 원칙

1. **False Positive 최소화**: 확실한 이슈만 보고
2. **Context 고려**: 테스트 코드, 예제 코드는 완화된 기준 적용
3. **구체적 제안**: "보안 문제"가 아닌 "어떻게 고치는지" 제시
4. **OWASP 참조**: 가능하면 공식 문서 링크 제공
5. **긍정적 피드백**: 잘한 부분도 언급

## Examples

### Example 1: 변경된 파일 리뷰

```
User: "보안 리뷰해줘"
Assistant:
1. git diff --name-only HEAD
2. 변경된 파일 3개 확인: auth.ts, api.ts, db.ts
3. 각 파일 Read 및 체크
4. "Security Review Report:
   - Critical: 1 issue (hardcoded password in auth.ts:45)
   - High: 2 issues (SQL injection in db.ts:120, CSRF missing)
   - Medium: 1 issue (detailed error exposure)

   즉시 수정이 필요한 Critical 이슈부터 처리하시겠습니까?"
```

### Example 2: 특정 디렉토리 리뷰

```
User: "src/auth/ 디렉토리 보안 체크해줘"
Assistant:
1. Glob ~/project/src/auth/**/*.ts
2. 파일 5개 발견
3. 각 파일 보안 체크
4. 리포트 생성 및 제시
```

### Example 3: 전체 프로젝트 스캔

```
User: "프로젝트 전체 보안 스캔"
Assistant:
1. "전체 프로젝트 스캔은 시간이 걸립니다. 계속할까요?"
User: "응"
Assistant:
2. 프로젝트 구조 파악
3. 우선순위 디렉토리 결정 (auth/, api/, config/)
4. 순차 스캔
5. 종합 리포트:
   "총 150개 파일 스캔 완료
    - Critical: 3 issues
    - High: 7 issues
    - Medium: 12 issues

    가장 시급한 이슈 3개부터 보여드릴까요?"
```

## Technical Details

OWASP Top 10 (2021) 참조:
1. Broken Access Control
2. Cryptographic Failures
3. Injection
4. Insecure Design
5. Security Misconfiguration
6. Vulnerable and Outdated Components
7. Identification and Authentication Failures
8. Software and Data Integrity Failures
9. Security Logging and Monitoring Failures
10. Server-Side Request Forgery (SSRF)
