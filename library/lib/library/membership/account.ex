defmodule Library.Membership.Account do
  use Ash.Resource,
    otp_app: :library,
    domain: Library.Membership,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshDoubleEntry.Account]

  alias Library.Membership.Balance
  alias Library.Membership.Transfer

  attributes do
    uuid_v7_primary_key :id

    attribute :number, :string do
      allow_nil? false
    end

    attribute :type, :atom do
      allow_nil? false
      constraints one_of: [:member, :vip]
    end
  end

  account do
    transfer_resource Transfer
    balance_resource Balance
    open_action_accept [:number, :type]
  end

  postgres do
    table "membership_accounts"
    repo Library.Repo
  end
end
