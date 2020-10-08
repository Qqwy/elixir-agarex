defmodule Agarex.Game.Server.State do
  alias __MODULE__.World

  defstruct [:start_time, :time, :game_state, :last_game_scores]

  def new(last_game_scores \\ []) do
    start_time = System.monotonic_time()
    %__MODULE__{start_time: start_time, time: start_time, game_state: World.new(), last_game_scores: last_game_scores}
  end
end
