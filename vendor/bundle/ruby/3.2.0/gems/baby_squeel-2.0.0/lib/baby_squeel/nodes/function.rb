require 'baby_squeel/nodes/node'

module BabySqueel
  module Nodes
    # See: https://github.com/rails/arel/pull/381
    class Function < Node
      def initialize(node)
        super
        node.extend Arel::Math
        node.extend Arel::OrderPredications
      end
    end
  end
end
