defmodule FinstaWeb.HomeLive do
  use FinstaWeb, :live_view

  alias Finsta.Posts.Post
  alias Finsta.Posts

  def render(%{loading: true} = assigns) do
    ~H"""
    <h1 class="text-2xl">Loading...</h1>
    """
  end

  def render(assigns) do
    ~H"""
    <h1 class="text-2xl">Finsta</h1>

    <.button type="button" class="btn-green-600" phx-click={show_modal("new-post-modal")}>
      New Post
    </.button>

    <.modal id="new-post-modal">
      <h3 class="text-xl font-normal">New Post</h3>
      <.simple_form for={@form} phx-change="validate" phx-submit="save" id="post_form">
        <.live_file_input upload={@uploads.image} required />
        <.input field={@form[:caption]} type="textarea" label="Caption" required />

        <.button type="submit" phx-disable-with="Posting..." class="w-full bg-green-700">
          Post
        </.button>
      </.simple_form>
    </.modal>

    <div id="feed" phx-update="stream" class="felx felx-col gap-2">
      <div
        :for={{dom_id, post} <- @streams.posts}
        id={dom_id}
        class="w-1/2 mx-auto flex flex-col gap-2 p-4 my-5 border rounded"
      >
        <img src={post.image_path} />
        <p><%= post.user.email %></p>
        <p><%= post.caption %></p>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      form =
        %Post{}
        |> Post.changeset(%{})
        |> to_form(as: "post")

      socket =
        socket
        |> allow_upload(:image, accept: ~w(.png .jpg .jpeg), max_entries: 1)
        |> assign(form: form, loading: false)
        |> stream(:posts, Posts.list_posts())

      {:ok, socket}
    else
      {:ok, assign(socket, loading: true)}
    end
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    IO.inspect(post_params)

    post_params
    |> Map.put("user_id", socket.assigns.current_user.id)
    |> Map.put("image_path", List.first(consume_files(socket)))
    |> IO.inspect()
    |> Posts.save()
    |> case do
      {:ok, _post} ->
        socket =
          socket
          |> put_flash(:info, "Post created successfully.")
          |> push_navigate(to: ~p"/home")

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  defp consume_files(socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
        dest = Path.join([:code.priv_dir(:finsta), "static", "uploads", Path.basename(path)])
        File.cp!(path, dest)
        {:postpone, ~p"/uploads/#{Path.basename(dest)}"}
      end)
  end
end
