# frozen_string_literal: true

module RecordingStudioIcons
  class Registry
    attr_reader :configuration, :renderer_registry

    def initialize(configuration: Configuration.new, renderer_registry: RendererRegistry.new)
      @mutex = Mutex.new
      @configuration = configuration
      @renderer_registry = renderer_registry
      register_builtin_renderers
    end

    def configure
      yield(configuration) if block_given?
      configuration
    end

    def reset_configuration!
      @mutex.synchronize do
        @configuration = Configuration.new
      end
    end

    def reset_renderers!
      @mutex.synchronize do
        @renderer_registry = RendererRegistry.new
        register_builtin_renderers
      end
    end

    def register_default_icon(type, icon_reference)
      configuration.default_icon(type, icon_reference)
    end

    def register_override_icon(type, icon_reference)
      configuration.override_icon(type, icon_reference)
    end

    def register_renderer(library, renderer)
      renderer_registry.register(library, renderer)
    end

    def resolve_icon(recordable_or_type)
      resolve_icon_details(recordable_or_type).icon
    end

    def resolve_icon_details(recordable_or_type)
      type_name = normalize_type(recordable_or_type)

      icon = configuration.override_icons[type_name]
      return ResolutionResult.new(type_name: type_name, icon: icon, source: :override_icon) if icon

      icon = configuration.default_icons[type_name]
      return ResolutionResult.new(type_name: type_name, icon: icon, source: :default_icon) if icon

      fallback_icon = configuration.fallback_icon
      return ResolutionResult.new(type_name: type_name, icon: fallback_icon, source: :fallback) if fallback_icon

      ResolutionResult.new(type_name: type_name, icon: nil, source: :none)
    end

    def render_icon(view_context, recordable_or_type, **options)
      icon_reference = resolve_icon(recordable_or_type)
      return nil unless icon_reference

      renderer = renderer_registry.fetch(icon_reference.library)
      if renderer.nil?
        raise MissingRendererError, "No renderer registered for #{icon_reference.library.inspect}" if configuration.raise_on_missing_renderer

        return nil
      end

      renderer.render(view_context, icon_reference, **options)
    end

    def normalize_icon_reference(icon_reference)
      IconReference.normalize(
        icon_reference,
        default_library: configuration.default_library,
        default_variant: configuration.default_variant
      )
    end

    def normalize_type(recordable_or_type)
      TypeNormalizer.call(recordable_or_type)
    end

    private

    def register_builtin_renderers
      @renderer_registry.register(:heroicons, Renderers::Heroicons)
    end
  end
end