defmodule Agarex.Game.State.Player do
  defstruct [:name, :score, :position, :velocity]

  @movement_speed 1/200000000

  def new() do
    %__MODULE__{
      name: "",
      size: 1,
      position: {10, 20},
      velocity: {1, 1},
      alive?: true
      }
  end

  def move(player, dt) do
    update_in(player.position fn {x, y} ->
      {vx, vy} = player.velocity
      x2 = x + vx * dt * @movement_speed
      y2 = y + vy * dt * @movement_speed
      {x2, y2}
    end)
  end

  def collide?(a, b) do
    {ax, ay} = a.position
    {bx, by} = b.position
    dx = bx - ax
    dy = by - ay
    radii = a.size + b.size

    # Distance between center points is smaller than the radii
    dx*dx + dy*dy < radii
  end

  def grow(player, size) do
    update_in(player.size, &(&1 + size))
  end

  def kill(player) do
    put_in(player.alive?, false)
  end
end
