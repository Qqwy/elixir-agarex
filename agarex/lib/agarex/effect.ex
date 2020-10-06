defmodule Agarex.Effect do
  def effectful_update_in(struct, access_list, function) do
    {result, effects} = normalize(function.(Access.get(struct, access_list)))
    {put_in(struct, access_list, result), effects}
  end

  defmacro effectful_update_in(nested_struct_keys, function) do
    quote do
      {result, effects} = Agarex.Effect.normalize(unquote(function).(unquote(nested_struct_keys)))
      {put_in(unquote(nested_struct_keys), result), effects}
    end
  end

  @doc false
  def normalize(state), do: {state, []}
  def normalize(state, effects) when is_list(effects), do: {state, effects}
  def normalize(state, effect), do: {state, [effect]}
end

