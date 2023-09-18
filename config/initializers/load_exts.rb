# frozen_string_literal: true

require 'ipaddress_extension'
require 'version_number_loader'

VersionNumberLoader.new.start

# needs to be manually loaded for some reason
if Rails.env.development?
  require 'paper_trail/version'
end
