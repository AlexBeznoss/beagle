class JobPostResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  field :provider, as: :select, enum: ::JobPost.providers
  field :name, as: :text
  field :company, as: :text
  field :location, as: :text
  field :url, as: :text,
    format_using: ->(value) { link_to("Link", value, target: "_blank", rel: "noopener") }
  field :img, as: :file, is_image: true
  field :hidden, as: :boolean
end
