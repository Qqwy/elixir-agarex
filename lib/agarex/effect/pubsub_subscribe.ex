defmodule Agarex.Effect.PubSubSubscribe do
  defstruct [:topic]

  def new(topic) do
    %__MODULE__{topic: topic}
  end
end
