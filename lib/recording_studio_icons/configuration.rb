# frozen_string_literal: true

require_relative "hooks"

module RecordingStudioIcons
  class Configuration
    VALID_KEYS = %w[
      default_icons
      override_icons
      fallback_icon
      default_library
      default_variant
      raise_on_missing_renderer
    ].freeze

    attr_reader :hooks

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

    def default_library
      @default_library
    end

    def default_library=(library)
      normalized_library = normalize_library(library)

      @mutex.synchronize do
        @default_library = normalized_library
      end
    end

    def default_variant
      @default_variant
    end

    def default_variant=(variant)
      normalized_variant = normalize_variant(variant)

      @mutex.synchronize do
        @default_variant = normalized_variant
      end
    end

    def raise_on_missing_renderer
      @raise_on_missing_renderer
    end

    def raise_on_missing_renderer=(value)
      @mutex.synchronize do
        @raise_on_missing_renderer = !!value
      end
    end

    def default_icons
      @default_icons
    end

    def override_icons
      @override_icons
    end

    def default_icon(type, icon_reference)
      update_map(:@default_icons, normalize_type(type), normalize_icon_reference(icon_reference))
    end

    def override_icon(type, icon_reference)
      update_map(:@override_icons, normalize_type(type), normalize_icon_reference(icon_reference))
    end

    def fallback_icon=(icon_reference)
      @mutex.synchronize do
        @fallback_icon = normalize_icon_reference(icon_reference)
      end
    end

    def fallback_icon
      @fallback_icon
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

      config_hash = normalize_hash(hash)
      validate_keys!(config_hash)

      config_hash.each do |key, value|
        case key.to_s
        when "default_icons"
          merge_type_map(value) { |type, icon| default_icon(type, icon) }
        when "override_icons"
          merge_type_map(value) { |type, icon| override_icon(type, icon) }
        when "fallback_icon"
          self.fallback_icon = value
        when "default_library"
          self.default_library = value
        when "default_variant"
          self.default_variant = value
        when "raise_on_missing_renderer"
          self.raise_on_missing_renderer = value
        else
          raise InvalidConfigurationError, "Unknown configuration key: #{key}"
        end
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

    def merge_type_map(hash)
      normalize_hash(hash).each do |key, value|
        yield(key, value)
      end
    end

    def normalize_hash(hash)
      return hash.to_h if hash.respond_to?(:to_h)

      if hash.respond_to?(:each_pair)
        hash.each_pair.each_with_object({}) do |(key, value), memo|
          memo[key] = value
        end
      elsif hash.respond_to?(:each)
        hash.each_with_object({}) do |(key, value), memo|
          memo[key] = value
        end
      else
        raise InvalidConfigurationError, "Configuration must be hash-like"
      end
    end

    def validate_keys!(config_hash)
      unknown_keys = config_hash.keys.map(&:to_s) - VALID_KEYS
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

    def normalize_type(type)
      TypeNormalizer.call(type)
    end
  end
end
