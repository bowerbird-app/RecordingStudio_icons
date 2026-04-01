# frozen_string_literal: true

require "test_helper"

class ConfigurationTest < Minitest::Test
  DummyType = Class.new

  def setup
    @configuration = RecordingStudioIcons::Configuration.new
  end

  def test_merge_updates_known_attributes_and_maps
    @configuration.merge!(
      default_library: :custom,
      default_icon_tokens: { "Workspace" => :workspace },
      default_icons: { DummyType => { library: :heroicons, name: "document-text", variant: :outline } },
      icon_token_map: { workspace: { library: :custom, name: "workspace-default" } },
      fallback_icon: { library: :custom, name: "fallback" },
      raise_on_missing_renderer: true
    )

    assert_equal :custom, @configuration.default_library
    assert_equal :workspace, @configuration.default_icon_tokens["Workspace"]
    assert_equal :heroicons, @configuration.default_icons[DummyType.name].library
    assert_equal "workspace-default", @configuration.icon_token_map[:workspace].name
    assert_equal "fallback", @configuration.fallback_icon.name
    assert_equal true, @configuration.raise_on_missing_renderer
  end

  def test_merge_ignores_unknown_keys
    @configuration.merge!(unknown_key: "ignored")

    refute_respond_to @configuration, :unknown_key
  end

  def test_merge_with_non_enumerable_is_noop
    original = @configuration.to_h

    @configuration.merge!(nil)

    assert_equal original[:default_library], @configuration.default_library
    assert_equal original[:default_icon_tokens], @configuration.default_icon_tokens
  end

  def test_to_h_reports_registered_hook_counts
    @configuration.hooks.before_initialize { nil }
    @configuration.hooks.before_initialize { nil }
    @configuration.hooks.after_initialize { nil }

    result = @configuration.to_h

    assert_equal 2, result.fetch(:hooks_registered).fetch(:before_initialize)
    assert_equal 1, result.fetch(:hooks_registered).fetch(:after_initialize)
  end

  def test_configure_without_block_is_safe
    RecordingStudioIcons.configure

    assert_kind_of RecordingStudioIcons::Configuration, RecordingStudioIcons.configuration
  end
end
