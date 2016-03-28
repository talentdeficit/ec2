defmodule EC2.Mixfile do
  use Mix.Project

  def project do
    [app: :ec2,
     version: "0.9.1",
     language: :erlang,
     description: description,
     package: package,
     deps: deps]
  end

  def application do
    []
  end

  defp deps do
    [{:jsx, "~> 2.8.0"}]
  end

  defp description do
    """
    helper library for working with aws ec2 metadata
    """
  end

  defp package do
    [files: ["src", "mix.exs", "rebar.config", "LICENSE"],
     maintainers: ["@talentdeficit"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/talentdeficit/ec2"}]
  end
end