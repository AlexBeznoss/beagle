class JobPostResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :pid, as: :text
  field :provider, as: :select, enum: ::JobPost.providers
  field :name, as: :text
  field :url, as: :text
  field :company, as: :text
  field :img_url, as: :text
  field :location, as: :text
  field :img, as: :file
  # add fields here
end
