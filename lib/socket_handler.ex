defmodule OTServer.SocketHandler do
  @behaviour :cowboy_websocket

  # taken from https://medium.com/@loganbbres/elixir-websocket-chat-example-c72986ab5778

  def init(request, _state) do
    state = %{registry_key: request.path, content: ""}

    {:cowboy_websocket, request, state}
  end

  def websocket_init(state) do
    {:ok, pid} =
    Registry.OTServer
    |> Registry.register(state.registry_key, {})

    {[{:text, state.content}], state}
  end

  def websocket_handle({:text, instruction}, %{content: text_content} = state) do
    [op, char, pos, _] = String.split(instruction, ["(", ",", ")"])
    {bef, aft} = String.split_at(text_content, String.to_integer(pos))
    text_content = do_operation(op, char, bef, aft)
    state = %{state | content: text_content}

    Registry.OTServer
    |> Registry.dispatch(state.registry_key, fn entries ->
      for {pid, _} <- entries do
        if pid != self() do
          Process.send(pid, state.content, [])
        end
      end
    end)

    {:reply, {:text, text_content}, state}
  end

  def do_operation("insert", char, bef, aft), do: bef <> char <> aft
  def do_operation("delete", char, bef, aft) do
    bef <> String.replace_prefix(aft, char, "")
  end

  def websocket_info(text_content, state) do
    state = %{state | content: text_content}
    {:reply, {:text, text_content}, state}
  end
end
