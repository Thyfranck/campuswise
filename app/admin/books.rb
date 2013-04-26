ActiveAdmin.register Book do
  config.per_page = 50
  actions :all, :except => [:new, :edit]

  index do
    selectable_column
    column :id
    column "Owner Name" do |book|
      User.find(book.user_id).name
    end
    column :title
    column :image do |book|
      image_tag(book.image_url(:thumb)) if book.image.present?
    end
    column :available do |book|
      book.available == true ? "Yes" : "No"
    end
    column :available_from
    column :returning_date
    column :price
    column :loan_price
    column :created_at
    default_actions
  end
  
end