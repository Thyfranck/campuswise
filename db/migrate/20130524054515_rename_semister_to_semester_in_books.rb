class RenameSemisterToSemesterInBooks < ActiveRecord::Migration
  def change
    rename_column :books, :loan_semister, :loan_semester
  end
end
