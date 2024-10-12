defmodule Library.Config do
  @spec pub_sub() :: Library.PubSub
  def pub_sub, do: Library.PubSub

  @spec csv_dir() :: String.t()
  def csv_dir, do: Application.fetch_env!(:library, :csv_dir)
end
