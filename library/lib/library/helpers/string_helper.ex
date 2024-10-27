defmodule Library.Helpers.StringHelper do
  @spec truncate(String.t(), non_neg_integer()) :: String.t()
  def truncate(string, max) do
    if String.length(string) > max,
      do: string |> String.slice(0..max) |> Kernel.<>("..."),
      else: string
  end
end
