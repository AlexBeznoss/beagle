# frozen_string_literal: true

class ApplicationComponent < Phlex::HTML
  include Phlex::Rails::Helpers::Routes

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end

  private

  if Rails.env.test?
    def test_id(name)
      {data: {test_id: name}}
    end
  else
    def test_id(_)
      {}
    end
  end
end
