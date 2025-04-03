defmodule Idb.Auth do
  alias Idb.Users
  use Guardian, otp_app: :idb

  def subject_for_token(%{id: id}, _claims) do
    sub = to_string(id)
    {:ok, sub}
  end

  def subject_for_token(_, _), do: :error

  def resource_from_claims(%{"sub" => id}) do
    id = String.to_integer(id)

    if Users.id_exists?(id) do
      {:ok, id}
    else
      :error
    end
  end

  def resource_from_claims(_), do: :error
end

defmodule Idb.AuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :idb

  plug(Guardian.Plug.VerifySession)
  plug(Guardian.Plug.VerifyHeader)
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource)
end

defmodule Idb.AuthErrorHandler do
  alias Idb.Utils

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, _tuple, _opts),
    do: Utils.send_detail(conn, "Authentication required. 该功能需要先登录。", 401)
end
