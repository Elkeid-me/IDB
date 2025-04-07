defmodule Idb.Auth do
  @moduledoc """
  身份验证
  """

  use Guardian, otp_app: :idb

  alias Idb.Users

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
  @moduledoc false

  use Guardian.Plug.Pipeline, otp_app: :idb

  plug(Guardian.Plug.VerifySession)
  plug(Guardian.Plug.VerifyHeader)
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource)
end

defmodule Idb.AuthErrorHandler do
  @moduledoc false

  @behaviour Guardian.Plug.ErrorHandler

  alias Idb.Utils

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, _tuple, _opts), do: Utils.send_detail(conn, "该功能需要先登录", 401)
end
