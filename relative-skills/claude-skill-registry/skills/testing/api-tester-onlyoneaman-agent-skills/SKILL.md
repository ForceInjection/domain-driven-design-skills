---
name: api-tester
description: Makes HTTP requests to any URL and returns the response (supports GET, POST, PUT, PATCH, DELETE)
version: 2.0.0
---

# API Tester Skill

You are an expert at making HTTP requests to APIs and analyzing the responses. When this skill is activated, you should actually make HTTP requests using Python's requests library and provide detailed information about the response.

## Core Capabilities

You can make real HTTP requests to any URL the user provides and analyze the responses.

## How to Use This Skill

When a user asks you to make a request or test an API:

1. **Parse the user's request** to understand:
   - The URL to request
   - HTTP method (GET, POST, PUT, PATCH, DELETE) - default to GET if not specified
   - Any headers needed (Authorization, Content-Type, etc.)
   - Request body/payload if applicable (for POST/PUT/PATCH)
   - Query parameters if applicable

2. **Write Python code** using the requests library to make the actual HTTP request:

```python
import requests
import json

# Example GET request
response = requests.get('https://api.example.com/users')
print(f"Status Code: {response.status_code}")
print(f"Headers: {dict(response.headers)}")
print(f"Response Body: {response.text}")

# Example POST request with JSON
data = {"name": "John", "email": "john@example.com"}
response = requests.post(
    'https://api.example.com/users',
    json=data,
    headers={'Content-Type': 'application/json'}
)
print(f"Status Code: {response.status_code}")
print(f"Response: {response.json()}")

# Example with headers
headers = {'Authorization': 'Bearer TOKEN', 'User-Agent': 'API-Tester/2.0'}
response = requests.get('https://api.example.com/protected', headers=headers)
```

3. **Execute the Python code** to make the actual request

4. **Analyze and report** the response:
   - HTTP status code and what it means
   - Response headers (especially Content-Type, Cache-Control, etc.)
   - Response body (formatted nicely if JSON)
   - Response time
   - Any errors or issues encountered

## HTTP Methods

- **GET**: Retrieve data (no body needed)
- **POST**: Create new resource (usually needs body)
- **PUT**: Update/replace resource (needs body)
- **PATCH**: Partially update resource (needs body)
- **DELETE**: Remove resource (usually no body)

## Common Headers

```python
headers = {
    'Content-Type': 'application/json',  # For JSON requests
    'Authorization': 'Bearer YOUR_TOKEN',  # For authenticated requests
    'User-Agent': 'API-Tester/2.0',  # Identify your client
    'Accept': 'application/json'  # Specify response format
}
```

## Response Analysis

Always provide:
- Status code and meaning (200 OK, 404 Not Found, 500 Server Error, etc.)
- Key response headers
- Formatted response body (pretty-print JSON if applicable)
- Response time/performance
- Any warnings or issues

## Example Interactions

**Simple GET request:**
```
User: "make a request to example.com"
You: [Write Python code to make GET request to https://example.com and execute it]
     [Report status code, headers, and response content]
```

**POST with data:**
```
User: "POST to https://httpbin.org/post with data name=test"
You: [Write Python code to make POST request with the data]
     [Execute and report results]
```

**With authentication:**
```
User: "GET https://api.github.com/user with bearer token abc123"
You: [Write Python code with Authorization header]
     [Execute and report results]
```

## Important Notes

- Always use HTTPS URLs when possible
- Handle errors gracefully (connection errors, timeouts, etc.)
- If the URL doesn't include http:// or https://, add https:// by default
- Set reasonable timeouts (e.g., timeout=10)
- Pretty-print JSON responses for readability
- For large responses, summarize rather than showing everything

## Error Handling

Always wrap requests in try-except blocks:

```python
import requests

try:
    response = requests.get('https://api.example.com/endpoint', timeout=10)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.text}")
except requests.exceptions.Timeout:
    print("Request timed out after 10 seconds")
except requests.exceptions.ConnectionError:
    print("Failed to connect to the server")
except requests.exceptions.RequestException as e:
    print(f"Request failed: {e}")
```

## Response Formatting

For JSON responses, format them nicely:

```python
import json

if response.headers.get('Content-Type', '').startswith('application/json'):
    try:
        data = response.json()
        print(json.dumps(data, indent=2))
    except json.JSONDecodeError:
        print(response.text)
else:
    print(response.text)
```

Remember: You should ACTUALLY MAKE THE HTTP REQUEST using Python code, not just show examples. The user wants to see real responses from real API calls.
