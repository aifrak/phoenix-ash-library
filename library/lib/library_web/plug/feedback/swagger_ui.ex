defmodule LibraryWeb.Plug.Feedback.SwaggerUI do
  defdelegate init(opts), to: OpenApiSpex.Plug.SwaggerUI
  defdelegate call(conn, opts), to: OpenApiSpex.Plug.SwaggerUI
end