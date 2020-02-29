# frozen_string_literal: true

require 'libravatar'

# Helper functions for the application
module ApplicationHelper
  def boostrap_class(alert)
    {
      success: 'alert-success',
      error: 'alert-danger',
      notice: 'alert-success',
      warning: 'alert-warning',
      danger: 'alert-danger',
      alert: 'alert-danger'
    }[alert.to_sym]
  end

  def flash_messages(_opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(
        :div,
        message,
        class: "alert #{boostrap_class(msg_type.to_sym)} fade in"
      ) do
        concat(content_tag(
          :button,
          id: 'close-button',
          class: 'close',
          type: :button,
          data: { dismiss: 'alert' },
          'aria-label' => :Close
        ) do
          concat content_tag(
            :span,
            '&times;'.dup.html_safe,
            'aria-hidden' => true
          )
        end)
        concat message
      end)
    end
    nil
  end

  def avatar(size = 50, user = current_user)
    libra = if user.nil?
              Libravatar.new({
                               email: 'nobody@nowhere.invalid'.dup,
                               size: size,
                               https: true,
                               default: 'robohash'
                             })
            else
              Libravatar.new({
                               email: user.email,
                               size: size,
                               https: true,
                               default: 'robohash'
                             })
            end
    libra.to_s
  end
end
