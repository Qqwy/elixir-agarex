defmodule Agarex.Game do
  alias __MODULE__.State
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
