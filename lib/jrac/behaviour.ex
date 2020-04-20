defmodule Jrac.Behaviour do
  @callback do_get_single(String.t(), integer) :: {:ok, any()} | {:error, any()}
  @callback do_get_page(String.t(), integer) :: {:ok, any()} | {:error, any()}
  @callback do_post(String.t(), map) :: {:ok, any()} | {:error, any()}
  @callback do_patch(String.t(), integer, map) :: {:ok, any()} | {:error, any()}
  @callback do_put(String.t(), integer, map) :: {:ok, any()} | {:error, any()}
  @callback do_delete(String.t(), integer) :: {:ok, any()} | {:error, any()}
  @callback build_uri(String.t()) :: String.t() | nil
  @callback build_uri(String.t(), integer | map) :: String.t() | nil

  require Logger

  defmacro __using__(base_url: base_url, headers: headers) do
    quote do
      @behaviour Jrac.Behaviour

      @get_success_code 200
      @post_success_code 201
      @patch_success_code 200
      @put_success_code 200
      @delete_success_code 204

      @doc """
      Perform a GET request to fetch a single object

      ```
      do_get_single("users", "1")
      ```

      """
      @spec do_get_single(String.t(), integer) :: {:ok, any()} | {:error, any()}
      def do_get_single(endpoint, id) when is_binary(endpoint) and is_binary(id) do
        with {:ok, response} <- HTTPoison.get(build_uri(endpoint, id), unquote(headers)),
             {:status_code, @get_success_code} <- {:status_code, response.status_code},
             {:ok, decoded} <- Poison.decode(response.body) do
          {:ok, decoded}
        else
          error -> {:error, error}
        end
      end

      def(do_get_single(endpoint, id),
        do: {:error, [:invalid_arguments, endpoint, id]}
      )

      @doc """
      Perform a GET request to fetch a page of objects

      Second parameter is a pagination vector in form of arbitrary map.
      %{"page" => "2"} will be transformed into &page=2 in URI

      ```
      do_get_page("users", %{"page" => "2"})
      ```

      """
      @spec do_get_page(String.t(), integer) :: {:ok, any()} | {:error, any()}

      def do_get_page(
            endpoint,
            %{} = page
          )
          when is_binary(endpoint) do
        with {:ok, response} <-
               HTTPoison.get(build_uri(endpoint, page), unquote(headers)),
             {:status_code, @get_success_code} <- {:status_code, response.status_code},
             {:ok, decoded} <- Poison.decode(response.body) do
          {:ok, decoded}
        else
          error -> {:error, error}
        end
      end

      def(do_get_page(endpoint, page),
        do: {:error, [:invalid_arguments, endpoint, page]}
      )

      @doc """
      Perform a PUT request to create an object

      ```
      do_post("users", data_struct)
      ```

      """
      @spec do_post(String.t(), map) :: {:ok, any()} | {:error, any()}
      def do_post(endpoint, data_struct)
          when is_binary(endpoint) and is_map(data_struct) do
        with {:ok, encoded} <- Poison.encode(data_struct),
             {:ok, response} <- HTTPoison.post(build_uri(endpoint), encoded, unquote(headers)),
             {:status_code, @post_success_code} <- {:status_code, response.status_code},
             {:ok, decoded} <- Poison.decode(response.body) do
          {:ok, decoded}
        else
          error -> {:error, error}
        end
      end

      def(do_post(endpoint, data_struct),
        do: {:error, [:invalid_arguments, endpoint, data_struct]}
      )

      @doc """
      Perform a PATCH request to partially update an object

      ```
      do_patch("users", "1", %{"key"=>"val"})
      ```

      """
      @spec do_patch(String.t(), integer, map) :: {:ok, any()} | {:error, any()}
      def do_patch(endpoint, id, kv_map)
          when is_binary(endpoint) and is_map(kv_map) and is_binary(id) do
        with {:ok, encoded} <- Poison.encode(kv_map),
             {:ok, response} <-
               HTTPoison.patch(build_uri(endpoint, id), encoded, unquote(headers)),
             {:status_code, @patch_success_code} <- {:status_code, response.status_code},
             {:ok, decoded} <- Poison.decode(response.body) do
          {:ok, decoded}
        else
          error -> {:error, error}
        end
      end

      def(do_patch(endpoint, id, kv_map),
        do: {:error, [:invalid_arguments, endpoint, id, kv_map]}
      )

      @doc """
      Perform a PUT request to completely replace an object

      ```
      do_put("users", "1", data_struct)
      ```

      """
      @spec do_put(String.t(), integer, map) :: {:ok, any()} | {:error, any()}
      def do_put(endpoint, id, data_struct)
          when is_binary(endpoint) and is_map(data_struct) and is_binary(id) do
        with {:ok, encoded} <- Poison.encode(data_struct),
             {:ok, response} <-
               HTTPoison.patch(build_uri(endpoint, id), encoded, unquote(headers)),
             {:status_code, @put_success_code} <- {:status_code, response.status_code},
             {:ok, decoded} <- Poison.decode(response.body) do
          {:ok, decoded}
        else
          error -> {:error, error}
        end
      end

      def(do_put(endpoint, id, data_struct),
        do: {:error, [:invalid_arguments, endpoint, id, data_struct]}
      )

      @doc """
      Perform a DELETE request to delete an object

      ```
      do_delete("users", "1")
      ```

      """
      @spec do_delete(String.t(), integer) :: {:ok, any()} | {:error, any()}
      def do_delete(endpoint, id) when is_binary(endpoint) and is_binary(id) do
        with {:ok, response} <- HTTPoison.delete(build_uri(endpoint, id), unquote(headers)),
             {:status_code, @delete_success_code} <- {:status_code, response.status_code} do
          {:ok}
        else
          error -> {:error, error}
        end
      end

      def(do_delete(endpoint, id),
        do: {:error, [:invalid_arguments, endpoint, id]}
      )

      @doc """
      Build a URI for a simple call

      ```
      build_uri("users")
      ```

      """
      @spec build_uri(String.t()) :: String.t() | nil
      def build_uri(endpoint) when is_binary(endpoint) do
        unquote(base_url) <> "/" <> endpoint
      end

      @spec build_uri(String.t(), map) :: String.t() | nil
      def build_uri(endpoint, params) when is_binary(endpoint) and is_map(params) do
        uri_params =
          params
          |> Enum.reduce([], fn {k, v}, acc -> acc ++ [k <> "=" <> v] end)
          |> Enum.join("&")

        unquote(base_url) <> "/" <> endpoint <> "?" <> uri_params
      end

      @doc """
      Build a URI for a call with an integer id or
      build a URI for a call with parameters

      ```
      build_uri("users", "1")
      "https://reqres.in/api/users/1"
      build_uri("users", %{"page"=>"2"})
      "https://reqres.in/api/users/?page=2"
      ```

      """
      @spec build_uri(String.t(), integer) :: String.t() | nil
      def build_uri(endpoint, id) when is_binary(endpoint) and is_binary(id) do
        unquote(base_url) <> "/" <> endpoint <> "/" <> to_string(id)
      end

      def build_uri(_endpoint, _id), do: nil
      defoverridable(Jrac.Behaviour)
    end
  end
end
