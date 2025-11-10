class CreateStudios < ActiveRecord::Migration[8.1]
  def change
    create_table :studios do |t|
      t.string :nom
      t.text :presentation_generale
      t.integer :date_creation
      t.integer :date_fin
      t.text :creations_majeures
      t.text :formation_et_influences
      t.text :heritage_et_impact
      t.text :style_ou_philosophie
      t.text :image
      t.text :source
      t.string :slug
      t.boolean :validation
      t.text :rejection_reason
      t.references :user, null: false, foreign_key: true
t.references :validated_by_user, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :studios, :slug, unique: true
  end
end
