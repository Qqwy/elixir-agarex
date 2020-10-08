defmodule Agarex.EffectInterpreter do
  alias Agarex.Effect
  @moduledoc """
  Running effects later.

  This is but one possible interpreter.
  It is the one used normally, but as it is a dependency you might inject in your code,
  you could e.g. use a different one during testing.
  """

  def run_effect(socket, effect) do
    case effect do
      # Define specialized effects up here.
      %Effect.LiveviewPushRedirect{} ->
        Phoenix.LiveView.push_redirect(socket, to: effect.path, replace: true)

      %Effect.PubSubBroadcast{} ->
        Phoenix.PubSub.broadcast(Agarex.PubSub, effect.topic, {effect.topic, effect.params})
        socket

      %Effect.PubSubSubscribe{} ->
        Phoenix.PubSub.subscribe(Agarex.PubSub, effect.topic)
        socket

      # Base cases for 'custom' effects
      # that are not (yet) specialized
      effect when is_function(effect, 0) ->
        effect.()
        socket

      effect when is_function(effect, 1) ->
        effect.(socket)
    end
  end
end
