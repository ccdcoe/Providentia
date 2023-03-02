# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

# core
gem 'bootsnap', '>= 1.4.2', require: false
gem 'haml-rails', '~> 2.0'
gem 'rgl', '~> 0.5.7'
gem 'pg'
gem 'puma', '~> 5.0'
gem 'nilify_blanks', '~> 1.4'
gem 'rails', '~> 7.0'
gem 'oj', '~> 3.10'
gem 'pry-rails', '~> 0.3.9'
gem 'rails-patterns'
gem 'friendly_id', '~> 5.4.0'
gem 'view_component'
gem 'jwt'
gem 'http', '~> 5.0'
gem 'turbo-rails', '~> 1.0'
gem 'liquid', '~> 5.3'

# functionality
gem 'ipaddress', github: 'ipaddress-gem/ipaddress'
gem 'jb', '~> 0.8.0'
gem 'simple_form', '~> 5.0'
gem 'ancestry'
gem 'paper_trail'
gem 'kaminari'
gem 'naturally', '~> 2.2'

# markdown
gem 'redcarpet'
gem 'rouge', '~> 3.30'

# auth
gem 'devise'
gem 'omniauth', '~> 2.0'
gem 'omniauth_openid_connect', github: 'sping/omniauth_openid_connect'
gem 'omniauth-rails_csrf_protection'
gem 'pundit'

# frontend
gem 'propshaft'
gem 'jsbundling-rails', '~> 1.0'
gem 'cssbundling-rails', '~> 1.0'

# monitoring
gem 'sentry-ruby'
gem 'sentry-rails'

group :development, :test do
  gem 'rubocop-rails_config'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rspec-rails', '~> 5.1.0'
  gem 'factory_bot_rails'
end

group :development do
  gem 'listen'
  gem 'web-console', '>= 3.3.0'
  gem 'bullet'
  gem 'rack-mini-profiler'
  # For memory profiling
  gem 'memory_profiler'

  # For call-stack profiling flamegraphs
  gem 'flamegraph'
  gem 'stackprof'
end

group :production do
  gem 'redis'
  gem 'hiredis', '~> 0.6.3'
end
