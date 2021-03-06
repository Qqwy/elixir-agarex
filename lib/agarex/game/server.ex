defmodule Agarex.Game.Server do
  alias Agarex.Game.Server.State
  use GenServer

  @fps 30
  @tick_ms div(1000, @fps)

  @game_round_length 180

  @moduledoc """
  A named GenServer which runs the Agar game.

  Dispatches a `tick` message to itself every #{@tick_ms} milliseconds,
  which then runs an update of the world state (thus at ~#{@fps} frames per second).

  After #{@game_round_length} seconds, the state of the GenServer is reset,
  to run the next game round.
  """


  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    Process.send_after(self(), :tick, @tick_ms)
    Phoenix.PubSub.subscribe(Agarex.PubSub, "game/player_velocity")
    {:ok, State.new()}
  end

  def add_player(name) do
    GenServer.call(__MODULE__, {:add_player, name})
  end

  @impl true
  def handle_call({:add_player, name}, _from, state) do
    {game_state, player_index} = State.World.add_player(state.game_state, name)
    state = put_in(state.game_state, game_state)
    {:reply, player_index, state}
  end

  @impl true
  def handle_info(:tick, state) do
    Process.send_after(self(), :tick, @tick_ms)
    state = tick(state)
    {:noreply, state}
  end

  def handle_info({"game/player_velocity", %{player_id: player_id, velocity: velocity}}, state) do
    state = update_in(state, [Access.key(:game_state), Access.key(:players), player_id], &State.World.Player.alter_velocity(&1, velocity))
    {:noreply, state}
  end

  defp tick(state) do
    new_time = System.monotonic_time()
    delta_time = new_time - state.time

    total_time = new_time - state.start_time
    rest_seconds = @game_round_length - System.convert_time_unit(total_time, :native, :second)

    game_state = State.World.tick(state.game_state, delta_time)

    scores = State.World.highscores(game_state)


    if rest_seconds < 0 do
      Phoenix.PubSub.broadcast(Agarex.PubSub, "game/over", {"game/over", %{}})
      State.new(scores)
    else
      Phoenix.PubSub.broadcast(Agarex.PubSub, "game/scores", {"game/scores", %{scores: scores, time: rest_seconds, last_game_scores: state.last_game_scores}})
      Phoenix.PubSub.broadcast(Agarex.PubSub, "game/tick", {"game/tick", %{game_state: game_state}})

      %{state | time: new_time, game_state: game_state}
    end
  end
end
