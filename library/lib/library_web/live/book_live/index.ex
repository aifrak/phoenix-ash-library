defmodule LibraryWeb.BookLive.Index do
  use LibraryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Books
      <:actions>
        <.link patch={~p"/books/new"}>
          <.button>New Book</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="books"
      rows={@streams.books}
      row_click={fn {_id, book} -> JS.navigate(~p"/books/#{book}") end}
    >
      <:col :let={{_id, book}} label="Id"><%= book.id %></:col>

      <:col :let={{_id, book}} label="Isbn"><%= book.isbn %></:col>

      <:col :let={{_id, book}} label="Title"><%= book.title %></:col>

      <:col :let={{_id, book}} label="Subject"><%= book.subject %></:col>

      <:col :let={{_id, book}} label="Summary"><%= book.summary %></:col>

      <:col :let={{_id, book}} label="Published at"><%= book.published_at %></:col>

      <:action :let={{_id, book}}>
        <div class="sr-only">
          <.link navigate={~p"/books/#{book}"}>Show</.link>
        </div>

        <.link patch={~p"/books/#{book}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, book}}>
        <.link
          phx-click={JS.push("delete", value: %{id: book.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal :if={@live_action in [:new, :edit]} id="book-modal" show on_cancel={JS.patch(~p"/books")}>
      <.live_component
        module={LibraryWeb.BookLive.FormComponent}
        id={(@book && @book.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        book={@book}
        patch={~p"/books"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:books, Ash.read!(Library.Catalog.Book, actor: socket.assigns[:current_user]))
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Book")
    |> assign(:book, Ash.get!(Library.Catalog.Book, id, actor: socket.assigns.current_user))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Book")
    |> assign(:book, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Books")
    |> assign(:book, nil)
  end

  @impl true
  def handle_info({LibraryWeb.BookLive.FormComponent, {:saved, book}}, socket) do
    {:noreply, stream_insert(socket, :books, book)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    book = Ash.get!(Library.Catalog.Book, id, actor: socket.assigns.current_user)
    Ash.destroy!(book, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :books, book)}
  end
end
