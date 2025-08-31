defmodule ExDbmigrate.Module do
  @moduledoc """
  Generates Elixir modules from database tables using Ecto.

  ## Usage

      ExDbmigrate.Module.generate_modules(ExDbmigrate.Repo)
  """

  @doc """
  Generates Elixir modules for all tables in the database.
  """
  def generate_modules(repo, opts \\ []) do
    tables = Repo.list_tables(repo)
    Enum.each(tables, fn table ->
      columns = Repo.get_columns(repo, table)
      module_code = build_module(table, columns)
      save_module(table, module_code, opts)
    end)
  end

  defp build_module(table, columns) do
    struct_fields =
      columns
      |> Enum.map(fn col ->
        name = Map.get(col, "column_name") || Map.get(col, "Field")
        ":#{name}"
      end)
      |> Enum.join(", ")

    """
    defmodule #{Macro.camelize(table)} do
      use Ecto.Schema

      schema "#{table}" do
        # Fields:
    #{Enum.map(columns, fn col ->
      name = Map.get(col, "column_name") || Map.get(col, "Field")
      type = Map.get(col, "data_type") || Map.get(col, "Type")
      "    field :#{name}, :string # type: #{type}"
    end) |> Enum.join("\n")}
      end
    end
    """
  end

  defp save_module(table, code, opts) do
    path = Keyword.get(opts, :out_dir, "generated")
    File.mkdir_p!(path)
    file_path = Path.join(path, "#{table}.ex")
    File.write!(file_path, code)
  end
end