require "pagy/extras/countless"
require "pagy/extras/meilisearch"

Pagy::DEFAULT[:page] = 1
Pagy::DEFAULT[:items] = 10
Pagy::DEFAULT.freeze
