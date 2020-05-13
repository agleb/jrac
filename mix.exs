defmodule Jrac.MixProject do
  use Mix.Project

  def project do
    [
      app: :jrac,
      version: "0.3.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      deps: deps(),
      name: "jrac",
      description: description(),
      source_url: "https://github.com/agleb/jrac",
      ignore_apps: [:httpoison]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.6"},
      {:poison, "~> 3.1"},
      {:ex_doc, "~> 0.14", only: :dev}
    ]
  end

  defp package() do
    [
      name: "jrac",
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Gleb Andreev"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/agleb/jrac"}
    ]
  end

  defp description() do
    "JSON RESTful API client"
  end

end
