# frozen_string_literal: true

require "test_helper"

class EngineTest < Minitest::Test
  def setup
    @original_configuration = RecordingStudioIcons.instance_variable_get(:@configuration)
    RecordingStudioIcons.instance_variable_set(:@configuration, RecordingStudioIcons::Configuration.new)
  end

  def teardown
    RecordingStudioIcons.configuration.hooks.clear!
    RecordingStudioIcons.instance_variable_set(:@configuration, @original_configuration)
  end

  def test_before_and_after_initialize_initializers_run_hooks
    before_called = false
    after_called = false

    RecordingStudioIcons.configuration.hooks.before_initialize { |_engine| before_called = true }
    RecordingStudioIcons.configuration.hooks.after_initialize { |_engine| after_called = true }

    find_initializer("recording_studio_icons.before_initialize").block.call(Object.new)
    find_initializer("recording_studio_icons.after_initialize").block.call(Object.new)

    assert before_called
    assert after_called
  end

  def test_load_config_merges_config_sources_and_runs_on_configuration_hook
    hook_called = false
    hook_payload = nil
    RecordingStudioIcons.configuration.hooks.on_configuration do |cfg|
      hook_called = true
      hook_payload = cfg
    end

    xcfg = Struct.new(:recording_studio_icons).new({ default_library: :custom })
    app_config = Struct.new(:x).new(xcfg)
    app = Struct.new(:config) do
      def config_for(_name)
        {
          default_icon_tokens: { "Workspace" => :workspace },
          icon_token_map: { workspace: { library: :heroicons, name: "folder", variant: :outline } }
        }
      end
    end.new(app_config)

    find_initializer("recording_studio_icons.load_config").block.call(app)

    assert hook_called
    assert_equal RecordingStudioIcons.configuration, hook_payload
    assert_equal :custom, RecordingStudioIcons.configuration.default_library
    assert_equal :workspace, RecordingStudioIcons.configuration.default_icon_tokens["Workspace"]
    assert_equal "folder", RecordingStudioIcons.configuration.icon_token_map[:workspace].name
  end

  def test_load_config_handles_errors_and_each_pair_fallback
    pair_config = Class.new do
      def each_pair
        yield(:raise_on_missing_renderer, true)
      end
    end.new

    xcfg = Struct.new(:recording_studio_icons).new(pair_config)
    app_config = Struct.new(:x).new(xcfg)

    app = Struct.new(:config) do
      def config_for(_name)
        raise "missing file"
      end
    end.new(app_config)

    find_initializer("recording_studio_icons.load_config").block.call(app)

    assert_equal true, RecordingStudioIcons.configuration.raise_on_missing_renderer
  end

  private

  def find_initializer(name)
    RecordingStudioIcons::Engine.initializers.find { |initializer| initializer.name == name }
  end
end
