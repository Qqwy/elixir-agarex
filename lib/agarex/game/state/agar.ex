defmodule Agarex.Game.State.Agar do
  defstruct [:position, :size]
  def new() do
    %__MODULE__{
      position: {100 * :random.uniform(), 100 * :random.uniform()},
      size: 1
    }
  end
end
