import Config

config :idb, Idb.Auth,
  issuer: "idb",
  secret_key: ""

config :idb, Idb.AuthPipeline,
  module: Idb.Auth,
  error_handler: Idb.AuthErrorHandler

config :jose,
  json_module: Jason

config :idb, Idb.Repo,
  database: "",
  username: "",
  password: "",
  hostname: "",
  port: 0,
  log: false

config :idb,
  port: 0,
  ecto_repos: [Idb.Repo]
