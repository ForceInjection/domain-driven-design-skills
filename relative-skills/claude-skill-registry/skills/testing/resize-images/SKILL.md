---
name: resize-images
description: Resizes images that are too large for the blog. Use when asked to resize images, optimize images, or make images smaller. Can resize to a specific width (e.g., "resize to 300px") or default to 1000px max width. Defaults to the most recent post's assets folder.
allowed-tools: Read, Glob, Grep, Bash, AskUserQuestion
---

# Resize Images Skill

Resize images in blog post assets folders. Default max width is 1000px, but can resize to any specified width.

## Finding Images to Resize

1. If a specific image path or post is provided, use that
2. Otherwise, find the most recent post by looking at `Public/_posts/` and selecting the textbundle with the latest date prefix (YYYY-MM-DD format)
3. Look in the `assets/` folder within the textbundle

## Supported Formats

Only process these image formats:
- `.jpeg`
- `.jpg`
- `.png`

## Target Width

- **Default**: 1000px (for images wider than 1000px)
- **Custom**: If the user specifies a width (e.g., "resize to 300px", "make it 500 wide"), use that exact width

When a custom width is specified, resize the image to that width regardless of its current size.

## Process

### 1. Find Unstaged Images

Find images that are either:
- New (untracked) files
- Modified but not staged

Use `git status --porcelain` to identify unstaged files, then filter for images in the target assets folder.

If a specific image is requested, use that directly without checking git status.

### 2. Check Dimensions

For each image, check its width using ImageMagick:
```bash
/usr/local/bin/magick identify -format "%w" <image_path>
```

### 3. Report and Confirm

Present a summary of images to resize:

For default (1000px max) mode:
```
## Images to Resize (max 1000px)

| Image | Current Width | New Width |
|-------|---------------|-----------|
| image1.png | 2400px | 1000px |
| image2.jpg | 1800px | 1000px |

Resize these images?
```

For custom width mode:
```
## Images to Resize (to 300px)

| Image | Current Width | New Width |
|-------|---------------|-----------|
| icon.png | 512px | 300px |

Resize these images?
```

Use the AskUserQuestion tool to confirm before proceeding.

### 4. Resize Images

After confirmation, resize each image using ImageMagick:
```bash
/usr/local/bin/magick mogrify -resize <width> <image_path>
```

### 5. Report Results

After resizing, report what was done:
```
## Resized Images

- image1.png: 2400px → 1000px
- icon.png: 512px → 300px
```

## Important

- For default mode: only resize images wider than 1000px
- For custom width mode: resize to the exact width specified
- Only process unstaged images unless a specific image is requested
- Always ask for confirmation before resizing
- If no images need resizing, report that clearly
