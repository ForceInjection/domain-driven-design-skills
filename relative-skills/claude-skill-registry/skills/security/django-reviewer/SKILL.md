---
name: django-reviewer
description: |
  WHEN: Django project review, ORM queries, views/templates, admin customization
  WHAT: ORM optimization + View patterns + Template security + Admin config + Migration safety
  WHEN NOT: FastAPI → fastapi-reviewer, Flask → flask-reviewer, DRF API only → consider api-expert
---

# Django Reviewer Skill

## Purpose
Reviews Django projects for ORM usage, view patterns, security, and best practices.

## When to Use
- Django project code review
- ORM query optimization
- View/template review
- Admin customization review
- Migration safety check

## Project Detection
- `django` in requirements.txt/pyproject.toml
- `manage.py` in project root
- `settings.py` with INSTALLED_APPS
- `urls.py`, `views.py`, `models.py` files

## Workflow

### Step 1: Analyze Project
```
**Django**: 4.2+ / 5.0+
**Database**: PostgreSQL/MySQL/SQLite
**Template Engine**: Django Templates/Jinja2
**REST**: Django REST Framework
**Admin**: Django Admin / Unfold
```

### Step 2: Select Review Areas
**AskUserQuestion:**
```
"Which areas to review?"
Options:
- Full Django review (recommended)
- ORM and query optimization
- Views and URL patterns
- Templates and security
- Admin customization
multiSelect: true
```

## Detection Rules

### ORM Optimization
| Check | Recommendation | Severity |
|-------|----------------|----------|
| N+1 query | Use select_related/prefetch_related | CRITICAL |
| .all() in template | Prefetch in view | HIGH |
| filter().first() | Use .filter().first() or get_or_none | LOW |
| Multiple .save() | Use bulk_update/bulk_create | MEDIUM |

```python
# BAD: N+1 query
def get_orders(request):
    orders = Order.objects.all()
    # Each order.customer triggers a query!
    return render(request, "orders.html", {"orders": orders})

# GOOD: select_related for ForeignKey
def get_orders(request):
    orders = Order.objects.select_related("customer").all()
    return render(request, "orders.html", {"orders": orders})

# GOOD: prefetch_related for ManyToMany/reverse FK
def get_orders(request):
    orders = Order.objects.prefetch_related("items").all()
    return render(request, "orders.html", {"orders": orders})

# BAD: Multiple saves
for item in items:
    item.status = "processed"
    item.save()

# GOOD: Bulk update
Item.objects.filter(id__in=item_ids).update(status="processed")
```

### View Patterns
| Check | Recommendation | Severity |
|-------|----------------|----------|
| Function view for CRUD | Use Class-Based Views | LOW |
| No permission check | Add @login_required or PermissionMixin | HIGH |
| Business logic in view | Move to service/manager | MEDIUM |
| No pagination | Add Paginator | MEDIUM |

```python
# BAD: Logic in view
def create_order(request):
    if request.method == "POST":
        # Too much logic here
        user = request.user
        cart = Cart.objects.get(user=user)
        order = Order.objects.create(user=user, total=cart.total)
        for item in cart.items.all():
            OrderItem.objects.create(order=order, product=item.product)
        cart.items.all().delete()
        send_confirmation_email(user, order)
        return redirect("order_detail", order.id)

# GOOD: Service layer
# services/order_service.py
class OrderService:
    @staticmethod
    def create_from_cart(user: User) -> Order:
        cart = Cart.objects.get(user=user)
        order = Order.objects.create(user=user, total=cart.total)
        OrderItem.objects.bulk_create([
            OrderItem(order=order, product=item.product)
            for item in cart.items.all()
        ])
        cart.items.all().delete()
        send_confirmation_email.delay(user.id, order.id)  # Celery task
        return order

# views.py
class CreateOrderView(LoginRequiredMixin, View):
    def post(self, request):
        order = OrderService.create_from_cart(request.user)
        return redirect("order_detail", order.id)
```

### Template Security
| Check | Recommendation | Severity |
|-------|----------------|----------|
| \|safe filter misuse | Only use for trusted content | CRITICAL |
| {% autoescape off %} | Avoid, use mark_safe in Python | HIGH |
| User input in JS | Use json_script filter | HIGH |
| No CSRF token | Add {% csrf_token %} | CRITICAL |

```html
<!-- BAD: XSS vulnerability -->
<div>{{ user_content|safe }}</div>

<!-- GOOD: Auto-escaped (default) -->
<div>{{ user_content }}</div>

<!-- BAD: User data in JS -->
<script>
var data = "{{ user_data }}";  // XSS risk!
</script>

<!-- GOOD: json_script filter -->
{{ user_data|json_script:"user-data" }}
<script>
const data = JSON.parse(
    document.getElementById("user-data").textContent
);
</script>
```

### Model Design
| Check | Recommendation | Severity |
|-------|----------------|----------|
| No indexes on filter fields | Add db_index=True | HIGH |
| CharField without max_length | Always specify max_length | MEDIUM |
| No __str__ method | Add for admin display | LOW |
| No Meta ordering | Add default ordering | LOW |

```python
# GOOD: Well-designed model
class Order(models.Model):
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="orders",
    )
    status = models.CharField(
        max_length=20,
        choices=OrderStatus.choices,
        default=OrderStatus.PENDING,
        db_index=True,  # Frequently filtered
    )
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["user", "status"]),
        ]

    def __str__(self):
        return f"Order {self.id} - {self.user.email}"
```

### Migration Safety
| Check | Recommendation | Severity |
|-------|----------------|----------|
| Non-nullable field without default | Add default or null=True first | CRITICAL |
| Large table ALTER | Use RunSQL with concurrent index | HIGH |
| Data migration in schema migration | Separate into data migration | MEDIUM |

```python
# BAD: Adding non-nullable field
class Migration(migrations.Migration):
    operations = [
        migrations.AddField(
            model_name="order",
            name="tracking_number",
            field=models.CharField(max_length=100),  # Will fail!
        ),
    ]

# GOOD: Safe migration strategy
# Step 1: Add nullable field
migrations.AddField(
    model_name="order",
    name="tracking_number",
    field=models.CharField(max_length=100, null=True),
),
# Step 2: Data migration to populate
# Step 3: Make non-nullable with default
```

## Response Template
```
## Django Code Review Results

**Project**: [name]
**Django**: 5.0 | **DB**: PostgreSQL | **DRF**: 3.14

### ORM Optimization
| Status | File | Issue |
|--------|------|-------|
| CRITICAL | views.py:45 | N+1 query - missing select_related |

### View Patterns
| Status | File | Issue |
|--------|------|-------|
| HIGH | views.py:23 | Missing LoginRequiredMixin |

### Template Security
| Status | File | Issue |
|--------|------|-------|
| CRITICAL | templates/user.html:12 | Unsafe |safe filter usage |

### Migrations
| Status | File | Issue |
|--------|------|-------|
| CRITICAL | 0015_add_field.py | Non-nullable field without default |

### Recommended Actions
1. [ ] Add select_related to order queries
2. [ ] Add permission mixins to views
3. [ ] Remove |safe from user content
4. [ ] Fix migration for tracking_number field
```

## Best Practices
1. **ORM**: Always prefetch related objects
2. **Views**: Use CBV, service layer for logic
3. **Security**: CSRF, XSS prevention, permissions
4. **Migrations**: Zero-downtime strategies
5. **Testing**: Factory Boy, pytest-django

## Integration
- `python-reviewer`: General Python patterns
- `security-scanner`: Django security audit
- `sql-optimizer`: Query analysis
