defmodule Library.Repo.Migrations.AddStateToBooks do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  alias Library.Catalog.Book.Types.State

  def up do
    # Note: Not sure if it is a good idea to have enum in database
    AshPostgres.Migration.create_enum(BookState)

    alter table(:books) do
      add :state, :book_state, null: false, default: "draft"
    end
  end

  def down do
    alter table(:books) do
      remove :state
    end

    AshPostgres.Migration.drop_enum(BookState)
  end
end