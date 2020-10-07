defmodule Agarex.Game.State.Agar do
  defstruct [:position, :size]
  def new() do
    %__MODULE__{
      position: {300 * :random.uniform(), 300 * :random.uniform()},
      size: 1
    }
  end
end
