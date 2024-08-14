defmodule Library.Repo do
  use AshPostgres.Repo, otp_app: :library

  # Installs extensions that ash commonly uses
  def installed_extensions do
    ["ash-functions", "uuid-ossp", "citext", AshMoney.AshPostgresExtension]
  end

  # Required by ash_postgres
  def min_pg_version do
    %Version{major: 16, minor: 0, patch: 0}
  end
end
