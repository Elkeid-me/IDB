defmodule Idb.MixProject do
  use Mix.Project

  def project do
    [
      app: :idb,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "IDB",
      source_url: "https://github.com/Elkeid-me/IDB",
      homepage_url: "http://elkeid-me.github.io/IDB",
      docs: [
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Idb.Application, []}
    ]
  end

  defp deps do
    [
      {:bandit, "~> 1.0"},
      {:corsica, "~> 2.0"},
      {:ecto_sql, "~> 3.0"},
      {:ex_doc, "~> 0.36", only: :dev, runtime: false},
      {:guardian, "~> 2.3"},
      {:jason, "~> 1.4"},
      {:makeup_json, ">= 0.0.0", only: :dev, runtime: false},
      {:myxql, "~> 0.7"}
    ]
  end
end
