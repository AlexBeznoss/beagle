# frozen_string_literal: true

# @api private
module Phlex::Callable
	def to_proc
		method(:call).to_proc
	end
end
