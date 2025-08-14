ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

# Explicitly require logger to fix Ruby 3.3.5 compatibility
require 'logger'

require 'bundler/setup' # Set up gems listed in the Gemfile.
