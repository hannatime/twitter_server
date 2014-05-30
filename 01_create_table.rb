class CreateTweetTable < Sequel::Migration

def up
  create_table :tweets do
    primary_key :id
    String :text
    String :username
    Time :created_at
   end
end

def down
    drop_table(:tweets)
end

end