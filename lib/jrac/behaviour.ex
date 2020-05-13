defmodule Jrac.Behaviour do
  @callback do_get_single(String.t(), integer) :: {:ok, any()} | {:error, any()}
  @callback do_get_page(String.t(), integer) :: {:ok, any()} | {:error, any()}
  @callback do_post(String.t(), map) :: {:ok, any()} | {:error, any()}
  @callback do_patch(String.t(), integer, map) :: {:ok, any()} | {:error, any()}
  @callback do_put(String.t(), integer, map) :: {:ok, any()} | {:error, any()}
  @callback do_delete(String.t(), integer) :: {:ok, any()} | {:error, any()}
  @callback build_url(String.t()) :: String.t() | nil
  @callback build_url(String.t(), any()) :: String.t() | nil

  defmacro __using__(app_name: app_name, base_url_key_name: base_url_key_name, headers: headers) do
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
      def do_get_single(endpoint, id) when is_binary(endpoint) do
        with {:ok, response} <- HTTPoison.get(build_url(endpoint, id), unquote(headers)),
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
      %{"page" => "2"} will be transformed into &page=2 in URL

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
               HTTPoison.get(build_url(endpoint, page), unquote(headers)),
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
             {:ok, response} <- HTTPoison.post(build_url(endpoint), encoded, unquote(headers)),
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
               HTTPoison.patch(build_url(endpoint, id), encoded, unquote(headers)),
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
               HTTPoison.patch(build_url(endpoint, id), encoded, unquote(headers)),
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
        with {:ok, response} <- HTTPoison.delete(build_url(endpoint, id), unquote(headers)),
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
      Build a URL for a simple call

      ```
      build_url("users")
      ```

      """
      def build_url(endpoint) when is_binary(endpoint) do
        Application.get_env(unquote(app_name), unquote(base_url_key_name)) <> "/" <> endpoint
      end

      def build_url(_endpoint), do: nil

      @doc """

            Build a URL for a call with an integer id or
            build a URL for a call with parameters

            ```
                  build_url("users", "1")
                  "https://reqres.in/api/users/1"
                  build_url("users", %{"page"=>"2"})
            ```

      """

      def build_url(endpoint, params) when is_binary(endpoint) and is_map(params) do
        url_params =
          params
          |> Enum.reduce([], fn {k, v}, acc -> acc ++ [k <> "=" <> to_string(v)] end)
          |> Enum.join("&")

        Application.get_env(unquote(app_name), unquote(base_url_key_name)) <>
          "/" <> endpoint <> "?" <> url_params
      end

      def build_url(endpoint, id) when is_binary(endpoint) do
        Application.get_env(unquote(app_name), unquote(base_url_key_name)) <>
          "/" <> endpoint <> "/" <> to_string(id)
      end

      def build_url(_endpoint, _id), do: nil
      defoverridable(Jrac.Behaviour)
    end
  end
end
