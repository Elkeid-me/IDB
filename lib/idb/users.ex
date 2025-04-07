defmodule Idb.Users do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Query

  alias Idb.{Passwords, Repo, Users}

  schema "users" do
    field(:username, :string)
    field(:password_hashed, :binary)
    field(:salt, :binary)

    has_many(:passwords, Passwords, foreign_key: :creator_id)
    timestamps()
  end

  def new(username, password) do
    salt = :crypto.strong_rand_bytes(16)

    Repo.insert(%Users{
      username: username,
      password_hashed: hash_password(password, salt),
      salt: salt
    })
  end

  def hash_password(password, salt), do: :crypto.pbkdf2_hmac(:sha256, password, salt, 100_000, 32)

  def password_verified?(password, password_hashed, salt),
    do: hash_password(password, salt) == password_hashed

  def id_exists?(id), do: Users |> where(id: ^id) |> Repo.exists?()
end

defmodule Idb.Users.Register do
  @moduledoc """
  用户注册

  - API：`<host>:<port>/api/v1/user/register`（例如 `127.0.0.1:8080/api/v1/register`）
  - 方法：POST
    - header
      - `Content-Type`: `application/json`
    - body
      ```json
      {
        "username": "alice",
        "password": "114514"
      }
      ```
  - 返回
    - header
      - status: `200` 或 `400`。
      - `Content-Type`: `application/json`
    - body

      注册成功（例）：
      ```json
      {
        "id": <用户 id>,
        "access": "<JSON Website Token>"
      }
      ```
      注册失败：
      ```json
      { "detail": "<原因>" }
    ```
  """

  alias Idb.{Users, Utils}

  def init(options), do: options

  def call(conn, _opts) do
    case conn.body_params do
      %{"username" => username, "password" => password}
      when is_binary(username) and is_binary(password) ->
        try do
          new_user = username |> Users.new(password) |> elem(1)

          Utils.send_jwt(conn, new_user.id)
        rescue
          _ -> Utils.send_detail(conn, "电子邮件已存在")
        end

      _ ->
        Utils.send_detail(conn, "不合法的参数")
    end
  end
end

defmodule Idb.Users.Login do
  @moduledoc """
  用户登录

  - API：`<host>:<port>/api/v1/user/login`
  - 方法：POST
    - header
      - `Content-Type`: `application/json`
    - body
      ```json
      {
        "username": "alice",
        "password": "114514"
      }
      ```
  - 返回
    - header
      - status: `200` 或 `400`。
      - `Content-Type`: `application/json`
    - body

      登录成功（例）：
      ```json
      {
        "id": <用户 id>,
        "access": "<JSON Website Token>"
      }
      ```
      登录失败：
      ```json
      { "detail": "<原因>" }
    ```
  """

  import Ecto.Query

  alias Idb.{Repo, Users, Utils}

  def init(options), do: options

  def call(conn, _opts) do
    case conn.body_params do
      %{
        "username" => username,
        "password" => password
      }
      when is_binary(username) and is_binary(password) ->
        case Users
             |> where(username: ^username)
             |> select([:password_hashed, :salt, :id])
             |> Repo.one() do
          %Users{password_hashed: password_hashed, salt: salt, id: id} ->
            if Users.password_verified?(password, password_hashed, salt) do
              Utils.send_jwt(conn, id)
            else
              Utils.send_detail(conn, "电子邮件或密码错误")
            end

          _ ->
            Utils.send_detail(conn, "电子邮件或密码错误")
        end

      _ ->
        Utils.send_detail(conn, "不合法的参数")
    end
  end
end
