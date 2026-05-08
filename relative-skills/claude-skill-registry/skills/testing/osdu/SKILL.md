---
name: osdu
description: "GitLab CI/CD test job reliability analysis for OSDU projects. Tracks test job (unit/integration/acceptance) pass/fail status across pipeline runs. Use for test job status, flaky test job detection, test reliability/quality metrics, cloud provider analytics. Wraps osdu-quality CLI."
version: 2.0.0
brief_description: "OSDU GitLab CI/CD test reliability analysis"
triggers:
  keywords: [osdu, gitlab, quality, ci, cd, pipeline, test, job, reliability, flaky, acceptance, integration, unit, azure, aws, gcp, cloud, provider]
  verbs: [analyze, track, monitor, test, check]
  patterns:
    - "test.*(?:reliability|status|job)"
    - "pipeline.*(?:analysis|status)"
    - "flaky.*test"
    - "ci.*cd"
    - "gitlab.*(?:pipeline|job)"
allowed-tools: Bash
---

<osdu-command>
  <objective>
    Analyze GitLab CI/CD test job reliability for OSDU platform projects, tracking test job pass/fail status across pipeline runs to identify flaky tests and provide quality metrics.
  </objective>

  <triggers>
    <use-when>
      <trigger>OSDU project test status queries ("how is {project} looking", "partition test quality")</trigger>
      <trigger>Flaky test detection ("are there flaky tests in {project}")</trigger>
      <trigger>Pipeline health monitoring ("recent pipeline failures")</trigger>
      <trigger>Cloud provider comparison ("azure vs aws test reliability")</trigger>
      <trigger>Stage-specific analysis ("unit test status", "integration test failures")</trigger>
    </use-when>

    <skip-when>
      <condition>Individual test case tracking (we track job-level, not test-level)</condition>
      <condition>Non-test jobs (build, deploy, lint, security scans)</condition>
      <condition>Non-OSDU projects or non-GitLab CI systems</condition>
      <condition>Real-time monitoring (data is from completed pipelines only)</condition>
    </skip-when>
  </triggers>

  <tracking-scope>
    <hierarchy>
      Pipeline Run → Test Stage (unit/integration/acceptance) → Test Job → Test Suite (many tests)
    </hierarchy>

    <capabilities>
      <supported>Test job pass/fail status across multiple pipeline runs</supported>
      <supported>Flaky test job detection (jobs that intermittently fail)</supported>
      <supported>Stage-level metrics (unit/integration/acceptance)</supported>
      <supported>Cloud provider breakdown (azure, aws, gcp, ibm, cimpl)</supported>
      <unsupported>Individual test results (not tracked)</unsupported>
      <unsupported>Non-test jobs like build, deploy, lint</unsupported>
    </capabilities>

    <example>
      Pipeline #1: job "unit-tests-azure" → PASS (100/100 tests passed)
      Pipeline #2: job "unit-tests-azure" → FAIL (99/100 tests passed)
      Pipeline #3: job "unit-tests-azure" → PASS (100/100 tests passed)
      Result: This job is FLAKY (unreliable across runs)
    </example>
  </tracking-scope>

  <query-strategy importance="critical">
    <token-usage-reference>
      <query type="status.py --format json" pipelines="5" projects="1" tokens="900" speed="10s" safety="always-safe"/>
      <query type="analyze.py --format json" pipelines="5" projects="1" tokens="35000" speed="30s" safety="use-cautiously"/>
      <query type="analyze.py --format json" pipelines="10" projects="1" tokens="68000" speed="60s" safety="heavy"/>
      <query type="analyze.py" pipelines="10+" projects="multiple" tokens="100000+" speed="120s+" safety="avoid"/>
      <query type="analyze.py" pipelines="all" projects="30" tokens="200000+" speed="180s+" safety="exceeds-limit"/>
    </token-usage-reference>

    <progressive-approach mandatory="true">
      <step number="1" name="start-light">
        <action>Use status.py for quick overview</action>
        <command>script_run osdu status.py --format json --pipelines 3 --project {name}</command>
        <rationale>Lightweight, fast, safe token usage</rationale>
      </step>

      <step number="2" name="deep-dive" condition="only-if-needed">
        <action>Use analyze.py with strict filters</action>
        <command>script_run osdu analyze.py --format json --pipelines 5 --project {name} --stage unit</command>
        <rationale>Heavy query, use only when status insufficient</rationale>
      </step>

      <step number="3" name="never-query-all">
        <action>ALWAYS specify --project to avoid 30-project scan</action>
        <rationale>Prevents token limit exceeded error</rationale>
      </step>
    </progressive-approach>

    <format-selection>
      <format type="json">
        <use-when>Extracting specific metrics or calculating statistics</use-when>
        <use-when>Building summaries or comparisons</use-when>
        <use-when>Parsing structured data programmatically</use-when>
        <use-when importance="critical">ALWAYS for status.py (lightweight, parseable)</use-when>
      </format>

      <format type="markdown">
        <use-when>Analyze.py queries (10x smaller than JSON, still readable)</use-when>
        <use-when>Creating reports for sharing</use-when>
        <use-when>Need human-readable tables without parsing</use-when>
        <use-when>Token budget is tight</use-when>
      </format>

      <format type="terminal" status="never-use">
        <avoid-because>Includes ANSI codes and colors, hard to parse</avoid-because>
        <avoid-because>Only for direct human terminal viewing</avoid-because>
      </format>
    </format-selection>
  </query-strategy>

  <available-projects count="30">
    <core-services description="Most Common Queries">
      <project name="partition" description="Multi-tenant data partitioning"/>
      <project name="storage" description="Blob/file storage service"/>
      <project name="indexer-service" description="Search indexing"/>
      <project name="search-service" description="Search API"/>
      <project name="entitlements" description="Auth/permissions"/>
      <project name="legal" description="Legal tags/compliance"/>
      <project name="schema-service" description="Schema registry"/>
      <project name="file" description="File metadata management"/>
    </core-services>

    <domain-services>
      <project name="wellbore-domain-services" description="Wellbore data"/>
      <project name="well-delivery" description="Well delivery workflows"/>
      <project name="seismic-store-service" description="Seismic data storage"/>
      <project name="dataset" description="Dataset management"/>
      <project name="register" description="Data registration"/>
      <project name="unit-service" description="Unit conversion"/>
    </domain-services>

    <reference-services>
      <project name="crs-catalog-service" description="Coordinate reference systems"/>
      <project name="crs-conversion-service" description="CRS conversion"/>
    </reference-services>

    <ddms-services>
      <project name="rafs-ddms-services" description="R&D data management"/>
      <project name="eds-dms" description="Engineering data management"/>
    </ddms-services>

    <workflow-processing>
      <project name="ingestion-workflow" description="Data ingestion pipelines"/>
      <project name="indexer-queue" description="Indexing queue management"/>
      <project name="notification" description="Event notifications"/>
      <project name="segy-to-mdio-conversion-dag" description="Seismic format conversion"/>
    </workflow-processing>

    <infrastructure>
      <project name="infra-azure-provisioning" description="Azure infra provisioning"/>
      <project name="os-core-common" description="Shared core libraries"/>
      <project name="os-core-lib-azure" description="Azure-specific libs"/>
    </infrastructure>

    <other-services>
      <project name="geospatial" description="Geospatial services"/>
      <project name="policy" description="Policy engine"/>
      <project name="secret" description="Secret management"/>
      <project name="open-etp-client" description="ETP protocol client"/>
      <project name="schema-upgrade" description="Schema migration tools"/>
    </other-services>

    <cloud-providers>
      <provider code="azure" name="Microsoft Azure"/>
      <provider code="aws" name="Amazon Web Services"/>
      <provider code="gcp" name="Google Cloud Platform"/>
      <provider code="ibm" name="IBM Cloud"/>
      <provider code="cimpl" name="CIMPL (Venus) provider"/>
    </cloud-providers>
  </available-projects>

  <prerequisites>
    <requirement>osdu-quality CLI installed: uv tool install git+https://community.opengroup.org/danielscholl/osdu-quality.git</requirement>
    <requirement>GitLab authentication (choose one):
      - GITLAB_TOKEN environment variable, OR
      - glab CLI authenticated (glab auth login)
    </requirement>
    <requirement>Access to OSDU GitLab projects</requirement>
  </prerequisites>

  <scripts>
    <script name="status.py" recommendation="preferred">
      <purpose>Quick overview of latest pipeline test results by stage</purpose>

      <when-to-use>
        <scenario>Initial health check ("how is {project} doing?")</scenario>
        <scenario>Recent pipeline status</scenario>
        <scenario>Quick pass/fail overview</scenario>
        <scenario importance="high">Default choice for most queries</scenario>
      </when-to-use>

      <token-impact>~900 tokens per project (very safe)</token-impact>

      <options>
        <option name="--pipelines N" default="10" recommended="3-5">Analyze last N pipelines</option>
        <option name="--project NAME" required="true">Specify project (see list above)</option>
        <option name="--format json" required="true">Structured output for parsing</option>
        <option name="--venus">Filter to CIMPL (Venus) provider pipelines only</option>
        <option name="--no-release">Exclude release tag pipelines (master/main branch only)</option>
      </options>

      <examples>
        <example description="Quick status check (recommended starting point)">
          script_run osdu status.py --format json --pipelines 3 --project partition
        </example>
        <example description="Check specific project without releases">
          script_run osdu status.py --format json --pipelines 5 --project storage --no-release
        </example>
        <example description="Venus provider status">
          script_run osdu status.py --format json --pipelines 3 --project indexer-service --venus
        </example>
      </examples>
    </script>

    <script name="analyze.py" recommendation="use-cautiously">
      <purpose>In-depth flaky test detection and reliability metrics across many pipeline runs</purpose>

      <when-to-use>
        <scenario>After status.py shows issues</scenario>
        <scenario>Flaky test job detection needed</scenario>
        <scenario>Calculating pass rates over time</scenario>
        <scenario>Provider comparison analysis</scenario>
        <scenario importance="critical">Only with strict filters (project + stage or provider)</scenario>
      </when-to-use>

      <token-impact>
        <impact pipelines="5" projects="1">~35K tokens (moderate)</impact>
        <impact pipelines="10" projects="1">~68K tokens (heavy)</impact>
        <impact projects="multiple">Can exceed 200K token limit ❌</impact>
      </token-impact>

      <critical-rules>
        <rule priority="1">ALWAYS specify --project (never scan all 30 projects)</rule>
        <rule priority="2">Start with --pipelines 5 (not default 10)</rule>
        <rule priority="3">Add --stage or --provider for additional filtering</rule>
        <rule priority="4">Use --format markdown if token budget is tight (10x smaller than JSON)</rule>
        <rule priority="5">Only use if status.py insufficient</rule>
      </critical-rules>

      <options>
        <option name="--pipelines N" default="10" recommended="5">Analyze last N pipelines</option>
        <option name="--project NAME" required="true">Specific project (comma-separated for multiple)</option>
        <option name="--format FORMAT" required="true" recommended="markdown">Use markdown to save tokens</option>
        <option name="--stage STAGE">Filter by test stage (unit/integration/acceptance)</option>
        <option name="--provider PROVIDER">Filter by cloud provider (azure/aws/gcp/ibm/cimpl)</option>
      </options>

      <examples>
        <example description="Analyze flaky tests (safe query)">
          script_run osdu analyze.py --format markdown --pipelines 5 --project partition --stage unit
        </example>
        <example description="Provider comparison (focused)">
          script_run osdu analyze.py --format markdown --pipelines 5 --project storage --provider azure
        </example>
        <example description="Multi-project with strict filter (use cautiously)">
          script_run osdu analyze.py --format markdown --pipelines 5 --project partition,storage --stage unit
        </example>
      </examples>
    </script>
  </scripts>

  <query-patterns>
    <pattern name="quick-health-check">
      <description>Best approach: Start with status.py</description>
      <command>script_run osdu status.py --format json --pipelines 3 --project partition</command>
    </pattern>

    <pattern name="flaky-test-detection">
      <step number="1">Check status</step>
      <command>script_run osdu status.py --format json --pipelines 5 --project partition</command>
      <step number="2">If issues found, deep dive with analyze.py</step>
      <command>script_run osdu analyze.py --format markdown --pipelines 5 --project partition --stage unit</command>
    </pattern>

    <pattern name="provider-comparison">
      <description>Compare Azure vs AWS for specific project/stage</description>
      <command>script_run osdu analyze.py --format markdown --pipelines 5 --project storage --stage integration --provider azure</command>
      <command>script_run osdu analyze.py --format markdown --pipelines 5 --project storage --stage integration --provider aws</command>
    </pattern>

    <pattern name="stage-specific-analysis">
      <description>Focus on unit tests only</description>
      <command>script_run osdu analyze.py --format markdown --pipelines 5 --project entitlements --stage unit</command>
    </pattern>
  </query-patterns>

  <anti-patterns importance="critical">
    <dont-do description="Query all projects without filters">
      <bad-example>script_run osdu analyze.py --format json --pipelines 10</bad-example>
      <reason>Will exceed 200K token limit!</reason>
    </dont-do>

    <dont-do description="Use high pipeline counts without project filter">
      <bad-example>script_run osdu analyze.py --format json --pipelines 20</bad-example>
      <reason>Takes 3+ minutes, huge output</reason>
    </dont-do>

    <dont-do description="Use terminal format in agent context">
      <bad-example>script_run osdu status.py --format terminal --project partition</bad-example>
      <reason>Includes ANSI codes, hard to parse</reason>
    </dont-do>

    <dont-do description="Jump straight to analyze.py">
      <bad-example>script_run osdu analyze.py --format json --pipelines 10 --project partition</bad-example>
      <reason>Heavy query when status.py would suffice</reason>
    </dont-do>
  </anti-patterns>

  <best-practices>
    <practice priority="1" name="Progressive Disclosure">
      Always start with status.py, only use analyze.py if needed
    </practice>
    <practice priority="2" name="Explicit Formats">
      Always specify --format json or --format markdown
    </practice>
    <practice priority="3" name="Project Specificity">
      Always include --project {name} to avoid all-30-projects scan
    </practice>
    <practice priority="4" name="Conservative Pipelines">
      Start with --pipelines 3-5, increase only if necessary
    </practice>
    <practice priority="5" name="Add Filters">
      Use --stage or --provider to narrow scope
    </practice>
    <practice priority="6" name="Markdown for Heavy">
      Prefer --format markdown for analyze.py (10x token savings)
    </practice>
  </best-practices>

  <output-formats>
    <format type="json" size="large" agent-usage="status.py-only">
      <best-for>Structured parsing, metrics extraction</best-for>
    </format>
    <format type="markdown" size="medium" agent-usage="analyze.py-preferred">
      <best-for>Reports, sharing, analyze.py queries</best-for>
    </format>
    <format type="terminal" size="small" agent-usage="never">
      <best-for>Human viewing in terminal with colors</best-for>
    </format>
  </output-formats>

  <error-handling>
    <error condition="osdu-quality CLI not installed">Clear message with installation command</error>
    <error condition="GITLAB_TOKEN not set">Message about authentication requirements</error>
    <error condition="GitLab API errors">API error details</error>
    <error condition="Invalid project/filter">List of valid options</error>
    <error condition="Query timeout">Suggestion to reduce --pipelines or add filters</error>
  </error-handling>

  <instructions>
    <guideline priority="critical">Always follow progressive query approach</guideline>
    <guideline priority="critical">Never query without --project filter</guideline>
    <guideline>Start with minimal pipeline counts</guideline>
    <guideline>Use markdown format for analyze.py to save tokens</guideline>
    <guideline>Apply stage or provider filters when possible</guideline>
  </instructions>
</osdu-command>