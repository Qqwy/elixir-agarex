defmodule Agarex.Game.State.Player do
  defstruct [:name, :score, :position, :direction]

  @movement_speed 1/200000000

  def new() do
    %__MODULE__{
      name: "",
      score: 0,
      position: {10, 20},
      direction: {1, 1}
      }
  end

  def tick(player, delta_time) do
    {x, y} = player.position
    {vx, vy} = player.direction
    put_in(player.position, {x + vx * delta_time * @movement_speed, y + vy * delta_time * @movement_speed})
  end
end
