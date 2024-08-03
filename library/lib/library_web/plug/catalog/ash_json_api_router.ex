defmodule LibraryWeb.Plug.Catalog.AshJsonApiRouter do
  use AshJsonApi.Router,
    # The api modules you want to serve
    domains: [Module.concat(["Library.Catalog"])],
    # optionally an open_api route
    open_api: "/open_api",
    open_api_title: "Library - Catalog",
    open_api_version: "0.1.0"
end
