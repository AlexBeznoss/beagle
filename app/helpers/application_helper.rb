module ApplicationHelper
  def pagination_path(page:)
    additions = {}
    additions[:search] = {q: params.dig(:search, :q)} if params.has_key?(:search)

    url_for(page:, **additions)
  end
end
