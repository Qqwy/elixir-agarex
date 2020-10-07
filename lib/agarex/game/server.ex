defmodule Agarex.Game.Server do
  alias Agarex.Game.State
  use GenServer

  @fps 30
  @tick_ms div(1000, @fps)

  @game_round_length 180

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    Process.send_after(self(), :tick, @tick_ms)
    Phoenix.PubSub.subscribe(Agarex.PubSub, "game/player_velocity")
    {:ok, initial_state()}
  end

  defp initial_state(last_game_scores \\ []) do
    start_time = System.monotonic_time()
    %{start_time: start_time, time: start_time, game_state: State.new(), last_game_scores: last_game_scores}
  end

  def add_player(name) do
    GenServer.call(__MODULE__, {:add_player, name})
  end

  @impl true
  def handle_call({:add_player, name}, _from, state) do
    {game_state, player_index} = State.add_player(state.game_state, name)
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
    state = update_in(state, [Access.key(:game_state), Access.key(:players), player_id], &State.Player.alter_velocity(&1, velocity))
    {:noreply, state}
  end

  defp tick(state) do
    new_time = System.monotonic_time()
    delta_time = new_time - state.time

    total_time = new_time - state.start_time
    rest_seconds = @game_round_length - System.convert_time_unit(total_time, :native, :second)

    game_state = State.tick(state.game_state, delta_time)

    scores = State.highscores(game_state)


    if rest_seconds < 0 do
      Phoenix.PubSub.broadcast(Agarex.PubSub, "game/over", {"game/over", %{}})
      initial_state(scores)
    else
      Phoenix.PubSub.broadcast(Agarex.PubSub, "game/scores", {"game/scores", %{scores: scores, time: rest_seconds, last_game_scores: state.last_game_scores}})
      Phoenix.PubSub.broadcast(Agarex.PubSub, "game/tick", {"game/tick", %{game_state: game_state}})

      %{state | time: new_time, game_state: game_state}
    end
  end
end
