# frozen_string_literal: true

module RecordingStudioIcons
  # Hook system for extending engine behavior from host applications.
  #
  # This module provides a registry for lifecycle hooks, service hooks,
  # and extension points that allow host applications to customize
  # engine behavior without modifying source code.
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
    # Error raised when a hook fails and raise_on_error is enabled
    class HookError < StandardError; end

    # Default priority for hooks (lower runs first)
    DEFAULT_PRIORITY = 100
    EMPTY_LIST = [].freeze

    attr_accessor :raise_on_error

    def initialize
      @registry = {}.freeze
      @model_extensions = {}.freeze
      @controller_extensions = {}.freeze
      @raise_on_error = false
      @mutex = Mutex.new
    end

    # Register a before_initialize hook
    #
    # @param handler [#call] An object that responds to `call`
    # @param priority [Integer] Hook priority (lower runs first)
    # @yield Block to execute
    def before_initialize(handler = nil, priority: DEFAULT_PRIORITY, &)
      register(:before_initialize, handler, priority: priority, &)
    end

    # Register an after_initialize hook
    #
    # @param handler [#call] An object that responds to `call`
    # @param priority [Integer] Hook priority (lower runs first)
    # @yield Block to execute
    def after_initialize(handler = nil, priority: DEFAULT_PRIORITY, &)
      register(:after_initialize, handler, priority: priority, &)
    end

    # Register an on_configuration hook
    #
    # @param handler [#call] An object that responds to `call`
    # @param priority [Integer] Hook priority (lower runs first)
    # @yield Block to execute
    def on_configuration(handler = nil, priority: DEFAULT_PRIORITY, &)
      register(:on_configuration, handler, priority: priority, &)
    end

    # Register a before_service hook
    #
    # @param handler [#call] An object that responds to `call`
    # @param priority [Integer] Hook priority (lower runs first)
    # @yield [service_class, args] Block receives service class and arguments
    def before_service(handler = nil, priority: DEFAULT_PRIORITY, &)
      register(:before_service, handler, priority: priority, &)
    end

    # Register an after_service hook
    #
    # @param handler [#call] An object that responds to `call`
    # @param priority [Integer] Hook priority (lower runs first)
    # @yield [service_class, result] Block receives service class and result
    def after_service(handler = nil, priority: DEFAULT_PRIORITY, &)
      register(:after_service, handler, priority: priority, &)
    end

    # Register an around_service hook
    #
    # @param handler [#call] An object that responds to `call`
    # @param priority [Integer] Hook priority (lower runs first)
    # @yield [service, block] Block receives service instance and execution block
    def around_service(handler = nil, priority: DEFAULT_PRIORITY, &)
      register(:around_service, handler, priority: priority, &)
    end

    # Register a custom event hook
    #
    # @param event_name [Symbol] The event name to listen for
    # @param handler [#call] An object that responds to `call`
    # @param priority [Integer] Hook priority (lower runs first)
    # @yield Block to execute when event fires
    def on(event_name, handler = nil, priority: DEFAULT_PRIORITY, &)
      register(event_name, handler, priority: priority, &)
    end

    # Register a model extension
    #
    # @param model_name [Symbol, String] The model name to extend
    # @yield Block containing the extension (included in model class)
    def extend_model(model_name, &block)
      return unless block_given?

      append_extension(:@model_extensions, model_name, block)
    end

    # Register a controller extension
    #
    # @param controller_name [Symbol, String] The controller name to extend
    # @yield Block containing the extension (included in controller class)
    def extend_controller(controller_name, &block)
      return unless block_given?

      append_extension(:@controller_extensions, controller_name, block)
    end

    # Get model extensions for a given model
    #
    # @param model_name [Symbol, String] The model name
    # @return [Array<Proc>] Array of extension blocks
    def model_extensions_for(model_name)
      @model_extensions.fetch(model_name.to_sym, EMPTY_LIST)
    end

    # Get controller extensions for a given controller
    #
    # @param controller_name [Symbol, String] The controller name
    # @return [Array<Proc>] Array of extension blocks
    def controller_extensions_for(controller_name)
      @controller_extensions.fetch(controller_name.to_sym, EMPTY_LIST)
    end

    # Run all hooks for a given event
    #
    # @param event_name [Symbol] The event name
    # @param args [Array] Arguments to pass to hooks
    # @return [Array] Results from all hooks
    def run(event_name, *args)
      hooks = @registry.fetch(event_name, EMPTY_LIST).sort_by { |h| h[:priority] }
      results = []

      hooks.each do |hook|
        result = execute_hook(hook[:handler], *args)
        results << result
      rescue StandardError => e
        handle_hook_error(e, event_name, hook)
      end

      results
    end

    # Run around hooks, wrapping the given block
    #
    # @param event_name [Symbol] The event name (e.g., :around_service)
    # @param context [Object] Context object passed to hooks
    # @yield The block to wrap
    # @return [Object] Result of the wrapped block
    def run_around(event_name, context, &block)
      hooks = @registry.fetch(event_name, EMPTY_LIST).sort_by { |h| h[:priority] }

      if hooks.empty?
        yield
      else
        # Build a chain of around hooks
        chain = hooks.reverse.reduce(block) do |next_block, hook|
          proc { execute_hook(hook[:handler], context, next_block) }
        end
        chain.call
      end
    end

    # Check if any hooks are registered for an event
    #
    # @param event_name [Symbol] The event name
    # @return [Boolean] True if hooks exist
    def registered?(event_name)
      @registry.fetch(event_name, EMPTY_LIST).any?
    end

    def counts
      @registry.transform_values(&:size)
    end

    # Clear all hooks (useful for testing)
    def clear!
      @mutex.synchronize do
        @registry = {}.freeze
        @model_extensions = {}.freeze
        @controller_extensions = {}.freeze
      end
    end

    # Clear hooks for a specific event
    #
    # @param event_name [Symbol] The event name
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
        next_hooks = current_hooks + [{
          handler: callable,
          priority: priority,
          registered_at: Time.now
        }.freeze]
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
      # Run hooks on the global configuration
      #
      # @param event_name [Symbol] The event name
      # @param args [Array] Arguments to pass to hooks
      # @return [Array] Results from all hooks
      def run(event_name, *)
        RecordingStudioIcons.configuration.hooks.run(event_name, *)
      end

      # Run around hooks on the global configuration
      #
      # @param event_name [Symbol] The event name
      # @param context [Object] Context object
      # @yield The block to wrap
      # @return [Object] Result of the wrapped block
      def run_around(event_name, context, &)
        RecordingStudioIcons.configuration.hooks.run_around(event_name, context, &)
      end

      # Trigger a custom event
      #
      # @param event_name [Symbol] The event name
      # @param args [Array] Arguments to pass to hooks
      # @return [Array] Results from all hooks
      def trigger(event_name, *)
        run(event_name, *)
      end
    end

    def append_extension(ivar_name, key, block)
      normalized_key = key.to_sym

      @mutex.synchronize do
        store = instance_variable_get(ivar_name)
        current_extensions = store.fetch(normalized_key, EMPTY_LIST)
        next_store = store.merge(normalized_key => (current_extensions + [block]).freeze)
        instance_variable_set(ivar_name, next_store.freeze)
      end
    end
  end
end
