defmodule FinstaWeb.HomeLive do
  use FinstaWeb, :live_view

  alias Finsta.Posts.Post

  def render(assigns) do
    ~H"""
    <h1 class="text-2xl">Finsta</h1>

    <.simple_form for={@form} action={"/post"} id="post_form">
      <.input field={@form[:caption]} type="textarea" label="Caption" required />
      <.input field={@form[:image_path]} type="file" label="Image" required />

      <:actions>
      <.button type="submit" phx-disable-with="Posting..." class="w-full">
      Post
      </.button>
      </:actions>
    </.simple_form>
    """
  end

  def mount(_params, _session, socket) do
    form =
      %Post{}
      |> Post.changeset(%{})
      |> to_form(as: "post")

    socket =
      socket
      |> assign(form: form)

    {:ok, socket}
  end
end
