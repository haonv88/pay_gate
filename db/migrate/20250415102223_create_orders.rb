class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount
      t.string :status
      t.string :reference
      t.string :transaction_id

      t.timestamps
    end
  end
end
