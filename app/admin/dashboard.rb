ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do
#    div :class => "blank_slate_container", :id => "dashboard_default_message" do
#      span :class => "blank_slate" do
#        span I18n.t("active_admin.dashboard_welcome.welcome")
#        small I18n.t("active_admin.dashboard_welcome.call_to_action")
#      end
#    end

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
          para "Total books borrowed: #{Book.where(:available => false).count}"
          para "Total request pending: #{Exchange.where(:accepted => false).count}"
        end
      end
    end

#    columns do
#
#    end

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end
