# frozen_string_literal: true

module RecordingStudioIcons
  class RendererRegistry
    def initialize
      @renderers = {}
      @mutex = Mutex.new
    end

    def register(library, renderer)
      @mutex.synchronize do
        @renderers[library.to_sym] = renderer
      end
    end

    def fetch(library)
      @renderers[library.to_sym]
    end

    def to_h
      @renderers.dup
    end

    def clear!
      @mutex.synchronize do
        @renderers.clear
      end
    end
  end
end
