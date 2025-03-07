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
    if valid_nick?(nick) and not Map.has_key?(state, nick) do
      state = remove_old_nick(state, pid)
      Process.monitor(pid)
      new_state = Map.put(state, nick, pid)
      :ets.insert(@store, {:chat_state, new_state})
      {:reply, {:ok, nick}, new_state}
    else
      {:reply, {:error, "Nickname invalid or already in use."}, state}
    end
  end

  # handle /LIST
  def handle_call(:list, _from, state) do
    {:reply, Map.keys(state), state}
  end

  def handle_call({:msg, sender_pid, recipients, msg}, _from, state) do
    sender_nick = case Enum.find(state, fn {_nick, pid} -> pid == sender_pid end) do
      {nick, _} -> nick
      nil -> "Unknown"
    end
    cond do
      recipients == "*" -> # all recipients
        Enum.each(state, fn {_nick, pid} -> send(pid, {:deliver, sender_nick, msg}) end)
      true -> # each recipient
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
