# frozen_string_literal: true

module RecordingStudioIcons
  # Hook system for extending engine behavior from host applications.
  #
  # @example Registering hooks
  #   RecordingStudioIcons.configuration.hooks.after_initialize do
  #     Rails.logger.info "RecordingStudioIcons initialized!"
  #   end
  #
  # @example Running hooks
  #   RecordingStudioIcons::Hooks.run(:after_initialize)
  #
  class Hooks
    class HookError < StandardError; end

    DEFAULT_PRIORITY = 100
    EMPTY_LIST = [].freeze

    attr_accessor :raise_on_error

    def initialize
      @registry = {}.freeze
      @raise_on_error = false
      @mutex = Mutex.new
    end

    def before_initialize(handler = nil, priority: DEFAULT_PRIORITY, &)
      register(:before_initialize, handler, priority: priority, &)
    end

    def after_initialize(handler = nil, priority: DEFAULT_PRIORITY, &)
      register(:after_initialize, handler, priority: priority, &)
    end

    def on_configuration(handler = nil, priority: DEFAULT_PRIORITY, &)
      register(:on_configuration, handler, priority: priority, &)
    end

    def on(event_name, handler = nil, priority: DEFAULT_PRIORITY, &)
      register(event_name, handler, priority: priority, &)
    end

    def run(event_name, *args)
      hooks = @registry.fetch(event_name, EMPTY_LIST)
      results = []

      hooks.each do |hook|
        result = execute_hook(hook[:handler], *args)
        results << result
      rescue StandardError => e
        handle_hook_error(e, event_name, hook)
      end

      results
    end

    def registered?(event_name)
      @registry.fetch(event_name, EMPTY_LIST).any?
    end

    def counts
      @registry.transform_values(&:size)
    end

    def clear!
      @mutex.synchronize do
        @registry = {}.freeze
      end
    end

    def clear(event_name)
      @mutex.synchronize do
        next_registry = @registry.dup
        next_registry.delete(event_name)
        @registry = next_registry.freeze
      end
    end

    private

    def register(event_name, handler, priority:, &block)
      callable = handler || block
      return unless callable

      @mutex.synchronize do
        current_hooks = @registry.fetch(event_name, EMPTY_LIST)
        next_hooks =
          (current_hooks + [{ handler: callable, priority: priority }.freeze]).sort_by { |hook| hook[:priority] }.freeze
        @registry = @registry.merge(event_name => next_hooks.freeze).freeze
      end
    end

    def execute_hook(handler, *)
      if handler.respond_to?(:call)
        handler.call(*)
      elsif handler.respond_to?(:to_proc)
        handler.to_proc.call(*)
      end
    end

    def handle_hook_error(error, event_name, hook)
      raise HookError, "Hook failed for #{event_name}: #{error.message}" if @raise_on_error

      log_hook_error(error, event_name, hook)
    end

    def log_hook_error(error, event_name, _hook)
      return unless defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger

      Rails.logger.error "[RecordingStudioIcons::Hooks] Error in #{event_name} hook: #{error.message}"
      Rails.logger.error error.backtrace.first(5).join("\n") if error.backtrace
    end

    class << self
      def run(event_name, *)
        RecordingStudioIcons.configuration.hooks.run(event_name, *)
      end
    end
  end
end
