defmodule Agarex.Local do
  alias __MODULE__.Controls
  alias Agarex.Effect
  require Effect

  defstruct [:controls, :game_state, :player_id]
  def new(player_id) do
    %__MODULE__{controls: Controls.new, game_state: nil, player_id: player_id}
  end

  def handle_event(event, params, struct) do
    case event do
      ["controls" | rest] ->
        {struct, effects} = Effect.effectful_update_in(struct.controls, &Controls.handle_event(rest, params, &1))
        {struct, effects ++ fn -> Controls.broadcast_velocity(struct.controls, struct.player_id) end}
      ["game" , "tick"] ->
        put_in(struct.game_state, params)
    end
  end
end
