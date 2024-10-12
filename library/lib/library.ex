defmodule Library do
  @moduledoc """
  Library keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @spec pub_sub() :: Library.PubSub
  def pub_sub, do: Library.PubSub

  @spec csv_dir() :: String.t()
  def csv_dir, do: Application.fetch_env!(:library, :csv_dir)
end
