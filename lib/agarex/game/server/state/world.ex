defmodule Agarex.Game.Server.State.World do
  alias __MODULE__.{Player, Agar}

  @agar_count 50

  defstruct [:players, :agar]

  def new() do
    %__MODULE__{
      players: Arrays.new(),
      agar: init_agar(),
    }
  end

  defp init_agar() do
    for id <- (0..@agar_count), into: %{} do
      {id, Agar.new()}
    end
  end

  def add_player(state, name) do
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
    state = Enum.reduce(colliding_players(state), state, &eat_smaller_feed_larger/2)
    state = Enum.reduce(players_colliding_with_agar(state), state, &eat_agar/2)
  end

  defp colliding_players(state) do
    alive_players = alive_players(state)

    for {a, a_id} <- alive_players,
      {b, b_id} <- alive_players,
      a_id != b_id,
      a.size < b.size,
      Player.collide?(a, b) do
        {a_id, b_id}
    end
  end

  defp eat_smaller_feed_larger({smaller_id, larger_id}, state) do
    smaller_size = get_in(state, [Access.key(:players), smaller_id, Access.key(:size)])

    update_in(state.players, fn players ->
      players
      |> update_in([smaller_id], &Player.kill/1)
      |> update_in([larger_id], &Player.grow(&1, smaller_size))
    end)
  end

  defp players_colliding_with_agar(state) do
    alive_players = alive_players(state)
    agar = state.agar
    for {agar_id, agar} <- agar,
      {player, player_id} <- alive_players,
      Player.collide?(player, agar) do
        {agar_id, player_id}
    end
  end

  defp eat_agar({agar_id, player_id}, state) do
    state
    |> update_in([Access.key(:players), player_id], &Player.grow(&1, 2))
    |> update_in([Access.key(:agar), agar_id], fn _ -> Agar.new() end)
  end

  defp alive_players(state) do
    state.players
    |> Arrays.to_list
    |> Enum.with_index
    |> Enum.filter(fn {player, _index} ->  player.alive? end)
  end

  def highscores(state) do
    state.players
    |> Enum.sort_by(fn player -> player.size end, :desc)
    |> Enum.map(fn player -> {player.name, player.size} end)
    |> Enum.uniq_by(fn {name, size} -> name end) # Keeps first, e.g. highest, occurrence of a name
  end

  def board_width() do
    300
  end

  def board_height() do
    300
  end
end
