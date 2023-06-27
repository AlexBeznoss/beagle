class RoutesAuthConstraint
  def self.call(context, authenticator)
    auth = lambda do |request|
      claims = request.env["clerk"].session_claims
      return false unless claims

      Current.session_claims = claims
      authenticator.call
    end

    context.constraints(auth) do
      yield
    end
  end
end
