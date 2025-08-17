defmodule LibraryWeb.AuthorLive.Show do
  use LibraryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Author {@author.id}
      <:subtitle>This is a author record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/authors/#{@author}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit author</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Id">{@author.id}</:item>

      <:item title="First name">{@author.first_name}</:item>

      <:item title="Last name">{@author.last_name}</:item>
    </.list>

    <.back navigate={~p"/authors"}>Back to authors</.back>

    <.modal
      :if={@live_action == :edit}
      id="author-modal"
      show
      on_cancel={JS.patch(~p"/authors/#{@author}")}
    >
      <.live_component
        module={LibraryWeb.AuthorLive.FormComponent}
        id={@author.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        author={@author}
        patch={~p"/authors/#{@author}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:author, Ash.get!(Library.Catalog.Author, id, actor: socket.assigns.current_user))}
  end

  defp page_title(:show), do: "Show Author"
  defp page_title(:edit), do: "Edit Author"
end
