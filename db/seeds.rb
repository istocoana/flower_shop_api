User.find_or_create_by!(email: "admin_flower_shop@yopmail.com") do |user|
  user.password = "adminpassword"
  user.password_confirmation = "adminpassword"
  user.role = "admin"
end
