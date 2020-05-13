# Jrac

[![Hex.pm](https://img.shields.io/hexpm/v/jrac.svg)](https://hex.pm/packages/jrac)

Jrac - JSON RESTful API client.

Jrac is a boilerplate for writing RESTful API consuming apps.

Methods: GET, POST, PUT, PATCH, DELETE

Note that Jrac does not support JSON API spec.

Jrac was made to consume simple RESTful APIs with JSON-encoded output.
The header "application/json" will be send to inform the API that.

Jrac is adaptive - you can override all methods as and when needed.

## Installation

Add `jrac` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:jrac, "~> 0.1.0"}
  ]
end
```

Add API base url to config

```elixir

config :jrac, base_url_key: "https://reqres.in/api"


```

## Usage

```elixir

# Set the URL for your API, set headers to be sent with each request
  use Jrac.Behaviour,
    app_name: :jrac,
    base_url_key_name: :base_url_key,
    headers: [{"Accept", "application/json"}]

case do_get_single("users", 4) do
  {:ok, user} -> user
  {:error, description} -> {:error, description}
  {:error, {:status_code, 404}} -> :not_found
  {:error, {:status_code, 500}} -> :shipwreck
end

...

```

## License

MIT.
