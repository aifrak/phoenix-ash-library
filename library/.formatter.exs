[
  import_deps: [
    :absinthe,
    :ecto,
    :ecto_sql,
    :phoenix,
    :ash,
    :ash_admin,
    :ash_csv,
    :ash_graphql,
    :ash_json_api,
    :ash_paper_trail,
    :ash_phoenix,
    :ash_postgres,
    :ash_state_machine
  ],
  subdirectories: ["priv/*/migrations"],
  plugins: [Phoenix.LiveView.HTMLFormatter, Spark.Formatter, Absinthe.Formatter],
  inputs: [
    "*.{heex,ex,exs}",
    "{config,lib,test}/**/*.{heex,ex,exs}",
    "priv/*/seeds.exs",
    "{lib,priv}/**/*.{gql,graphql}"
  ]
]
