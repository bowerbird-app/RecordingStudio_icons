# frozen_string_literal: true

module RecordingStudioIcons
  class RendererRegistry
    def initialize
      @renderers = {}.freeze
      @mutex = Mutex.new
    end

    def register(library, renderer)
      @mutex.synchronize do
        @renderers = @renderers.merge(library.to_sym => renderer).freeze
      end
    end

    def fetch(library)
      @renderers[library.to_sym]
    end

    def to_h
      @renderers.dup.freeze
    end

    def clear!
      @mutex.synchronize do
        @renderers = {}.freeze
      end
    end
  end
end
