defmodule Chat.Server do
  use GenServer
  @store Chat.Store
  # dispatching messages and handling nicknames
  # 닉네임 관리, 메시지 디스패칭, ETS 기반 상태 저장 및 복원

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via(name))
  end

  def via(name) do
    {:via, :global, {__MODULE__, name}}
  end


  def init(name) do
    value =
      case :ets.lookup(@store, name) do
        [{^name, v}] -> v
        _ -> IO.puts("Nickname not set yet.")
      end
      {:ok, {name, value}}
  end



end
