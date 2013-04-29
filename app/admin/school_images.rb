ActiveAdmin.register SchoolImage do
  menu :parent => "Manage Schools"
    
  config.per_page = 50

  index do
    selectable_column
    column :id
    column :school
    column :image do |school_image|
      image_tag(school_image.image_url(:thumb)) if school_image.image.present?
    end
    default_actions
  end

  show do |school_image|
    attributes_table do
      row :id
      row :school
      row :image do |school_image|
        image_tag(school_image.image.to_s, :height => "250")
      end
    end
  end
end
