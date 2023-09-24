require 'baby_squeel/table'

module BabySqueel
  class Relation < Table
    attr_accessor :_scope

    def initialize(scope)
      super(scope.arel_table)
      @_scope = scope
    end

    # Constructs a new BabySqueel::Association. Raises
    # an exception if the association is not found.
    def association(name)
      if reflection = _scope.reflect_on_association(name)
        Association.new(self, reflection)
      else
        raise AssociationNotFoundError.new(_scope.model_name, name)
      end
    end

    # Invokes a sifter defined on the model
    #
    # ==== Examples
    #     Post.where.has { sift(:name_contains, 'joe') }
    #
    def sift(sifter_name, *args)
      Nodes.wrap _scope.public_send("sift_#{sifter_name}", *args)
    end

    private

    def resolver
      @resolver ||= Resolver.new(self, [:column, :association])
    end
  end
end
