defmodule TCPClient do

  def connect(host, port) do
    case :gen_tcp.connect(host, port, [:binary, active: false, packet: :line]) do
      {:ok, socket} ->
        loop(socket)
      {:error, reason} ->
        IO.puts("Connection failed: #{inspect(reason)}")
        {:error, reason}
    end
  end


  defp loop(socket) do
    case IO.gets("> ") do
      :eof ->
        :gen_tcp.close(socket)
      data ->
        :gen_tcp.send(socket, data)
        {:ok, reply} = :gen_tcp.recv(socket, 0, 3000)
        IO.write(reply)
        loop(socket)
    end
  end
end

with [host, port | _] <- System.argv(),
      {port, ""} <- Integer.parse(port)
do
  TCPClient.connect(String.to_atom(host), port)
else
  _ -> TCPClient.connect(:localhost, 6666)
end

# TCPClient.connect("localhost", 6666)
