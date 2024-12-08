# frozen_string_literal: true

class FlashListComponent < ApplicationComponent
  include Phlex::Rails::Helpers::TurboFrameTag

  def initialize(flashs)
    @flashs = flashs
  end

  def view_template
    div class: "fixed inset-x-0 top-0 flex items-end justify-right px-4 py-6 sm:p-6 justify-end z-50 pointer-events-none" do
      turbo_frame_tag "flashs", class: "flex flex-col max-w-sm w-full" do
        @flashs.each do |flash_type, message|
          render FlashComponent.new(flash_type, message)
        end
      end
    end
  end
end
