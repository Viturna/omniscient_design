class AddCategoryToBugReports < ActiveRecord::Migration[8.1]
  def change
    add_column :bug_reports, :category, :string
  end
end
