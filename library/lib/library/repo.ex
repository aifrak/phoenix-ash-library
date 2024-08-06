defmodule Library.Repo do
  use AshPostgres.Repo, otp_app: :library

  # Installs extensions that ash commonly uses
  def installed_extensions do
    ["ash-functions", "uuid-ossp", "citext", AshMoney.AshPostgresExtension]
  end
end
