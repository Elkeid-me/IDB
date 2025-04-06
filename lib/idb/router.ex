defmodule Idb.AuthRouter do
  @moduledoc """
  身份验证路由

  所有需要登录的请求被 `Idb.Router` 转发到此处。
  """
  alias Idb.{Users, Passwords}
  use Plug.Router
  plug(Idb.AuthPipeline)
  plug(:match)
  plug(:dispatch)

  get("/api/v1/item/list/", to: Passwords.List)

  post("/api/v1/item/add/", to: Passwords.Add)
  post("/api/v1/item/delete/", to: Passwords.Delete)
  post("/api/v1/item/edit/", to: Passwords.Edit)
  post("/api/v1/item/search/", to: Passwords.Search)
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

  post("/api/v1/user/register/", to: Users.Register)
  post("/api/v1/user/login/", to: Users.Login)

  get("/api/v1/item/list/", to: Idb.AuthRouter)

  post("/api/v1/item/add/", to: Idb.AuthRouter)
  post("/api/v1/item/delete/", to: Idb.AuthRouter)
  post("/api/v1/item/edit/", to: Idb.AuthRouter)
  post("/api/v1/item/search/", to: Idb.AuthRouter)

  match _ do
    Utils.send_detail(
      conn,
      "请求的 API 不存在，或方法不被允许",
      404
    )
  end
end
