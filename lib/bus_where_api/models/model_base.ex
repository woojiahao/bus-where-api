defmodule BusWhereApi.Models.ModelBase do
  @callback from_body(map()) :: struct()

  defmacro __using__(_opts) do
    quote do
      @derive {Jason.Encoder, []}

      import BusWhereApi.Models.ModelBase
      alias BusWhereApi.Models.Helpers

      Module.register_attribute(__MODULE__, :fields, accumulate: true)
      Module.register_attribute(__MODULE__, :enums, accumulate: true)

      @before_compile BusWhereApi.Models.ModelBase
    end
  end

  defmacro __before_compile__(env) do
    fields = Module.get_attribute(env.module, :fields) || []
    enums = Module.get_attribute(env.module, :enums) || []

    field_names =
      Enum.map(fields, fn {field, _type, _key, opts} ->
        {field, Keyword.get(opts, :default)}
      end)

    enum_names =
      Enum.map(enums, fn {field, _mapping, _key, opts} ->
        {field, Keyword.get(opts, :default)}
      end)

    field_types =
      Enum.map(fields, fn {field, type, _key, _opts} ->
        {field, type_spec(type)}
      end)

    enum_types =
      Enum.map(enums, fn {field, mapping, _key, _opts} ->
        {field, enum_type_spec(mapping)}
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
      defstruct unquote(field_names ++ enum_names)

      def from_body(body) when is_map(body) do
        non_enum_fields =
          Enum.reduce(unquote(escaped_fields), %__MODULE__{}, fn {field, type, key, opts}, acc ->
            raw_value =
              case Map.get(body, key) do
                nil -> Keyword.get(opts, :default)
                v -> v
              end

            value = parse(type, raw_value, opts)

            Map.put(acc, field, value)
          end)

        Enum.reduce(unquote(escaped_enums), non_enum_fields, fn {field, mapping, key, opts},
                                                                acc ->
          raw_value =
            case Map.get(body, key) do
              nil -> Keyword.get(opts, :default)
              v -> v
            end

          value = parse(:enum, raw_value, mapping, opts)

          Map.put(acc, field, value)
        end)
      end

      def from_body(_) do
        %__MODULE__{}
      end

      @type t :: unquote(struct_type)
    end
  end

  @spec field(
          atom(),
          :integer | :float | :string | :datetime | :bool | {:struct, module()},
          String.t() | nil,
          default: any(),
          offset_s: integer(),
          parser: any :: any
        ) :: Macro.t()
  defmacro field(name, type, key \\ nil, opts \\ []) do
    quote do
      @fields {unquote(name), unquote(type), unquote(key || to_string(name)), unquote(opts)}
    end
  end

  @spec enum(atom(), %{any() => atom()}, String.t() | nil, default: any()) :: Macro.t()
  defmacro enum(name, mapping, key \\ nil, opts \\ []) do
    quote do
      unless is_map(unquote(mapping)) do
        raise ArgumentError, "enum mapping must be a map"
      end

      @enums {unquote(name), unquote(mapping), unquote(key || to_string(name)), unquote(opts)}
    end
  end

  def parse(:integer, nil, _), do: nil

  def parse(:integer, v, _) when is_binary(v) do
    case(Integer.parse(v)) do
      :error -> nil
      {i, _} -> i
    end
  end

  def parse(:integer, v, _) when is_integer(v) or is_float(v), do: v
  def parse(:integer, _, _), do: nil

  def parse(:float, nil, _), do: nil

  def parse(:float, v, _) when is_binary(v) do
    case(Float.parse(v)) do
      :error -> nil
      {i, _} -> i
    end
  end

  def parse(:float, v, _) when is_integer(v) or is_float(v), do: v
  def parse(:float, _, _), do: nil

  def parse(:string, v, opts) do
    case Keyword.get(opts, :parser) do
      nil -> v
      parser -> parser.(v)
    end
  end

  def parse(:datetime, nil, _), do: nil

  def parse(:datetime, v, opts) do
    case DateTime.from_iso8601(v) do
      {:ok, time, _} ->
        case Keyword.get(opts, :offset_s) do
          nil -> time
          offset_s -> DateTime.add(time, offset_s)
        end

      {:error, _} ->
        nil
    end
  end

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
