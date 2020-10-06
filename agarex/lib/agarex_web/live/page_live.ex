defmodule AgarexWeb.PageLive do
  use AgarexWeb, :live_view

  alias Agarex.{Local, Effect, EffectInterpreter}
  require Agarex.Effect

  def mount(%{"player_name" => player_name}, _session, socket) do
    socket =
    if connected?(socket) do
      player_index = Agarex.Game.Server.add_player(player_name)
      Phoenix.PubSub.subscribe(Agarex.PubSub, "game/tick")

      socket
      |> assign(:local, Agarex.Local.new(player_index))
    else
      socket
      |> assign(:local, nil)
    end

    {:ok, socket}
  end

  def handle_event(event, params, socket) do
    do_handle_event(event, params, socket)
  end

  def handle_info({event, params}, socket) do
    do_handle_event(event, params, socket)
  end

  defp do_handle_event(raw_event, params, socket) do
    local = socket.assigns.local
    event = normalize_event(raw_event)
    {new_state, effects} =
      Agarex.Local.handle_event(event, params, socket.assigns.local)
      |> Effect.normalize

    socket =
      socket
      |> assign(:local, new_state)
      |> EffectInterpreter.run_effects(effects)

    {:noreply, socket}
  end

  defp normalize_event(event) do
    String.split(event, "/")
  end

  defp relative_size_class(other_player, current_player) do
    case other_player.size - current_player.size do
      res when res < 0 -> "smaller"
      res when res > 0 -> "bigger"
      _ -> "same_size"
    end
  end
end
