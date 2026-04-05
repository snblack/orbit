module ApplicationHelper
  def initials_for(user)
    name = user.display_name.presence || user.email
    name.split.first(2).map { |w| w[0].upcase }.join
  end

  def avatar_color_for(user)
    "hsl(#{(user.id * 37) % 360}, 55%, 65%)"
  end
end
