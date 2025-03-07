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

## Run the program

cd chat

@terminal1
iex --sname server -S mix

@terminal2
iex --sname proxy proxy_server.ex
> Node.ping(:server@macbookpro30)

@terminal3
elixir clent.ex
> /NICK 1234
> /NICK bart
> /MSG * ;;
> /MSG * hello world

@terminal4
elixir clent.ex
> /NICK lisa
> /LIST
> /MSG * hell world


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/chat>.

