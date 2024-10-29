defmodule Library.Helpers.StringHelper do
  @spec truncate(String.t() | map(), non_neg_integer()) :: String.t()
  def truncate(string, max) when is_binary(string) do
    if String.length(string) > max,
      do: string |> String.slice(0..max) |> Kernel.<>("..."),
      else: string
  end

  def truncate(map, max) when is_map(map) do
    map |> Jason.encode!() |> truncate(max)
  end
end
