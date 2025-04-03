defmodule Idb.Passwords do
  alias Idb.Users
  use Ecto.Schema

  schema "passwords" do
    field(:website, :string)
    field(:username, :string)
    field(:password, :string)

    belongs_to(:creator, Users, foreign_key: :creator_id)
    timestamps()
  end
end

defmodule Idb.Passwords.List do
  alias Idb.{Repo, Passwords, Utils}
  import Ecto.Query

  def init(options), do: options

  def call(conn, _opts) do
    id = Guardian.Plug.current_resource(conn)

    data = Passwords |> where(creator_id: ^id) |> Repo.all()
    Utils.send_json(conn, data)
  end
end

defmodule Idb.Passwords.Add do
  alias Idb.{Repo, Passwords, Utils}
  def init(options), do: options

  def call(conn, _opts) do
    id = Guardian.Plug.current_resource(conn)

    with %{"website" => website, "username" => username, "password" => password} <-
           conn.body_params do
      data = %Passwords{website: website, username: username, password: password, creator_id: id}

      case Repo.insert(data) do
        {:ok, _} -> Utils.send_message(conn, "")
        {:error, _} -> Utils.send_detail(conn, "数据库插入失败", 500)
      end
    else
      _ -> Utils.send_detail(conn, "Invalid parameters. 不合法的参数。")
    end
  end
end
