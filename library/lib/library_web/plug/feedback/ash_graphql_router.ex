defmodule LibraryWeb.Plug.Feedback.AshGraphqlRouter do
  defdelegate init(opts), to: Absinthe.Plug
  defdelegate call(conn, opts), to: Absinthe.Plug
end
