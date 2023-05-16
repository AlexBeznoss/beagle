class PhlexLayoutWrapper
  def initialize(klass:, args:, kwargs:)
    @klass = klass
    @instance = klass.new(*args, **kwargs)
  end

  def render(view, _locals, &block)
    @instance.call(view_context: view) do |yielded|
      case yielded # rubocop:disable Style/ConditionalAssignment
      when Symbol
        output = view.view_flow.get(yielded)
      else
        output = yield
      end

      case output
      when ActiveSupport::SafeBuffer
        @instance.unsafe_raw output
      end

      nil
    end
  end

  def identifier
    @klass.identifier
  end

  def virtual_path
    @klass.virtual_path
  end
end
