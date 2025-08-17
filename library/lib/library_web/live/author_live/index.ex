defmodule LibraryWeb.AuthorLive.Index do
  use LibraryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Authors
      <:actions>
        <.link patch={~p"/authors/new"}>
          <.button>New Author</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="authors"
      rows={@streams.authors}
      row_click={fn {_id, author} -> JS.navigate(~p"/authors/#{author}") end}
    >
      <:col :let={{_id, author}} label="Id">{author.id}</:col>

      <:col :let={{_id, author}} label="First name">{author.first_name}</:col>

      <:col :let={{_id, author}} label="Last name">{author.last_name}</:col>

      <:action :let={{_id, author}}>
        <div class="sr-only">
          <.link navigate={~p"/authors/#{author}"}>Show</.link>
        </div>

        <.link patch={~p"/authors/#{author}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, author}}>
        <.link
          phx-click={JS.push("delete", value: %{id: author.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="author-modal"
      show
      on_cancel={JS.patch(~p"/authors")}
    >
      <.live_component
        module={LibraryWeb.AuthorLive.FormComponent}
        id={(@author && @author.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        author={@author}
        patch={~p"/authors"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:authors, Ash.read!(Library.Catalog.Author, actor: socket.assigns[:current_user]))
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Author")
    |> assign(:author, Ash.get!(Library.Catalog.Author, id, actor: socket.assigns.current_user))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Author")
    |> assign(:author, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Authors")
    |> assign(:author, nil)
  end

  @impl true
  def handle_info({LibraryWeb.AuthorLive.FormComponent, {:saved, author}}, socket) do
    {:noreply, stream_insert(socket, :authors, author)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    author = Ash.get!(Library.Catalog.Author, id, actor: socket.assigns.current_user)
    Ash.destroy!(author, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :authors, author)}
  end
end
