defmodule Agarex.Game.Server.State.World.Agar do
  alias Agarex.Game.Server.State.World

  @moduledoc """
  A very simple struct,
  containing the position of a particular piece of 'agar',
  the food that all players can eat.
  """

  defstruct [:position, :size]
  def new() do
    %__MODULE__{
      position: {World.board_width() * :random.uniform(), World.board_height() * :random.uniform()},
      size: 1
    }
  end
end
