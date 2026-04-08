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
      default_variant: :solid,
      default_icons: { DummyType => { library: :heroicons, name: "document-text", variant: :outline } },
      override_icons: { "Workspace" => { library: :custom, name: "workspace" } },
      fallback_icon: { library: :custom, name: "fallback" },
      raise_on_missing_renderer: true
    )

    assert_equal :custom, @configuration.default_library
    assert_equal :solid, @configuration.default_variant
    assert_equal :heroicons, @configuration.default_icons[DummyType.name].library
    assert_equal "workspace", @configuration.override_icons["Workspace"].name
    assert_equal "fallback", @configuration.fallback_icon.name
    assert_equal true, @configuration.raise_on_missing_renderer
  end

  def test_merge_rejects_unknown_keys
    assert_raises(RecordingStudioIcons::InvalidConfigurationError) do
      @configuration.merge!(unknown_key: "ignored")
    end
  end

  def test_merge_with_non_enumerable_is_noop
    original = @configuration.to_h

    @configuration.merge!(nil)

    assert_equal original[:default_library], @configuration.default_library
    assert_equal original[:default_icons], @configuration.to_h[:default_icons]
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

  def test_merge_accepts_each_pair_hash_like_values
    hash_like = Class.new do
      def each_pair(&block)
        return enum_for(:each_pair) unless block

        block.call(:default_library, :custom)
        block.call(:default_variant, :solid)
        block.call(:raise_on_missing_renderer, true)
      end
    end.new

    @configuration.merge!(hash_like)

    assert_equal :custom, @configuration.default_library
    assert_equal :solid, @configuration.default_variant
    assert_equal true, @configuration.raise_on_missing_renderer
  end

  def test_merge_accepts_each_enumerables
    @configuration.merge!([[:default_library, :custom], [:default_variant, :solid]])

    assert_equal :custom, @configuration.default_library
    assert_equal :solid, @configuration.default_variant
  end

  def test_merge_rejects_non_hash_like_values
    assert_raises(RecordingStudioIcons::InvalidConfigurationError) do
      @configuration.merge!("invalid")
    end
  end

  def test_default_library_rejects_blank_values
    assert_raises(RecordingStudioIcons::InvalidConfigurationError) do
      @configuration.default_library = "  "
    end
  end

  def test_default_variant_rejects_blank_values
    assert_raises(RecordingStudioIcons::InvalidConfigurationError) do
      @configuration.default_variant = "  "
    end
  end

  def test_default_variant_applies_to_shorthand_icon_references
    @configuration.default_library = :heroicons
    @configuration.default_variant = :solid

    @configuration.override_icon("Page", :star)

    result = @configuration.override_icons.fetch("Page")

    assert_equal :heroicons, result.library
    assert_equal :solid, result.variant
  end

  def test_to_h_includes_fallback_icon_when_present
    @configuration.fallback_icon = { library: :heroicons, name: "folder", variant: :outline }

    result = @configuration.to_h

    assert_equal "folder", result.fetch(:fallback_icon).fetch(:name)
  end
end
