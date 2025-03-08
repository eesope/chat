defmodule Chat.Server do
  use GenServer
  @store Chat.Store
  # handling nicknames, message dispatching, status store/recover on ETS

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: {:global, __MODULE__})
  end

  def init(_args) do
    state =
      case :ets.lookup(@store, :chat_state) do
        [{:chat_state, saved_state}] -> saved_state
        [] -> %{} # start with empty status
    end
    {:ok, state}
  end

  # handle /NICK
  def handle_call({:set_nick, pid, nick}, _from, state) do
    refine_nick = nick |> String.split(~r/\s+/, parts: 2) |> List.first()
    if valid_nick?(refine_nick) and not Map.has_key?(state, refine_nick) do
      state = remove_old_nick(state, pid)
      Process.monitor(pid)
      new_state = Map.put(state, refine_nick, pid)
      :ets.insert(@store, {:chat_state, new_state})
      {:reply, {:ok, refine_nick}, new_state}
    else
      {:reply, {:error, "Nickname invalid or already in use."}, state}
    end
  end

  # handle /LIST
  def handle_call(:list, _from, state) do
    {:reply, Map.keys(state), state}
  end

  # handle /MSG
  def handle_call({:msg, sender_pid, recipients, msg}, _from, state) do
    case Enum.find(state, fn {_nick, pid} -> pid == sender_pid end) do
      {sender_nick, _} ->
        cond do
          recipients == "*" ->
            Enum.each(state, fn {_nick, pid} -> send(pid, {:deliver, sender_nick, msg}) end)
          true ->
            recipients_list =
              recipients
              |> String.split(",")
              |> Enum.map(&String.trim/1)
            Enum.each(recipients_list, fn nick ->
              if Map.has_key?(state, nick) do
                send(state[nick], {:deliver, sender_nick, msg})
              end
            end)
        end
        {:reply, :ok, state}
        nil ->
          {:reply, {:error, "You need to register a nickname before sending message."}, state}
    end
  end


  defp valid_nick?(nick) do
    String.match?(nick, ~r/^[A-Za-z][A-Za-z0-9]{0,11}$/)
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    new_state =
      state
      |> Enum.reject(fn {_nick, p} -> p == pid end)
      |> Enum.into(%{})
    :ets.insert(@store, {:chat_state, new_state})
    {:noreply, new_state}
  end

  defp remove_old_nick(state, pid) do
    case Enum.find(state, fn {_nick, p} -> p == pid end) do
      {old_nick, _} -> Map.delete(state, old_nick)
      nil -> state
    end
  end
end
