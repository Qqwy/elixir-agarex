defmodule AgarexWeb.Game.PlayerComponent do
  use Phoenix.LiveComponent

  def relative_size_class(other_player, current_player) do
    case other_player.size - current_player.size do
                             res when res < 0 -> "smaller"
                             res when res > 0 -> "bigger"
                             _ -> "same_size"
    end
  end
end
