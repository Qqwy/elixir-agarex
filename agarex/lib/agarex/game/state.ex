defmodule Agarex.Game.State do
  alias __MODULE__.Player

  defstruct [:players]

  def new() do
    %__MODULE__{
      players: [Player.new()]
    }
  end

  def tick(state, delta_time) do
    updated_players =
      state.players
      |> Enum.map(&Player.tick(&1, delta_time))

    %{state | players: updated_players}
    # TODO players eating each-other
  end
end
