---
name: emacs-variables
description: Use when inspecting or modifying Emacs variables - provides elisp patterns for variable handling, customization, and state management
---

# Emacs Variables Skill

## Display Guidelines

**E-ink Monitor Compatibility**: User uses an e-ink monitor that only supports black, white, and grey.
- NEVER use colors (`:foreground "red"`, `:foreground "cyan"`, etc.)
- Use `:weight bold`, `:weight light`, `:slant italic`, `:underline t` for differentiation
- Standard Emacs faces (font-lock-*-face) are acceptable as they adapt to themes

## Variable Basics

### Define variable
```elisp
(defvar my-var "default" "Documentation string.")
(defvar my-var nil)  ; define without overwriting
```

### Set variable
```elisp
(setq my-var "value")
(setq var1 "val1" var2 "val2")  ; multiple
```

### Get variable value
```elisp
my-var  ; just use the symbol
(symbol-value 'my-var)  ; programmatic access
```

## Buffer-Local Variables

### Make buffer-local
```elisp
(make-local-variable 'my-var)
(setq-local my-var "buffer-specific")
```

### Define as buffer-local by default
```elisp
(defvar-local my-buffer-var nil "Always buffer-local.")
```

### Get value in other buffer
```elisp
(buffer-local-value 'my-var other-buffer)
```

### Check if buffer-local
```elisp
(local-variable-p 'my-var)
(local-variable-if-set-p 'my-var)
```

## User Options (Customizable)

### Define custom option
```elisp
(defcustom my-option "default"
  "Documentation for option."
  :type 'string
  :group 'my-group)
```

### Common :type values
```elisp
:type 'boolean
:type 'string
:type 'integer
:type '(choice (const nil) (string :tag "Custom"))
:type '(repeat string)
```

## Variable Inspection

### Check if bound
```elisp
(boundp 'my-var)  ; is it defined?
```

### Describe variable
```elisp
(describe-variable 'my-var)  ; interactive
```

### Get documentation
```elisp
(documentation-property 'my-var 'variable-documentation)
```

## Let Bindings

### Local binding
```elisp
(let ((x 1)
      (y 2))
  (+ x y))  ; x, y only exist here
```

### Sequential binding
```elisp
(let* ((x 1)
       (y (+ x 1)))  ; y can use x
  y)
```

## Dynamic Binding

### Temporarily change variable
```elisp
(let ((some-global-var "temporary"))
  ;; functions called here see temporary value
  (do-something))
;; original value restored
```

### Common pattern
```elisp
(let ((inhibit-read-only t))
  ;; can modify read-only buffer here
  (erase-buffer))
```

## Hash Tables

### Create hash table
```elisp
(make-hash-table :test 'equal)
```

### Access hash table
```elisp
(gethash key table)
(gethash key table default)
(puthash key value table)
(remhash key table)
```

### Iterate hash table
```elisp
(maphash (lambda (key value)
           ;; process key, value
           )
         table)
```

## Property Lists

### Get property
```elisp
(plist-get '(:a 1 :b 2) :a)  ; => 1
```

### Put property
```elisp
(plist-put plist :key value)
```

### In symbol properties
```elisp
(get 'my-symbol 'property)
(put 'my-symbol 'property value)
```

## Common Patterns

### Safe variable access
```elisp
(when (boundp 'maybe-var)
  (symbol-value 'maybe-var))
```

### Toggle boolean
```elisp
(setq my-flag (not my-flag))
```

### Increment/modify
```elisp
(cl-incf counter)
(cl-decf counter)
(push item my-list)
(pop my-list)
```

### Environment variables
```elisp
(getenv "PATH")
(setenv "MY_VAR" "value")
```

### Mode-line variables
```elisp
;; For e-ink: use weight/slant, not colors
(setq my-mode-line-string
      (propertize " [Status]"
                  'face '(:weight bold)
                  'help-echo "Tooltip text"))
```

## Hooks

### Add to hook
```elisp
(add-hook 'some-mode-hook #'my-function)
(add-hook 'some-mode-hook #'my-function nil t)  ; buffer-local
```

### Remove from hook
```elisp
(remove-hook 'some-mode-hook #'my-function)
```

### Run hooks
```elisp
(run-hooks 'my-hook)
(run-hook-with-args 'my-hook arg1 arg2)
```
