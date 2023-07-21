defmodule Finsta.Posts do
  import Ecto.Query

  alias Finsta.Posts.Post
  alias Finsta.Repo

  def save(post_params) do
    %Post{}
    |> Post.changeset(post_params)
    |> Repo.insert()
  end

  def list_posts do
    query =
      from p in Post,
        select: p,
        order_by: [desc: :inserted_at],
        preload: [:user]

    Repo.all(query)
  end
end
