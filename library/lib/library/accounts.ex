defmodule Library.Accounts do
  use Ash.Domain,
    otp_app: :library

  resources do
    resource Library.Accounts.Token
    resource Library.Accounts.User
  end
end
