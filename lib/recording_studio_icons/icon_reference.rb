# frozen_string_literal: true

module RecordingStudioIcons
  class IconReference
    attr_reader :library, :name, :variant, :options

    def self.normalize(value, default_library: nil)
      return if value.nil?
      return value if value.is_a?(self)

      case value
      when String
        new(library: default_library, name: value)
      when Symbol
        new(library: default_library, name: value.to_s.tr("_", "-"))
      when Hash
        symbolized = value.each_with_object({}) { |(key, item), memo| memo[key.to_sym] = item }
        name = symbolized[:name]
        raise InvalidIconReferenceError, "Icon reference name is required" if blank?(name)

        new(
          library: symbolized[:library] || default_library,
          name: name,
          variant: symbolized[:variant],
          options: symbolized[:options] || {}
        )
      else
        raise InvalidIconReferenceError, "Unsupported icon reference: #{value.inspect}"
      end
    end

    def initialize(library:, name:, variant: nil, options: {})
      raise InvalidIconReferenceError, "Icon reference library is required" if blank?(library)
      raise InvalidIconReferenceError, "Icon reference name is required" if blank?(name)
      raise InvalidIconReferenceError, "Icon reference options must be a hash" unless options.is_a?(Hash)

      @library = library.to_sym
      @name = normalize_name(name)
      @variant = variant&.to_sym
      @options = options.each_with_object({}) { |(key, value), memo| memo[key.to_sym] = value }.freeze
      freeze
    end

    def to_h
      {
        library: library,
        name: name,
        variant: variant,
        options: options
      }
    end

    def ==(other)
      other.is_a?(IconReference) && to_h == other.to_h
    end
    alias eql? ==

    def hash
      to_h.hash
    end

    private

    def normalize_name(value)
      value.is_a?(Symbol) ? value.to_s.tr("_", "-") : value.to_s
    end

    def self.blank?(value)
      value.nil? || value.to_s.strip.empty?
    end

    def blank?(value)
      self.class.blank?(value)
    end
  end
end
