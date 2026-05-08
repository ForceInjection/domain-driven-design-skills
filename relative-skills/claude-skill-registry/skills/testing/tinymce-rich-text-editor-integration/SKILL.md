---
name: "TinyMCE Rich Text Editor Integration"
description: "Integrate TinyMCE rich text editor using ngx-tinymce. Use this skill when implementing WYSIWYG editors, content management, article editing, or any rich text input. Covers configuration, plugins, toolbar customization, file uploads, content sanitization, and Angular integration with reactive forms and signals. Ensures accessibility and proper validation."
license: "MIT"
---

# TinyMCE Rich Text Editor Integration Skill

This skill helps integrate TinyMCE rich text editor using ngx-tinymce in Angular.

## Core Principles

### Rich Text Editing
- **WYSIWYG**: What You See Is What You Get editing
- **Plugins**: Extensible with TinyMCE plugins
- **Validation**: Content validation and sanitization
- **Forms Integration**: Works with Angular Reactive Forms

### Key Features
- Customizable toolbar
- Image upload and management
- Code view and formatting
- Auto-save functionality
- Responsive design
- Accessibility support

## Installation

```bash
npm install ngx-tinymce@^20.0.0
```

## Basic Configuration

### Standalone Component

```typescript
import { Component, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { TinymceModule } from 'ngx-tinymce';
import { SHARED_IMPORTS } from '@shared';

@Component({
  selector: 'app-article-editor',
  standalone: true,
  imports: [SHARED_IMPORTS, TinymceModule, FormsModule],
  template: `
    <tinymce
      [(ngModel)]="content"
      [config]="config"
      (ngModelChange)="handleContentChange($event)"
    />
    
    <button nz-button nzType="primary" (click)="save()">
      Save Article
    </button>
  `
})
export class ArticleEditorComponent {
  content = signal('');
  
  config = {
    height: 500,
    menubar: false,
    plugins: [
      'advlist', 'autolink', 'lists', 'link', 'image', 'charmap',
      'preview', 'anchor', 'searchreplace', 'visualblocks', 'code',
      'fullscreen', 'insertdatetime', 'media', 'table', 'help', 'wordcount'
    ],
    toolbar:
      'undo redo | formatselect | bold italic backcolor | \
      alignleft aligncenter alignright alignjustify | \
      bullist numlist outdent indent | removeformat | help'
  };
  
  handleContentChange(content: string): void {
    this.content.set(content);
  }
  
  save(): void {
    console.log('Saving content:', this.content());
  }
}
```

## Reactive Forms Integration

```typescript
import { Component, inject } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { TinymceModule } from 'ngx-tinymce';

@Component({
  selector: 'app-article-form',
  standalone: true,
  imports: [SHARED_IMPORTS, TinymceModule, ReactiveFormsModule],
  template: `
    <form [formGroup]="articleForm" (ngSubmit)="submit()">
      <nz-form-item>
        <nz-form-label [nzRequired]="true">Title</nz-form-label>
        <nz-form-control nzErrorTip="Please enter title">
          <input nz-input formControlName="title" placeholder="Article title" />
        </nz-form-control>
      </nz-form-item>
      
      <nz-form-item>
        <nz-form-label [nzRequired]="true">Content</nz-form-label>
        <nz-form-control nzErrorTip="Please enter content">
          <tinymce
            formControlName="content"
            [config]="config"
          />
        </nz-form-control>
      </nz-form-item>
      
      <button 
        nz-button 
        nzType="primary" 
        [disabled]="articleForm.invalid"
      >
        Publish
      </button>
    </form>
  `
})
export class ArticleFormComponent {
  private fb = inject(FormBuilder);
  
  articleForm: FormGroup = this.fb.group({
    title: ['', [Validators.required, Validators.maxLength(200)]],
    content: ['', [Validators.required, Validators.minLength(10)]]
  });
  
  config = {
    height: 400,
    plugins: ['lists', 'link', 'image', 'code', 'table'],
    toolbar: 'undo redo | bold italic | bullist numlist | link image'
  };
  
  submit(): void {
    if (this.articleForm.valid) {
      console.log('Article:', this.articleForm.value);
    }
  }
}
```

## Advanced Configuration

### Full-Featured Editor

```typescript
config = {
  height: 600,
  menubar: 'file edit view insert format tools table help',
  plugins: [
    'advlist', 'autolink', 'lists', 'link', 'image', 'charmap', 'preview',
    'anchor', 'searchreplace', 'visualblocks', 'code', 'fullscreen',
    'insertdatetime', 'media', 'table', 'code', 'help', 'wordcount',
    'codesample', 'emoticons', 'template', 'paste', 'pagebreak'
  ],
  toolbar: [
    'undo redo | formatselect | bold italic underline strikethrough | forecolor backcolor',
    'alignleft aligncenter alignright alignjustify | outdent indent | numlist bullist',
    'link image media codesample | table | code fullscreen preview | emoticons charmap'
  ],
  toolbar_mode: 'sliding',
  contextmenu: 'link image table',
  skin: 'oxide',
  content_css: 'default',
  branding: false, // Remove "Powered by TinyMCE"
  elementpath: true,
  statusbar: true,
  resize: true,
  autosave_interval: '30s',
  autosave_prefix: 'tinymce-autosave-{path}{query}-{id}-',
  autosave_restore_when_empty: true,
  autosave_retention: '2m'
};
```

## Image Upload

### Firebase Storage Integration

```typescript
import { Storage, ref, uploadBytes, getDownloadURL } from '@angular/fire/storage';

@Component({
  selector: 'app-editor-with-upload',
  template: `
    <tinymce [(ngModel)]="content" [config]="config" />
  `
})
export class EditorWithUploadComponent {
  private storage = inject(Storage);
  content = signal('');
  
  config = {
    height: 500,
    plugins: ['image', 'link', 'media'],
    toolbar: 'image link',
    
    // Custom image upload handler
    images_upload_handler: async (blobInfo: any, progress: any) => {
      return this.uploadImage(blobInfo.blob(), blobInfo.filename());
    },
    
    // Automatic uploads when pasting
    automatic_uploads: true,
    
    // Image options
    image_advtab: true,
    image_caption: true,
    image_title: true
  };
  
  private async uploadImage(blob: Blob, filename: string): Promise<string> {
    try {
      // Create storage reference
      const storageRef = ref(this.storage, `images/${Date.now()}_${filename}`);
      
      // Upload file
      await uploadBytes(storageRef, blob);
      
      // Get download URL
      const url = await getDownloadURL(storageRef);
      
      return url;
    } catch (error) {
      console.error('Image upload failed:', error);
      throw error;
    }
  }
}
```

### Base64 Images (Simple)

```typescript
config = {
  plugins: ['image'],
  toolbar: 'image',
  
  // Convert images to base64
  images_upload_handler: (blobInfo: any) => {
    return new Promise((resolve) => {
      const reader = new FileReader();
      reader.onload = () => resolve(reader.result as string);
      reader.readAsDataURL(blobInfo.blob());
    });
  }
};
```

## Content Sanitization

```typescript
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';

@Component({
  selector: 'app-article-view',
  template: `
    <div [innerHTML]="sanitizedContent()"></div>
  `
})
export class ArticleViewComponent {
  private sanitizer = inject(DomSanitizer);
  private content = signal('<p>Article content</p>');
  
  sanitizedContent = computed(() => 
    this.sanitizer.sanitize(SecurityContext.HTML, this.content()) || ''
  );
}
```

## Custom Plugins

### Character Counter Plugin

```typescript
config = {
  plugins: ['wordcount'],
  toolbar: 'wordcount',
  
  // Custom setup function
  setup: (editor: any) => {
    editor.on('init', () => {
      console.log('Editor initialized');
    });
    
    editor.on('change', () => {
      const content = editor.getContent();
      console.log('Content changed:', content.length);
    });
    
    // Add custom button
    editor.ui.registry.addButton('customButton', {
      text: 'Custom Action',
      onAction: () => {
        editor.insertContent('&nbsp;<strong>Custom content</strong>&nbsp;');
      }
    });
  }
};
```

## Code Highlighting

```typescript
config = {
  plugins: ['codesample'],
  toolbar: 'codesample',
  
  codesample_languages: [
    { text: 'TypeScript', value: 'typescript' },
    { text: 'JavaScript', value: 'javascript' },
    { text: 'Python', value: 'python' },
    { text: 'Java', value: 'java' },
    { text: 'HTML/XML', value: 'markup' },
    { text: 'CSS', value: 'css' },
    { text: 'SQL', value: 'sql' }
  ],
  
  // Use Prism.js for syntax highlighting
  codesample_global_prismjs: true
};
```

## Templates

```typescript
config = {
  plugins: ['template'],
  toolbar: 'template',
  
  templates: [
    {
      title: 'Meeting Notes',
      description: 'Template for meeting notes',
      content: `
        <h2>Meeting Notes</h2>
        <p><strong>Date:</strong> </p>
        <p><strong>Attendees:</strong> </p>
        <h3>Agenda</h3>
        <ol>
          <li>Item 1</li>
          <li>Item 2</li>
        </ol>
        <h3>Action Items</h3>
        <ul>
          <li>Action 1</li>
        </ul>
      `
    },
    {
      title: 'Blog Post',
      description: 'Template for blog posts',
      content: `
        <h1>Blog Title</h1>
        <p><em>Published on: </em></p>
        <h2>Introduction</h2>
        <p>Introduction text...</p>
        <h2>Main Content</h2>
        <p>Main content...</p>
        <h2>Conclusion</h2>
        <p>Conclusion...</p>
      `
    }
  ]
};
```

## Localization

```typescript
config = {
  language: 'zh_CN', // Chinese Simplified
  language_url: '/assets/tinymce/langs/zh_CN.js',
  
  // Or use built-in translations
  directionality: 'ltr' // 'ltr' or 'rtl'
};
```

## Mobile Responsive

```typescript
config = {
  // Mobile-friendly toolbar
  mobile: {
    menubar: false,
    toolbar: ['undo', 'redo', 'bold', 'italic']
  },
  
  // Desktop toolbar
  toolbar: 'undo redo | bold italic underline | alignleft aligncenter alignright',
  
  // Responsive behavior
  resize: 'both',
  min_height: 300,
  max_height: 800
};
```

## Auto-Save

```typescript
@Component({
  selector: 'app-auto-save-editor',
  template: `
    <tinymce [(ngModel)]="content" [config]="config" />
    <div class="save-status">
      @if (saveStatus()) {
        <nz-tag [nzColor]="saveStatus() === 'saved' ? 'success' : 'warning'">
          {{ saveStatus() }}
        </nz-tag>
      }
    </div>
  `
})
export class AutoSaveEditorComponent {
  content = signal('');
  saveStatus = signal<'saving' | 'saved' | null>(null);
  
  config = {
    plugins: ['autosave'],
    autosave_interval: '30s',
    autosave_restore_when_empty: true,
    
    setup: (editor: any) => {
      // Listen to auto-save events
      editor.on('BeforeAutoSave', () => {
        this.saveStatus.set('saving');
      });
      
      editor.on('AutoSave', () => {
        this.saveContent();
      });
    }
  };
  
  private async saveContent(): Promise<void> {
    try {
      // Save to backend
      await this.articleService.save(this.content());
      this.saveStatus.set('saved');
      
      // Clear status after 2 seconds
      setTimeout(() => this.saveStatus.set(null), 2000);
    } catch (error) {
      console.error('Auto-save failed:', error);
    }
  }
}
```

## Validation

```typescript
import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

/**
 * Validate minimum text length (excluding HTML tags)
 */
export function minTextLengthValidator(minLength: number): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const html = control.value || '';
    
    // Strip HTML tags
    const text = html.replace(/<[^>]*>/g, '').trim();
    
    if (text.length < minLength) {
      return { minTextLength: { required: minLength, actual: text.length } };
    }
    
    return null;
  };
}

// Usage
articleForm = this.fb.group({
  content: ['', [
    Validators.required,
    minTextLengthValidator(100) // At least 100 characters of text
  ]]
});
```

## Accessibility

```typescript
config = {
  // Accessibility options
  a11y_advanced_options: true,
  
  // ARIA labels
  aria_label: 'Rich text editor',
  
  // Keyboard shortcuts help
  plugins: ['help'],
  toolbar: 'help',
  
  // Focus management
  auto_focus: false,
  
  // Screen reader support
  statusbar: true,
  elementpath: true
};
```

## Checklist

When integrating TinyMCE:

- [ ] Install ngx-tinymce package
- [ ] Configure toolbar and plugins
- [ ] Implement image upload handler
- [ ] Sanitize HTML output
- [ ] Add form validation
- [ ] Test on mobile devices
- [ ] Implement auto-save
- [ ] Configure accessibility options
- [ ] Test keyboard navigation
- [ ] Handle errors gracefully
- [ ] Optimize editor performance
- [ ] Test with screen readers

## Best Practices

### ✅ DO

```typescript
// Sanitize content before display
sanitizedContent = computed(() => 
  this.sanitizer.sanitize(SecurityContext.HTML, this.content())
);

// Use custom upload handler
config = {
  images_upload_handler: (blobInfo) => this.uploadImage(blobInfo)
};

// Validate content
content: ['', [Validators.required, minTextLengthValidator(50)]]

// Auto-save implementation
autosave_interval: '30s'
```

### ❌ DON'T

```typescript
// Don't trust user HTML
<div [innerHTML]="content"></div> // XSS vulnerability!

// Don't use default image upload (base64 bloat)
images_upload_url: '/upload' // Use custom handler instead

// Don't forget accessibility
// Always include aria_label and help plugin
```

## References

- [ngx-tinymce Documentation](https://github.com/cipchk/ngx-tinymce)
- [TinyMCE Official Docs](https://www.tiny.cloud/docs/)
- [TinyMCE Plugins](https://www.tiny.cloud/docs/plugins/)
- [Angular Sanitization](https://angular.dev/best-practices/security)
