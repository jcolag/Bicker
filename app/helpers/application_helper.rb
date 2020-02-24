require 'libravatar'

module ApplicationHelper # rubocop:todo Style/Documentation
  def boostrap_class(alert)
    { success: 'alert-success', error: 'alert-danger', notice: 'alert-success', warning: 'alert-warning',
      danger: 'alert-danger', alert: 'alert-danger' }[alert.to_sym]
  end

  def flash_messages(_opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "alert #{boostrap_class(msg_type.to_sym)} fade in") do
        concat(content_tag(:button, id: 'close-button', class: 'close', type: :button, data: { dismiss: 'alert' }, 'aria-label' => :Close) do
          concat content_tag(:span, '&times;'.html_safe, 'aria-hidden' => true)
        end)
        concat message
      end)
    end
    nil
  end

  # rubocop:todo Naming/MethodParameterName
  def avatar(sz = 50, user = current_user) # rubocop:todo Metrics/MethodLength
    libra = if user.nil?
              Libravatar.new({
                               email: 'nobody@nowhere.invalid',
                               size: sz,
                               https: true,
                               default: 'robohash'
                             })
            else
              Libravatar.new({
                               email: user.email,
                               size: sz,
                               https: true,
                               default: 'robohash'
                             })
            end
    libra.to_s
  end
  # rubocop:enable Naming/MethodParameterName
end
