require 'baby_squeel/dsl'

module BabySqueel
  module ActiveRecord
    module WhereChain
      # Constructs Arel for ActiveRecord::Base#where using the DSL.
      def has(&block)
        arel = DSL.evaluate(@scope, &block)
        @scope.where!(arel) unless arel.blank?
        @scope
      end
    end
  end
end
