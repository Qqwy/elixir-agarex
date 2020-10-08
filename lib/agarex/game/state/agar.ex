defmodule Agarex.Game.State.Agar do
  alias Agarex.Game.State

  defstruct [:position, :size]
  def new() do
    %__MODULE__{
      position: {State.board_width() * :random.uniform(), State.board_height() * :random.uniform()},
      size: 1
    }
  end
end
