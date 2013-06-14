class ChangeDataTypes < ActiveRecord::Migration
  def change
    change_column :books, :loan_daily, :decimal, :precision => 10, :scale => 2
    change_column :books, :loan_weekly, :decimal, :precision => 10, :scale => 2
    change_column :books, :loan_monthly, :decimal, :precision => 10, :scale => 2
    change_column :books, :loan_semester, :decimal, :precision => 10, :scale => 2
    change_column :books, :price, :decimal, :precision => 10, :scale => 2
    change_column :books, :purchase_price, :decimal, :precision => 10, :scale => 2
    change_column :exchanges, :amount, :decimal, :precision => 10, :scale => 2
    change_column :withdraw_requests, :amount, :decimal, :precision => 10, :scale => 2
    change_column :payments, :payment_amount, :decimal, :precision => 10, :scale => 2
    change_column :users, :balance, :decimal, :precision => 10, :scale => 2
    change_column :exchanges, :counter_offer, :decimal, :precision => 10, :scale => 2
  end
end
