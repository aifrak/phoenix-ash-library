defmodule LibraryWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    # The api modules you want to serve
    domains: [Module.concat(["Library.Catalog"])],
    # optionally an open_api route
    open_api: "/open_api",
    prefix: "/api/json",
    open_api_title: "Library",
    open_api_version: "0.1.0"
end
