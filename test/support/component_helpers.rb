module ComponentHelpers
  def controller
    @controller ||= ApplicationController.new.tap do |controller|
      controller.set_request!(ActionDispatch::TestRequest.create)
      controller.set_response!(ActionDispatch::TestResponse.new)
    end
  end

  def view_context
    @view_context ||= controller.view_context
  end

  def render(component)
    Nokogiri::HTML.fragment(component.render_in(view_context))
  end
end
