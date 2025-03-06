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
Assume machine name is elixir

1. In project folder start server:
$ iex --sname bart -S mix
iex(bart@elixir)>

2. On another terminal:
$ iex --sname homer

3. Check connection
iex(homer@elixir)> Node.ping(:bart@elixir)

case reply:
:pong <- success
:pang <- fail


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/chat>.

