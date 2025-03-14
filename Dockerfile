# Use official Ruby base image
FROM ruby:3.1-slim AS builder

# Install essential Linux packages
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Create a non-root user
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN addgroup --gid $GROUP_ID jekyll && \
    adduser --uid $USER_ID --gid $GROUP_ID --disabled-password --gecos "" jekyll && \
    chown -R jekyll:jekyll /app

# Switch to non-root user
USER jekyll

# Copy Gemfile first for caching
COPY --chown=jekyll:jekyll Gemfile* ./

# Install dependencies
RUN bundle install

# Copy the rest of the application
COPY --chown=jekyll:jekyll . .

# Expose port for local development
EXPOSE 4000

# Allow override of command in CI/CD
ENTRYPOINT [ "bundle", "exec", "jekyll" ]
CMD ["serve", "--host", "0.0.0.0", "--force_polling"]
