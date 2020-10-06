defmodule Agarex.Local.Controls do
  defstruct up: false, down: false, left: false, right: false
  def new() do
    %__MODULE__{}
  end

  def handle_event(event, params, struct) do
    case event do
      ["key_up"] ->
        key_up(struct, params["key"])
      ["key_down"] ->
        key_up(struct, params["key"])
    end
  end

  def key_up(controls, key_str) do
    put_in(controls, [Access.key(translate(key_str))], true)
  end

  def key_down(controls, key_str) do
    put_in(controls, [Access.key(translate(key_str))], false)
  end

  def to_velocity(c) do
    horizontal = (c.left && -1) + (c.right && 1)
    vertical = (c.down && -1) + (c.up && -1)
    {horizontal, vertical}
  end

  defp translate(key_str)
  defp translate("ArrowUp"), do: :up
  defp translate("ArrowDown"), do: :down
  defp translate("ArrowLeft"), do: :left
  defp translate("ArrowRight"), do: :right

  def broadcast_velocity(controls, player_id) do
    Phoenix.PubSub.broadcast(Agarex.PubSub, "game/player_velocity", {"game/player_velocity", %{player_id: player_id}, to_velocity(controls)})
  end
end
