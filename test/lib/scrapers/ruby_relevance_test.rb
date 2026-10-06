require "test_helper"

class Scrapers::RubyRelevanceTest < ActiveSupport::TestCase
  test "accepts Ruby titles and explicit engineering requirements" do
    assert relevant?("Ruby Developer", "")
    assert relevant?("Senior Engineer (Rails)", "")
    assert relevant?("Senior Software Engineer", "<p>Our stack is Ruby on Rails, MongoDB and React.</p><p>Deep experience with Rails.</p>")
    assert relevant?("Senior Product Engineer", "Semaphore systems include Go, Elixir, Ruby and React.")
  end

  test "rejects incidental tags, non engineering roles, links and recruiting boilerplate" do
    assert_not relevant?("Technical Product Manager", "Our stack is Ruby.")
    assert_not relevant?("Angular Developer", "Angular is required. NOT YOUR TECH STACK? We place developers with Ruby experience too.")
    assert_not relevant?("Software Engineer", '<p>Java experience.</p><a href="https://example.com/ruby">Other roles</a>')
    assert_not relevant?("Software Engineer", "<p>Experience with Go required.</p><p>Ruby is our mascot.</p>")
    assert_not relevant?("Java Engineer", "No Ruby experience required. We develop Java systems.")
    assert_not relevant?("Backend Engineer", "We are migrating from Ruby to Go; Go experience required.")
  end

  private

  def relevant?(title, description)
    Scrapers::RubyRelevance.call(title:, description:)
  end
end
