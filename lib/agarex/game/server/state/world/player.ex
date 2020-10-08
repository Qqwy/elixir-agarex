defmodule Agarex.Game.Server.State.World.Player do
  alias Agarex.Game.Server.State.World
  defstruct [:name, :size, :position, :velocity, :alive?]

  @moduledoc """
  A player's character within the game.

  Note that a player's character has no concept of a 'keyboard' that controls it;
  (a basic separation of concerns).
  That part is implemented in `Agarex.Game.LocalState.Controls`.

  We keep track also of 'dead' players for two reasons:

  1. easy 'death' animations. (They are removed anyway when the next round starts a couple of minutes later)
  2. to keep track of the high scores while the game is running.

  The 'size' is how large a player is (and also their score).
  Visually this is expressed as the 'area' of the player's circle,
  which means that when we need to do math that requires the radius of the circle,
  we have to convert using the well-known trigonometric formula `radius = sqrt(area / pi)`.
  """

  @movement_speed 1/30000000

  def new(name) do
    %__MODULE__{
      name: name,
      size: 10,
      position: {World.board_width() * :random.uniform(), World.board_height() * :random.uniform()},
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


      clamp({x2, y2}, player.size)
    end)
  end

  defp clamp({x2, y2}, size) do
    radius = :math.sqrt(size / :math.pi)
    x2 = max(radius, x2)
    x2 = min(World.board_width() - radius, x2)

    y2 = max(radius, y2)
    y2 = min(World.board_height() - radius, y2)

    {x2, y2}
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
