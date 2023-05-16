# frozen_string_literal: true

class JobPosts::JobActionsComponent < ApplicationComponent
  def initialize(actions)
    @actions = actions
  end

  def template
    div(class: "flex flex-row absolute right-0 -top-2") do
      @actions.each do |action|
        render action
      end
    end
  end
end
