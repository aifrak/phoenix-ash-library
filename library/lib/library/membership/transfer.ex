defmodule Library.Membership.Transfer do
  use Ash.Resource,
    otp_app: :library,
    domain: Library.Membership,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshDoubleEntry.Transfer]

  alias Library.Membership.Account
  alias Library.Membership.Balance

  transfer do
    account_resource Account
    balance_resource Balance
  end

  postgres do
    table "membership_transfers"
    repo Library.Repo
  end
end
