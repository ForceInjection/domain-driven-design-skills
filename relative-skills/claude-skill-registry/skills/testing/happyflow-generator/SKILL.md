---
name: happyflow-generator
description: Automatically generate and execute Python test scripts from OpenAPI specifications
---

# HappyFlow Generator Skill

## Metadata
- **Skill Name**: HappyFlow Generator
- **Version**: 1.0.0
- **Category**: API Testing & Automation
- **Required Capabilities**: Code execution, web requests, file operations
- **Estimated Duration**: 2-5 minutes per API spec
- **Difficulty**: Intermediate

## Description

Automatically generate and execute Python test scripts from OpenAPI specifications that successfully call all API endpoints in dependency-correct order, ensuring all requests return 2xx status codes.

**Input**: OpenAPI spec (URL/file) + authentication credentials  
**Output**: Working Python script that executes complete API happy path flow

**Key Difference**: This skill contains ALL implementation code - no external MCP tools required. Everything executes using built-in code execution capabilities.

## Complete Workflow

### Phase 1: Authentication Setup

Execute this code to prepare authentication headers:

```python
import base64
import requests
from typing import Dict, Any

def setup_authentication(auth_type: str, credentials: Dict[str, Any]) -> Dict[str, str]:
    """Prepare authentication headers based on auth type"""

    if auth_type == "bearer":
        return {"Authorization": f"Bearer {credentials['token']}"}

    elif auth_type == "api_key":
        header_name = credentials.get('header_name', 'X-API-Key')
        return {header_name: credentials['api_key']}

    elif auth_type == "basic":
        auth_string = f"{credentials['username']}:{credentials['password']}"
        encoded = base64.b64encode(auth_string.encode()).decode()
        return {"Authorization": f"Basic {encoded}"}

    elif auth_type == "oauth2_client_credentials":
        token_url = credentials['token_url']
        data = {
            'grant_type': 'client_credentials',
            'client_id': credentials['client_id'],
            'client_secret': credentials['client_secret']
        }
        if 'scopes' in credentials:
            data['scope'] = ' '.join(credentials['scopes'])

        response = requests.post(token_url, data=data)
        response.raise_for_status()
        token_data = response.json()

        return {"Authorization": f"Bearer {token_data['access_token']}"}

    return {}

# Example usage:
# auth_headers = setup_authentication("bearer", {"token": "abc123"})
```

---

### Phase 2: OpenAPI Parsing

Execute this code to parse OpenAPI specifications:

```python
import requests
import yaml
import json
import re
from typing import Dict, List, Any

def parse_openapi_spec(spec_source: str) -> Dict[str, Any]:
    """Parse OpenAPI specification and extract structured information"""

    # Fetch spec
    if spec_source.startswith('http'):
        response = requests.get(spec_source)
        response.raise_for_status()
        content = response.text
        try:
            spec = json.loads(content)
        except json.JSONDecodeError:
            spec = yaml.safe_load(content)
    else:
        with open(spec_source, 'r') as f:
            content = f.read()
            try:
                spec = json.loads(content)
            except json.JSONDecodeError:
                spec = yaml.safe_load(content)

    # Extract base information
    openapi_version = spec.get('openapi', spec.get('swagger', 'unknown'))
    base_url = ""

    if 'servers' in spec and spec['servers']:
        base_url = spec['servers'][0]['url']
    elif 'host' in spec:
        scheme = spec.get('schemes', ['https'])[0]
        base_path = spec.get('basePath', '')
        base_url = f"{scheme}://{spec['host']}{base_path}"

    # Extract endpoints
    endpoints = []
    paths = spec.get('paths', {})

    for path, path_item in paths.items():
        for method in ['get', 'post', 'put', 'patch', 'delete']:
            if method not in path_item:
                continue

            operation = path_item[method]

            # Extract parameters
            parameters = []
            for param in operation.get('parameters', []):
                parameters.append({
                    'name': param.get('name'),
                    'in': param.get('in'),
                    'required': param.get('required', False),
                    'schema': param.get('schema', {}),
                    'example': param.get('example')
                })

            # Extract request body
            request_body = None
            if 'requestBody' in operation:
                rb = operation['requestBody']
                content = rb.get('content', {})

                if 'application/json' in content:
                    json_content = content['application/json']
                    request_body = {
                        'required': rb.get('required', False),
                        'content_type': 'application/json',
                        'schema': json_content.get('schema', {}),
                        'example': json_content.get('example')
                    }

            # Extract responses
            responses = {}
            for status_code, response_data in operation.get('responses', {}).items():
                if status_code.startswith('2'):
                    content = response_data.get('content', {})
                    if 'application/json' in content:
                        json_content = content['application/json']
                        responses[status_code] = {
                            'description': response_data.get('description', ''),
                            'schema': json_content.get('schema', {}),
                            'example': json_content.get('example')
                        }

            endpoint = {
                'operation_id': operation.get('operationId', f"{method}_{path}"),
                'path': path,
                'method': method.upper(),
                'tags': operation.get('tags', []),
                'summary': operation.get('summary', ''),
                'parameters': parameters,
                'request_body': request_body,
                'responses': responses
            }

            endpoints.append(endpoint)

    return {
        'openapi_version': openapi_version,
        'base_url': base_url,
        'endpoints': endpoints,
        'schemas': spec.get('components', {}).get('schemas', {})
    }

# Example usage:
# parsed_spec = parse_openapi_spec("https://api.example.com/openapi.json")
```

---

### Phase 3: Dependency Analysis

Execute this code to analyze dependencies and determine execution order:

```python
import re
from typing import List, Dict, Any

def analyze_dependencies(endpoints: List[Dict]) -> Dict[str, Any]:
    """Analyze endpoint dependencies and create execution order"""

    dependencies = {}
    outputs = {}

    for endpoint in endpoints:
        endpoint_id = f"{endpoint['method']} {endpoint['path']}"
        dependencies[endpoint_id] = []
        outputs[endpoint_id] = {}

    # Detect path parameter dependencies
    for endpoint in endpoints:
        endpoint_id = f"{endpoint['method']} {endpoint['path']}"
        path = endpoint['path']
        path_params = re.findall(r'\{(\w+)\}', path)

        for param in path_params:
            for other_endpoint in endpoints:
                other_id = f"{other_endpoint['method']} {other_endpoint['path']}"

                if other_endpoint['method'] in ['POST', 'PUT']:
                    for status, response in other_endpoint.get('responses', {}).items():
                        schema = response.get('schema', {})
                        properties = schema.get('properties', {})

                        if 'id' in properties or param in properties:
                            if other_id != endpoint_id and other_id not in dependencies[endpoint_id]:
                                dependencies[endpoint_id].append(other_id)
                                output_field = 'id' if 'id' in properties else param
                                outputs[other_id][param] = f"response.body.{output_field}"

    # HTTP method ordering
    method_priority = {'POST': 1, 'GET': 2, 'PUT': 3, 'PATCH': 3, 'DELETE': 4}

    for endpoint in endpoints:
        endpoint_id = f"{endpoint['method']} {endpoint['path']}"
        path_clean = re.sub(r'\{[^}]+\}', '', endpoint['path'])

        for other_endpoint in endpoints:
            other_id = f"{other_endpoint['method']} {other_endpoint['path']}"
            other_path_clean = re.sub(r'\{[^}]+\}', '', other_endpoint['path'])

            if path_clean == other_path_clean:
                if method_priority.get(endpoint['method'], 5) > method_priority.get(other_endpoint['method'], 5):
                    if other_id not in dependencies[endpoint_id]:
                        dependencies[endpoint_id].append(other_id)

    # Topological sort
    def topological_sort(deps):
        in_degree = {node: 0 for node in deps}
        for node in deps:
            for dep in deps[node]:
                in_degree[dep] = in_degree.get(dep, 0) + 1

        queue = [node for node in deps if in_degree[node] == 0]
        result = []

        while queue:
            queue.sort(key=lambda x: (x.split()[1].count('/'), method_priority.get(x.split()[0], 5)))
            node = queue.pop(0)
            result.append(node)

            for other_node in deps:
                if node in deps[other_node]:
                    in_degree[other_node] -= 1
                    if in_degree[other_node] == 0:
                        queue.append(other_node)

        return result

    execution_order_ids = topological_sort(dependencies)

    execution_plan = []
    for step, endpoint_id in enumerate(execution_order_ids, 1):
        endpoint = next(e for e in endpoints if f"{e['method']} {e['path']}" == endpoint_id)

        inputs = {}
        for dep_id in dependencies[endpoint_id]:
            if dep_id in outputs:
                for param_name, json_path in outputs[dep_id].items():
                    dep_step = execution_order_ids.index(dep_id) + 1
                    inputs[param_name] = {
                        'source': f"step_{dep_step}",
                        'json_path': json_path
                    }

        execution_plan.append({
            'step': step,
            'endpoint': endpoint,
            'dependencies': dependencies[endpoint_id],
            'inputs': inputs,
            'outputs': outputs[endpoint_id]
        })

    return {
        'execution_order': execution_plan,
        'dependency_graph': dependencies
    }

# Example usage:
# dependency_analysis = analyze_dependencies(parsed_spec['endpoints'])
```

---

### Phase 4: Script Generation

Execute this code to generate the Python test script:

```python
import json
from typing import Dict, List, Any

def generate_value_from_schema(schema: Dict, field_name: str = "") -> Any:
    """Generate example value based on schema"""

    if 'example' in schema:
        return schema['example']
    if 'default' in schema:
        return schema['default']
    if 'enum' in schema:
        return schema['enum'][0]

    schema_type = schema.get('type', 'string')

    if schema_type == 'string':
        if schema.get('format') == 'email':
            return 'test@example.com'
        elif schema.get('format') == 'uuid':
            return '550e8400-e29b-41d4-a716-446655440000'
        elif 'email' in field_name.lower():
            return 'test@example.com'
        elif 'name' in field_name.lower():
            return 'Test User'
        return 'test_value'
    elif schema_type == 'integer':
        return schema.get('minimum', 1)
    elif schema_type == 'number':
        return 10.5
    elif schema_type == 'boolean':
        return True
    elif schema_type == 'array':
        return [generate_value_from_schema(schema.get('items', {}))]
    elif schema_type == 'object':
        obj = {}
        for prop, prop_schema in schema.get('properties', {}).items():
            if prop in schema.get('required', []):
                obj[prop] = generate_value_from_schema(prop_schema, prop)
        return obj

    return None

def generate_python_script(execution_plan: List[Dict], base_url: str, auth_headers: Dict) -> str:
    """Generate complete Python script"""

    lines = []

    # Header
    lines.append('#!/usr/bin/env python3')
    lines.append('"""HappyFlow Generator - Auto-generated API test script"""')
    lines.append('')
    lines.append('import requests')
    lines.append('import json')
    lines.append('import sys')
    lines.append('from datetime import datetime')
    lines.append('')

    # Class
    lines.append('class APIFlowExecutor:')
    lines.append('    def __init__(self, base_url, auth_headers):')
    lines.append('        self.base_url = base_url.rstrip("/")')
    lines.append('        self.session = requests.Session()')
    lines.append('        self.session.headers.update(auth_headers)')
    lines.append('        self.context = {}')
    lines.append('        self.results = []')
    lines.append('')
    lines.append('    def log(self, message, level="INFO"):')
    lines.append('        print(f"[{datetime.utcnow().isoformat()}] [{level}] {message}")')
    lines.append('')
    lines.append('    def execute_flow(self):')
    lines.append('        try:')

    for step_info in execution_plan:
        lines.append(f'            self.step_{step_info["step"]}()')

    lines.append('            self.log("✓ All requests completed", "SUCCESS")')
    lines.append('            return True')
    lines.append('        except Exception as e:')
    lines.append('            self.log(f"✗ Failed: {e}", "ERROR")')
    lines.append('            return False')
    lines.append('')

    # Generate steps
    for step_info in execution_plan:
        endpoint = step_info['endpoint']
        step_num = step_info['step']
        method = endpoint['method']
        path = endpoint['path']

        lines.append(f'    def step_{step_num}(self):')
        lines.append(f'        """Step {step_num}: {method} {path}"""')
        lines.append(f'        self.log("Step {step_num}: {method} {path}")')

        # Build URL
        url_expr = f'f"{{self.base_url}}{path}"'
        url_expr = re.sub(r'\{(\w+)\}', r"{self.context['']}", url_expr)
        lines.append(f'        url = {url_expr}')

        # Payload
        if endpoint.get('request_body'):
            schema = endpoint['request_body'].get('schema', {})
            example = endpoint['request_body'].get('example')

            if example:
                payload = example
            else:
                payload = generate_value_from_schema(schema)

            lines.append(f'        payload = {json.dumps(payload)}')
            lines.append(f'        response = self.session.{method.lower()}(url, json=payload, timeout=30)')
        else:
            lines.append(f'        response = self.session.{method.lower()}(url, timeout=30)')

        lines.append('        self.log(f"Status: {response.status_code}")')
        lines.append('        assert response.status_code in [200, 201, 202, 204]')

        # Extract outputs
        if step_info['outputs']:
            lines.append('        if response.text:')
            lines.append('            data = response.json()')
            for output_name, json_path in step_info['outputs'].items():
                field = json_path.split('.')[-1]
                lines.append(f'            self.context["{output_name}"] = data.get("{field}")')

        lines.append('        self.results.append({"step": %d, "status": response.status_code})' % step_num)
        lines.append('')

    # Main
    lines.append('    def print_summary(self):')
    lines.append('        print("\n" + "="*60)')
    lines.append('        print("EXECUTION SUMMARY")')
    lines.append('        print("="*60)')
    lines.append('        for r in self.results:')
    lines.append('            print(f"✓ Step {r[\'step\']}: {r[\'status\']}")')
    lines.append('        print("="*60)')
    lines.append('')
    lines.append('def main():')
    lines.append(f'    BASE_URL = "{base_url}"')
    lines.append(f'    AUTH_HEADERS = {json.dumps(auth_headers)}')
    lines.append('    executor = APIFlowExecutor(BASE_URL, AUTH_HEADERS)')
    lines.append('    success = executor.execute_flow()')
    lines.append('    executor.print_summary()')
    lines.append('    sys.exit(0 if success else 1)')
    lines.append('')
    lines.append('if __name__ == "__main__":')
    lines.append('    main()')

    return '\n'.join(lines)

# Example usage:
# script = generate_python_script(dependency_analysis['execution_order'], base_url, auth_headers)
```

---

### Phase 5: Execute and Iterate

Execute this code to run the script and fix errors:

```python
import subprocess
import tempfile
import os
import re

def execute_script_with_retries(script_content: str, max_retries: int = 5):
    """Execute script and retry with fixes"""

    for attempt in range(1, max_retries + 1):
        print(f"\n=== Attempt {attempt}/{max_retries} ===")

        with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
            f.write(script_content)
            script_path = f.name

        try:
            result = subprocess.run(
                ['python', script_path],
                capture_output=True,
                text=True,
                timeout=300
            )

            print(result.stdout)

            if result.returncode == 0:
                print("\n✓ SUCCESS! All requests returned 2xx")
                return {
                    'success': True,
                    'script': script_content,
                    'attempts': attempt
                }

            # Analyze errors and apply fixes
            print(f"✗ Exit code: {result.returncode}")

            # Simple fix patterns
            if '400' in result.stdout and 'missing required field' in result.stdout:
                # Add missing fields
                field_match = re.search(r"field '(\w+)'", result.stdout)
                if field_match:
                    field = field_match.group(1)
                    script_content = script_content.replace(
                        'payload = {',
                        f'payload = {{"{field}": "test_value", '
                    )
                    print(f"Applied fix: Added missing field '{field}'")
                    continue

            if '422' in result.stdout:
                # Adjust constraint violations
                script_content = script_content.replace('"quantity": 0', '"quantity": 1')
                script_content = script_content.replace('"age": 0', '"age": 18')
                print("Applied fix: Adjusted values to meet constraints")
                continue

            break

        finally:
            if os.path.exists(script_path):
                os.unlink(script_path)

    return {
        'success': False,
        'script': script_content,
        'attempts': max_retries
    }

# Example usage:
# result = execute_script_with_retries(generated_script)
```

---

## Complete End-to-End Example

Here's how to execute the entire workflow:

```python
# 1. Setup
auth_headers = setup_authentication("bearer", {"token": "YOUR_TOKEN"})

# 2. Parse OpenAPI
parsed_spec = parse_openapi_spec("https://api.example.com/openapi.json")
print(f"Found {len(parsed_spec['endpoints'])} endpoints")

# 3. Analyze dependencies
dependency_analysis = analyze_dependencies(parsed_spec['endpoints'])
print(f"Execution order: {len(dependency_analysis['execution_order'])} steps")

# 4. Generate script
generated_script = generate_python_script(
    dependency_analysis['execution_order'],
    parsed_spec['base_url'],
    auth_headers
)
print(f"Generated script: {len(generated_script)} characters")

# 5. Execute with retries
final_result = execute_script_with_retries(generated_script, max_retries=5)

# 6. Output results
if final_result['success']:
    print("\n" + "="*60)
    print("✓ HAPPYFLOW SCRIPT GENERATED SUCCESSFULLY")
    print("="*60)
    print(f"Attempts required: {final_result['attempts']}")
    print("\nFinal Script:")
    print(final_result['script'])
else:
    print("\n✗ Failed to generate working script")
    print("Manual intervention required")
```

## Usage Instructions

When invoked, execute this skill by:

1. **Receive input** from user (OpenAPI spec URL + credentials)
2. **Execute Phase 1** code with user's auth credentials
3. **Execute Phase 2** code with spec URL
4. **Execute Phase 3** code with parsed endpoints
5. **Execute Phase 4** code to generate script
6. **Execute Phase 5** code to test and fix script
7. **Return final working script** to user

## Output Format

Return to user:

```markdown
## ✓ HappyFlow Script Generated Successfully

**API**: [API name from spec]
**Total Endpoints**: [count]
**Execution Attempts**: [attempts]

### Generated Script
```python
[COMPLETE WORKING SCRIPT]
```

### Usage
1. Save as `test_api.py`
2. Run: `python test_api.py`
3. All requests will return 2xx status codes
```

## Advantages of Self-Contained Approach

- **No external dependencies**: All logic embedded in skill
- **Portable**: Works anywhere with Python execution
- **Transparent**: User can see exact implementation
- **Customizable**: Easy to modify code for specific needs
- **Debuggable**: Can trace through each function

## Version History

- v1.0.0 (2025-12-29): Self-contained implementation with embedded code
