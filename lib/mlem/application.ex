defmodule Mlem.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # # Start the Ecto repository
      # supervisor(LiveCircle.Repo, []),
      # # Start the endpoint when the application starts
      worker(Mlem.ModelRegistry, []),
      worker(Mlem.ModelServer, []),
      # # Start your own worker by calling: LiveCircle.Worker.start_link(arg1, arg2, arg3)
      # worker(LiveCircle.Ports.PythonPool, []),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mlem.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
