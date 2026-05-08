---
name: wordpress-security-patterns
description: WordPress security best practices and vulnerability prevention patterns. Use when reviewing WordPress code for security issues, writing secure WordPress code, or checking for common vulnerabilities like SQL injection, XSS, CSRF, and authentication issues.
---

# WordPress Security Patterns

Comprehensive security patterns and best practices for WordPress development. This skill provides the knowledge base for identifying and preventing common WordPress security vulnerabilities.

## SQL Injection Prevention

### Core Principle
NEVER trust user input. ALWAYS use `$wpdb->prepare()` for database queries.

### Required Pattern
```php
// ALWAYS use this pattern
global $wpdb;
$results = $wpdb->get_results($wpdb->prepare(
    "SELECT * FROM {$wpdb->prefix}posts WHERE post_author = %d AND post_status = %s",
    $author_id,
    $status
));
```

### Format Specifiers
- `%d` - Integer
- `%f` - Float
- `%s` - String
- Arrays: Use `implode(',', array_map('absint', $ids))` for IN clauses

### Common Mistakes to Flag
```php
// ❌ VULNERABLE - Direct variable insertion
$query = "SELECT * FROM wp_posts WHERE ID = {$_GET['id']}";
$wpdb->query($query);

// ❌ VULNERABLE - String concatenation
$query = "SELECT * FROM wp_posts WHERE post_title LIKE '%" . $_GET['search'] . "%'";

// ❌ VULNERABLE - Even with sanitization, use prepare()
$id = intval($_GET['id']);
$query = "SELECT * FROM wp_posts WHERE ID = $id"; // Still wrong!
```

### Correct Patterns
```php
// ✅ CORRECT - Prepared statement
$results = $wpdb->get_results($wpdb->prepare(
    "SELECT * FROM {$wpdb->posts} WHERE ID = %d",
    absint($_GET['id'])
));

// ✅ CORRECT - Multiple parameters
$results = $wpdb->get_row($wpdb->prepare(
    "SELECT * FROM {$wpdb->posts} WHERE post_type = %s AND post_status = %s",
    sanitize_key($_POST['type']),
    sanitize_key($_POST['status'])
));

// ✅ CORRECT - LIKE queries
$search = '%' . $wpdb->esc_like($_GET['s']) . '%';
$results = $wpdb->get_results($wpdb->prepare(
    "SELECT * FROM {$wpdb->posts} WHERE post_title LIKE %s",
    $search
));

// ✅ CORRECT - IN clause with integers
$ids = array_map('absint', $_POST['post_ids']);
$placeholders = implode(',', array_fill(0, count($ids), '%d'));
$query = $wpdb->prepare(
    "SELECT * FROM {$wpdb->posts} WHERE ID IN ($placeholders)",
    ...$ids
);
```

## Cross-Site Scripting (XSS) Prevention

### Core Principle
NEVER output unescaped data. ALWAYS use appropriate escaping functions.

### Escaping Functions Matrix

| Context | Function | Usage |
|---------|----------|-------|
| HTML content | `esc_html()` | Plain text in HTML |
| HTML attributes | `esc_attr()` | Attributes like `class`, `id`, `data-*` |
| URLs | `esc_url()` | `href`, `src` attributes |
| JavaScript strings | `esc_js()` | Inline JavaScript strings |
| Textarea content | `esc_textarea()` | `<textarea>` content |
| Allowed HTML | `wp_kses_post()` | Content with safe HTML |
| Custom HTML | `wp_kses()` | With allowed tags array |

### Required Patterns

**Template Output:**
```php
// ✅ CORRECT - HTML content
<h1><?php echo esc_html($post_title); ?></h1>

// ✅ CORRECT - HTML attributes
<div class="<?php echo esc_attr($css_class); ?>" 
     data-id="<?php echo esc_attr($post_id); ?>">

// ✅ CORRECT - URLs
<a href="<?php echo esc_url($link); ?>">Link</a>
<img src="<?php echo esc_url($image_url); ?>" alt="">

// ✅ CORRECT - Mixed attributes
<input type="text" 
       name="<?php echo esc_attr($field_name); ?>"
       value="<?php echo esc_attr($field_value); ?>"
       placeholder="<?php echo esc_attr__('Enter text', 'textdomain'); ?>">
```

**JavaScript Context:**
```php
// ✅ CORRECT - JavaScript string
<script>
var message = '<?php echo esc_js($user_message); ?>';
</script>

// ✅ CORRECT - Better: Use wp_localize_script()
wp_localize_script('my-script', 'myData', array(
    'message' => $user_message, // Automatically escaped
    'ajaxUrl' => admin_url('admin-ajax.php'),
));
```

**Allowed HTML:**
```php
// ✅ CORRECT - Post content with safe HTML
echo wp_kses_post($post_content);

// ✅ CORRECT - Custom allowed tags
$allowed_html = array(
    'a' => array('href' => array(), 'title' => array()),
    'br' => array(),
    'em' => array(),
    'strong' => array(),
);
echo wp_kses($custom_html, $allowed_html);
```

### Common XSS Vulnerabilities to Flag

```php
// ❌ VULNERABLE - No escaping
echo '<div>' . $_GET['message'] . '</div>';

// ❌ VULNERABLE - Unescaped attribute
echo '<div class="' . $_POST['class'] . '">';

// ❌ VULNERABLE - Unescaped URL
echo '<a href="' . $_GET['redirect'] . '">Click</a>';

// ❌ VULNERABLE - Even with sanitization
$clean = sanitize_text_field($_GET['input']);
echo '<div>' . $clean . '</div>'; // Still needs esc_html()!

// ❌ VULNERABLE - JSON in HTML
echo '<script>var data = ' . json_encode($user_data) . ';</script>';
// Should use wp_json_encode() which escapes properly
```

## CSRF Protection (Nonces)

### Core Principle
ALWAYS verify nonces for all state-changing operations.

### Required Pattern - Forms
```php
// ✅ CORRECT - Form with nonce
<form method="post" action="">
    <?php wp_nonce_field('my_action_name', 'my_nonce_field'); ?>
    <input type="text" name="field_name">
    <?php submit_button(); ?>
</form>

// ✅ CORRECT - Verification
if (!isset($_POST['my_nonce_field']) || 
    !wp_verify_nonce($_POST['my_nonce_field'], 'my_action_name')) {
    wp_die(__('Security check failed', 'textdomain'));
}
```

### Required Pattern - AJAX
```php
// ✅ CORRECT - JavaScript (after wp_localize_script)
$.ajax({
    url: ajaxData.ajaxUrl,
    type: 'POST',
    data: {
        action: 'my_ajax_action',
        nonce: ajaxData.nonce,
        user_data: userData
    }
});

// ✅ CORRECT - PHP handler
add_action('wp_ajax_my_ajax_action', 'my_ajax_handler');
function my_ajax_handler() {
    check_ajax_referer('my_ajax_nonce', 'nonce');
    
    // Process request
    $data = sanitize_text_field($_POST['user_data']);
    
    wp_send_json_success(array('result' => $data));
}

// ✅ CORRECT - Enqueue with localized nonce
wp_enqueue_script('my-script', $url, array('jquery'), '1.0', true);
wp_localize_script('my-script', 'ajaxData', array(
    'ajaxUrl' => admin_url('admin-ajax.php'),
    'nonce' => wp_create_nonce('my_ajax_nonce'),
));
```

### Required Pattern - URLs
```php
// ✅ CORRECT - URL with nonce
$url = wp_nonce_url(
    admin_url('admin-post.php?action=my_action'),
    'my_action_nonce'
);
echo '<a href="' . esc_url($url) . '">Delete</a>';

// ✅ CORRECT - Verification
if (!isset($_GET['_wpnonce']) || 
    !wp_verify_nonce($_GET['_wpnonce'], 'my_action_nonce')) {
    wp_die(__('Security check failed', 'textdomain'));
}
```

### Nonce Vulnerabilities to Flag

```php
// ❌ VULNERABLE - No nonce in form
<form method="post">
    <input type="text" name="data">
    <input type="submit">
</form>

// ❌ VULNERABLE - No nonce verification
if ($_POST['action'] === 'save') {
    update_option('my_option', $_POST['value']); // Unprotected!
}

// ❌ VULNERABLE - AJAX without nonce
add_action('wp_ajax_my_action', function() {
    // No check_ajax_referer()!
    update_post_meta($_POST['post_id'], 'key', $_POST['value']);
});
```

## Authentication & Authorization

### Core Principle
ALWAYS check user capabilities before sensitive operations.

### Required Patterns

**Capability Checks:**
```php
// ✅ CORRECT - Basic capability check
if (!current_user_can('manage_options')) {
    wp_die(__('Insufficient permissions', 'textdomain'));
}

// ✅ CORRECT - Post-specific capability
if (!current_user_can('edit_post', $post_id)) {
    wp_die(__('You cannot edit this post', 'textdomain'));
}

// ✅ CORRECT - Custom post type capability
if (!current_user_can('edit_products')) {
    wp_die(__('Insufficient permissions', 'textdomain'));
}
```

**Common Capabilities:**
- `manage_options` - Admin settings
- `edit_posts` - Edit posts
- `edit_pages` - Edit pages
- `edit_users` - Edit users
- `upload_files` - Media uploads
- `edit_published_posts` - Edit published content
- Custom capabilities for custom post types

**Admin Page Protection:**
```php
// ✅ CORRECT - Admin page with capability
add_menu_page(
    'My Plugin',
    'My Plugin',
    'manage_options', // Required capability
    'my-plugin',
    'my_plugin_page'
);

function my_plugin_page() {
    // Double-check capability
    if (!current_user_can('manage_options')) {
        wp_die(__('Insufficient permissions', 'textdomain'));
    }
    
    // Page content
}
```

**AJAX Handler Protection:**
```php
// ✅ CORRECT - Protected AJAX handler
add_action('wp_ajax_save_settings', 'save_settings_handler');
function save_settings_handler() {
    // Check nonce
    check_ajax_referer('save_settings_nonce', 'nonce');
    
    // Check capability
    if (!current_user_can('manage_options')) {
        wp_send_json_error(array(
            'message' => __('Insufficient permissions', 'textdomain')
        ));
    }
    
    // Process request
}
```

### Authorization Vulnerabilities to Flag

```php
// ❌ VULNERABLE - No capability check
add_action('admin_post_delete_user', function() {
    wp_delete_user($_POST['user_id']); // Anyone can delete!
});

// ❌ VULNERABLE - Trusting user roles
if ($_POST['user_role'] === 'administrator') { // Can be spoofed!
    do_admin_thing();
}

// ❌ VULNERABLE - Checking logged-in status only
if (is_user_logged_in()) {
    delete_post($_POST['post_id']); // Any logged-in user!
}
```

## Input Sanitization

### Core Principle
Sanitize ALL input. Different data types need different sanitization.

### Sanitization Functions

**Text & Strings:**
```php
// ✅ Simple text (strips tags and newlines)
$text = sanitize_text_field($_POST['input']);

// ✅ Textarea (strips tags, preserves newlines)
$textarea = sanitize_textarea_field($_POST['description']);

// ✅ Email
$email = sanitize_email($_POST['email']);

// ✅ URL
$url = sanitize_url($_POST['website']);

// ✅ Filename
$filename = sanitize_file_name($_FILES['upload']['name']);

// ✅ HTML class
$class = sanitize_html_class($_POST['css_class']);

// ✅ Key (lowercase alphanumeric + underscores)
$key = sanitize_key($_POST['option_key']);

// ✅ Title (for use in title tags)
$title = sanitize_title($_POST['post_title']);
```

**Numbers:**
```php
// ✅ Integer (positive only)
$id = absint($_POST['post_id']);

// ✅ Integer (positive or negative)
$value = intval($_POST['number']);

// ✅ Float
$price = floatval($_POST['price']);
```

**Arrays:**
```php
// ✅ Array of integers
$ids = array_map('absint', $_POST['post_ids']);

// ✅ Array of text fields
$fields = array_map('sanitize_text_field', $_POST['fields']);

// ✅ Recursive sanitization
function sanitize_array($array) {
    foreach ($array as $key => &$value) {
        if (is_array($value)) {
            $value = sanitize_array($value);
        } else {
            $value = sanitize_text_field($value);
        }
    }
    return $array;
}
```

**Special Cases:**
```php
// ✅ Rich content (with allowed HTML)
$content = wp_kses_post($_POST['content']);

// ✅ Meta key
$meta_key = sanitize_key($_POST['meta_key']);

// ✅ Hex color
$color = sanitize_hex_color($_POST['color']);

// ✅ Username (for user_login)
$username = sanitize_user($_POST['username']);
```

### Sanitization Mistakes to Flag

```php
// ❌ No sanitization
update_option('my_option', $_POST['value']);

// ❌ Wrong function for data type
$id = sanitize_text_field($_POST['id']); // Should be absint()

// ❌ Sanitizing but not validating
$email = sanitize_email($_POST['email']);
send_email($email); // What if it's not a valid email format?

// ✅ CORRECT - Sanitize AND validate
$email = sanitize_email($_POST['email']);
if (!is_email($email)) {
    return new WP_Error('invalid_email', __('Invalid email', 'textdomain'));
}
```

## File Upload Security

### Core Principle
NEVER trust uploaded files. Validate type, size, and use WordPress upload handlers.

### Required Pattern
```php
// ✅ CORRECT - Using WordPress upload handler
if (!function_exists('wp_handle_upload')) {
    require_once(ABSPATH . 'wp-admin/includes/file.php');
}

$uploadedfile = $_FILES['file'];
$upload_overrides = array(
    'test_form' => false,
    'mimes' => array(
        'jpg|jpeg|jpe' => 'image/jpeg',
        'png' => 'image/png',
        'pdf' => 'application/pdf',
    )
);

$movefile = wp_handle_upload($uploadedfile, $upload_overrides);

if ($movefile && !isset($movefile['error'])) {
    // File uploaded successfully
    $file_path = $movefile['file'];
    $file_url = $movefile['url'];
} else {
    // Error handling
    $error = $movefile['error'];
}
```

### File Upload Checks
```php
// ✅ Check capabilities
if (!current_user_can('upload_files')) {
    wp_die(__('Insufficient permissions', 'textdomain'));
}

// ✅ Check nonce
check_ajax_referer('file_upload_nonce', 'nonce');

// ✅ Validate file type
$allowed_types = array('image/jpeg', 'image/png', 'application/pdf');
$file_type = wp_check_filetype($_FILES['file']['name']);
if (!in_array($file_type['type'], $allowed_types)) {
    wp_die(__('Invalid file type', 'textdomain'));
}

// ✅ Check file size (5MB example)
$max_size = 5 * 1024 * 1024; // 5MB
if ($_FILES['file']['size'] > $max_size) {
    wp_die(__('File too large', 'textdomain'));
}
```

### File Upload Vulnerabilities to Flag

```php
// ❌ VULNERABLE - Direct file move
move_uploaded_file(
    $_FILES['upload']['tmp_name'],
    '/uploads/' . $_FILES['upload']['name']
);

// ❌ VULNERABLE - No type validation
copy($_FILES['upload']['tmp_name'], $destination);

// ❌ VULNERABLE - Trusting client-provided MIME type
if ($_FILES['upload']['type'] === 'image/jpeg') { // Can be spoofed!
    // ...
}
```

## WordPress-Specific Security Patterns

### Use WordPress Functions Over PHP
```php
// ✅ Use WordPress HTTP API
$response = wp_remote_get($url);
// ❌ Don't use: file_get_contents($url)

// ✅ Use WordPress redirect
wp_safe_redirect($url);
// ❌ Don't use: header('Location: ' . $url);

// ✅ Use WordPress JSON encoding
wp_json_encode($data);
// ❌ Don't use: json_encode($data);

// ✅ Use WordPress filesystem API
WP_Filesystem();
global $wp_filesystem;
$wp_filesystem->put_contents($file, $content);
// ❌ Don't use: file_put_contents($file, $content);
```

### Disable File Editing in Production
```php
// ✅ Add to wp-config.php
define('DISALLOW_FILE_EDIT', true);
define('DISALLOW_FILE_MODS', true);
```

### API Endpoint Security
```php
// ✅ Register secured REST API endpoint
register_rest_route('myplugin/v1', '/data', array(
    'methods' => 'POST',
    'callback' => 'my_endpoint_callback',
    'permission_callback' => function() {
        return current_user_can('edit_posts');
    },
    'args' => array(
        'title' => array(
            'required' => true,
            'validate_callback' => function($param) {
                return is_string($param);
            },
            'sanitize_callback' => 'sanitize_text_field',
        ),
    ),
));
```

## Priority Flags

When reviewing code, flag issues in this priority:

### CRITICAL (Fix Immediately)
1. SQL injection vulnerabilities
2. Unescaped output (XSS)
3. Missing nonce verification on state changes
4. Missing capability checks on sensitive operations
5. File upload without validation

### HIGH (Fix Before Deploy)
1. Using PHP functions instead of WordPress APIs
2. Incorrect sanitization for data type
3. Missing input validation
4. Weak nonces (predictable or shared)
5. Trusting client-side data

### MEDIUM (Schedule Fix)
1. Missing internationalization
2. Deprecated WordPress functions
3. Inefficient database queries
4. Missing error handling
5. Poor code organization

## Testing Recommendations

When security issues are found, recommend:
1. Manual testing with malicious input
2. Using WordPress.com VIP code scanner
3. Using PHPCS with WordPress security standards
4. Penetration testing for critical applications
5. Security audit by WordPress security specialist

## References

- [WordPress Security Handbook](https://developer.wordpress.org/apis/security/)
- [Plugin Security Best Practices](https://developer.wordpress.org/plugins/security/)
- [Data Validation](https://developer.wordpress.org/apis/security/data-validation/)
- [Escaping Output](https://developer.wordpress.org/apis/security/escaping/)
- [Nonces](https://developer.wordpress.org/apis/security/nonces/)
