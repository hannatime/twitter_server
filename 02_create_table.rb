class AddLangAndGuid < Sequel::Migration

    def up
        alter_table :tweets do
            add_column  :guid, Integer
            add_column  :lang, String
            add_column  :time_zone, String
        end
    end

    def down
        alter_table :tweets do
            drop_column :guid
            drop_column :lang
            drop_column :time_zone
        end
    end
end