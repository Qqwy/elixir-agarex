defmodule Agarex.Game.LocalState do
  alias __MODULE__.Controls
  alias Agarex.Effect
  require Effect

  @moduledoc """
  This module takes care of the state that is local to a single brower tab.

  It does two (closely related) things:

  1. Defining the local state struct
  2. Defining how this struct transforms based on certain events (from either the browser or broadcasted by the `Agarex.Game.Server` GenServer).
  """

  defstruct [:controls, :game_state, :player_id, :time, :scores]
  def new(player_id) do
    %__MODULE__{controls: Controls.new, game_state: nil, player_id: player_id, time: nil, scores: []}
  end

  def handle_event(event, params, struct) do
    case event do
      ["controls" | rest] ->
        {struct, effects} = Effect.effectful_update_in(struct.controls, &Controls.handle_event(rest, params, &1))
        {struct, effects ++ [Controls.broadcast_velocity(struct.controls, struct.player_id)] }
      ["game" , "tick"] ->
        struct = %{struct | game_state: params.game_state}
        if current_player(struct).alive? do
          struct
        else
          index_redirect = Effect.LiveviewPushRedirect.new(AgarexWeb.Router.Helpers.page_path(AgarexWeb.Endpoint, :index))
          {struct, [index_redirect]}
        end
      ["game" , "scores"] ->
        %{struct | scores: params.scores, time: params.time}
      ["game", "over"] ->
        index_redirect = Effect.LiveviewPushRedirect.new(AgarexWeb.Router.Helpers.page_path(AgarexWeb.Endpoint, :index))
        {struct, [index_redirect]}
    end
  end

  def current_player(struct) do
    get_in(struct, [Access.key(:game_state), Access.key(:players), struct.player_id])
  end
end
