class AddSemisterDatesToSchools < ActiveRecord::Migration
  def change
    add_column :schools, :spring_semester, :date
    add_column :schools, :fall_semester, :date
  end
end
