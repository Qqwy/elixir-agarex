defmodule AgarexWeb.PageLive do
  use AgarexWeb, :live_view

  alias Agarex.Local
  alias Agarex.EffectsInterpreter

  def mount(%{"player_name" => player_name}, _session, socket) do

    player_index = Agarex.Game.Server.add_player(player_name)
    Phoenix.PubSub.subscribe(Agarex.PubSub, "game/tick")

    socket =
      socket
      |> assign(:local, Agarex.Local.new(player_index))

    {:ok, socket}
  end

  def handle_event(event, params, socket) do
    do_handle_event(event, params, socket)
  end

  def handle_info({event, params}, socket) do
    do_handle_event(event, params, socket)
  end

  defp do_handle_event(raw_event, params, socket) do
    event = normalize_event(raw_event)
    {new_state, effects} =
      Agarex.Local.handle_event(event, params, socket.assigns.local)

    socket =
      socket
      |> assign(:local, new_state)
      |> EffectInterpreter.run_effects(effects)

    {:noreply, socket}
  end

  defp normalize_event(event) do
    String.split(event, "/")
  end
end
