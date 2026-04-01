# frozen_string_literal: true

class CustomDemoIconRenderer
  class << self
    def render(view_context, icon_reference, **options)
      classes = [options.delete(:class), "inline-flex items-center justify-center rounded-full bg-slate-900/10 px-2 py-1 text-xs font-semibold text-slate-700"].compact.join(" ")
      label = icon_reference.name.to_s.tr("-", " ")
      view_context.tag.span(label, { class: classes, data: { icon_library: icon_reference.library, icon_name: icon_reference.name } }.merge(options))
    end
  end
end
