defmodule LibraryWeb.AuthorLive.FormComponent do
  use LibraryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage author records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="author-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:first_name]} type="text" label="First name" /><.input
          field={@form[:last_name]}
          type="text"
          label="Last name"
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Author</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"author" => author_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, author_params))}
  end

  def handle_event("save", %{"author" => author_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: author_params) do
      {:ok, author} ->
        notify_parent({:saved, author})

        socket =
          socket
          |> put_flash(:info, "Author #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{author: author}} = socket) do
    form =
      if author do
        AshPhoenix.Form.for_update(author, :update,
          as: "author",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Library.Catalog.Author, :create,
          as: "author",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
