#!/bin/bash

# Check for Ruby installation
if ! command -v ruby &> /dev/null; then
  echo "Ruby is not installed. Please install Ruby 3.3.0 before proceeding."
  exit 1
fi

# Check Ruby version
required_ruby_version="3.3.0"
current_ruby_version=$(ruby -v | cut -d " " -f 2)

if [ "$current_ruby_version" != "$required_ruby_version" ]; then
  echo "Ruby version is $current_ruby_version. Please install Ruby $required_ruby_version."
  exit 1
fi

# Check for Bundler installation
if ! gem list bundler -i > /dev/null 2>&1; then
  echo "Bundler is not installed. Installing Bundler..."
  gem install bundler
fi

# Install dependencies
bundle install

echo "Build complete. All dependencies installed."
