defmodule Idb.AuthRouter do
  @moduledoc """
  身份验证路由

  所有需要登录的请求被 `Idb.Router` 转发到此处，身份验证由 `Idb.AuthPipeline` 处理，验证错误由 `Idb.AuthErrorHandler` 处理。
  """
  alias Idb.Users
  use Plug.Router
  plug(Idb.AuthPipeline)
  plug(:match)
  plug(:dispatch)

  post("/users/edit/", to: Users.Register)
  # get("/users/profile/", to: Users.Profile)

  # post("/experiments/create/", to: Experiments.Create)
end

defmodule Idb.Router do
  @moduledoc """
  核心路由

  所有流量到达此处，然后根据 URL 匹配、转发。此外，配置了 `Corsica` 处理跨域请求。
  """
  alias Idb.{Users, Utils}
  use Plug.Router
  plug(Plug.Logger)

  plug(:match)

  plug(Corsica,
    origins: "*",
    allow_credentials: true,
    allow_methods: ["OPTIONS", "GET", "POST"],
    allow_headers: :all
  )

  plug(Plug.Parsers,
    parsers: [:urlencoded, :json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  post("/api/v1/users/register/", to: Users.Register)
  post("/api/v1/users/login/", to: Users.Login)

  match _ do
    Utils.send_detail(
      conn,
      "Requested API not found, or the method is not allowed. 请求的 API 不存在，或方法不被允许。",
      404
    )
  end
end
