# frozen_string_literal: true

require "test_helper"

class HooksTest < Minitest::Test
  ToProcOnlyHandler = Struct.new(:callback) do
    def to_proc
      callback
    end
  end

  NonCallableHandler = Class.new

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

  def test_on_configuration_registration
    called = false

    @hooks.on_configuration { called = true }

    assert @hooks.registered?(:on_configuration)
    @hooks.run(:on_configuration)
    assert called
  end

  def test_raise_on_error_raises_hook_error
    @hooks.raise_on_error = true
    @hooks.after_initialize { raise "test error" }

    assert_raises(RecordingStudioIcons::Hooks::HookError) do
      @hooks.run(:after_initialize)
    end
  end

  def test_class_run_dispatches_custom_events
    called = false
    RecordingStudioIcons.configuration.hooks.on(:custom_event) { called = true }

    RecordingStudioIcons::Hooks.run(:custom_event)

    assert called
  ensure
    RecordingStudioIcons.configuration.hooks.clear!
  end

  def test_custom_event_registration
    seen_values = []

    @hooks.on(:custom_event) { |value| seen_values << value }

    @hooks.run(:custom_event, "value")

    assert_equal ["value"], seen_values
  end

  def test_registration_without_handler_or_block_is_a_noop
    @hooks.on(:custom_event)

    refute @hooks.registered?(:custom_event)
  end

  def test_clear_removes_only_the_requested_event
    @hooks.before_initialize { :before }
    @hooks.after_initialize { :after }

    @hooks.clear(:before_initialize)

    refute @hooks.registered?(:before_initialize)
    assert @hooks.registered?(:after_initialize)
  end

  def test_run_returns_empty_array_when_no_hooks_are_registered
    assert_equal [], @hooks.run(:missing_event)
  end

  def test_hook_errors_are_swallowed_when_raise_on_error_is_false
    logger = Class.new do
      attr_reader :messages

      def initialize
        @messages = []
      end

      def error(message)
        @messages << message
      end
    end.new

    @hooks.after_initialize { raise "soft failure" }

    Rails.stub(:logger, logger) do
      assert_equal [], @hooks.run(:after_initialize)
    end

    assert(logger.messages.any? { |message| message.include?("soft failure") })
  end

  def test_handler_objects_that_only_define_to_proc_are_supported
    handler = ToProcOnlyHandler.new(proc(&:upcase))

    @hooks.on(:custom_event, handler)

    assert_equal ["VALUE"], @hooks.run(:custom_event, "value")
  end

  def test_non_callable_handler_objects_return_nil_results
    @hooks.on(:custom_event, NonCallableHandler.new)

    assert_equal [nil], @hooks.run(:custom_event, "value")
  end

  def test_hook_errors_are_swallowed_when_logger_is_unavailable
    @hooks.after_initialize { raise "soft failure" }

    Rails.stub(:logger, nil) do
      assert_equal [], @hooks.run(:after_initialize)
    end
  end
end
