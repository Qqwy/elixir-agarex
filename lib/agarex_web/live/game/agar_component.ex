defmodule AgarexWeb.Game.AgarComponent do
  use Phoenix.LiveComponent

  defp relative_position(agar, current_player) do
    {x, y} = agar.position
    {cx, cy} = current_player.position
    dx = x - cx
    dy = y - cy

    {dx, dy}
  end
end
