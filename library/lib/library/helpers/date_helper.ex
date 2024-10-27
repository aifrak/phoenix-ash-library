defmodule Library.Helpers.DateHelper do
  @spec format_datetime(DateTime.t()) :: String.t()
  def format_datetime(%DateTime{} = datetime),
    do: Calendar.strftime(datetime, "%c.%f")
end
