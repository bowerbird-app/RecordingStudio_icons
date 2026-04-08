# frozen_string_literal: true

require "action_controller"

module RecordingStudioIcons
  module Renderers
    class Heroicons
      ICONS = {
        ["document-text", :outline] => {
          view_box: "0 0 24 24",
          path_attributes: {
            :"stroke-linecap" => "round",
            :"stroke-linejoin" => "round",
            d: "M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5A3.375 3.375 0 0 0 10.125 2.25H8.25A2.25 2.25 0 0 0 6 4.5v15A2.25 2.25 0 0 0 8.25 21.75h7.5A2.25 2.25 0 0 0 18 19.5v-5.25M8.25 12h7.5m-7.5 3h4.5"
          }.freeze
        },
        ["folder", :outline] => {
          view_box: "0 0 24 24",
          path_attributes: {
            :"stroke-linecap" => "round",
            :"stroke-linejoin" => "round",
            d: "M2.25 7.5A2.25 2.25 0 0 1 4.5 5.25h5.379a2.25 2.25 0 0 1 1.591.659l1.122 1.121a2.25 2.25 0 0 0 1.591.659H19.5A2.25 2.25 0 0 1 21.75 9.94v8.31A2.25 2.25 0 0 1 19.5 20.5H4.5a2.25 2.25 0 0 1-2.25-2.25V7.5Z"
          }.freeze
        },
        ["chat-bubble-left-right", :outline] => {
          view_box: "0 0 24 24",
          path_attributes: {
            :"stroke-linecap" => "round",
            :"stroke-linejoin" => "round",
            d: "M20.25 8.511c.884.284 1.5 1.107 1.5 1.989v4.875c0 1.101-.9 2.001-2.001 2.001H6.744l-3.38 2.25a.75.75 0 0 1-1.164-.624V10.5c0-.882.616-1.705 1.5-1.989m16.5 0A2.25 2.25 0 0 0 18 6.375H6A2.25 2.25 0 0 0 3.75 8.625m16.5-.114V6.375A2.25 2.25 0 0 0 18 4.125H6A2.25 2.25 0 0 0 3.75 6.375v2.136"
          }.freeze
        },
        ["rectangle-stack", :outline] => {
          view_box: "0 0 24 24",
          path_attributes: {
            :"stroke-linecap" => "round",
            :"stroke-linejoin" => "round",
            d: "M6.75 7.5h10.5m-10.5 4.5h10.5m-10.5 4.5h10.5M3.75 5.25A2.25 2.25 0 0 1 6 3h12a2.25 2.25 0 0 1 2.25 2.25v13.5A2.25 2.25 0 0 1 18 21H6a2.25 2.25 0 0 1-2.25-2.25V5.25Z"
          }.freeze
        },
        ["document-duplicate", :outline] => {
          view_box: "0 0 24 24",
          path_attributes: {
            :"stroke-linecap" => "round",
            :"stroke-linejoin" => "round",
            d: "M15.75 17.25v3.375c0 .621-.504 1.125-1.125 1.125H6.75a1.125 1.125 0 0 1-1.125-1.125V7.5c0-.621.504-1.125 1.125-1.125h3.375m5.625 10.875h2.625A1.125 1.125 0 0 0 19.5 16.125V5.625A1.125 1.125 0 0 0 18.375 4.5h-7.5A1.125 1.125 0 0 0 9.75 5.625v2.625m6 9V10.5A1.125 1.125 0 0 0 14.625 9.375H9.75A1.125 1.125 0 0 0 8.625 10.5v6.75c0 .621.504 1.125 1.125 1.125h4.875A1.125 1.125 0 0 0 15.75 17.25Z"
          }.freeze
        }
      }.freeze

      def self.render(view_context, icon_reference, **options)
        definition = ICONS[[icon_reference.name, icon_reference.variant || :outline]]
        return nil unless definition

        helper = view_context.respond_to?(:tag) ? view_context : ActionController::Base.helpers
        classes = [options.delete(:class), "recording-studio-icons__svg"].compact.join(" ")
        attributes = {
          xmlns: "http://www.w3.org/2000/svg",
          fill: "none",
          viewBox: definition[:view_box],
          stroke: "currentColor",
          "stroke-width": 1.5,
          class: classes,
          "data-icon-library": icon_reference.library,
          "data-icon-name": icon_reference.name
        }.merge(options.transform_keys(&:to_sym))

        helper.tag.svg(**attributes) do
          helper.tag.path(**definition[:path_attributes])
        end
      end
    end
  end
end
