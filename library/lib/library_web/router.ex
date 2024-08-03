defmodule LibraryWeb.Router do
  use LibraryWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LibraryWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/json" do
    pipe_through [:api]

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
