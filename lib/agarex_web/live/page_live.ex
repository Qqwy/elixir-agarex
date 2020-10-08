defmodule AgarexWeb.PageLive do
  use AgarexWeb, :live_view

  alias Agarex.Effect

  @moduledoc """
  Main LiveView started on application load, keeping track of general game information
  and setting the player's name before joining a game.


  As this module is currently so simple, it is one of the cases in which I opted to _not_
  use the more verbose/compartmentalized patterns. We can always change towards that style in the future
  if this LiveView ends up becoming more complex.
  """

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
    redirect = Effect.LiveviewPushRedirect.new(AgarexWeb.Router.Helpers.game_path(AgarexWeb.Endpoint, :index, %{"player_name" => player_name}))
    socket = Effect.run_effect(socket, redirect)

    {:noreply, socket}
  end

  def handle_event("name_change", %{"player_name" => player_name}, socket) do
    socket =
      socket
      |> assign(:player_name, player_name)

    {:noreply, socket}
  end
end
