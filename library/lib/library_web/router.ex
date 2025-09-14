defmodule LibraryWeb.Router do
  use LibraryWeb, :router

  use AshAuthentication.Phoenix.Router

  import AshAuthentication.Plug.Helpers
  import AshAdmin.Router

  pipeline :graphql do
    plug :load_from_bearer
    plug :set_actor, :user
    plug AshGraphql.Plug
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LibraryWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
    plug :set_actor, :user
  end

  scope "/", LibraryWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/books-tutorial", BooksLive

    # Books
    live "/books", BookLive.Index, :index
    live "/books/new", BookLive.Index, :new
    live "/books/:id/edit", BookLive.Index, :edit

    live "/books/:id", BookLive.Show, :show
    live "/books/:id/show/edit", BookLive.Show, :edit

    # Authors
    live "/authors", AuthorLive.Index, :index
    live "/authors/new", AuthorLive.Index, :new
    live "/authors/:id/edit", AuthorLive.Index, :edit

    live "/authors/:id", AuthorLive.Show, :show
    live "/authors/:id/show/edit", AuthorLive.Show, :edit

    # Test pages
    live "/test/reviews-notifications/:book_id", ReviewNotificationTestLive
  end

  # ash_authentication_phoenix
  scope "/", LibraryWeb do
    pipe_through :browser

    auth_routes AuthController, Library.Accounts.User, path: "/auth"
    sign_out_route AuthController

    # Remove these if you'd like to use your own authentication views
    sign_in_route register_path: "/register",
                  reset_path: "/reset",
                  auth_routes_prefix: "/auth",
                  on_mount: [{LibraryWeb.LiveUserAuth, :live_no_user}],
                  overrides: [
                    LibraryWeb.AuthOverrides,
                    AshAuthentication.Phoenix.Overrides.Default
                  ]

    # Remove this if you do not want to use the reset password feature
    reset_route auth_routes_prefix: "/auth",
                overrides: [LibraryWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]

    # Remove this if you do not use the confirmation strategy
    confirm_route Library.Accounts.User, :confirm_new_user,
      auth_routes_prefix: "/auth",
      overrides: [LibraryWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]

    # Remove this if you do not use the magic link strategy.
    magic_sign_in_route(Library.Accounts.User, :magic_link,
      auth_routes_prefix: "/auth",
      overrides: [LibraryWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]
    )

    ash_authentication_live_session :authenticated_routes do
      # in each liveview, add one of the following at the top of the module:
      #
      # If an authenticated user must be present:
      # on_mount {LibraryWeb.LiveUserAuth, :live_user_required}
      #
      # If an authenticated user *may* be present:
      # on_mount {LibraryWeb.LiveUserAuth, :live_user_optional}
      #
      # If an authenticated user must *not* be present:
      # on_mount {LibraryWeb.LiveUserAuth, :live_no_user}
    end

    # Custom routes to play with authentication
    ash_authentication_live_session :authentication_required,
      on_mount: {LibraryWeb.LiveUserAuth, :live_user_required} do
      live "/top-secret", TopSecretLive, :index
    end
  end

  scope "/" do
    pipe_through :browser

    # Reminder:
    # There is no builtin security for your AshAdmin (except your app's normal policies).
    # In most cases you will want to secure your AshAdmin routes in some way to prevent
    # them from being publicly accessible.
    ash_admin "/admin"
  end

  scope "/gql" do
    pipe_through [:graphql]

    # Examples of having 3 GraphQL schemas served in 3 different routes

    scope "/catalog" do
      forward "/playground",
              LibraryWeb.Plug.Catalog.GraphiQL,
              schema: Module.concat(["LibraryWeb.Graphql.Domain.Catalog.GraphqlSchema"]),
              interface: :playground

      forward "/", LibraryWeb.Plug.Catalog.AshGraphqlRouter,
        schema: Module.concat(["LibraryWeb.Graphql.Domain.Catalog.GraphqlSchema"])
    end

    scope "/feedback" do
      forward "/playground",
              LibraryWeb.Plug.Feedback.GraphiQL,
              schema: Module.concat(["LibraryWeb.Graphql.Domain.Feedback.GraphqlSchema"]),
              interface: :playground

      forward "/", LibraryWeb.Plug.Feedback.AshGraphqlRouter,
        schema: Module.concat(["LibraryWeb.Graphql.Domain.Feedback.GraphqlSchema"])
    end

    scope "/collaboration" do
      forward "/playground",
              LibraryWeb.Plug.Collaboration.GraphiQL,
              schema: Module.concat(["LibraryWeb.Graphql.Domain.Collaboration.GraphqlSchema"]),
              interface: :playground

      forward "/", LibraryWeb.Plug.Collaboration.AshGraphqlRouter,
        schema: Module.concat(["LibraryWeb.Graphql.Domain.Collaboration.GraphqlSchema"])
    end
  end

  scope "/api/json" do
    pipe_through [:api]

    # Examples of having 3 SwaggerUI served in 3 different routes

    scope "/catalog" do
      forward "/swaggerui", LibraryWeb.Plug.Catalog.SwaggerUI,
        path: "/api/json/catalog/open_api",
        default_model_expand_depth: 4

      forward "/", LibraryWeb.Plug.Catalog.AshJsonApiRouter
    end

    scope "/feedback" do
      forward "/swaggerui", LibraryWeb.Plug.Feedback.SwaggerUI,
        path: "/api/json/feedback/open_api",
        default_model_expand_depth: 4

      forward "/", LibraryWeb.Plug.Feedback.AshJsonApiRouter
    end

    scope "/collaboration" do
      forward "/swaggerui", LibraryWeb.Plug.Collaboration.SwaggerUI,
        path: "/api/json/collaboration/open_api",
        default_model_expand_depth: 4

      forward "/", LibraryWeb.Plug.Collaboration.AshJsonApiRouter
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", LibraryWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:library, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LibraryWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
