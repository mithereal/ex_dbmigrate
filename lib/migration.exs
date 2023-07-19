defmodule ExDbmigrate.Util.Migration do
  use Ecto.Migration

    def change do

      alter table(@schema.table) do
#        generate_references(@schema)

      end

    end
  end