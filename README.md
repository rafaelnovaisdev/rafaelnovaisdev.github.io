# Rafael Novais - Personal Website & Blog

[![GitHub Pages](https://img.shields.io/badge/Hosted%20on-GitHub%20Pages-blue?logo=github)](https://rafaelnovais.dev)
[![Jekyll](https://img.shields.io/badge/Built%20with-Jekyll-cc0000?logo=jekyll)](https://jekyllrb.com/)

## 🚀 Quick Start

### Prerequisites

- [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/)
- (Optional) Ruby 3.1.2+ and Bundler for local development

### Local Development with Docker (Recommended)

```bash
# Clone the repository
git clone https://github.com/rafaelnovaisdev/rafaelnovaisdev.github.io.git
cd rafaelnovaisdev.github.io

# Start the development server
docker-compose up --build

# Access the site at http://localhost:4000
```

### Local Development with Ruby

```bash
# Install dependencies
bundle install

# Start the development server
bundle exec jekyll serve --livereload
```

## 📁 Project Structure

```
.
├── _data/            # Site data and configuration
├── _includes/        # Reusable components
├── _layouts/         # Page templates
├── _posts/           # Blog posts (YYYY-MM-DD-title.md)
├── _projects/        # Project pages (XXXX-project-name.md)
├── _sass/            # SCSS styles
├── assets/           # Static files (CSS, JS, images)
├── favicon_io_images # Favicon assets
├── terraform/        # Infrastructure as Code
├── _config.yml       # Site configuration
└── docker-compose.yml # Docker development setup
```

## 📝 Content Management

### Adding a New Blog Post

1. Create a new markdown file in `_posts/` with the format: `YYYY-MM-DD-title.md`
2. Add front matter:
   ```yaml
   ---
   layout: post
   title: "Your Post Title"
   date: YYYY-MM-DD HH:MM:SS +0000
   categories: [category1, category2]
   tags: [tag1, tag2]
   ---
   ```

### Adding a New Project

1. Create a new markdown file in `_projects/` with the format: `XXXX-project-name.md`
2. Add front matter:
   ```yaml
   ---
   layout: project
   title: "Project Name"
   category: project
   project_number: "XXXX"
   start_date: YYYY-MM-DD
   last_updated: YYYY-MM-DD
   status: "In Progress"  # Planning, In Progress, On Hold, Completed, Archived
   tech_stack: ["Tech 1", "Tech 2"]
   github_url: "https://github.com/username/repo"
   ---
   ```

## �️ Project Status System

- **Planning**: Initial idea/planning phase
- **In Progress**: Actively being worked on
- **On Hold**: Paused, but will resume later
- **Completed**: Finished and delivered
- **Archived**: No longer maintained

## �🚀 Deployment

The site is automatically deployed to GitHub Pages on push to the `main` branch.

## � Project Analysis

### What's Included

- **Infrastructure**:
  - Docker configuration for consistent development
  - Terraform setup for infrastructure management
  - GitHub Actions for CI/CD

- **Features**:
  - Responsive design with mobile support
  - Project showcase with status tracking
  - Blog functionality with categories and tags
  - SEO optimization
  - Syntax highlighting for code blocks

### Potential Improvements

1. **Testing**: Add automated tests for templates and content
2. **Performance**: Implement image optimization pipeline
3. **Analytics**: Add privacy-focused analytics (e.g., Plausible)
4. **Search**: Add client-side search functionality
5. **Comments**: Consider adding comments system (e.g., giscus)

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- Built with [Jekyll](https://jekyllrb.com/)
- Theme: Custom based on no-style-please
- Icons: [Font Awesome](https://fontawesome.com/)
