defmodule LibraryWeb.Plug.Collaboration.AshJsonApiRouter do
  use AshJsonApi.Router,
    # The api modules you want to serve
    domains: [Module.concat(["Library.Collaboration"])],
    # optionally an open_api route
    open_api: "/open_api",
    open_api_title: "Library - Collaboration",
    open_api_version: "0.1.0"
end
