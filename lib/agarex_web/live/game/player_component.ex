defmodule AgarexWeb.Game.PlayerComponent do
  use Phoenix.LiveComponent

  @moduledoc """
  Stateless LiveComponent in charge of rendering a player character in the game world.
  """

  defp relative_position(player, current_player) do
    {x, y} = player.position
    {cx, cy} = current_player.position
    dx = x - cx
    dy = y - cy

    {dx, dy}
  end

  defp relative_size_class(other_player, current_player) do
    case other_player.size - current_player.size do
                             res when res < 0 -> "smaller"
                             res when res > 0 -> "bigger"
                             _ -> "same_size"
    end
  end
end
