defmodule Agarex.Game.State do
  alias __MODULE__.Player

  defstruct [:players]

  def new() do
    %__MODULE__{
      players: Arrays.new()
    }
  end

  def add_player(state, name) do
    IO.inspect("Adding player: #{name}")
    state = update_in(state.players, fn players ->
      Arrays.append(players, Player.new(name))
    end)
    player_index = Arrays.size(state.players) - 1
    {state, player_index}
  end

  def tick(state, dt) do
    state
    |> move_players(dt)
    |> resolve_collisions()
  end

  defp move_players(state, dt) do
    update_in(state.players, fn players ->
      Arrays.map(players, fn _, player -> Player.move(player, dt) end)
    end)
  end

  defp resolve_collisions(state) do
    Enum.reduce(colliding_players(state), state, &eat_smaller_feed_larger/2)
  end

  defp colliding_players(state) do
    alive_players =
      state.players
      |> Arrays.to_list
      |> Enum.with_index
      |> Enum.filter(fn {player, _index} ->  player.alive? end)

    for {a, a_id} <- alive_players,
      {b, b_id} <- alive_players,
      a.alive?,
      b.alive?,
      a_id != b_id,
      a.size < b.size,
      Player.collide?(a, b) do
        {a_id, b_id}
    end
  end

  defp eat_smaller_feed_larger({smaller_id, larger_id}, state) do
    IO.inspect({smaller_id, larger_id})
    IO.inspect(state.players)
    smaller_size = get_in(state, [Access.key(:players), smaller_id, Access.key(:size)])

    update_in(state.players, fn players ->
      players
      |> update_in([smaller_id], &Player.kill/1)
      |> update_in([larger_id], &Player.grow(&1, smaller_size))
    end)
  end
end
