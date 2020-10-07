defmodule AgarexWeb.PageLive do
  use AgarexWeb, :live_view

  def mount(params, _session, socket) do
    Phoenix.PubSub.subscribe(Agarex.PubSub, "game/tick")

    socket =
      socket
      |> assign(:game_state, nil)

    {:ok, socket}
  end

  def handle_event("game/tick", game_state, socket) do
    socket =
      socket
      |> assign(:game_state, game_state)

    {:noreply, socket}
  end

  def handle_event("player/start_game") do
    # Handle live redirect
    {:noreply, push_redirect(socket, to: "/game", replace: true)}
  end
end
