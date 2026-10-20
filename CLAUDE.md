# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is Gordon Burgett's site, built with the Hugo static site generator and the PaperMod theme, plus custom layouts. He is a fractional AI engineer in Dallas-Fort Worth. The business site is https://dfwfractionalfde.com. This site is his writing and background, and it is live at https://gordonburgett.net.

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

Pushes to `master` are built and published to GitHub Pages by `.github/workflows/gh-pages.yml`.

1. The workflow checks out the repo with theme submodules and runs `hugo --minify`
2. `peaceiris/actions-gh-pages` publishes the `public/` directory
3. GitHub Pages serves the apex host `https://gordonburgett.net` (`static/CNAME`)

`baseURL` in `config.yml` is `https://gordonburgett.net/`. Canonical URLs, Open Graph, the sitemap, JSON-LD, and the Sitemap line in robots.txt all follow it.

A Dockerfile from an older Apache setup is still in the repo. It is not how the site is deployed.

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
- `layouts/index.html` - Home page (hero, proof, about, reading, FAQ, contact)
- `layouts/partials/gb_header.html` - Redesign header. `header.html` switches between this and the classic PaperMod header
- `layouts/partials/gb_footer.html` - Redesign footer, including the link to https://dfwfractionalfde.com
- `layouts/partials/extend_head.html` - Fonts for redesign pages, Search Console verification, Person JSON-LD, noindex for unlisted posts. Open Graph and Twitter cards are not emitted here
- `layouts/partials/templates/opengraph.html` and `twitter_cards.html` - The only Open Graph and Twitter tags
- `layouts/partials/page_description.html` - Meta description: front matter `description`, then `quote`, then a shortened summary
- `layouts/posts/single.html` and `layouts/projects/single.html` - Article pages via `gb_article.html`
- `layouts/albania/single.html` - Albania journal pages, including the only Plausible snippet

**Custom Sections on Homepage:**
1. Hero (name, fractional AI engineer, who the work is for)
2. How I think about this
3. Proof (linked case studies)
4. About
5. What I'm reading
6. FAQ (the visible questions and the FAQPage JSON-LD come from the same `$faqs` slice)
7. Contact

`layouts/partials/sections/capabilities.html` and `sections/projects.html` are leftovers from an older home page. The current home page does not render them.

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
- `baseURL` - `https://gordonburgett.net/`
- `title` and `params.description` - Home page title and meta description
- `params.title` - Short site name used on inner page titles (`Page | Gordon Burgett`)
- `params.schema.sameAs` - Absolute profile URLs for the home Organization JSON-LD. Do not put relative paths here
- `params.homeInfoParams` - Older home bio, kept for the classic list layout
- `params.socialIcons` - GitHub, LinkedIn, and the contact page
- `params.fuseOpts` - Client-side search configuration
- `languages.en.menu.main` - Navigation menu items

**Search:** Uses Fuse.js for client-side search with JSON index output.

**Analytics:** Plausible (`https://plausible.io/js/script.js`, `data-domain="gordonburgett.net"`) is loaded only in `layouts/albania/single.html`. Home, posts, projects, and the other sections do not load it. `layouts/partials/google_analytics.html` is intentionally empty.

**SEO files:**
- `static/llms.txt` - Plain-text summary for answer engines (who Gordon is, what he offers, key pages)
- `enableRobotsTXT: true` - Generated robots.txt allows all crawlers, including AI crawlers, and points at the sitemap
- Home FAQ JSON-LD is `layouts/partials/schema_faq.html`, called with the same slice the FAQ renders
- Person JSON-LD is `layouts/partials/schema_person.html`

## Common Patterns

### Adding a New Project

1. Create project file: `hugo new projects/project-name.md`
2. Add a project image to `static/images/projects/`
3. Include badges and links in front matter
4. The home page proof block is a fixed list in `layouts/index.html`. Add the page there if it should show on the home page

### Adding a New Blog Post

1. Create the post in the right year: `hugo new posts/2026/05_post-name.md`
2. Set front matter: title, date, Categories, Tags, and a `description` (plain sentence, used as the meta description)
3. Add images to `static/images/YYYY/`
4. Set `draft = false` when ready to publish

### Mobile Navigation

Redesign pages use `layouts/partials/gb_header.html`. The nav collapses at 900px in `assets/css/extended/redesign.css`. Older pages still use `layouts/partials/header_classic.html`, with the overlay menu at 768px in `assets/css/extended/custom.css`.

## Theme Relationship

**Active Theme:** PaperMod (git submodule at `themes/PaperMod`)

**Legacy Themes:** hugo-profile, hugo-uno (not in use, but available as submodules)

The site overrides theme templates by placing files in `layouts/` with matching paths. Hugo prioritizes project layouts over theme layouts, allowing selective customization while maintaining theme updates.

## Important Notes

- Avoid em-dashes in content - use regular dashes or rewrite (user preference)
- Redesign pages use near-black `#14171a` and teal `#1c5f63`. LinkedIn blue (`#0077b5`) remains in the older custom CSS
- Images should be organized by year in `static/images/YYYY/`
- All new posts should follow the TOML front matter format with `+++` delimiters
- Draft posts require `draft = true` and will only show with `hugo server -D`
- avoid em-dashes, use warm personal style in all blog posts.  Make posts punchy but avoid LinkedIn-speak