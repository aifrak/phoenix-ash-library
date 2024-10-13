defmodule Library.Config do
  @spec csv_dir() :: String.t()
  def csv_dir, do: Application.fetch_env!(:library, :csv_dir)
end
