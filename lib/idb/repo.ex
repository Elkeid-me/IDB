defmodule Idb.Repo do
  @moduledoc false

  use Ecto.Repo, otp_app: :idb, adapter: Ecto.Adapters.MyXQL
end
