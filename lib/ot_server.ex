defmodule OTServer do
  use Application

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: OTServer.Router,
        options: [
          dispatch: dispatch(),
          port: 4000
        ]
      ),
      Registry.child_spec(
        keys: :duplicate,
        name: Registry.OTServer,
        partitions: System.schedulers_online()
      ),
    ]
    opts = [strategy: :one_for_one, name: OTServer.Application]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_,
        [
          {"/ws/[...]", OTServer.SocketHandler, []},
          {:_, Plug.Cowboy.Handler, {OTServer.Router, []}}
        ]
      }
    ]
  end
end
