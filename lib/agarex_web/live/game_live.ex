defmodule AgarexWeb.GameLive do
  use AgarexWeb, :live_view

  @moduledoc """
  Main LiveView treating the running game from the perspective of a single user.
  """

  alias Agarex.Game.LocalState
  alias Agarex.{Effect, EffectInterpreter}
  require Agarex.Effect


  def mount(%{"player_name" => player_name}, _session, socket) do
    socket =
      if connected?(socket) do
        player_index = Agarex.Game.Server.add_player(player_name)
        effects = [
          Effect.PubSubSubscribe.new("game/tick"),
          Effect.PubSubSubscribe.new("game/scores"),
          Effect.PubSubSubscribe.new("game/over"),
        ]

        socket
        |> Effect.run_effects(effects)
        |> assign(:local, LocalState.new(player_index))
      else
        socket
        |> assign(:local, nil)
      end

    {:ok, socket}
  end

  def mount(_params, socket) do
    {:ok, redirect(socket, to: "/")}
  end

  def handle_event(event, params, socket) do
    do_handle_event(event, params, socket)
  end

  def handle_info({event, params}, socket) do
    do_handle_event(event, params, socket)
  end

  defp do_handle_event(raw_event, params, socket) do
    event = normalize_event(raw_event)
    {new_local_state, effects} =
      LocalState.handle_event(event, params, socket.assigns.local)
      |> Effect.normalize

    socket =
      socket
      |> assign(:local, new_local_state)
      |> Effect.run_effects(effects, EffectInterpreter)

    {:noreply, socket}
  end

  defp normalize_event(event) do
    String.split(event, "/")
  end
end
