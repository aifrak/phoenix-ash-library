defmodule LibraryWeb.Plug.Collaboration.SwaggerUI do
  defdelegate init(opts), to: OpenApiSpex.Plug.SwaggerUI
  defdelegate call(conn, opts), to: OpenApiSpex.Plug.SwaggerUI
end
