defmodule LibraryWeb.TopSecretLive do
  use LibraryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <h2 class="text-xl text-center">TOP SECRET</h2>
    """
  end
end
