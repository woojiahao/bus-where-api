defmodule BusWhereApi.Models.ModelBase do
  @callback from_body(map()) :: struct()

  defmacro __using__(_opts) do
    quote do
      @derive {Jason.Encoder, []}

      import BusWhereApi.Models.ModelBase

      Module.register_attribute(__MODULE__, :fields, accumulate: true)
      Module.register_attribute(__MODULE__, :enums, accumulate: true)

      @before_compile BusWhereApi.Models.ModelBase
    end
  end

  defmacro __before_compile__(env) do
    fields = Module.get_attribute(env.module, :fields) || []
    enums = Module.get_attribute(env.module, :enums) || []

    field_types =
      Enum.map(fields, fn {field, type, _key, _opts} ->
        {field, BusWhereApi.Models.ModelBase.type_spec(type)}
      end)

    enum_types =
      Enum.map(enums, fn {field, mapping, _key, _opts} ->
        {field, BusWhereApi.Models.ModelBase.enum_type_spec(mapping)}
      end)

    struct_type =
      {:%, [],
       [
         {:__MODULE__, [], nil},
         {:%{}, [], field_types ++ enum_types}
       ]}

    escaped_fields = Macro.escape(fields)
    escaped_enums = Macro.escape(enums)

    quote do
      def from_body(body) when is_map(body) do
        non_enum_fields =
          Enum.reduce(unquote(escaped_fields), %__MODULE__{}, fn {field, type, key, opts}, acc ->
            raw_value =
              case Map.get(body, key) do
                nil -> Keyword.get(opts, :default)
                v -> v
              end

            value = BusWhereApi.Models.ModelBase.parse(type, raw_value, opts)

            Map.put(acc, field, value)
          end)

        Enum.reduce(unquote(escaped_enums), non_enum_fields, fn {field, mapping, key, opts},
                                                                acc ->
          raw_value =
            case Map.get(body, key) do
              nil -> Keyword.get(opts, :default)
              v -> v
            end

          value = BusWhereApi.Models.ModelBase.parse(:enum, raw_value, mapping, opts)

          Map.put(acc, field, value)
        end)
      end

      def from_body(_) do
        %__MODULE__{}
      end

      @type t :: unquote(struct_type)
    end
  end

  defmacro field(name, type, key \\ nil, opts \\ []) do
    quote do
      @fields {unquote(name), unquote(type), unquote(key || to_string(name)), unquote(opts)}
    end
  end

  defmacro enum(name, mapping, key \\ nil, opts \\ []) do
    quote do
      unless is_map(unquote(mapping)) do
        raise ArgumentError, "enum mapping must be a map"
      end

      @enums {unquote(name), unquote(mapping), unquote(key || to_string(name)), unquote(opts)}
    end
  end

  def parse(:integer, nil, _), do: nil
  def parse(:integer, v, _), do: String.to_integer(v)

  def parse(:float, nil, _), do: nil
  def parse(:float, v, _), do: String.to_float(v)

  def parse(:string, v, _), do: v

  def parse(:datetime, nil, _), do: nil

  def parse(:datetime, v, offset_s: offset_s),
    do: parse(:datetime, v, offset_s: offset_s) |> DateTime.add(offset_s)

  def parse(:datetime, v, _), do: DateTime.from_iso8601(v) |> elem(1)

  def parse(:bool, 1, _), do: true
  def parse(:bool, 0, _), do: false
  def parse(:bool, v, _), do: v

  def parse(:enum, v, mapping, _), do: Map.get(mapping, v)

  def parse({:struct, module}, nil, _), do: struct(module)
  def parse({:struct, module}, v, _), do: module.from_body(v)

  def parse(_, v, _), do: v

  def type_spec(:integer), do: quote(do: integer())
  def type_spec(:float), do: quote(do: float())
  def type_spec(:string), do: quote(do: String.t())
  def type_spec(:bool), do: quote(do: boolean())
  def type_spec(:datetime), do: quote(do: DateTime.t())

  def type_spec({:struct, mod}), do: quote(do: unquote(mod).t())

  def enum_type_spec(mapping) when map_size(mapping) == 0 do
    quote(do: nil)
  end

  def enum_type_spec(mapping) do
    mapping
    |> Map.values()
    |> Enum.uniq()
    |> Enum.map(fn atom -> quote(do: unquote(atom)) end)
    |> build_union()
  end

  def build_union([]), do: quote(do: nil)
  def build_union([single]), do: single

  def build_union([a, b | rest]) do
    Enum.reduce(rest, {:|, [], [a, b]}, fn v, acc ->
      {:|, [], [acc, v]}
    end)
  end
end
