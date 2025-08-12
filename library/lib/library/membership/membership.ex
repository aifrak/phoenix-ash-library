defmodule Library.Membership do
  use Ash.Domain,
    otp_app: :library,
    extensions: [AshAdmin.Domain]

  alias Library.Membership.Account
  alias Library.Membership.Balance
  alias Library.Membership.Transfer

  resources do
    resource Account
    resource Balance
    resource Transfer
  end

  admin do
    show? true
    resource_group_labels domain: "Domain"
    default_resource_page :primary_read
  end
end
