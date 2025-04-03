defmodule Idb.Users do
  alias Idb.{Repo, Users, Passwords}
  use Ecto.Schema
  import Ecto.Query

  schema "users" do
    field(:email, :string)
    field(:password_hashed, :binary)
    field(:salt, :binary)

    has_many(:passwords, Passwords, foreign_key: :creator_id)
    timestamps()
  end

  def new(email, password) do
    salt = :crypto.strong_rand_bytes(16)

    %Users{
      email: email,
      password_hashed: hash_password(password, salt),
      salt: salt
    }
    |> Repo.insert()
  end

  def hash_password(password, salt), do: :crypto.pbkdf2_hmac(:sha256, password, salt, 100_000, 32)

  def verify_password(password, password_hashed, salt),
    do: hash_password(password, salt) == password_hashed

  def id_exists?(id), do: Users |> where(id: ^id) |> Repo.exists?()
end

defmodule Idb.Users.Register do
  alias Idb.{Utils, Users}
  def init(options), do: options

  def call(conn, _opts) do
    with %{"email" => email, "password" => password} <- conn.body_params do
      try do
        new_user = Users.new(email, password)
        Utils.send_jwt(conn, new_user.id)
      rescue
        e in Ecto.ConstraintError ->
          case e.constraint do
            "users_email_index" ->
              Utils.send_detail(conn, "Email already exists. 电子邮件已存在。")
          end
      end
    else
      _ -> Utils.send_detail(conn, "Invalid parameters. 不合法的参数。")
    end
  end
end

defmodule Idb.Users.Login do
  alias Idb.{Users, Repo, Utils}
  import Ecto.Query
  def init(options), do: options

  def call(conn, _opts) do
    with %{
           "email" => email,
           "password" => password
         } <- conn.body_params do
      with %Users{password_hashed: password_hashed, salt: salt, id: id} <-
             Users
             |> where(email: ^email)
             |> select([:password_hashed, :salt, :id])
             |> Repo.one() do
        if Users.verify_password(password, password_hashed, salt) do
          Utils.send_jwt(conn, id)
        else
          Utils.send_detail(conn, "Email or password is wrong. 电子邮件或密码错误。")
        end
      else
        _ ->
          Utils.send_detail(conn, "Email or password is wrong. 电子邮件或密码错误。")
      end
    else
      _ -> Utils.send_detail(conn, "Invalid parameters. 不合法的参数。")
    end
  end
end
