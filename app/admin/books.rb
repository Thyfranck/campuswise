ActiveAdmin.register Book do
  config.per_page = 50
  actions :all, :except => [:new, :edit]

  filter :user
  filter :title
  filter :available
  filter :available_from
  filter :returning_date
  filter :created_at

  controller do
    def scoped_collection
      Book.where("requested = ?", false)
    end
  end

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
    column :created_at
    default_actions
  end

  show do
    attributes_table do
      row :id
      row :user
      row :title
      row :author
      row :isbn
      row :publisher
      row :price
      row :loan_daily
      row :loan_weekly
      row :loan_monthly
      row :loan_semester
      row :available do |book|
        book.available == true ? "Yes" :
          link_to("No - Change", make_available_admin_book_path(book) , :confirm => "Are you sure to update the availability of this book?")
      end
#      row :image do |book|
#        image_tag(book.image, :height => 100)
#      end
      
    end
  end

  member_action :make_available do
    @book = Book.find(params[:id])
    @book.make_available
    redirect_to :action => :index
  end

  member_action :remove_notification do
    @notification = DashboardNotification.find(params[:id])
    @notification.destroy
    redirect_to request.referrer
  end
end
