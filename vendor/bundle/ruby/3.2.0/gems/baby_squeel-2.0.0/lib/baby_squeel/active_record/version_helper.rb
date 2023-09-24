require 'baby_squeel/dsl'

module BabySqueel
  module ActiveRecord
    class VersionHelper
      def self.at_least_6_1?
        ::ActiveRecord::VERSION::MAJOR > 6 ||
          ::ActiveRecord::VERSION::MAJOR == 6 && ::ActiveRecord::VERSION::MINOR >= 1
      end
    end
  end
end
