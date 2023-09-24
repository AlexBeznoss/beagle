require 'baby_squeel/nodes/node'
require 'baby_squeel/nodes/attribute'
require 'baby_squeel/nodes/function'
require 'baby_squeel/nodes/grouping'
require 'baby_squeel/nodes/binary'

module BabySqueel
  module Nodes
    class << self
      # Wraps an Arel node in a Proxy so that it can
      # be extended.
      def wrap(arel)
        case arel
        when Arel::Nodes::Grouping
          Grouping.new(arel)
        when Arel::Nodes::Function
          Function.new(arel)
        when Arel::Nodes::Binary
          Binary.new(arel)
        when Arel::Nodes::Node, Arel::Nodes::SqlLiteral
          Node.new(arel)
        else
          arel
        end
      end

      # Unwraps a BabySqueel::Proxy before being passed to
      # ActiveRecord.
      def unwrap(node)
        if node.respond_to? :_arel
          unwrap node._arel
        elsif node.is_a? Array
          node.map { |n| unwrap(n) }
        else
          node
        end
      end
    end
  end
end
