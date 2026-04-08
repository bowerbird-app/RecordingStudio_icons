# frozen_string_literal: true

require "recording_studio_icons/version"
require "recording_studio_icons/errors"
require "recording_studio_icons/type_normalizer"
require "recording_studio_icons/icon_reference"
require "recording_studio_icons/resolution_result"
require "recording_studio_icons/renderer_registry"
require "recording_studio_icons/registry"
require "recording_studio_icons/view_helper"
require "recording_studio_icons/renderers/heroicons"
require "recording_studio_icons/hooks"
require "recording_studio_icons/configuration"
require "recording_studio_icons/engine"

module RecordingStudioIcons
  PRECEDENCE = %i[
    override_icon
    default_icon
    fallback
    none
  ].freeze

  class << self
    def registry
      @registry_mutex ||= Mutex.new
      @registry ||= @registry_mutex.synchronize { @registry ||= Registry.new }
    end

    def configuration
      registry.configuration
    end

    def configure(&)
      return configuration unless block_given?

      registry.configure(&)
    end

    def reset_configuration!
      registry.reset_configuration!
    end

    def renderer_registry
      registry.renderer_registry
    end

    def reset_renderers!
      registry.reset_renderers!
    end

    def register_default_icon(type, icon_reference)
      registry.register_default_icon(type, icon_reference)
    end

    def register_override_icon(type, icon_reference)
      registry.register_override_icon(type, icon_reference)
    end

    def register_renderer(library, renderer)
      registry.register_renderer(library, renderer)
    end

    def resolve_icon(recordable_or_type)
      registry.resolve_icon(recordable_or_type)
    end

    def icon_for_type(type)
      resolve_icon(type)
    end

    def resolve_icon_details(recordable_or_type)
      registry.resolve_icon_details(recordable_or_type)
    end

    def render_icon(view_context, recordable_or_type, **)
      registry.render_icon(view_context, recordable_or_type, **)
    end

    def normalize_icon_reference(icon_reference)
      registry.normalize_icon_reference(icon_reference)
    end

    def normalize_type(recordable_or_type)
      registry.normalize_type(recordable_or_type)
    end
  end

  registry
end
