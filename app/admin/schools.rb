ActiveAdmin.register School do
  menu :parent => "Manage Schools"

  form do |f|
    f.inputs "School Information" do
      f.input :name
      f.input :email_postfix
      f.input(:spring_semester, {:discard_year => true})
      f.input(:fall_semester, {:discard_year => true})
    end
    f.actions
  end

  index do
    column :name
    column :email_postfix
    column :spring_semester do |school|
      school.spring_semester.strftime("%B #{school.spring_semester.day.ordinalize}") if school.spring_semester.present?
    end
    column :fall_semester do |school|
      school.fall_semester.strftime("%B #{school.fall_semester.day.ordinalize}") if school.fall_semester.present?
    end
    default_actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :email_postfix
      row :spring_semester do |school|
        school.spring_semester.strftime("%B #{school.spring_semester.day.ordinalize}")
      end
      row :fall_semester do |school|
        school.fall_semester.strftime("%B #{school.fall_semester.day.ordinalize}")
      end
    end
  end
  
end
