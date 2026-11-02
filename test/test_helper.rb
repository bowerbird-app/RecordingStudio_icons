# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require_relative "simplecov_helper"
require "minitest/autorun"
require "rails"
require "recording_studio_icons"

module IsolatedIconRegistry
  def setup
    @original_icon_registry = RecordingStudioIcons.instance_variable_get(:@registry)
    RecordingStudioIcons.instance_variable_set(:@registry, RecordingStudioIcons::Registry.new)
  end

  def teardown
    RecordingStudioIcons.instance_variable_set(:@registry, @original_icon_registry)
  end
end
