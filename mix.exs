defmodule EXRequester.Mixfile do
  use Mix.Project

  def project do
    [app: :exrequester,
    version: "0.0.1",
    elixir: "~> 1.0",
    build_embedded: Mix.env == :prod,
    start_permanent: Mix.env == :prod,
    deps: deps]
  end

  def application do
    [applications: [:logger, :httpotion, :ibrowse]]
  end

  defp deps do
    [{:httpotion, "~> 2.2.0"},
    {:poison, "~> 1.5"},
    {:httpotion, "~> 2.2"}]
  end
end
