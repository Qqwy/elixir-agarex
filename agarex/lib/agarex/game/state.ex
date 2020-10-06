defmodule Agarex.Game.State do
  alias __MODULE__.Player

  defstruct [:players]

  def new() do
    %__MODULE__{
      players: %{0 => Player.new()}
    }
  end

  def tick(state, dt) do
    state
    |> move_players(dt)
    |> resolve_collisions()
  end

  defp move_players(state, dt) do
    updated_players =
      state.players
      |> Enum.map(&Player.tick(&1, dt))

    %{state | players: updated_players}
  end

  defp resolve_collisions(state) do
    Enum.reduce(colliding_players(state), state, &eat_smaller_feed_larger/2)
  end

  defp colliding_players(state) do
    alive_players =
      state.players
      |> Enum.filter(&(&1.alive?))

    for {a_id, a} <- alive_players,
      {b_id, b} <- alive_players,
      a.alive?,
      b.alive?,
      a_id != b_id,
      collide?(a, b) do
        cond do
          a.size == b.size -> nil
          a.size < b.size -> {a_id, b_id}
          a.size > b.size -> {b_id, a_id}
        end
    end
    |> Enum.filter(&(&1 == nil))
  end

  defp eat_small_feed_larger({smaller_id, larger_id}, state) do
    smaller_size = get_in(state, [Access.key(:players), smaller_id, Access.key(:size)])

    update_in(state.players, fn players ->
      players
      |> update_in(smaller_id, &Player.kill/1)
      |> update_in(larger_id, &Player.grow(&1, smaller_size))
    end)
  end

  def add_new_player(state, name) do
    
  end
end
