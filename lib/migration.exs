defmodule ExDbmigrate.Util.Migration do
  use Ecto.Migration

  def change do
    alter table(@schema.table) do
      for(l <- @schema.links) do
        migration_module =
          String.split(l.references.ref_table, "_")
          |> Enum.map(fn x -> String.capitalize(x) end)
          |> Enum.join("")

        case l.references.type do
          :belongs_to -> belongs_to(l.references.ref_table, migration_module)
          :many_to_many -> many_to_many(l.references.ref_table, migration_module)
          :has_many -> has_many(l.references.ref_table, migration_module)
          _ -> has_one(l.references.ref_table, migration_module)
        end
      end
    end
  end
end
