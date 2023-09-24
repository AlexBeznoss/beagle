module BabySqueel
  # This is the thing that gets added to Active Record's joins_values.
  # By including Polyamorous::TreeNode, when this instance is found when
  # traversing joins in ActiveRecord::Associations::JoinDependency::walk_tree,
  # Join#add_to_tree will be called.
  class Join
    include Polyamorous::TreeNode

    def initialize(associations)
      @associations = associations
    end

    # Each individual association object knows how
    # to build a Polyamorous::Join. Those joins
    # will be added to the hash incrementally.
    def add_to_tree(hash)
      @associations.inject(hash) do |acc, assoc|
        assoc.add_to_tree(acc)
      end
    end
  end
end
