defmodule Chat.ProxyServer do

  def start_link(port \\ 6666) do
    case :gen_tcp.listen(port, [:binary, active: false, packet: :line, reuseaddr: true]) do
      {:ok, lsocket} -> # return PID for supervisor
        IO.puts("Proxy server listening on port #{port}...")
        Task.start_link(fn -> accept(lsocket) end)
      {:error, reason} ->
        {:error, reason}
    end
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  defp accept(lsocket) do
    case :gen_tcp.accept(lsocket) do
      {:ok, socket} ->
        delivery_pid = spawn(fn -> delivery_loop(socket) end)
        spawn(fn -> command_loop(socket, delivery_pid) end)
        accept(lsocket) # recursively listening
      {:error, reason} ->
        IO.puts("Error: #{inspect(reason)}")
    end
  end

  defp delivery_loop(socket) do # asynchronously print msg
    receive do
      {:deliver, sender, msg} ->
        :gen_tcp.send(socket, "[#{sender}] #{msg} \n")
        delivery_loop(socket)
    end
  end

  defp command_loop(socket, delivery_pid) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        data = String.trim(data)
        response = parse_command(data, delivery_pid)
        :gen_tcp.send(socket, response <> "\n")
        command_loop(socket, delivery_pid)
      {:error, :closed} ->
        IO.puts("Client disconnected.")
    end
  end

  defp parse_command(data, delivery_pid) do
    parts = String.split(data, ~r/\s+/, parts: 2)
    case parts do

      [cmd, nick] when cmd in ["/NICK", "/N"]->
        case GenServer.call({:global, Chat.Server}, {:set_nick, delivery_pid, nick}) do
          {:ok, refined_nick} -> "Nickname set to #{refined_nick}"
          {:error, reason} -> "Error: #{reason}"
        end

      [cmd] when cmd in ["/LIST", "/L"] ->
        nick_list = GenServer.call({:global, Chat.Server}, :list)
        "Nicknames: " <> Enum.join(nick_list, ", ")

      [cmd, rest] when cmd in ["/MSG", "/M"]->
        case String.split(rest, ~r/\s+/, parts: 2) do
          [recipients, message] ->
            case GenServer.call({:global, Chat.Server}, {:msg, delivery_pid, recipients, message}) do
              :ok -> "Message sent."
              {:error, reason} -> "Error: #{reason}"
            end
          _ ->
            "Error: invalid /MSG format"
        end

      # every other command lines
      _ -> "Error: invalid command"
    end
  end
end
