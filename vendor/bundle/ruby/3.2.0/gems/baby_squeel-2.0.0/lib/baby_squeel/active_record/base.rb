require 'baby_squeel/dsl'

module BabySqueel
  module ActiveRecord
    module Base
      delegate :joining,
               :selecting,
               :ordering,
               :reordering,
               :grouping,
               :when_having,
               :plucking,
               :averaging,
               :counting,
               :maximizing,
               :minimizing,
               :summing,
               to: :all

      # Define a sifter that can be used within DSL blocks.
      #
      # ==== Examples
      #    class Post < ActiveRecord::Base
      #      sifter :name_contains do |string|
      #        name =~ "%#{string}%"
      #      end
      #    end
      #
      #    Post.where.has { sift(:name_contains, 'joe') }
      #
      def sifter(name, &block)
        define_singleton_method "sift_#{name}" do |*args|
          DSL.evaluate_sifter(self, *args, &block)
        end
      end
    end
  end
end
