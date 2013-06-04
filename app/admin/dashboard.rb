ActiveAdmin.register_page "Dashboard" do
  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do

    columns do
      column do
        panel "Statistics" do
          table do
            tr
            td "Total Admin Users"
            td ": #{AdminUser.count}"
            tr
            td "Total Schools"
            td ": #{School.count}"
            tr
            td "Total Users"
            td ": #{User.count}"
            tr
            td "Total Books to Rent"
            td ": #{Book.where(:requested => false).count}"
            tr
            td "Total Books Requested"
            td ": #{Book.where(:requested => true).count}"
            tr
            td "Total Exchange Requests"
            td ": #{Exchange.count}"
            tr
            td "Total Accepted Requests"
            td ": #{Exchange.count}"
            tr
            td "Total Accepted Requests"
            td ": #{Exchange.accepted.count}"
            tr
            td "Total PAID Amount"
            td ": $#{Payment.sum(&:payment_amount)}"
          end
        end
      end
      column :span => 3 do
        panel "Notifications" do
          if AdminUser.first.dashboard_notifications.any?
            AdminUser.first.dashboard_notifications.order("created_at desc").each do |notification|
              ul do
                li notification.content.html_safe
                para link_to "Remove", remove_notification_admin_book_path(notification.id)
              end
            end
          else
            para "No new notifications"
          end
        end
      end
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

