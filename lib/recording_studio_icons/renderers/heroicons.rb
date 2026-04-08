# frozen_string_literal: true

require "action_controller"

module RecordingStudioIcons
  module Renderers
    HEROICON_DEFINITIONS = {
      ["document-text", :outline] => {
        view_box: "0 0 24 24",
        path_attributes: {
          "stroke-linecap": "round",
          "stroke-linejoin": "round",
          d: [
            "M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5",
            "A3.375 3.375 0 0 0 10.125 2.25H8.25A2.25 2.25 0 0 0 6 4.5v15A2.25 2.25 0 0 0 8.25 21.75",
            "h7.5A2.25 2.25 0 0 0 18 19.5v-5.25M8.25 12h7.5m-7.5 3h4.5"
          ].join(" ")
        }.freeze
      },
      ["folder", :outline] => {
        view_box: "0 0 24 24",
        path_attributes: {
          "stroke-linecap": "round",
          "stroke-linejoin": "round",
          d: [
            "M2.25 7.5A2.25 2.25 0 0 1 4.5 5.25h5.379a2.25 2.25 0 0 1 1.591.659l1.122 1.121",
            "a2.25 2.25 0 0 0 1.591.659H19.5A2.25 2.25 0 0 1 21.75 9.94v8.31A2.25 2.25 0 0 1 19.5 20.5",
            "H4.5a2.25 2.25 0 0 1-2.25-2.25V7.5Z"
          ].join(" ")
        }.freeze
      },
      ["chat-bubble-left-right", :outline] => {
        view_box: "0 0 24 24",
        path_attributes: {
          "stroke-linecap": "round",
          "stroke-linejoin": "round",
          d: [
            "M20.25 8.511c.884.284 1.5 1.107 1.5 1.989v4.875c0 1.101-.9 2.001-2.001 2.001H6.744",
            "l-3.38 2.25a.75.75 0 0 1-1.164-.624V10.5c0-.882.616-1.705 1.5-1.989m16.5 0A2.25 2.25 0 0 0 18 6.375H6",
            "A2.25 2.25 0 0 0 3.75 8.625m16.5-.114V6.375A2.25 2.25 0 0 0 18 4.125H6A2.25 2.25 0 0 0 3.75 6.375v2.136"
          ].join(" ")
        }.freeze
      },
      ["rectangle-stack", :outline] => {
        view_box: "0 0 24 24",
        path_attributes: {
          "stroke-linecap": "round",
          "stroke-linejoin": "round",
          d: [
            "M6.75 7.5h10.5m-10.5 4.5h10.5m-10.5 4.5h10.5M3.75 5.25A2.25 2.25 0 0 1 6 3h12",
            "a2.25 2.25 0 0 1 2.25 2.25v13.5A2.25 2.25 0 0 1 18 21H6a2.25 2.25 0 0 1-2.25-2.25V5.25Z"
          ].join(" ")
        }.freeze
      },
      ["document-duplicate", :outline] => {
        view_box: "0 0 24 24",
        path_attributes: {
          "stroke-linecap": "round",
          "stroke-linejoin": "round",
          d: [
            "M15.75 17.25v3.375c0 .621-.504 1.125-1.125 1.125H6.75a1.125 1.125 0 0 1-1.125-1.125V7.5",
            "c0-.621.504-1.125 1.125-1.125h3.375m5.625 10.875h2.625A1.125 1.125 0 0 0 19.5 16.125V5.625",
            "A1.125 1.125 0 0 0 18.375 4.5h-7.5A1.125 1.125 0 0 0 9.75 5.625v2.625m6 9V10.5",
            "A1.125 1.125 0 0 0 14.625 9.375H9.75",
            "A1.125 1.125 0 0 0 8.625 10.5v6.75c0 .621.504 1.125 1.125 1.125h4.875A1.125 1.125 0 0 0 15.75 17.25Z"
          ].join(" ")
        }.freeze
      }
    }.freeze

    class Heroicons
      ALLOWED_SVG_OPTIONS = %i[aria class data height role stroke_width width].freeze

      def self.render(view_context, icon_reference, **options)
        definition = icon_definition(icon_reference)
        return nil unless definition

        helper = tag_helper(view_context)
        attributes = svg_attributes(definition, icon_reference, options)

        helper.tag.svg(**attributes) do
          helper.tag.path(**definition[:path_attributes])
        end
      end

      def self.icon_definition(icon_reference)
        HEROICON_DEFINITIONS[[icon_reference.name, icon_reference.variant || :outline]]
      end

      def self.tag_helper(view_context)
        view_context.respond_to?(:tag) ? view_context : ActionController::Base.helpers
      end

      def self.svg_attributes(definition, icon_reference, options)
        normalized_options = sanitize_options(options)

        base_svg_attributes(definition, icon_reference)
          .merge(class: css_classes(normalized_options))
          .merge(optional_svg_attributes(normalized_options))
      end

      def self.base_svg_attributes(definition, icon_reference)
        {
          xmlns: "http://www.w3.org/2000/svg",
          fill: "none",
          viewBox: definition[:view_box],
          stroke: "currentColor",
          "stroke-width": 1.5,
          "data-icon-library": icon_reference.library,
          "data-icon-name": icon_reference.name
        }
      end

      def self.css_classes(options)
        [options.delete(:class), "recording-studio-icons__svg"].compact.join(" ")
      end

      def self.sanitize_options(options)
        options.each_with_object({}) do |(key, value), memo|
          normalized_key = key.to_sym
          next unless ALLOWED_SVG_OPTIONS.include?(normalized_key)

          memo[normalized_key] = value
        end
      end

      def self.optional_svg_attributes(options)
        attributes = options.slice(:aria, :data, :height, :role, :width)
        stroke_width = options[:stroke_width]
        attributes["stroke-width"] = stroke_width if stroke_width
        attributes
      end
    end
  end
end
