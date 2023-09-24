require 'baby_squeel/nodes/node'

module BabySqueel
  module Nodes
    class Binary < Node
      def initialize(node)
        super
        node.extend Arel::AliasPredication
      end
    end
  end
end
