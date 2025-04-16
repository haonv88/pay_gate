class CreateWebhookLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :webhook_logs do |t|
      t.string :source
      t.jsonb :payload

      t.timestamps
    end
  end
end
