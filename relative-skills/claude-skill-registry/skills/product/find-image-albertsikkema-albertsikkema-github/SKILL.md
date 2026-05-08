---
name: find-image
description: Find and suggest images for blog posts. Use when the user asks to find images, needs a picture, wants stock photos, or is looking for visuals for their blog post.
---

# Find Image for Blog Post

Help the user find appropriate images for their blog posts and generate the proper HTML markup.

## Instructions

1. **Understand the context**: Ask or determine what the blog post is about
2. **Search for images**: Use web search to find relevant free stock images from sources like:
   - Unsplash (https://unsplash.com) - High-quality free photos
   - Pexels (https://pexels.com) - Free stock photos and videos
   - Pixabay (https://pixabay.com) - Free images and royalty-free stock
   - Undraw (https://undraw.co) - Free illustrations for tech/business

3. **Provide search links**: Give the user direct search URLs to find images

4. **Suggest filenames**: Propose descriptive filenames following the convention:
   - Use lowercase with hyphens
   - Be descriptive (e.g., `gdpr-logging-architecture-diagram.png`)
   - Include the main topic

5. **Generate HTML markup**: Provide the complete figure HTML with:
   - Proper alt text (descriptive, WCAG 2.1 AA compliant, under 125 chars)
   - Standard figcaption

## Image Guidelines (from project standards)

- **Location**: `/assets/images/`
- **Preferred formats**: WebP (best compression), PNG (diagrams/screenshots), JPG (photos)
- **Max size**: < 500KB (images are auto-optimized via pre-commit hook)
- **Alt text requirements**:
  - Be descriptive and specific
  - Relate to surrounding content
  - Aim for 125 characters or less
  - Don't start with "Image of" or "Picture of"
  - Include relevant keywords naturally

## Output Format

When suggesting an image, provide:

1. **Search links** for finding the image:
```
Unsplash: https://unsplash.com/s/photos/[search-term]
Pexels: https://www.pexels.com/search/[search-term]/
```

2. **Suggested filename**:
```
[topic]-[description].webp
```

3. **HTML markup to use**:
```html
<figure>
  <img src="/assets/images/[filename]" alt="[Descriptive alt text]">
  <figcaption>This is what AI thinks an image for this blog should look like...</figcaption>
</figure>
```

## Examples

### Example 1: AI Development Post

User asks for an image for a post about "Building AI Agents with Claude"

**Search links:**
- Unsplash: https://unsplash.com/s/photos/artificial-intelligence-robot
- Pexels: https://www.pexels.com/search/artificial%20intelligence/

**Suggested filename:** `claude-ai-agent-development.webp`

**HTML markup:**
```html
<figure>
  <img src="/assets/images/claude-ai-agent-development.webp" alt="Abstract visualization of AI neural network connections representing intelligent agent systems">
  <figcaption>This is what AI thinks an image for this blog should look like...</figcaption>
</figure>
```

### Example 2: Python Security Post

User asks for an image for a post about "GDPR-Compliant Logging in Python"

**Search links:**
- Unsplash: https://unsplash.com/s/photos/data-security-privacy
- Pexels: https://www.pexels.com/search/data%20protection/

**Suggested filename:** `gdpr-python-logging-security.webp`

**HTML markup:**
```html
<figure>
  <img src="/assets/images/gdpr-python-logging-security.webp" alt="Secure data protection concept with lock symbol representing GDPR privacy compliance">
  <figcaption>This is what AI thinks an image for this blog should look like...</figcaption>
</figure>
```

## Technical Diagrams

For technical content, also suggest tools to create diagrams:
- **Excalidraw** (https://excalidraw.com) - Hand-drawn style diagrams
- **Draw.io** (https://draw.io) - Professional flowcharts and architecture diagrams
- **Mermaid** (in markdown) - Code-based diagrams

For diagrams, use a specific figcaption describing what the diagram shows instead of the standard AI humor caption.
