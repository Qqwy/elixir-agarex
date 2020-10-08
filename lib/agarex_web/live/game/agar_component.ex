defmodule AgarexWeb.Game.AgarComponent do
  use Phoenix.LiveComponent
  @moduledoc """
  Stateless LiveComponent in charge of rendering a piece of Agar.

  Arguably we could have used a function for this instead
  of an extra component, but the fact that we want helpers like
  calculating the relative position is the reason I chose not to.
  """

  defp relative_position(agar, current_player) do
    {x, y} = agar.position
    {cx, cy} = current_player.position
    dx = x - cx
    dy = y - cy

    {dx, dy}
  end
end
