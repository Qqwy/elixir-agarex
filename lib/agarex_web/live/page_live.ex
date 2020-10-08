defmodule AgarexWeb.PageLive do
  use AgarexWeb, :live_view

  def mount(params, _session, socket) do
    Phoenix.PubSub.subscribe(Agarex.PubSub, "game/scores")

    socket =
      socket
      |> assign(:last_game_scores, [])
      |> assign(:scores, [])
      |> assign(:time, nil)
      |> assign(:player_name, "")

    {:ok, socket}
  end

  def handle_info({"game/scores", params}, socket) do
    socket =
      socket
      |> assign(:last_game_scores, params.last_game_scores)
      |> assign(:scores, params.scores)
      |> assign(:time, params.time)

    {:noreply, socket}
  end

  def handle_event("start_game", %{"player_name" => player_name}, socket) do
    # Handle live redirect
    {:noreply, push_redirect(socket, to: AgarexWeb.Router.Helpers.game_path(socket, :index, %{"player_name" => player_name}), replace: true)}
  end

  def handle_event("name_change", %{"player_name" => player_name}, socket) do
    socket =
      socket
      |> assign(:player_name, player_name)

    {:noreply, socket}
  end
end
