defmodule Idb.Passwords do
  alias Idb.{Repo, Passwords, Users}
  use Ecto.Schema
  import Ecto.Query

  schema "passwords" do
    field(:website, :string)
    field(:username, :string)
    field(:password, :string)

    belongs_to(:creator, Users, foreign_key: :creator_id)
    timestamps()
  end

  def creator(id) do
    case Passwords |> where(id: ^id) |> select([:creator_id]) |> Repo.one() do
      %{creator_id: creator} -> creator
      nil -> nil
    end
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

defmodule Idb.Passwords.Delete do
  alias Idb.{Repo, Passwords, Utils}
  import Ecto.Query

  def init(options), do: options

  def call(conn, _opts) do
    user_id = Guardian.Plug.current_resource(conn)

    with %{"id" => id} <- conn.body_params do
      case Passwords.creator(id) do
        nil ->
          Utils.send_detail(conn, "不存在的条目。")

        ^user_id ->
          case Repo.delete(%Passwords{id: id}, id) do
            {:ok, _} -> Utils.send_message(conn, "")
            {:error, _} -> Utils.send_detail(conn, "数据库插入失败", 500)
          end

        _ ->
          Utils.send_detail(conn, "不是该用户所属的条目")
      end
    else
      _ -> Utils.send_detail(conn, "不合法的参数。")
    end
  end
end

defmodule Idb.Passwords.Edit do
  alias Idb.{Repo, Passwords, Utils}
  import Ecto.Query

  def init(options), do: options

  def call(conn, _opts) do
    user_id = Guardian.Plug.current_resource(conn)

    with %{"id" => id} <- conn.body_params do
      case Passwords.creator(id) do
        nil ->
          Utils.send_detail(conn, "不存在的条目。")

        ^user_id ->
          attrs =
            conn.body_params
            |> Map.take(["website", "username", "password"])

          try do
            Passwords
            |> where(id: ^id)
            |> Repo.one()
            |> Ecto.Changeset.cast(attrs, [:website, :username, :password])
            |> Repo.update()

            Utils.send_message(conn, "更新成功")
          rescue
            e ->
              Utils.send_detail(conn, "更新失败")
              IO.inspect(e)
          end

        _ ->
          Utils.send_detail(conn, "不是该用户所属的条目")
      end
    else
      _ -> Utils.send_detail(conn, "不合法的参数。")
    end
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
      _ -> Utils.send_detail(conn, "不合法的参数。")
    end
  end
end
