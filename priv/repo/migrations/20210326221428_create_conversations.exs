defmodule Gather.Repo.Migrations.CreateConversations do
  use Ecto.Migration

  def change do
    create table(:conversations) do
      add :title, :string, null: false

      timestamps()
    end
  end
end
