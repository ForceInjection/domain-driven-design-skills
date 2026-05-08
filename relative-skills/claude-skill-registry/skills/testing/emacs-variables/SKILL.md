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

## Lexical Binding and Closures

**IMPORTANT**: Emacs has two binding modes - dynamic (default in older code) and lexical.
Literate-elisp files and files without `lexical-binding: t` use dynamic binding.

### The Problem: Closures in Dynamic Binding

In dynamic binding, lambdas don't capture variables - they look them up at runtime:

```elisp
;; BROKEN in dynamic binding - tn is void at call time
(defun make-broken-fn (name)
  (let ((tn name))
    (lambda () (message "Name: %s" tn))))  ; tn looked up when called, not defined!
```

### Solution: Use lexical-let

`lexical-let` (from cl-lib) creates true lexical closures even in dynamic binding mode:

```elisp
(require 'cl-lib)

;; WORKS - lexical-let captures variables properly
(defun make-working-fn (name)
  (lexical-let ((tn name))
    (lambda () (message "Name: %s" tn))))  ; tn captured at definition time
```

### When to Use lexical-let

Use `lexical-let` when:
- Creating closures/lambdas that reference outer variables
- Building callbacks or handler functions dynamically
- Any lambda that will be called later and needs captured state

```elisp
;; Creating multiple closures that each capture different values
(defun make-toggler (tag-name)
  "Create a function that toggles TAG-NAME."
  (lexical-let ((tn tag-name))
    (lambda ()
      (interactive)
      (toggle-tag tn))))

;; Creating a description function for transient menu
(defun make-description (tag desc)
  "Create a description function for TAG with DESC."
  (lexical-let ((t tag) (d desc))
    (lambda ()
      (format "[%s] %s" (if (selected-p t) "X" " ") d))))
```

### Alternative: Enable Lexical Binding

For new files, prefer enabling lexical binding in the file header:

```elisp
;;; my-file.el --- Description -*- lexical-binding: t; -*-
```

Then regular `let` creates closures correctly:

```elisp
;; Works with lexical-binding: t
(defun make-fn (name)
  (let ((tn name))
    (lambda () (message "Name: %s" tn))))
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
