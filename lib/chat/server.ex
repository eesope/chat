defmodule Chat.Server do
  use GenServer
  @store Chat.Store
  # handling nicknames, message dispatching, status store/recover on ETS

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: {:global, __MODULE__})
  end

  # /NICK, /LIST, /MSG 등을 처리하는 API들을 구현
  # 예) Chat.Server.set_nick(pid, nick) 또는 Chat.Server.msg(pid, recipients, message)

  def init(_args) do
    state =
      case :ets.lookup(@store, :chat_state) do
        [{:chat_state, saved_state}] -> saved_state
        [] -> %{} # empty status
    end
    {:ok, state}
  end

  # handle /NICK
  def handle_call({:set_nick, pid, nick}, _from, state) do
    # validate nickname -> store ETS or ask new nickname

    if valid_nick?(nick) and not Map.has_key?(state, nick) do
      new_state = Map.put(state, nick, pid)
      :ets.insert(@store, {:chat_state, new_state})
      {:reply, {:ok, nick}, new_state}
    else
      {:reply, {:error, "Nickname invalid or already in use."}, state}
    end
  end

  #handle /LIST
  def handle_call(:list, _from, state) do
    {:reply, Map.keys(state), state}
  end

  def valid_nick?(nick) do

  end


end
