---
name: flask-reviewer
description: |
  WHEN: Flask project review, Blueprint structure, extensions, request handling
  WHAT: Blueprint organization + Extension patterns + Request/response handling + Configuration + Testing
  WHEN NOT: FastAPI → fastapi-reviewer, Django → django-reviewer, General Python → python-reviewer
---

# Flask Reviewer Skill

## Purpose
Reviews Flask projects for application structure, extension usage, and best practices.

## When to Use
- Flask project code review
- Blueprint structure review
- Extension configuration review
- Request handling patterns
- Flask API design

## Project Detection
- `flask` in requirements.txt/pyproject.toml
- `from flask import Flask` imports
- `app.py` or `__init__.py` with Flask()
- `blueprints/` or `routes/` directory

## Workflow

### Step 1: Analyze Project
```
**Flask**: 3.0+
**Extensions**: Flask-SQLAlchemy, Flask-Login, Flask-WTF
**API**: Flask-RESTful / Flask-RESTX
**Database**: SQLAlchemy
**Template**: Jinja2
```

### Step 2: Select Review Areas
**AskUserQuestion:**
```
"Which areas to review?"
Options:
- Full Flask review (recommended)
- Application structure
- Blueprint organization
- Extension configuration
- Security and validation
multiSelect: true
```

## Detection Rules

### Application Factory
| Check | Recommendation | Severity |
|-------|----------------|----------|
| Global app instance | Use application factory | HIGH |
| Config in code | Use config classes | MEDIUM |
| No extension init | Use init_app pattern | MEDIUM |
| Circular imports | Use factory + blueprints | HIGH |

```python
# BAD: Global app instance
# app.py
from flask import Flask
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
db = SQLAlchemy(app)  # Tight coupling

# GOOD: Application factory
# app/__init__.py
from flask import Flask
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

def create_app(config_name="default"):
    app = Flask(__name__)
    app.config.from_object(config[config_name])

    db.init_app(app)

    from app.routes import main_bp, api_bp
    app.register_blueprint(main_bp)
    app.register_blueprint(api_bp, url_prefix="/api")

    return app
```

### Blueprint Organization
| Check | Recommendation | Severity |
|-------|----------------|----------|
| All routes in one file | Split into blueprints | MEDIUM |
| No URL prefix | Add url_prefix to blueprints | LOW |
| Mixed concerns | Separate by domain | MEDIUM |
| No __init__.py exports | Export blueprint properly | LOW |

```python
# GOOD: Blueprint structure
# app/routes/users.py
from flask import Blueprint, request, jsonify

users_bp = Blueprint("users", __name__, url_prefix="/users")

@users_bp.route("/", methods=["GET"])
def list_users():
    return jsonify(users=User.query.all())

@users_bp.route("/<int:user_id>", methods=["GET"])
def get_user(user_id):
    user = User.query.get_or_404(user_id)
    return jsonify(user=user.to_dict())

# app/routes/__init__.py
from app.routes.users import users_bp
from app.routes.products import products_bp

__all__ = ["users_bp", "products_bp"]
```

### Request Handling
| Check | Recommendation | Severity |
|-------|----------------|----------|
| No input validation | Use marshmallow/pydantic | HIGH |
| request.json without check | Handle None case | MEDIUM |
| No error handlers | Add @app.errorhandler | MEDIUM |
| Sync blocking calls | Consider async or Celery | MEDIUM |

```python
# BAD: No validation
@app.route("/user", methods=["POST"])
def create_user():
    data = request.json  # Could be None!
    user = User(name=data["name"])  # KeyError risk
    return jsonify(user.to_dict())

# GOOD: With validation (marshmallow)
from marshmallow import Schema, fields, validate

class UserSchema(Schema):
    name = fields.Str(required=True, validate=validate.Length(min=1, max=100))
    email = fields.Email(required=True)

user_schema = UserSchema()

@app.route("/user", methods=["POST"])
def create_user():
    data = request.get_json()
    if not data:
        return jsonify(error="No JSON data"), 400

    errors = user_schema.validate(data)
    if errors:
        return jsonify(errors=errors), 400

    user = User(**user_schema.load(data))
    db.session.add(user)
    db.session.commit()
    return jsonify(user=user.to_dict()), 201
```

### Configuration
| Check | Recommendation | Severity |
|-------|----------------|----------|
| Secrets in code | Use environment variables | CRITICAL |
| No config classes | Use config hierarchy | MEDIUM |
| DEBUG=True in prod | Environment-based config | CRITICAL |
| No instance folder | Use instance config | LOW |

```python
# config.py
import os

class Config:
    SECRET_KEY = os.environ.get("SECRET_KEY") or "dev-key-change-me"
    SQLALCHEMY_TRACK_MODIFICATIONS = False

class DevelopmentConfig(Config):
    DEBUG = True
    SQLALCHEMY_DATABASE_URI = os.environ.get("DEV_DATABASE_URL") or \
        "sqlite:///dev.db"

class ProductionConfig(Config):
    DEBUG = False
    SQLALCHEMY_DATABASE_URI = os.environ.get("DATABASE_URL")

    @classmethod
    def init_app(cls, app):
        # Production-specific initialization
        import logging
        from logging.handlers import RotatingFileHandler

        handler = RotatingFileHandler("app.log", maxBytes=10240, backupCount=10)
        handler.setLevel(logging.INFO)
        app.logger.addHandler(handler)

config = {
    "development": DevelopmentConfig,
    "production": ProductionConfig,
    "default": DevelopmentConfig,
}
```

### Error Handling
| Check | Recommendation | Severity |
|-------|----------------|----------|
| No custom error pages | Add error handlers | MEDIUM |
| Exception details in response | Hide in production | HIGH |
| No logging | Add structured logging | MEDIUM |

```python
# app/errors.py
from flask import jsonify, render_template

def register_error_handlers(app):
    @app.errorhandler(400)
    def bad_request(error):
        if request_wants_json():
            return jsonify(error="Bad request"), 400
        return render_template("errors/400.html"), 400

    @app.errorhandler(404)
    def not_found(error):
        if request_wants_json():
            return jsonify(error="Not found"), 404
        return render_template("errors/404.html"), 404

    @app.errorhandler(500)
    def internal_error(error):
        db.session.rollback()
        app.logger.error(f"Internal error: {error}")
        if request_wants_json():
            return jsonify(error="Internal server error"), 500
        return render_template("errors/500.html"), 500

def request_wants_json():
    return request.accept_mimetypes.best_match(
        ["application/json", "text/html"]
    ) == "application/json"
```

## Response Template
```
## Flask Code Review Results

**Project**: [name]
**Flask**: 3.0 | **SQLAlchemy**: 2.0 | **Extensions**: Login, WTF

### Application Structure
| Status | File | Issue |
|--------|------|-------|
| HIGH | app.py | Global app instance - use factory |

### Blueprint Organization
| Status | File | Issue |
|--------|------|-------|
| MEDIUM | routes.py | 50+ routes - split into blueprints |

### Request Handling
| Status | File | Issue |
|--------|------|-------|
| HIGH | views.py:34 | No input validation on POST |

### Configuration
| Status | File | Issue |
|--------|------|-------|
| CRITICAL | config.py | SECRET_KEY hardcoded |

### Recommended Actions
1. [ ] Implement application factory pattern
2. [ ] Split routes into domain blueprints
3. [ ] Add marshmallow validation schemas
4. [ ] Move secrets to environment variables
```

## Best Practices
1. **Factory Pattern**: Always use create_app()
2. **Blueprints**: Organize by domain/feature
3. **Validation**: marshmallow or pydantic
4. **Config**: Environment-based hierarchy
5. **Extensions**: Use init_app pattern

## Integration
- `python-reviewer`: General Python patterns
- `security-scanner`: Flask security audit
- `api-documenter`: API documentation
