defmodule Jrac.Error do
  defexception [:message]

  @impl true
  def exception(%{call: call, details: details}) do
    msg = "Jrac.Error at #{inspect(call)} with #{inspect(details)}"
    %Jrac.Error{message: msg}
  end
end
