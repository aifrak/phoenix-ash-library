defmodule LibraryWeb.Plug.Catalog.AshGraphqlRouter do
  defdelegate init(opts), to: Absinthe.Plug
  defdelegate call(conn, opts), to: Absinthe.Plug
end
