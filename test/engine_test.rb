# frozen_string_literal: true

require "test_helper"

class EngineTest < Minitest::Test
  def setup
    @original_registry = RecordingStudioIcons.instance_variable_get(:@registry)
    RecordingStudioIcons.instance_variable_set(:@registry, RecordingStudioIcons::Registry.new)
  end

  def teardown
    RecordingStudioIcons.configuration.hooks.clear!
    RecordingStudioIcons.instance_variable_set(:@registry, @original_registry)
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

  ConfigStub = Struct.new(:recording_studio_icons)

  def test_load_config_merges_initializer_source_and_runs_on_configuration_hook
    hook_called = false
    hook_payload = nil
    RecordingStudioIcons.configuration.hooks.on_configuration do |cfg|
      hook_called = true
      hook_payload = cfg
    end

    app = Struct.new(:config).new(
      ConfigStub.new(
        {
          default_library: :custom,
          default_icons: { "Workspace" => { library: :heroicons, name: "folder", variant: :outline } }
        }
      )
    )

    find_initializer("recording_studio_icons.load_config").block.call(app)

    assert hook_called
    assert_equal RecordingStudioIcons.configuration, hook_payload
    assert_equal :custom, RecordingStudioIcons.configuration.default_library
    assert_equal "folder", RecordingStudioIcons.configuration.default_icons["Workspace"].name
  end

  def test_load_config_is_noop_when_initializer_config_is_absent
    app = Struct.new(:config).new(Object.new)

    find_initializer("recording_studio_icons.load_config").block.call(app)

    assert_equal false, RecordingStudioIcons.configuration.raise_on_missing_renderer
  end

  private

  def find_initializer(name)
    RecordingStudioIcons::Engine.initializers.find { |initializer| initializer.name == name }
  end
end
