# frozen_string_literal: true

require "test_helper"

class HooksTest < Minitest::Test
  def setup
    @hooks = RecordingStudioIcons::Hooks.new
  end

  def teardown
    @hooks.clear!
  end

  def test_before_initialize_registration
    called = false
    @hooks.before_initialize { called = true }

    assert @hooks.registered?(:before_initialize)
    @hooks.run(:before_initialize)
    assert called
  end

  def test_hooks_run_in_priority_order
    order = []

    @hooks.after_initialize(priority: 30) { order << 3 }
    @hooks.after_initialize(priority: 10) { order << 1 }
    @hooks.after_initialize(priority: 20) { order << 2 }

    @hooks.run(:after_initialize)

    assert_equal [1, 2, 3], order
  end

  def test_around_hook_wraps_execution
    events = []

    @hooks.around_service do |_service, block|
      events << :before
      result = block.call
      events << :after
      result
    end

    result = @hooks.run_around(:around_service, "service") do
      events << :inside
      "result"
    end

    assert_equal %i[before inside after], events
    assert_equal "result", result
  end

  def test_raise_on_error_raises_hook_error
    @hooks.raise_on_error = true
    @hooks.after_initialize { raise "test error" }

    assert_raises(RecordingStudioIcons::Hooks::HookError) do
      @hooks.run(:after_initialize)
    end
  end

  def test_class_trigger_is_alias_for_run
    called = false
    RecordingStudioIcons.configuration.hooks.on(:custom_event) { called = true }

    RecordingStudioIcons::Hooks.trigger(:custom_event)

    assert called
  ensure
    RecordingStudioIcons.configuration.hooks.clear!
  end
end
