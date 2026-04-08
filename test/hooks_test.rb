# frozen_string_literal: true

require "test_helper"

class HooksTest < Minitest::Test
  ToProcOnlyHandler = Struct.new(:callback) do
    def to_proc
      callback
    end
  end

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

  def test_extend_model_and_controller_store_registered_blocks
    model_extension = proc { :model_extension }
    controller_extension = proc { :controller_extension }

    @hooks.extend_model(:workspace, &model_extension)
    @hooks.extend_controller("pages", &controller_extension)

    assert_equal [model_extension], @hooks.model_extensions_for("workspace")
    assert_equal [controller_extension], @hooks.controller_extensions_for(:pages)
  end

  def test_unknown_extensions_return_empty_lists
    assert_equal [], @hooks.model_extensions_for(:missing_model)
    assert_equal [], @hooks.controller_extensions_for(:missing_controller)
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

  def test_run_around_without_hooks_yields_directly
    result = @hooks.run_around(:missing_around, :context) { "direct result" }

    assert_equal "direct result", result
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

    assert logger.messages.any? { |message| message.include?("soft failure") }
  end

  def test_handler_objects_that_only_define_to_proc_are_supported
    handler = ToProcOnlyHandler.new(proc { |value| value.upcase })

    @hooks.on(:custom_event, handler)

    assert_equal ["VALUE"], @hooks.run(:custom_event, "value")
  end
end
