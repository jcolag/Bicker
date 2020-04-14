# frozen_string_literal: true

require 'kramdown'
require 'onebox'
require 'uri'

# The model for paragraphs
class Paragraph < ApplicationRecord
  belongs_to :message
  belongs_to :parent, optional: true
  belongs_to :next, optional: true
  belongs_to :user

  def self.create_new(par)
    paragraph = Paragraph.new(par)
    paragraph.save
    last_child = nil
    URI.extract(par[:content], %w[http https]).reverse_each do |url|
      preview = Onebox.preview(url).placeholder_html
      child = Paragraph.new(Paragraph.make_p(paragraph, last_child, preview))
      last_child = child.save unless preview.length.zero?
    end
    paragraph
  end

  def self.make_p(paragraph, nextp, content)
    user = User.select { |u| u.login == 'bicker' }.first
    doc = Kramdown::Document.new(content, html_to_native: true)
    markdown = doc.to_kramdown.gsub(/<[^>]*>/, '')
    {
      message_id: paragraph.message_id,
      parent_id: paragraph.id,
      next_id: nextp ? nextp.id : nil,
      user_id: user.id,
      content: markdown
    }
  end
end
