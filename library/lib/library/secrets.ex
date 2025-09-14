defmodule Library.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        Library.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:library, :token_signing_secret)
  end
end
