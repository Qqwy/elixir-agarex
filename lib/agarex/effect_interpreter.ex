defmodule Agarex.EffectInterpreter do
  @moduledoc """
  Running effects later.

  This is but one possible interpreter.
  It is the one used normally, but as it is a dependency you might inject in your code,
  you could e.g. use a different one during testing.
  """

  def run_effects(socket, effects) do
    Enum.reduce(effects, socket, &run_effect/2)
  end

  # Define specialized effects up here.

  # Base cases for 'custom' effects
  # that are not (yet) specialized
  defp run_effect(effect, socket) when is_function(effect, 0) do
    effect.()
    socket
  end

  defp run_effect(effect, socket) when is_function(effect, 1) do
    effect.(socket)
  end
end
