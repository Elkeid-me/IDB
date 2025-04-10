defmodule Idb.Passwords do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Query

  alias Idb.{Passwords, Repo, Users}

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

defmodule Idb.Passwords.Add do
  @moduledoc """
  创建条目

  - API：`<host>:<port>/api/v1/item/add`
  - 方法：POST
    - header
      - `Content-Type`: `application/json`
      - `Authorization`: `Bearer <从注册或登录获取的 access>`
    - body
      ```json
      {
        "website": "baidu.com",
        "username": "alice@gmail.com",
        "password": "114514"
      }
      ```
  - 返回
    - header
      - status: `200`、`400`、`401` 或 `500`。
        - `200`：成功
        - `400`：错误的请求体
        - `401`：未登录，或 `access` 不正确
        - `500`：服务器内部故障
      - `Content-Type`: `application/json`
    - body

      添加成功（例）：
      ```json
      { "message": "添加成功" }
      ```
      添加失败：
      ```json
      { "detail": "<原因>" }
      ```
  """

  alias Idb.{Passwords, Repo, Utils}

  def init(options), do: options

  def call(conn, _opts) do
    user_id = Guardian.Plug.current_resource(conn)

    case conn.body_params do
      %{"website" => website, "username" => username, "password" => password}
      when is_binary(website) and is_binary(username) and is_binary(password) ->
        data = %Passwords{
          website: website,
          username: username,
          password: password,
          creator_id: user_id
        }

        case Repo.insert(data) do
          {:ok, _} -> Utils.send_message(conn, "添加成功")
          {:error, _} -> Utils.send_detail(conn, "数据库插入失败", 500)
        end

      _ ->
        Utils.send_detail(conn, "不合法的参数")
    end
  end
end

defmodule Idb.Passwords.List do
  @moduledoc """
  列出用户所有条目

  - API：`<host>:<port>/api/v1/item/list`
  - 方法：GET
    - header
      - `Authorization`: `Bearer <从注册或登录获取的 access>`

  - 返回
    - header
      - status: `200`、`401` 或 `500`。
        - `200`：成功
        - `401`：未登录，或 `access` 不正确
        - `500`：服务器内部故障
      - `Content-Type`: `application/json`
    - body

      成功（例）：
      ```json
      [
        {
          "id": <id>,
          "website": "<website>",
          "username": "<username>",
          "password": "<password>"
        },
        ...
      ]
      ```
      失败：
      ```json
      { "detail": "<原因>" }
      ```
  """

  import Ecto.Query

  alias Idb.{Passwords, Repo, Utils}

  def init(options), do: options

  def call(conn, _opts) do
    user_id = Guardian.Plug.current_resource(conn)

    data =
      Passwords
      |> where(creator_id: ^user_id)
      |> select([:id, :website, :username, :password])
      |> Repo.all()
      |> Enum.map(fn item -> Map.take(item, [:id, :website, :username, :password]) end)

    Utils.send_json(conn, data)
  end
end

defmodule Idb.Passwords.Delete do
  @moduledoc """
  删除条目

  - API：`<host>:<port>/api/v1/item/delete`
  - 方法：POST
    - header
      - `Content-Type`: `application/json`
      - `Authorization`: `Bearer <从注册或登录获取的 access>`
    - body
      ```json
      {
        "id"：<条目 id>
      }
      ```
  - 返回
    - header
      - status: `200`、`400`、`401` 或 `500`。
        - `200`：成功
        - `400`：错误的请求体
        - `401`：未登录，或 `access` 不正确
        - `500`：服务器内部故障
      - `Content-Type`: `application/json`
    - body

      删除成功（例）：
      ```json
      { "message": "删除成功" }
      ```
      删除失败：
      ```json
      { "detail": "<原因>" }
      ```
  """

  import Ecto.Query

  alias Idb.{Passwords, Repo, Utils}

  def init(options), do: options

  def call(conn, _opts) do
    user_id = Guardian.Plug.current_resource(conn)

    case conn.body_params do
      %{"id" => item_id} ->
        case Passwords.creator(item_id) do
          nil ->
            Utils.send_detail(conn, "不存在的条目")

          ^user_id ->
            case Repo.delete(%Passwords{id: item_id}) do
              {:ok, _} -> Utils.send_message(conn, "删除成功")
              {:error, _} -> Utils.send_detail(conn, "数据库删除失败", 500)
            end

          _ ->
            Utils.send_detail(conn, "不是该用户所属的条目")
        end

      _ ->
        Utils.send_detail(conn, "不合法的参数")
    end
  end
end

defmodule Idb.Passwords.Edit do
  @moduledoc """
  编辑条目

  - API：`<host>:<port>/api/v1/item/edit`
  - 方法：POST
    - header
      - `Content-Type`: `application/json`
      - `Authorization`: `Bearer <从注册或登录获取的 access>`
    - body
      ```json
      {
        "id"：<条目 id>, // 此字段必须提供

        // 以下三个字段不必同时存在，只需提供变动的字段即可
        "website": "<website>",
        "username": "<username>",
        "password": "<password>"
      }
      ```
  - 返回
    - header
      - status: `200`、`400`、`401` 或 `500`。
        - `200`：成功
        - `400`：错误的请求体
        - `401`：未登录，或 `access` 不正确
        - `500`：服务器内部故障
      - `Content-Type`: `application/json`
    - body

      编辑成功（例）：
      ```json
      { "message": "更新成功" }
      ```
      编辑失败：
      ```json
      { "detail": "<原因>" }
      ```
  """

  import Ecto.Query

  alias Idb.{Passwords, Repo, Utils}

  def init(options), do: options

  def call(conn, _opts) do
    user_id = Guardian.Plug.current_resource(conn)

    case conn.body_params do
      %{"id" => item_id} ->
        case Passwords.creator(item_id) do
          nil ->
            Utils.send_detail(conn, "不存在的条目")

          ^user_id ->
            attrs = Map.take(conn.body_params, ["website", "username", "password"])

            try do
              Passwords
              |> where(id: ^item_id)
              |> Repo.one()
              |> Ecto.Changeset.cast(attrs, [:website, :username, :password])
              |> Repo.update()

              Utils.send_message(conn, "更新成功")
            rescue
              e ->
                Utils.send_detail(conn, "更新失败", 500)
                IO.inspect(e)
            end

          _ ->
            Utils.send_detail(conn, "不是该用户所属的条目")
        end

      _ ->
        Utils.send_detail(conn, "不合法的参数")
    end
  end
end

defmodule Idb.Passwords.Search do
  @moduledoc """
  搜索条目，从该用户所有的条目中选取 `website` 和 `username` 包含特定子串的项。

  关于内部实现的注释：尝试规避 [LIKE 注入](https://github.blog/engineering/like-injection/)

  - API：`<host>:<port>/api/v1/item/search`
  - 方法：POST
    - header
      - `Content-Type`: `application/json`
      - `Authorization`: `Bearer <从注册或登录获取的 access>`
    - body
      ```json
      { "query": "<要搜索的子串>" }
      ```
  - 返回
      - header
        - status: `200`、`401` 或 `500`。
          - `200`：成功
          - `401`：未登录，或 `access` 不正确
          - `500`：服务器内部故障
        - `Content-Type`: `application/json`
      - body

        成功（例）：
        ```json
        [
          {
            "id": <id>,
            "website": "<website>",
            "username": "<username>",
            "password": "<password>"
          },
          ...
        ]
        ```
        失败：
        ```json
        { "detail": "<原因>" }
        ```
  """

  import Ecto.Query

  alias Idb.{Passwords, Repo, Utils}

  def init(options), do: options

  def call(conn, _opts) do
    user_id = Guardian.Plug.current_resource(conn)

    case conn.body_params do
      %{"query" => query} when is_binary(query) ->
        query = query |> String.replace("%", "\\%") |> String.replace("_", "\\_")

        data =
          Passwords
          |> where(
            [i],
            i.creator_id == ^user_id and
              (like(i.username, ^"%#{query}%") or like(i.website, ^"%#{query}%"))
          )
          |> select([:id, :website, :username, :password])
          |> Repo.all()
          |> Enum.map(fn elem -> Map.take(elem, [:id, :website, :username, :password]) end)

        Utils.send_json(conn, data)

      _ ->
        Utils.send_detail(conn, "不合法的参数")
    end
  end
end
