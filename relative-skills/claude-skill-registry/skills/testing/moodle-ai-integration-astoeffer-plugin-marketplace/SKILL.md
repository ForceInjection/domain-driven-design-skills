---
name: moodle-ai-integration
description: Integrate with Moodle AI Subsystem (4.5+). Create custom Actions, Providers, and Placements for AI-powered features.
---

# Moodle AI Integration Skill

Integrate with Moodle's AI Subsystem (4.5+).

## Trigger
- Creating AI-powered features
- Implementing Providers/Actions/Placements
- User requests AI integration

## Architecture Knowledge

```
Placement (UI) ──▶ Manager ──▶ Provider (AI)
     │                │              │
     ▼                ▼              ▼
  User sees      Coordinates    Calls OpenAI,
  AI features    & logs         Claude, etc.
```

**Key**: Placements and Providers are decoupled!

## Actions

### 1. Create Custom Action
```php
// classes/aiactions/my_action.php
namespace mod_myplugin\aiactions;

class my_action extends \core_ai\aiactions\base {
    public function __construct(
        int $contextid,
        protected string $prompttext
    ) {
        parent::__construct($contextid);
    }

    public function store(): int {
        global $DB;
        return $DB->insert_record('ai_action_my_action', [
            'contextid' => $this->contextid,
            'prompttext' => $this->prompttext,
            'timecreated' => time(),
        ]);
    }
}
```

### 2. Create Response Class
```php
// classes/aiactions/responses/my_action_response.php
namespace mod_myplugin\aiactions\responses;

class my_action_response extends \core_ai\aiactions\responses\response_base {
    public ?string $result = null;

    public function set_response_data(array $response): void {
        $this->result = $response['result'] ?? null;
    }

    public function get_response_data(): array {
        return ['result' => $this->result];
    }
}
```

### 3. Use in Code
```php
$action = new \mod_myplugin\aiactions\my_action(
    contextid: $context->id,
    prompttext: $userprompt
);

$response = (new \core_ai\manager())->process_action($action);

if ($response->get_success()) {
    $data = $response->get_response_data();
}
```

### 4. Handle User Policy
```php
// Check policy
if (!\core_ai\manager::get_user_policy_status($USER->id)) {
    // Show policy acceptance UI
}

// Record acceptance
\core_ai\manager::user_policy_accepted($USER->id, $context->id);
```

## Database Table
```xml
<!-- db/install.xml -->
<TABLE NAME="ai_action_my_action">
    <FIELD NAME="id" TYPE="int" NOTNULL="true" SEQUENCE="true"/>
    <FIELD NAME="contextid" TYPE="int" NOTNULL="true"/>
    <FIELD NAME="prompttext" TYPE="text" NOTNULL="true"/>
    <FIELD NAME="timecreated" TYPE="int" NOTNULL="true"/>
</TABLE>
```

## Webservices for AJAX
- `core_ai_get_policy_status` - Check acceptance
- `core_ai_set_policy_status` - Record acceptance

## Checklist
- [ ] Action class with `store()` method
- [ ] Response class with `set_response_data()`
- [ ] Database table for action data
- [ ] Policy check before AI features
- [ ] Error handling for API failures
- [ ] Logging enabled via Manager
