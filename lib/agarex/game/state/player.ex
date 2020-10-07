defmodule Agarex.Game.State.Player do
  defstruct [:name, :size, :position, :velocity, :alive?]

  @movement_speed 1/30000000

  def new(name) do
    %__MODULE__{
      name: name,
      size: bit_size(name),
      position: {100 * :random.uniform(), 100 * :random.uniform()},
      velocity: {0, 0},
      alive?: true,
    }
  end

  def move(player = %__MODULE__{alive?: false}, dt), do: player
  def move(player, dt) do
    update_in(player.position, fn {x, y} ->
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
    ra = :math.sqrt(a.size / :math.pi)
    rb = :math.sqrt(b.size / :math.pi)
    radii =  ra + rb

    # Circles overlap when the distance between center points
    # is smaller than the sum of the radii
    # (Pythagoras)
    dx*dx + dy*dy < radii*radii
  end

  def grow(player, size) do
    update_in(player.size, &(&1 + size))
  end

  def kill(player) do
    put_in(player.alive?, false)
  end

  def alter_velocity(player, velocity) when tuple_size(velocity) == 2 do
    put_in(player.velocity, velocity)
  end
end
