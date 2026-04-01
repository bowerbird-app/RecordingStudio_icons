# frozen_string_literal: true

require_relative "hooks"

module RecordingStudioIcons
  class Configuration
    attr_accessor :default_library, :raise_on_missing_renderer, :raise_on_missing_token_mapping
    attr_reader :default_icon_tokens, :override_icon_tokens, :default_icons, :override_icons,
                :icon_token_map, :hooks

    def initialize
      @default_icon_tokens = {}
      @override_icon_tokens = {}
      @default_icons = {}
      @override_icons = {}
      @icon_token_map = {}
      @fallback_icon = nil
      @default_library = :heroicons
      @raise_on_missing_renderer = false
      @raise_on_missing_token_mapping = false
      @hooks = Hooks.new
    end

    def default_icon_token(type, token)
      @default_icon_tokens[normalize_type(type)] = normalize_token(token)
    end

    def override_icon_token(type, token)
      @override_icon_tokens[normalize_type(type)] = normalize_token(token)
    end

    def default_icon(type, icon_reference)
      @default_icons[normalize_type(type)] = normalize_icon_reference(icon_reference)
    end

    def override_icon(type, icon_reference)
      @override_icons[normalize_type(type)] = normalize_icon_reference(icon_reference)
    end

    def map_icon_token(token, icon_reference)
      @icon_token_map[normalize_token(token)] = normalize_icon_reference(icon_reference)
    end

    def fallback_icon=(icon_reference)
      @fallback_icon = normalize_icon_reference(icon_reference)
    end

    def fallback_icon
      @fallback_icon
    end

    def to_h
      {
        default_icon_tokens: default_icon_tokens.dup,
        override_icon_tokens: override_icon_tokens.dup,
        default_icons: default_icons.transform_values(&:to_h),
        override_icons: override_icons.transform_values(&:to_h),
        icon_token_map: icon_token_map.transform_values(&:to_h),
        fallback_icon: fallback_icon&.to_h,
        default_library: default_library,
        raise_on_missing_renderer: raise_on_missing_renderer,
        raise_on_missing_token_mapping: raise_on_missing_token_mapping,
        hooks_registered: hooks.instance_variable_get(:@registry).transform_values(&:size)
      }
    end

    def merge!(hash)
      return unless hash.respond_to?(:each)

      hash.each do |key, value|
        case key.to_s
        when "default_icon_tokens"
          merge_type_map(value) { |type, token| default_icon_token(type, token) }
        when "override_icon_tokens"
          merge_type_map(value) { |type, token| override_icon_token(type, token) }
        when "default_icons"
          merge_type_map(value) { |type, icon| default_icon(type, icon) }
        when "override_icons"
          merge_type_map(value) { |type, icon| override_icon(type, icon) }
        when "icon_token_map"
          merge_type_map(value) { |token, icon| map_icon_token(token, icon) }
        when "fallback_icon"
          self.fallback_icon = value
        else
          setter = "#{key}="
          public_send(setter, value) if respond_to?(setter)
        end
      end
    end

    private

    def merge_type_map(hash)
      return unless hash.respond_to?(:each)

      hash.each do |key, value|
        yield(key, value)
      end
    end

    def normalize_icon_reference(icon_reference)
      IconReference.normalize(icon_reference, default_library: default_library)
    end

    def normalize_token(token)
      token.to_sym
    end

    def normalize_type(type)
      TypeNormalizer.call(type)
    end
  end
end
