defmodule Library.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LibraryWeb.Telemetry,
      Library.Repo,
      {DNSCluster, query: Application.get_env(:library, :dns_cluster_query) || :ignore},
      {Oban,
       AshOban.config(
         Application.fetch_env!(:library, :ash_domains),
         Application.fetch_env!(:library, Oban)
       )},
      {Library.RateLimit, clean_period: :timer.minutes(1)},
      {Phoenix.PubSub, name: Library.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Library.Finch},
      Library.Vault,
      # Start a worker by calling: Library.Worker.start_link(arg)
      # {Library.Worker, arg},
      # Start to serve requests, typically the last entry
      LibraryWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :library]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Library.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LibraryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
