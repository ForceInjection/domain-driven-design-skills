---
name: drf-serializer
description: Generate Django REST Framework serializers with validation, nested relationships, and best practices. Use when creating or updating API serializers, especially for complex models with relationships.
allowed-tools: Read, Write, Grep
---

You are a Django REST Framework serializer expert. You generate clean, efficient, and well-validated serializers for REST APIs.

## Serializer Generation Capabilities

### 1. Basic ModelSerializer

Generate serializers from models with appropriate fields and validation.

**Input**: Model information
**Output**: Complete serializer with:
- Appropriate fields
- Read-only fields
- Validation methods
- Meta configuration

**Example**:

```python
from rest_framework import serializers
from .models import Product

class ProductSerializer(serializers.ModelSerializer):
    """Serializer for Product model"""

    class Meta:
        model = Product
        fields = [
            'id',
            'name',
            'slug',
            'description',
            'price',
            'stock',
            'category',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'slug', 'created_at', 'updated_at']

    def validate_price(self, value):
        """Ensure price is positive"""
        if value <= 0:
            raise serializers.ValidationError("Price must be greater than zero")
        return value

    def validate_stock(self, value):
        """Ensure stock is non-negative"""
        if value < 0:
            raise serializers.ValidationError("Stock cannot be negative")
        return value
```

### 2. Nested Serializers

Handle relationships with nested serialization for both read and write operations.

**Pattern 1: Read-only nested**

```python
class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'slug']


class ProductSerializer(serializers.ModelSerializer):
    category = CategorySerializer(read_only=True)  # Nested for reading
    category_id = serializers.PrimaryKeyRelatedField(
        queryset=Category.objects.all(),
        source='category',
        write_only=True  # PK for writing
    )

    class Meta:
        model = Product
        fields = [
            'id',
            'name',
            'price',
            'category',      # Nested object in response
            'category_id',   # ID for creating/updating
        ]
```

**Pattern 2: Writable nested**

```python
class AddressSerializer(serializers.ModelSerializer):
    class Meta:
        model = Address
        fields = ['street', 'city', 'state', 'zip_code']


class CustomerSerializer(serializers.ModelSerializer):
    addresses = AddressSerializer(many=True)

    class Meta:
        model = Customer
        fields = ['id', 'name', 'email', 'addresses']

    def create(self, validated_data):
        """Handle nested address creation"""
        addresses_data = validated_data.pop('addresses')
        customer = Customer.objects.create(**validated_data)

        for address_data in addresses_data:
            Address.objects.create(customer=customer, **address_data)

        return customer

    def update(self, instance, validated_data):
        """Handle nested address updates"""
        addresses_data = validated_data.pop('addresses', None)

        # Update customer fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        # Update addresses if provided
        if addresses_data is not None:
            instance.addresses.all().delete()  # Clear existing
            for address_data in addresses_data:
                Address.objects.create(customer=instance, **address_data)

        return instance
```

### 3. Different Serializers for Different Operations

**List Serializer** (lightweight):

```python
class ProductListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for list view"""
    category_name = serializers.CharField(source='category.name', read_only=True)
    thumbnail = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = ['id', 'name', 'price', 'category_name', 'thumbnail']

    def get_thumbnail(self, obj):
        """Get thumbnail URL"""
        if obj.image:
            return obj.image.url
        return None
```

**Detail Serializer** (comprehensive):

```python
class ProductDetailSerializer(serializers.ModelSerializer):
    """Detailed serializer for detail view"""
    category = CategorySerializer(read_only=True)
    reviews = ReviewSerializer(many=True, read_only=True)
    average_rating = serializers.SerializerMethodField()
    related_products = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = [
            'id',
            'name',
            'slug',
            'description',
            'price',
            'stock',
            'category',
            'images',
            'reviews',
            'average_rating',
            'related_products',
            'created_at',
            'updated_at',
        ]

    def get_average_rating(self, obj):
        """Calculate average rating"""
        from django.db.models import Avg
        result = obj.reviews.aggregate(avg_rating=Avg('rating'))
        return result['avg_rating']

    def get_related_products(self, obj):
        """Get related products"""
        related = Product.objects.filter(
            category=obj.category
        ).exclude(id=obj.id)[:4]

        return ProductListSerializer(related, many=True, context=self.context).data
```

**Create/Update Serializer**:

```python
class ProductWriteSerializer(serializers.ModelSerializer):
    """Serializer for creating/updating products"""

    class Meta:
        model = Product
        fields = [
            'name',
            'description',
            'price',
            'stock',
            'category',
            'featured',
        ]

    def validate(self, attrs):
        """Cross-field validation"""
        if attrs.get('featured') and attrs.get('stock', 0) == 0:
            raise serializers.ValidationError(
                "Featured products must have stock available"
            )
        return attrs
```

### 4. SerializerMethodField Patterns

Add computed or derived fields:

```python
class OrderSerializer(serializers.ModelSerializer):
    total_items = serializers.SerializerMethodField()
    discount_amount = serializers.SerializerMethodField()
    final_total = serializers.SerializerMethodField()
    status_display = serializers.CharField(source='get_status_display', read_only=True)

    class Meta:
        model = Order
        fields = [
            'id',
            'subtotal',
            'tax',
            'total',
            'total_items',
            'discount_amount',
            'final_total',
            'status',
            'status_display',
        ]

    def get_total_items(self, obj):
        """Count total items in order"""
        return obj.items.count()

    def get_discount_amount(self, obj):
        """Calculate discount amount"""
        if obj.discount_code:
            return obj.subtotal * (obj.discount_code.percentage / 100)
        return 0

    def get_final_total(self, obj):
        """Calculate final total with discounts"""
        discount = self.get_discount_amount(obj)
        return obj.total - discount
```

### 5. Dynamic Fields

Allow clients to specify which fields to include:

```python
class DynamicFieldsModelSerializer(serializers.ModelSerializer):
    """
    A ModelSerializer that takes an additional `fields` argument to
    control which fields should be displayed.
    """

    def __init__(self, *args, **kwargs):
        # Get fields from context or kwargs
        fields = kwargs.pop('fields', None)
        context = kwargs.get('context', {})
        request = context.get('request')

        if request and not fields:
            # Get fields from query param: ?fields=id,name,price
            fields = request.query_params.get('fields')

        super().__init__(*args, **kwargs)

        if fields:
            fields = fields.split(',') if isinstance(fields, str) else fields
            # Drop fields not specified
            allowed = set(fields)
            existing = set(self.fields.keys())
            for field_name in existing - allowed:
                self.fields.pop(field_name)


class ProductSerializer(DynamicFieldsModelSerializer):
    class Meta:
        model = Product
        fields = ['id', 'name', 'description', 'price', 'stock', 'category']

# Usage: GET /api/products/?fields=id,name,price
```

### 6. Validation Patterns

**Field-level validation**:

```python
def validate_email(self, value):
    """Validate email is unique"""
    if User.objects.filter(email=value).exists():
        raise serializers.ValidationError("Email already in use")
    return value.lower()

def validate_phone(self, value):
    """Validate phone number format"""
    import re
    phone_regex = r'^\+?1?\d{9,15}$'
    if not re.match(phone_regex, value):
        raise serializers.ValidationError("Invalid phone number format")
    return value
```

**Object-level validation**:

```python
def validate(self, attrs):
    """Validate entire object"""
    start_date = attrs.get('start_date')
    end_date = attrs.get('end_date')

    if start_date and end_date and start_date > end_date:
        raise serializers.ValidationError({
            'end_date': "End date must be after start date"
        })

    # Check business rules
    if attrs.get('discount') > 0 and not attrs.get('discount_code'):
        raise serializers.ValidationError(
            "Discount code required when discount is applied"
        )

    return attrs
```

**Custom validators**:

```python
from rest_framework.validators import UniqueTogetherValidator

class BookingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Booking
        fields = ['id', 'room', 'date', 'time_slot', 'user']
        validators = [
            UniqueTogetherValidator(
                queryset=Booking.objects.all(),
                fields=['room', 'date', 'time_slot'],
                message="This time slot is already booked"
            )
        ]
```

### 7. Hyperlinked Serializers

Use hyperlinks instead of primary keys:

```python
class ProductHyperlinkedSerializer(serializers.HyperlinkedModelSerializer):
    category = serializers.HyperlinkedRelatedField(
        view_name='category-detail',
        read_only=True
    )
    reviews = serializers.HyperlinkedRelatedField(
        many=True,
        read_only=True,
        view_name='review-detail'
    )

    class Meta:
        model = Product
        fields = [
            'url',  # Self link
            'id',
            'name',
            'category',
            'reviews',
        ]
        extra_kwargs = {
            'url': {'view_name': 'product-detail', 'lookup_field': 'slug'}
        }
```

### 8. Serializer Inheritance

Create base serializers and extend them:

```python
class BaseProductSerializer(serializers.ModelSerializer):
    """Base serializer with common fields"""

    class Meta:
        model = Product
        fields = ['id', 'name', 'slug', 'price']
        read_only_fields = ['id', 'slug']


class ProductPublicSerializer(BaseProductSerializer):
    """Public API serializer"""
    category_name = serializers.CharField(source='category.name')

    class Meta(BaseProductSerializer.Meta):
        fields = BaseProductSerializer.Meta.fields + [
            'description',
            'category_name',
        ]


class ProductAdminSerializer(BaseProductSerializer):
    """Admin API serializer with extra fields"""
    category = CategorySerializer(read_only=True)

    class Meta(BaseProductSerializer.Meta):
        fields = BaseProductSerializer.Meta.fields + [
            'description',
            'stock',
            'cost',
            'category',
            'active',
            'featured',
            'created_at',
            'updated_at',
        ]
        read_only_fields = BaseProductSerializer.Meta.read_only_fields + [
            'created_at',
            'updated_at',
        ]
```

### 9. File Upload Serializers

Handle file uploads properly:

```python
class ProductImageSerializer(serializers.ModelSerializer):
    image = serializers.ImageField(required=True)
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = ProductImage
        fields = ['id', 'image', 'image_url', 'alt_text', 'order']

    def get_image_url(self, obj):
        """Get absolute URL for image"""
        request = self.context.get('request')
        if obj.image and request:
            return request.build_absolute_uri(obj.image.url)
        return None

    def validate_image(self, value):
        """Validate image file"""
        # Check file size (5MB max)
        if value.size > 5 * 1024 * 1024:
            raise serializers.ValidationError("Image size cannot exceed 5MB")

        # Check file type
        allowed_types = ['image/jpeg', 'image/png', 'image/webp']
        if value.content_type not in allowed_types:
            raise serializers.ValidationError(
                f"Unsupported file type. Allowed: {', '.join(allowed_types)}"
            )

        return value
```

### 10. Bulk Operations

Handle bulk create/update:

```python
class ProductBulkSerializer(serializers.ListSerializer):
    """Handle bulk product operations"""

    def create(self, validated_data):
        """Bulk create products"""
        products = [Product(**item) for item in validated_data]
        return Product.objects.bulk_create(products)

    def update(self, instance, validated_data):
        """Bulk update products"""
        product_mapping = {product.id: product for product in instance}

        data_mapping = {item['id']: item for item in validated_data}

        # Update existing products
        products_to_update = []
        for product_id, data in data_mapping.items():
            product = product_mapping.get(product_id)
            if product:
                for attr, value in data.items():
                    setattr(product, attr, value)
                products_to_update.append(product)

        Product.objects.bulk_update(
            products_to_update,
            ['name', 'price', 'stock']  # Fields to update
        )

        return products_to_update


class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = ['id', 'name', 'price', 'stock']
        list_serializer_class = ProductBulkSerializer
```

## Best Practices

1. **Use appropriate read-only fields**: Set `read_only=True` for computed or auto-generated fields
2. **Separate serializers by use case**: List, detail, create, update
3. **Validate thoroughly**: Add field-level and object-level validation
4. **Optimize nested serializers**: Use `select_related()`/`prefetch_related()` in views
5. **Document serializers**: Add docstrings explaining purpose and usage
6. **Handle errors gracefully**: Provide clear validation error messages
7. **Use SerializerMethodField sparingly**: Can impact performance
8. **Test serializers**: Unit test validation logic and data transformation

## Common Patterns Checklist

When creating a serializer:

- [ ] Define appropriate fields (include/exclude)
- [ ] Set read_only_fields for auto-generated fields
- [ ] Add validation for business rules
- [ ] Handle nested relationships appropriately
- [ ] Consider different serializers for different operations
- [ ] Add computed fields if needed (SerializerMethodField)
- [ ] Document expected input/output format
- [ ] Test validation and data transformation

This skill helps you create robust, well-validated DRF serializers efficiently.
