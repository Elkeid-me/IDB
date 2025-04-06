defmodule Idb.Utils do
  @moduledoc """
  工具库
  """
  import Jason
  import Plug.Conn
  alias Idb.Auth

  def send_json(conn, data, status \\ 200) do
    json = encode!(data)
    conn |> put_resp_content_type("application/json") |> send_resp(status, json)
  end

  @doc """
  将 `detail` 以 `{ "detail": detail }` 格式发送。

  `detail` 应当为字符串。

  `detail` 为失败时的信息。成功时应当使用 `send_message/3`。
  """
  def send_detail(conn, detail, status \\ 400),
    do: send_json(conn, %{"detail" => detail}, status)

  @doc """
  将 `message` 以 `{ "message": message }` 格式发送。

  `message` 应当为字符串。

  `message` 为成功时的信息。失败时应当使用 `send_detail/3`。
  """
  def send_message(conn, message, status \\ 200),
    do: send_json(conn, %{"message" => message}, status)

  @doc """
  以 `id` 为 sub，编码 jwt 并发送。
  """
  def send_jwt(conn, id) do
    jwt = %{id: id} |> Auth.encode_and_sign() |> elem(1)
    send_json(conn, %{id: id, access: jwt})
  end
end
