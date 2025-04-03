defmodule Idb.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    port = Application.get_env(:idb, :port, 8000)
    children = [{Bandit, plug: Idb.Router, scheme: :http, port: port}, Idb.Repo]
    opts = [strategy: :one_for_one, name: Idb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
