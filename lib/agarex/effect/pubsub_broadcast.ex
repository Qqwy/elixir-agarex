defmodule Agarex.Effect.PubSubBroadcast do
  defstruct [:topic, :params]

  def new(topic, params) do
    %__MODULE__{topic: topic, params: params}
  end
end
