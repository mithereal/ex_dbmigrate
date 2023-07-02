defmodule ExDbmigrate.Table.Server do
  use GenServer
  require Logger

  @registry_name :tables
  @assoc_types [:belongs_to,:many_to_many,:has_one,:has_many]

  defstruct table: nil,
            links: nil,
            assoc_type: nil,
            schema: %{},
            timestamps: false

  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [args]},
      type: :worker
    }
  end

  def schema(arg, data) do
    name = via_tuple(arg)
    GenServer.call(name, {:schema, data})
  end

  def links(arg, data) do
    name = via_tuple(arg)
    GenServer.call(name, {:links, data})
  end

  def init(init_arg) do
    data = ExDbmigrate.list_foreign_keys(init_arg)

    ref_type = ExDbmigrate.Config.key_type()

    link_data =
      Enum.map(data, fn data ->
        %{
          column_name: data.column_name,
          references: %{
            ref_table: data.foreign_table_name,
            ref_column: data.foreign_column_name,
            type: ref_type
          }
        }
      end)

    assoc_type = case Enum.count(link_data) do
      x when x > 1 -> :many_to_many
      1 -> :belongs_to
      0 -> nil
    end

    data = ExDbmigrate.fetch_table_data(init_arg)

    column_names =
      Enum.map(link_data, fn data ->
        data.column_name
      end)

    schema_data =
      Enum.map(data.rows, fn [id, _is_null, type, _position, _max_length] ->
        unless id == "id" || Enum.member?(column_names, id) do
          type = String.to_atom(ExDbmigrate.type_select(type))
          {String.to_atom(id), type}
        end
      end)
      |> Enum.reject(fn x -> is_nil(x) end)

    column_names =
      Enum.map(schema_data, fn data ->
        {id, _d} = data

        id
      end)

    timestamps =
      Enum.member?(column_names, :updated_at) || Enum.member?(column_names, :inserted_at)

    schema_data = Keyword.drop(schema_data, [:updated_at, :inserted_at])

    {:ok,
     %__MODULE__{table: init_arg, links: link_data, schema: schema_data, timestamps: timestamps, assoc_type: assoc_type}}
  end

  def start_link([arg]) do
    name = via_tuple(arg)
    GenServer.start_link(__MODULE__, arg, name: name)
  end

  def shutdown() do
    GenServer.call(__MODULE__, :shutdown)
  end

  def show(name) do
    name = via_tuple(name)
    GenServer.call(name, :show)
  end

  @impl true
  def handle_call(
        {:links, data},
        _from,
        state
      ) do
    link_data =
      Enum.map(data, fn x ->
        ref_type = ExDbmigrate.Config.key_type()

        %{
          column_name: x.column_name,
          references: %{ref_table: x.foreign_table_name, type: ref_type}
        }
      end)

    state = %{state | links: link_data}

    {:reply, state, state}
  end

  def handle_call(
        {:schema, data},
        _from,
        state
      ) do
    state = %{state | schema: data}
    {:reply, state, state}
  end

  def handle_call(
        :shutdown,
        _from,
        state
      ) do
    {:stop, {:ok, "Normal Shutdown"}, state}
  end

  def handle_call(
        :show,
        _from,
        state
      ) do
    {:reply, state, state}
  end

  def handle_cast(
        :shutdown,
        state
      ) do
    {:stop, :normal, state}
  end

  @doc false
  def via_tuple(data, registry \\ @registry_name) do
    {:via, Registry, {registry, data}}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
