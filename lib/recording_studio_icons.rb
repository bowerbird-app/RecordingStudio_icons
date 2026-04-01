# frozen_string_literal: true

require "recording_studio_icons/version"
require "recording_studio_icons/errors"
require "recording_studio_icons/type_normalizer"
require "recording_studio_icons/icon_reference"
require "recording_studio_icons/resolution_result"
require "recording_studio_icons/renderer_registry"
require "recording_studio_icons/renderers/heroicons"
require "recording_studio_icons/hooks"
require "recording_studio_icons/configuration"
require "recording_studio_icons/engine"

module RecordingStudioIcons
  PRECEDENCE = %i[
    override_icon
    override_icon_token
    default_icon
    default_icon_token
    fallback
    none
  ].freeze

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration) if block_given?
    end

    def reset_configuration!
      @configuration = Configuration.new
    end

    def renderer_registry
      @renderer_registry ||= RendererRegistry.new
    end

    def reset_renderers!
      @renderer_registry = RendererRegistry.new
      register_renderer(:heroicons, Renderers::Heroicons)
    end

    def register_default_icon(type, icon_reference)
      configuration.default_icon(type, icon_reference)
    end

    def register_override_icon(type, icon_reference)
      configuration.override_icon(type, icon_reference)
    end

    def register_default_icon_token(type, token)
      configuration.default_icon_token(type, token)
    end

    def register_override_icon_token(type, token)
      configuration.override_icon_token(type, token)
    end

    def map_icon_token(token, icon_reference)
      configuration.map_icon_token(token, icon_reference)
    end

    def register_renderer(library, renderer)
      renderer_registry.register(library, renderer)
    end

    def resolve_icon(recordable_or_type)
      resolve_icon_details(recordable_or_type).icon
    end

    def icon_for_type(type)
      resolve_icon(type)
    end

    def resolve_icon_details(recordable_or_type)
      type_name = normalize_type(recordable_or_type)

      icon = configuration.override_icons[type_name]
      return ResolutionResult.new(type_name: type_name, icon: icon, source: :override_icon) if icon

      token = configuration.override_icon_tokens[type_name]
      mapped = resolve_token(token)
      return ResolutionResult.new(type_name: type_name, icon: mapped, source: :override_icon_token, token: token) if token && mapped

      icon = configuration.default_icons[type_name]
      return ResolutionResult.new(type_name: type_name, icon: icon, source: :default_icon) if icon

      token = configuration.default_icon_tokens[type_name]
      mapped = resolve_token(token)
      return ResolutionResult.new(type_name: type_name, icon: mapped, source: :default_icon_token, token: token) if token && mapped

      return ResolutionResult.new(type_name: type_name, icon: configuration.fallback_icon, source: :fallback) if configuration.fallback_icon

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
      IconReference.normalize(icon_reference, default_library: configuration.default_library)
    end

    def normalize_type(recordable_or_type)
      TypeNormalizer.call(recordable_or_type)
    end

    private

    def resolve_token(token)
      return if token.nil?

      mapped = configuration.icon_token_map[token.to_sym]
      if mapped.nil? && configuration.raise_on_missing_token_mapping
        raise MissingTokenMappingError, "No icon mapping registered for token #{token.inspect}"
      end

      mapped
    end
  end

  reset_renderers!
end
