# frozen_string_literal: true

require_relative "lib/recording_studio_icons/version"

Gem::Specification.new do |spec|
  spec.name        = "recording_studio_icons"
  spec.version     = RecordingStudioIcons::VERSION
  spec.authors     = ["Bowerbird"]
  spec.email       = ["support@bowerbird.app"]
  spec.homepage    = "https://github.com/bowerbird-app/RecordingStudio_icons"
  spec.summary     = "Configuration-driven icon registry addon for RecordingStudio"
  spec.description = "Adds semantic-token and icon-reference based defaults for RecordingStudio recordable types."
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/bowerbird-app/RecordingStudio_icons"
  spec.metadata["changelog_uri"] = "https://github.com/bowerbird-app/RecordingStudio_icons/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.1.0"
  spec.add_dependency "recording_studio", ">= 0"
end
