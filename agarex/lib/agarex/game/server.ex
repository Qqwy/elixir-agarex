defmodule Agarex.Game.Server do
  alias Agarex.Game.State
  use GenServer

  @fps 30
  @tick_ms div(1000, @fps)

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    Process.send_after(self(), :tick, @tick_ms)
    {:ok, %{time: System.monotonic_time(), game_state: State.new()}}
  end

  def add_player(name) do
    GenServer.call(__MODULE__, {:add_player, name})
  end

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

  @impl true
  defp tick(state) do
    new_time = System.monotonic_time()
    delta_time = new_time - state.time

    game_state = State.tick(state.game_state, delta_time)
    Phoenix.PubSub.broadcast(Agarex.PubSub, "game/tick", {"game/tick", game_state})

    %{state | time: new_time, game_state: game_state}
  end
end
