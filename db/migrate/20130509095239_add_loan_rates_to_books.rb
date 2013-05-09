class AddLoanRatesToBooks < ActiveRecord::Migration
  def change
    add_column :books, :loan_daily, :decimal
    add_column :books, :loan_weekly, :decimal
    add_column :books, :loan_monthly, :decimal
    add_column :books, :loan_semister, :decimal
    remove_column :books, :loan_price
  end
end
