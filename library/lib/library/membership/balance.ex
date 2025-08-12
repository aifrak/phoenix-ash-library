defmodule Library.Membership.Balance do
  use Ash.Resource,
    otp_app: :library,
    domain: Library.Membership,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshDoubleEntry.Balance]

  alias Library.Membership.Account
  alias Library.Membership.Transfer

  attributes do
    uuid_v7_primary_key :id
  end

  actions do
    read :read do
      primary? true
      pagination keyset?: true, required?: false
    end
  end

  balance do
    transfer_resource Transfer
    account_resource Account
  end

  postgres do
    table "membership_balances"
    repo Library.Repo

    references do
      reference :transfer, on_delete: :delete
    end
  end
end
