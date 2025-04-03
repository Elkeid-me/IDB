defmodule Idb.Repo do
  use Ecto.Repo, otp_app: :idb, adapter: Ecto.Adapters.MyXQL
end
