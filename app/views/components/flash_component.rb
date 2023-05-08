# frozen_string_literal: true

class FlashComponent < ApplicationComponent
  def initialize(flash_type, message)
    @flash_type = flash_type
    @message = message
  end

  def template
    div(
      data_controller: "alert",
      data_alert_dismiss_after_value: "5000",
      data_alert_remove_delay_value: "100",
      class: "max-w-sm w-full shadow-lg rounded px-4 py-3 mb-3 rounded relative border-l-4 pointer-events-auto #{flash_style}"
    ) do
      div(class: "p-2") do
        div(class: "flex items-start") do
          div(class: "ml-3 w-0 flex-1 pt-0.5") do
            p(class: "text-md leading-5 font-medium") do
              plain @message
            end
          end
          div(class: "ml-4 flex-shrink-0 flex") do
            button(
              data_action: "alert#close",
              class: "inline-flex text-black focus:outline-none focus:text-gray-300 transition ease-in-out duration-150"
            ) do
              i(class: "bx bx-x text-2xl current-color")
            end
          end
        end
      end
    end
  end

  private

  def flash_style
    {
      notice: "bg-teal-400 border-teal-700 text-black",
      alert: "bg-yellow border-yellow-dark text-black"
    }.stringify_keys[@flash_type.to_s] || @flash_type.to_s
  end
end
