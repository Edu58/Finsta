defmodule Finsta.Posts do
  alias Finsta.Posts.Post
  alias Finsta.Repo

  def save(post_params) do
    %Post{}
    |> Post.changeset(post_params)
    |> Repo.insert()
  end
end
