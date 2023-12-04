# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# core
gem 'bootsnap', '>= 1.4.2', require: false
gem 'haml-rails', '~> 2.0'
gem 'rgl'
gem 'pg'
gem 'puma'
gem 'nilify_blanks', '~> 1.4'
gem 'rails', '~> 7.0'
gem 'oj', '~> 3.10'
gem 'pry-rails', '~> 0.3.9'
gem 'rails-patterns'
gem 'friendly_id', '~> 5.5.0'
gem 'view_component'
gem 'jwt'
gem 'http', '~> 5.0'
gem 'turbo-rails', '~> 1.0'
gem 'liquid', '~> 5.3'
gem 'redis'
gem 'hiredis', '~> 0.6.3'
gem 'mail', '~> 2.8'
gem 'nokogiri', '~> 1.14'
gem 'stringex', '~> 2.8', require: 'stringex_lite'

# functionality
gem 'acts-as-taggable-on', '~> 9.0'
gem 'ipaddress', github: 'ipaddress-gem/ipaddress'
gem 'simple_form', '~> 5.0'
gem 'ancestry'
gem 'paper_trail'
gem 'kaminari'
gem 'naturally', '~> 2.2'

# markdown
gem 'redcarpet'
gem 'rouge'

# auth
gem 'devise'
gem 'omniauth', '~> 2.0'
gem 'omniauth_openid_connect'
gem 'omniauth-rails_csrf_protection'
gem 'pundit'

# frontend
gem 'propshaft'
gem 'vite_rails', '~> 3.0'

# monitoring
gem 'sentry-ruby'
gem 'sentry-rails'

group :development, :test do
  gem 'rubocop-rails_config'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'rails-pg-extras'
  gem 'database_cleaner-active_record'
  gem 'faker', '~> 3.2'
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
