defmodule Agarex.Game.LocalState.Controls do
  defstruct up: false, down: false, left: false, right: false
  def new() do
    %__MODULE__{}
  end

  def handle_event(event, params, struct) do
    case event do
      ["key_up"] ->
        key_up(struct, params["key"])
      ["key_down"] ->
        key_down(struct, params["key"])
    end
  end

  def key_up(controls, key_str) do
    case translate(key_str) do
      nil -> controls
      key ->
        put_in(controls, [Access.key(key)], false)
    end
  end

  def key_down(controls, key_str) do
    case translate(key_str) do
      nil -> controls
      key ->
        put_in(controls, [Access.key(key)], true)
    end
  end

  def to_velocity(c) do
    horizontal = bool_to_int(c.right) - bool_to_int(c.left)
    vertical = bool_to_int(c.down) - bool_to_int(c.up)
    {horizontal, vertical}
  end

  defp bool_to_int(false), do: 0
  defp bool_to_int(true), do: 1

  defp translate(key_str)
  defp translate("ArrowUp"), do: :up
  defp translate("ArrowDown"), do: :down
  defp translate("ArrowLeft"), do: :left
  defp translate("ArrowRight"), do: :right
  defp translate(_), do: nil

  def broadcast_velocity(controls, player_id) do
    Phoenix.PubSub.broadcast(Agarex.PubSub, "game/player_velocity", {"game/player_velocity", %{player_id: player_id, velocity: to_velocity(controls)}})
  end
end
