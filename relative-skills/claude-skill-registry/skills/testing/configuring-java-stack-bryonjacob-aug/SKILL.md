---
name: configuring-java-stack
description: Java stack configuration - Maven, JUnit 5, Spotless, SpotBugs, JaCoCo with 96% coverage threshold
---

# Java Stack

## Standards Compliance

| Standard | Level | Status |
|----------|-------|--------|
| aug-just/justfile-interface | Baseline (Level 0) | ✓ Full |
| development-stack-standards | Level 2 | ✓ Complete |

**Dimensions:** 11/13 (Foundation + Quality Gates + Security)

## Toolchain

| Tool | Use |
|------|-----|
| **Maven** | Build & dependency management |
| **Java 21** | Language (LTS) |
| **JUnit 5** | Testing framework |
| **Spotless** | Code formatter (Google Java Format) |
| **SpotBugs** | Static analysis / linting |
| **JaCoCo** | Code coverage (96% threshold) |
| **Checkstyle** | Basic complexity check |
| **PMD** | Detailed complexity analysis |
| **cloc** | Lines of code counter |

## Stack Dimensions

| Dimension | Tool | Level |
|-----------|------|-------|
| Package manager | Maven | 0 |
| Format | Spotless + Google Java Format | 0 |
| Lint | SpotBugs | 0 |
| Typecheck | javac | 0 |
| Test | JUnit 5 | 0 |
| Coverage | JaCoCo (96%) | 1 |
| Complexity | Checkstyle (≤10) | 1 |
| Test watch | fizzed-watcher | 1 |
| LOC | cloc | 1 |
| Deps | versions:display-dependency-updates | 2 |
| Vulns | dependency-check | 2 |
| License | license:add-third-party | 2 |
| SBOM | cyclonedx-maven-plugin | 2 |

## Quick Reference

```bash
mvn clean install -DskipTests
mvn spotless:apply
mvn spotbugs:check checkstyle:check
mvn compile
mvn test -Dgroups="!integration"
mvn clean verify -Dgroups="!integration"
```

## Docker Compatibility

Web services: Bind to `0.0.0.0` (not `127.0.0.1`)

```properties
# application.properties
server.address=0.0.0.0
server.port=${PORT:8080}
```

## Standard Justfile Interface

**Implements:** aug-just/justfile-interface (Level 0 baseline)
**Requires:** aug-just plugin for justfile management

```just
set shell := ["bash", "-uc"]

# Show all available commands
default:
    @just --list

# Install dependencies and setup development environment
dev-install:
    mvn clean install -DskipTests

# Format code (auto-fix)
format:
    mvn spotless:apply

# Lint code (auto-fix, complexity threshold=10)
lint:
    mvn spotbugs:check checkstyle:check

# Type check code
typecheck:
    mvn clean compile

# Run unit tests
test:
    mvn test -Dgroups="!integration"

# Run tests in watch mode
test-watch:
    mvn fizzed-watcher:run

# Run unit tests with coverage threshold (96%)
coverage:
    mvn clean verify -Dgroups="!integration" -Djacoco.haltOnFailure=true

# Run integration tests with coverage report (no threshold)
integration-test:
    mvn verify -Dgroups="integration"

# Detailed complexity report for refactoring decisions
complexity:
    mvn pmd:pmd

# Show N largest files by lines of code
loc N="20":
    @echo "📊 Top {{N}} largest files by LOC:"
    @cloc src/ --by-file --include-lang=Java --quiet | sort -rn | head -{{N}}

# Show outdated packages
deps:
    mvn versions:display-dependency-updates

# Check for security vulnerabilities
vulns:
    mvn dependency-check:check

# Analyze licenses (flag GPL, etc.)
lic:
    mvn license:add-third-party

# Generate software bill of materials
sbom:
    mvn org.cyclonedx:cyclonedx-maven-plugin:makeAggregateBom

# Build artifacts
build:
    mvn clean package

# Run all quality checks (format, lint, typecheck, coverage - fastest first)
check-all: format lint typecheck coverage
    @echo "✅ All checks passed"

# Remove generated files and artifacts
clean:
    mvn clean
```

## pom.xml Configuration

**Key plugins:**

```xml
<properties>
    <maven.compiler.source>21</maven.compiler.source>
    <maven.compiler.target>21</maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
</properties>

<dependencies>
    <!-- JUnit 5 -->
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <version>5.10.1</version>
        <scope>test</scope>
    </dependency>
</dependencies>

<build>
    <plugins>
        <!-- Spotless: formatting -->
        <plugin>
            <groupId>com.diffplug.spotless</groupId>
            <artifactId>spotless-maven-plugin</artifactId>
            <version>2.43.0</version>
            <configuration>
                <java>
                    <googleJavaFormat>
                        <version>1.19.2</version>
                        <style>GOOGLE</style>
                    </googleJavaFormat>
                </java>
            </configuration>
        </plugin>

        <!-- SpotBugs: static analysis -->
        <plugin>
            <groupId>com.github.spotbugs</groupId>
            <artifactId>spotbugs-maven-plugin</artifactId>
            <version>4.8.3.0</version>
            <configuration>
                <effort>Max</effort>
                <threshold>Low</threshold>
                <failOnError>true</failOnError>
            </configuration>
        </plugin>

        <!-- JaCoCo: coverage -->
        <plugin>
            <groupId>org.jacoco</groupId>
            <artifactId>jacoco-maven-plugin</artifactId>
            <version>0.8.11</version>
            <executions>
                <execution>
                    <id>check</id>
                    <goals>
                        <goal>check</goal>
                    </goals>
                    <configuration>
                        <rules>
                            <rule>
                                <limits>
                                    <limit>
                                        <counter>LINE</counter>
                                        <value>COVEREDRATIO</value>
                                        <minimum>0.96</minimum>
                                    </limit>
                                </limits>
                            </rule>
                        </rules>
                    </configuration>
                </execution>
            </executions>
        </plugin>

        <!-- Checkstyle: complexity check -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-checkstyle-plugin</artifactId>
            <version>3.3.1</version>
            <configuration>
                <configLocation>google_checks.xml</configLocation>
                <failsOnError>true</failsOnError>
            </configuration>
        </plugin>
    </plugins>
</build>
```

## Notes

- Tag integration tests: `@Tag("integration")` (JUnit 5)
- Unit tests (untagged) run in check-all with 96% threshold
- Treat compiler warnings as errors: `-Xlint:all -Werror`
