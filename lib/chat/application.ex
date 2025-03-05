defmodule Chat.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Chat.Worker.start_link(arg)
      # {Chat.Worker, arg}
      Chat.Supervisor
    ]

    # init ets table @program start -> save state; recover from crashes
    :ets.new(Chat.Store, [:named_table, :public])

    opts = [strategy: :one_for_one, name: Chat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
