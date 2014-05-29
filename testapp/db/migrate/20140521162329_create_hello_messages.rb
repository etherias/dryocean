class CreateHelloMessages < ActiveRecord::Migration
  def change
    create_table :hello_messages do |t|
      t.string :message
      t.integer :times_shown

      t.timestamps
    end
  end
end
