# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ex_cldr, default_backend: Library.Cldr

config :library,
  # Order is used by ash_admin
  ash_domains: [Library.Catalog, Library.Feedback, Library.Collaboration],
  ecto_repos: [Library.Repo],
  generators: [timestamp_type: :utc_datetime],
  csv_dir: "#{System.fetch_env!("BASE_DIR")}/tmp/csv/"

# Configures the endpoint
config :library, LibraryWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: LibraryWeb.ErrorHTML, json: LibraryWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Library.PubSub,
  live_view: [signing_salt: "EZR89pmY"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :library, Library.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  library: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  library: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ash,
  custom_types: [
    # Ash types
    money: AshMoney.Types.Money,
    # Custom types
    book_state: Library.Catalog.Book.Types.State
  ],
  known_types: [AshMoney.Types.Money]

# Log Ash authorization error details
config :ash, :policies,
  log_policy_breakdowns: :error,
  log_successful_policy_breakdowns: :error

config :spark, :formatter,
  remove_parens?: true,
  "Ash.Domain": [
    section_order: [
      :resources,
      :json_api,
      :graphql,
      :admin,
      :paper_trail
    ]
  ],
  "Ash.Resource": [
    section_order: [
      :resource,
      :code_interface,
      :attributes,
      :relationships,
      :identities,
      :validations,
      :aggregates,
      :calculations,
      :preparations,
      :policies,
      :changes,
      :state_machine,
      :actions,
      :postgres,
      :csv,
      :pub_sub,
      :authentication,
      :token,
      :json_api,
      :graphql,
      :admin,
      :paper_trail
    ]
  ]

# Used by ash_json_api
config :mime,
  extensions: %{"json" => "application/vnd.api+json"},
  types: %{"application/vnd.api+json" => ["json"]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
