defmodule Agarex.Effect.LiveviewPushRedirect do
  defstruct [:path]

  def new(path) do
    %__MODULE__{path: path}
  end
end
