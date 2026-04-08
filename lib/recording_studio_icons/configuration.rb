# frozen_string_literal: true

require_relative "hooks"

module RecordingStudioIcons
  module ConfigurationHelpers
    VALID_KEYS = %w[
      default_icons override_icons fallback_icon default_library default_variant raise_on_missing_renderer
    ].freeze

    module_function

    def normalize_hash(hash)
      return hash.to_h if hash.respond_to?(:to_h)
      return hash.each_pair.to_h if hash.respond_to?(:each_pair)
      return hash.each.to_h if hash.respond_to?(:each)

      raise InvalidConfigurationError, "Configuration must be hash-like"
    end

    def normalize_library(library)
      raise InvalidConfigurationError, "default_library is required" if library.nil? || library.to_s.strip.empty?

      library.to_sym
    end

    def normalize_variant(variant)
      return nil if variant.nil?

      normalized_variant = variant.to_s.strip
      raise InvalidConfigurationError, "default_variant is required" if normalized_variant.empty?

      normalized_variant.to_sym
    end
  end

  class Configuration
    MAP_MERGERS = { "default_icons" => :default_icon, "override_icons" => :override_icon }.freeze
    ATTRIBUTE_WRITERS = {
      "fallback_icon" => :fallback_icon=, "default_library" => :default_library=,
      "default_variant" => :default_variant=, "raise_on_missing_renderer" => :raise_on_missing_renderer=
    }.freeze

    attr_reader :hooks, :default_library, :default_variant, :raise_on_missing_renderer, :default_icons,
                :override_icons, :fallback_icon

    def initialize
      @default_icons = {}.freeze
      @override_icons = {}.freeze
      @fallback_icon = nil
      @default_library = :heroicons
      @default_variant = nil
      @raise_on_missing_renderer = false
      @hooks = Hooks.new
      @mutex = Mutex.new
    end

    def default_library=(library)
      normalized_library = ConfigurationHelpers.normalize_library(library)

      @mutex.synchronize do
        @default_library = normalized_library
      end
    end

    def default_variant=(variant)
      normalized_variant = ConfigurationHelpers.normalize_variant(variant)

      @mutex.synchronize do
        @default_variant = normalized_variant
      end
    end

    def raise_on_missing_renderer=(value)
      @mutex.synchronize do
        @raise_on_missing_renderer = !!value
      end
    end

    def default_icon(type, icon_reference)
      update_map(:@default_icons, TypeNormalizer.call(type), normalize_icon_reference(icon_reference))
    end

    def override_icon(type, icon_reference)
      update_map(:@override_icons, TypeNormalizer.call(type), normalize_icon_reference(icon_reference))
    end

    def fallback_icon=(icon_reference)
      @mutex.synchronize do
        @fallback_icon = normalize_icon_reference(icon_reference)
      end
    end

    def to_h
      {
        default_icons: default_icons.transform_values(&:to_h),
        override_icons: override_icons.transform_values(&:to_h),
        fallback_icon: fallback_icon&.to_h,
        default_library: default_library,
        default_variant: default_variant,
        raise_on_missing_renderer: raise_on_missing_renderer,
        hooks_registered: hooks.counts
      }
    end

    def merge!(hash)
      return self if hash.nil?

      config_hash = ConfigurationHelpers.normalize_hash(hash)
      validate_keys!(config_hash)

      config_hash.each do |key, value|
        apply_configuration_entry(key.to_s, value)
      end

      self
    end

    private

    def update_map(ivar_name, key, value)
      @mutex.synchronize do
        current = instance_variable_get(ivar_name)
        instance_variable_set(ivar_name, current.merge(key => value).freeze)
      end
    end

    def merge_type_map(hash, &)
      ConfigurationHelpers.normalize_hash(hash).each(&)
    end

    def validate_keys!(config_hash)
      unknown_keys = config_hash.keys.map(&:to_s) - ConfigurationHelpers::VALID_KEYS
      return if unknown_keys.empty?

      raise InvalidConfigurationError, "Unknown configuration keys: #{unknown_keys.join(', ')}"
    end

    def normalize_icon_reference(icon_reference)
      IconReference.normalize(
        icon_reference,
        default_library: default_library,
        default_variant: default_variant
      )
    end

    def apply_configuration_entry(key, value)
      if MAP_MERGERS.key?(key)
        merge_type_map(value) { |type, icon| public_send(MAP_MERGERS.fetch(key), type, icon) }
      else
        public_send(ATTRIBUTE_WRITERS.fetch(key), value)
      end
    end
  end
end
