defmodule Library.Repo.Migrations.AddStateToBooks do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    # Note: Not sure if it is a good idea to have enum in database
    AshPostgres.Migration.create_enum(Library.Catalog.Book.Types.State)

    alter table(:books) do
      add :state, :book_state, null: false, default: "draft"
    end
  end

  def down do
    alter table(:books) do
      remove :state
    end

    AshPostgres.Migration.drop_enum(Library.Catalog.Book.Types.State)
  end
end
