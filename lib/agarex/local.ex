defmodule Agarex.Local do
  alias __MODULE__.Controls
  alias Agarex.Effect
  require Effect

  defstruct [:controls, :game_state, :player_id, :time, :scores]
  def new(player_id) do
    %__MODULE__{controls: Controls.new, game_state: nil, player_id: player_id, time: nil, scores: []}
  end

  def handle_event(event, params, struct) do
    case event do
      ["controls" | rest] ->
        {struct, effects} = Effect.effectful_update_in(struct.controls, &Controls.handle_event(rest, params, &1))
        {struct, effects ++ fn -> Controls.broadcast_velocity(struct.controls, struct.player_id) end}
      ["game" , "tick"] ->
        %{struct | game_state: params.game_state}
      ["game" , "scores"] ->
        %{struct | scores: params.scores, time: params.time}
      ["game", "over"] ->
        {struct, fn socket ->
          Phoenix.LiveView.push_redirect(socket, to: AgarexWeb.Router.Helpers.page_path(socket, :index), replace: true)
        end}
    end
    |> IO.inspect(label: :local_handle_event)
  end

  def current_player(struct) do
    IO.inspect(struct)
    get_in(struct, [Access.key(:game_state), Access.key(:players), struct.player_id])
    |> IO.inspect(label: :current_player)
  end
end
