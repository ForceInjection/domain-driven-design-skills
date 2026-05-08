---
name: cui-java-cdi
description: CDI and Quarkus development standards for CUI projects, including CDI aspects, container configuration, testing, and native optimization
allowed-tools: [Read, Edit, Write, Bash, Grep, Glob]
---

# CUI Java CDI Skill

Standards and patterns for CDI and Quarkus development in CUI projects. This skill provides comprehensive guidance on CDI dependency injection, Quarkus container configuration, testing practices, and native image optimization.

## Workflow

### Step 1: Load Foundational Java Patterns

**CRITICAL**: Load foundational Java development patterns first.

```
Skill: cui-java-core
```

The cui-java-core skill provides essential foundational patterns that CDI builds upon, including constructor injection, dependency management, null safety, immutability, exception handling, and modern Java features. These core Java patterns are prerequisites for CDI-specific development.

### Step 2: Load Applicable CDI Standards

**CRITICAL**: Load current CDI standards to use as enforcement criteria.

1. **Always load foundational CDI standards**:
   ```
   Read: standards/cdi-aspects.md
   Read: standards/cdi-container.md
   ```
   These provide core CDI patterns and container configuration always needed for development.

2. **Conditional loading based on context**:

   - If writing CDI unit tests:
     ```
     Read: standards/cdi-testing.md
     ```

   - If writing integration tests or setting up integration test infrastructure:
     ```
     Read: standards/integration-testing.md
     ```

   - If working with reflection registration patterns and native image requirements:
     ```
     Read: standards/quarkus-reflection.md
     ```

   - If performing native optimization or systematic reflection optimization:
     ```
     Read: standards/quarkus-native.md
     ```

   - If implementing security features or security testing:
     ```
     Read: standards/cdi-security.md
     ```

3. **Extract key requirements from all loaded standards**

4. **Store in working memory** for use during task execution

### Step 3: Analyze Existing CDI Code

**When to Execute**: After loading standards

**What to Analyze**:

1. **Dependency Injection Patterns**:
   - Verify constructor injection usage (field injection is prohibited)
   - Check for proper `@Inject` annotation usage
   - Validate CDI bean scopes (`@ApplicationScoped`, `@RequestScoped`, etc.)
   - Review producer methods and their scope configurations

2. **CDI Component Structure**:
   - Identify CDI beans and their dependencies
   - Check for circular dependencies
   - Verify proper use of `Instance<T>` for optional dependencies
   - Review qualifier usage and ambiguous dependency resolution

3. **Container Configuration** (if applicable):
   - Review Dockerfile and base image selection
   - Verify security hardening (OWASP compliance)
   - Check certificate management approach (PEM vs PKCS12)
   - Validate health check implementation

4. **Testing Configuration** (if testing context):
   - Review `@QuarkusTest` vs `@QuarkusIntegrationTest` usage
   - Check JaCoCo coverage configuration
   - Verify test profiles and configuration overrides
   - Validate test resource configuration

5. **Integration Testing Setup** (if integration test context):
   - Verify script-based lifecycle management (start/stop scripts)
   - Check Maven profile configuration for native builds
   - Review Docker Compose configuration
   - Validate HTTPS and certificate setup
   - Ensure API-only testing (no CDI injection in integration tests)

6. **Native Optimization** (if native context):
   - Analyze reflection registration patterns
   - Review `@RegisterForReflection` annotations
   - Check deployment processor configurations (ReflectiveClassBuildItem)
   - Verify AdditionalBeanBuildItem usage for CDI beans
   - Identify optimization opportunities

7. **Security Configuration** (if security context):
   - Verify secure dependency injection patterns
   - Check security configuration validation at startup
   - Review secure logging practices (no sensitive data logging)
   - Validate security testing coverage
   - Ensure runtime security hardening (OWASP compliance)

### Step 4: Apply CDI Standards to Development Task

**When to Execute**: During implementation or code review

**What to Apply**:

1. **Constructor Injection Standard**:
   - Convert any field injection to constructor injection
   - Make injected fields `final`
   - Remove unnecessary `@Inject` for single-constructor beans
   - Add `@Inject` to correct constructor when multiple exist

2. **CDI Scope Selection**:
   - Apply `@ApplicationScoped` for stateless services
   - Use `@RequestScoped` for request-specific data
   - Avoid `@Singleton` unless eager initialization required
   - Validate scope matches lifecycle requirements

3. **Producer Method Patterns**:
   - Use `@Dependent` scope for producers that may return null
   - Ensure normal-scoped producers never return null
   - Prefer `Instance<T>` over `Optional<T>` in producers
   - Implement Null Object pattern when appropriate

4. **Container Security** (if container context):
   - Use distroless base image for production
   - Implement internal health checks (no curl/wget)
   - Configure OWASP security hardening
   - Set up PEM certificates with proper permissions

5. **Testing Practices** (if testing context):
   - Configure JaCoCo for Quarkus correctly
   - Use `@QuarkusTest` for CDI injection tests
   - Ensure `@{argLine}` in Surefire configuration
   - Implement test profiles for different scenarios

6. **Integration Testing Setup** (if integration test context):
   - Configure Maven profile with single execution (avoid duplicate builds)
   - Implement script-based lifecycle (start/stop containers)
   - Use API-only testing with RestAssured (no `@Inject`)
   - Configure HTTPS with self-signed certificates
   - Set up external port mapping (10443:8443)
   - Ensure production-equivalent Docker Compose configuration

7. **Native Optimization** (if native context):
   - Use `@RegisterForReflection` for application-level classes
   - Use `ReflectiveClassBuildItem` for infrastructure classes
   - Use `AdditionalBeanBuildItem` for CDI beans (not reflection)
   - Minimize reflection scope to actual needs
   - Use type-safe class references (not strings)
   - Avoid double registration (annotation + build step)

8. **Security Implementation** (if security context):
   - Implement secure configuration validation at startup
   - Use constructor injection for security dependencies
   - Implement secure logging (mask sensitive data)
   - Add security unit and integration tests
   - Validate HTTPS-only enforcement
   - Configure runtime security hardening

### Step 5: Verify Implementation Quality

**When to Execute**: After applying standards

**Quality Checks**:

1. **CDI Pattern Verification**:
   - [ ] All dependencies use constructor injection
   - [ ] All injected fields are `final`
   - [ ] Proper CDI scopes applied
   - [ ] No field or setter injection present
   - [ ] Producer methods follow scope rules

2. **Testing Verification** (if testing context):
   - [ ] JaCoCo properly configured
   - [ ] Test coverage collected successfully
   - [ ] Test profiles configured correctly
   - [ ] All CDI components tested

3. **Integration Testing Verification** (if integration test context):
   - [ ] Maven profile configured with single execution
   - [ ] Script-based lifecycle scripts exist and work
   - [ ] Docker Compose uses production-equivalent configuration
   - [ ] Tests use API-only approach (no CDI injection)
   - [ ] HTTPS configured with certificates
   - [ ] Port mapping correct (external 10443, internal 8443)

4. **Container Verification** (if container context):
   - [ ] Distroless base image used
   - [ ] Security hardening applied
   - [ ] Health checks implemented correctly
   - [ ] Certificates configured with proper permissions

5. **Native Optimization Verification** (if native context):
   - [ ] Reflection registration optimized and selective
   - [ ] No double registration (annotation + build step)
   - [ ] CDI beans use AdditionalBeanBuildItem
   - [ ] Type-safe class references used
   - [ ] Native compilation succeeds
   - [ ] Tests pass in native mode
   - [ ] Performance metrics maintained or improved

6. **Security Verification** (if security context):
   - [ ] Secure configuration validation at startup
   - [ ] No sensitive data logged
   - [ ] Security tests implemented with 100% coverage
   - [ ] HTTPS-only enforcement verified
   - [ ] Runtime security hardening applied

7. **Compilation and Build**:
   ```
   # Compile the module
   Task:
     subagent_type: maven-builder
     description: Compile module
     prompt: |
       Compile module to verify changes.

       Parameters:
       - command: clean compile
       - module: [module-name]

       CRITICAL: Wait for completion. Fix any compilation errors.

   # Run tests
   Task:
     subagent_type: maven-builder
     description: Run tests
     prompt: |
       Run module tests.

       Parameters:
       - command: clean test
       - module: [module-name]

       CRITICAL: Wait for completion. Fix any test failures.

   # Quality verification
   Task:
     subagent_type: maven-builder
     description: Quality verification
     prompt: |
       Run pre-commit quality checks.

       Parameters:
       - command: -Ppre-commit clean verify -DskipTests
       - module: [module-name]

       CRITICAL: Wait for completion. Fix all quality issues.

   # Final verification
   Task:
     subagent_type: maven-builder
     description: Final verification
     prompt: |
       Run final build and install.

       Parameters:
       - command: clean install
       - module: [module-name]

       CRITICAL: Wait for completion. Ensure all tests and quality checks pass.
   ```

8. **Native Build** (if native context):
   ```
   # Native compilation
   Task:
     subagent_type: maven-builder
     description: Native build
     prompt: |
       Build native executable.

       Parameters:
       - command: clean package -Dnative
       - module: [module-name]

       CRITICAL: Wait for completion (may take several minutes).
       Record build time and executable size.
   ```

### Step 6: Document Changes and Commit

**When to Execute**: After verification passes

**Documentation Updates**:
- Update module README if CDI architecture changed
- Document any special configuration requirements
- Note any deviations from standards with rationale
- Include performance metrics if applicable

**Commit Standards**:
- Follow standard commit message format
- Reference related issues or tasks
- Include "Zero information loss verified" if migrating code
- Add co-authored-by line for Claude Code

## Common Patterns and Error Prevention

For detailed CDI patterns and troubleshooting, see the loaded standards files:
- **CDI Patterns**: Constructor injection, optional dependencies, producer methods - see `standards/cdi-aspects.md`
- **CDI Testing**: JaCoCo configuration, test profiles, coverage requirements - see `standards/cdi-testing.md`
- **Integration Testing**: API-only testing, script-based lifecycle, Maven profiles - see `standards/integration-testing.md`
- **Container Configuration**: Docker, health checks, certificates, OWASP security - see `standards/cdi-container.md`
- **Reflection Standards**: Registration patterns, AdditionalBeanBuildItem, auto-registration - see `standards/quarkus-reflection.md`
- **Native Optimization Process**: Systematic optimization workflow, phases, verification - see `standards/quarkus-native.md`
- **Security Patterns**: Secure configuration, secure logging, security testing - see `standards/cdi-security.md`

## Quality Verification

All changes must pass:
- [x] Constructor injection used exclusively
- [x] All injected fields are `final`
- [x] Proper CDI scopes applied
- [x] Producer methods follow scope rules
- [x] Tests pass with coverage collected
- [x] Integration tests use API-only approach (if applicable)
- [x] Reflection registration optimized (if applicable)
- [x] Security validation at startup (if applicable)
- [x] No sensitive data logged (always)
- [x] Quality checks pass (`-Ppre-commit`)
- [x] Native compilation succeeds (if applicable)

## References

### Core CDI and Quarkus
* CDI 2.0 Specification: https://docs.oracle.com/javaee/7/tutorial/cdi-basic.htm
* Quarkus CDI Guide: https://quarkus.io/guides/cdi
* Quarkus CDI Reference: https://quarkus.io/guides/cdi-reference

### Testing
* Quarkus Testing Guide: https://quarkus.io/guides/getting-started-testing
* JUnit 5 User Guide: https://junit.org/junit5/docs/current/user-guide/
* REST Assured Documentation: https://rest-assured.io/
* Maven Failsafe Plugin: https://maven.apache.org/surefire/maven-failsafe-plugin/
* JaCoCo Documentation: https://www.jacoco.org/jacoco/trunk/doc/

### Native Compilation
* Quarkus Native Guide: https://quarkus.io/guides/writing-native-applications-tips
* Quarkus Extension Development: https://quarkus.io/guides/writing-extensions
* GraalVM Native Image Reflection: https://github.com/oracle/graal/blob/master/docs/reference-manual/native-image/Reflection.md

### Container Security
* Docker Security Best Practices: https://docs.docker.com/develop/security-best-practices/
* OWASP Docker Top 10: https://owasp.org/www-project-docker-top-10/
* NIST Container Security Guide: https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-190.pdf
* CIS Docker Benchmark: https://www.cisecurity.org/benchmark/docker

### Application Security
* OWASP Top 10: https://owasp.org/www-project-top-ten/
* Quarkus Security Guide: https://quarkus.io/guides/security
