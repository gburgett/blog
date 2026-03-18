# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is Gordon Burgett's personal blog built with Hugo static site generator, using the PaperMod theme with extensive customizations. The site focuses on technical leadership, AI/ML projects, and professional portfolio presentation with LinkedIn-aligned branding.

## Development Commands

### Running the Development Server

```bash
hugo server -D
```

The site will be available at http://localhost:1313/ with live reload enabled. The `-D` flag includes draft posts.

### Building the Site

```bash
hugo
```

This generates static files to the `public/` directory.

### Creating New Content

```bash
# New blog post (will use archetypes/default.md template)
hugo new posts/2026/04_my-new-post.md

# New project
hugo new projects/my-project.md
```

### Deployment

The site is deployed via Docker:

1. Build static files: `hugo`
2. Docker builds Apache container with `public/` directory
3. Container pushed to DockerHub: `gordonburgett/blog`
4. HAProxy terminates SSL and forwards to container ports 8080/8081

## Architecture

### Content Organization

**Content Sections:**
- `content/posts/` - Blog articles organized by year (2024/, 2026/)
- `content/projects/` - Portfolio projects with custom badges and links
- `content/albania/` - Mission work documentation with custom layouts
- `content/archive/` - Historical posts from 2014-2019
- `content/contact/` - Contact form page
- `content/newsletter/` - Newsletter content

**Front Matter Format:** TOML (uses `+++` delimiters)

**Project Front Matter:**
```toml
+++
title = "Project Name"
date = "2024-01-01"
showInHome = true  # Controls featured projects section
image = "/images/projects/project-name.png"
badges = ["React", "TypeScript", "AWS"]
links = [
    {icon = "fas fa-globe", url = "https://example.com/"}
]
+++
```

**Post Front Matter:**
```toml
+++
title = "Post Title"
date = "2026-03-18T10:00:00-05:00"
Categories = ["AI", "Development"]
Tags = ["AI", "Development"]
draft = false
quote = "Pull quote for social sharing"
image = "/images/post-image.png"
+++
```

### Layout Customization

The site heavily customizes PaperMod theme through layout overrides:

**Key Layout Files:**
- `layouts/index.html` - Home page: renders home_info, capabilities section, projects grid, recent posts
- `layouts/partials/header.html` - Custom header with hamburger menu and mobile navigation
- `layouts/partials/extend_head.html` - Meta tags for Open Graph, Twitter Cards, Plausible Analytics
- `layouts/partials/sections/capabilities.html` - Capabilities grid section (4 categories)
- `layouts/partials/sections/projects.html` - Featured projects grid with cards
- `layouts/projects/single.html` - Individual project page template

**Custom Sections on Homepage:**
1. Home info (profile image, bio, social icons)
2. Capabilities section (4 categories: AI/ML, Systems, Leadership, Tech Stack)
3. Featured Projects (filtered by `showInHome` parameter)
4. Recent Blog Posts (first 5)

### Styling

**Primary CSS:** `assets/css/extended/custom.css` (736+ lines)

**Key Style Sections:**
- Hamburger menu and mobile navigation overlay
- Projects grid (responsive, card-based)
- Capabilities section (4-column grid)
- LinkedIn color scheme: `--linkedin-blue: #0077b5`, `--linkedin-hover: #005e93`
- Profile image (circular with hover effects)
- Contact form styling
- Responsive breakpoint at 768px

**Additional CSS:**
- `static/css/custom.css` - Legacy custom styles
- `static/css/albania.css` - Albania section styles

### Configuration

**Main Config:** `config.yml`

**Important Parameters:**
- `params.homeInfoParams` - Home page headline and bio
- `params.capabilities` - Capabilities section with 4 categories
- `params.projects.enable` - Toggle featured projects section
- `params.socialIcons` - GitHub, LinkedIn, Email links
- `params.fuseOpts` - Client-side search configuration
- `languages.en.menu.main` - Navigation menu items

**Search:** Uses Fuse.js for client-side search with JSON index output.

**Analytics:** Plausible Analytics script in `extend_head.html`.

## Common Patterns

### Adding a New Featured Project

1. Create project file: `hugo new projects/project-name.md`
2. Set `showInHome = true` in front matter
3. Add project image to `static/images/projects/`
4. Include badges array and links array
5. Project will appear in homepage grid automatically

### Adding a New Blog Post

1. Create post in appropriate year: `hugo new posts/2026/05_post-name.md`
2. Set front matter: title, date, Categories, Tags
3. Add images to `static/images/2026/` (organize by year)
4. Set `draft = false` when ready to publish

### Hiding a Project from Homepage

Set `showInHome = false` in project front matter. The project page remains accessible but won't appear in the featured grid.

### Modifying the Capabilities Section

Edit `config.yml` under `params.capabilities.items`. Each item has:
- `category` - Section header
- `items` - Array of bullet points

### Mobile Navigation

The custom hamburger menu is implemented in:
- `layouts/partials/header.html` - HTML structure and JavaScript
- `assets/css/extended/custom.css` - Styling and animations

Mobile menu overlay activates at 768px breakpoint.

## Theme Relationship

**Active Theme:** PaperMod (git submodule at `themes/PaperMod`)

**Legacy Themes:** hugo-profile, hugo-uno (not in use, but available as submodules)

The site overrides theme templates by placing files in `layouts/` with matching paths. Hugo prioritizes project layouts over theme layouts, allowing selective customization while maintaining theme updates.

## Important Notes

- Avoid em-dashes in content - use regular dashes or rewrite (user preference)
- LinkedIn blue (#0077b5) is the primary brand color
- Images should be organized by year in `static/images/YYYY/`
- All new posts should follow the TOML front matter format with `+++` delimiters
- Draft posts require `draft = true` and will only show with `hugo server -D`
- avoid em-dashes, use warm personal style in all blog posts.  Make posts punchy but avoid LinkedIn-speak