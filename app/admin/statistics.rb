ActiveAdmin.register_page "Site Statistics" do
  content do
    columns do
      column do
        panel "School" do
          para "Total number of School: #{School.all.count}"
          para "Number of students in each campus:"
          ul do
            School.all.map do |school|
              li "Name: #{school.name}; Total: #{school.users.count}; Active: #{school.users.where(:activation_state => "active").count}; Inactive: #{school.users.where(:activation_state => "pending").count}"
            end
          end

          para "Number of books in each campus:"
          ul do
            School.all.map do |school|
              li "Name: #{school.name}; Total: #{school.books.count}; Available: #{school.books.where(:available => true).count}; Borrowed: #{school.books.where(:available => false).count}"
            end
          end
        end
      end
      column do
        panel "User" do
          para "Total User: #{User.all.count}"
          para "Total Active user: #{User.where(:activation_state => "active").count}"
          para "Total Inactive user: #{User.where(:activation_state => "pending").count}"
          para "Total payment verified user: #{BillingSetting.all.count}"
          para "Total phone verified user: #{User.where(:phone_verified => "verified").count}"

        end
      end

      column do
        panel "Books" do
          para "Total Books: #{User.where(:activation_state => "active").count}"
          para "Total books available: #{Book.where(:available => true).count}"
          para "Total books borrowed: #{Exchange.where(:status => Exchange::STATUS[:accepted]).count}"
          para "Total request pending: #{Exchange.where(:status => Exchange::STATUS[:pending]).count}"
        end
      end
    end
  end
end