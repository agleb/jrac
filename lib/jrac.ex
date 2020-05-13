defmodule Jrac do

  @moduledoc """
  Jrac - JSON RESTful API client.

  Jrac is a boilerplate for writing RESTful API consuming apps.

  Note that Jrac does not support JSON API spec.

  Jrac was made to consume simple RESTful APIs with JSON-encoded output.

  use Jrac.Behaviour, app_name: :jrac, base_url: "https://reqres.in/api", headers: [{"Accept", "application/json"}]

  """
end
