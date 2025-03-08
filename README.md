# Chat

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `chat` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:chat, "~> 0.1.0"}
  ]
end
```

## Test/Run the program

@terminal1

cd chat 

iex --sname server -S mix

@terminal2

cd chat/lib/chat

elixir tcp_clent.ex

> /NICK 1234

> /NICK bart

> /MSG * ;;

> /MSG * hello world

@terminal3

cd chat/lib/chat

elixir clent.ex

> /NICK lisa

> /LIST

> /MSG * hell world

@terminal4 <- if you want to test ping pong

cd chat/lib/chat

iex --sname proxy proxy_server.ex

> Node.ping(:server@macbookpro30)


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/chat>.

