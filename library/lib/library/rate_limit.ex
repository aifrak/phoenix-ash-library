defmodule Library.RateLimit do
  @moduledoc """
  Module to initialize "hammer".
  """

  use Hammer, backend: :ets
end
