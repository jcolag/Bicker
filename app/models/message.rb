# frozen_string_literal: true

# Model for message objects
class Message < ApplicationRecord
  belongs_to :category
  belongs_to :user
  validates :subject, presence: true

  def self.split_paragraphs(msg)
    msg.split(/[\r\n]/).reject(&:empty?)
  end

  def self.unroll_paragraphs(paragraphs)
    return [] if paragraphs.empty?

    paragraphs, lastp = get_next paragraphs, nil
    plist = Array.new(1, lastp)
    until paragraphs.empty?
      paragraphs, nextp = get_next paragraphs, lastp.id
      plist.push nextp
      lastp = nextp
    end
    plist.reverse
  end

  def self.get_next(paragraphs, next_id)
    list = paragraphs.select { |p| p.next_id == next_id }
    first = list.first
    unless first.children.empty?
      first.children = unroll_paragraphs first.children
    end
    paragraphs.delete first
    [paragraphs, first]
  end

  def self.get_paragraphs(who, helpers, message, parent)
    result = []
    paragraphs = Paragraph.select { |p| by_parent p, message, parent }
    paragraphs.map do |p, count|
      seen = see_paragraph p.id, who.id
      p = format_paragraph p
      pp = ClientParagraph.new helpers, p, seen, count
      pp.children = get_paragraphs who, helpers, message, p.id
      result.push pp
    end
    result
  end

  def self.by_parent(paragraph, message, parent)
    paragraph.message_id == message && paragraph.parent_id == parent
  end

  def self.see_paragraph(paragraph, who)
    seen = Beenseen.select do |s|
      (s.paragraph_id == paragraph) && (s.user_id == who)
    end
    if seen.empty?
      see = Beenseen.new
      see.user_id = who
      see.paragraph_id = paragraph
      see.save
    end
    seen
  end

  def self.format_paragraph(paragraph)
    return if paragraph.nil?

    mark = initialize_formatting
    if paragraph.content.starts_with?('```') ||
       paragraph.content.starts_with?('~~~')
      paragraph.content = mark.render paragraph.content
      return paragraph
    end
    if paragraph.content.starts_with? '#'
      # Demote each header
      paragraph.content = '#' + paragraph.content
    end
    content = paragraph.content
    escaped = CGI.escapeHTML content
    escaped.gsub! '&quot;', '"'
    escaped.gsub! '&#39;', "'"
    punct = RubyPants.new(escaped, 3).to_html
    html = mark.render punct
    content = html
              .sub('<p>', '')
              .reverse.sub('</p>'.dup.reverse, '')
              .reverse
    if !content.starts_with?('<code>') &&
       !content.starts_with?('<table>') &&
       !content.starts_with?(/<h[1-6]/)
      content = content
                .gsub(
                  %r{(\.|,|!|\?|:|\(|\)|&|;|/|&ndash;|&mdash;|&hellip;)}m,
                  "\n".dup.concat('\1').concat("\n")
                )
                .gsub(
                  /(<a [^<]*<[^>]*>|<[^>]*>|&[A-Za-z]*;|&\n*#[0-9]*\n*;)/
                ) do |match|
        match.gsub(/\n/) { |_inner| '' }
      end
                .split("\n")
      if paragraph.split
        if content.count == 1
          content += ' '
        else
          # It looks like we should test that the last element of
          # the array is punctuation, but since this paragraph has
          # been split, we already know it must be, so we can
          # barrel through without any test
          last = content.pop
          content[-1] += last
        end
      end
      paragraph.content = content
    else
      paragraph.content = [content]
    end
    paragraph
  end

  def self.initialize_formatting
    rend = Redcarpet::Render::HTML.new(
      escape_html: true, hard_wrap: true, prettify: true,
      safe_links_only: true, with_toc_data: true
    )
    Redcarpet::Markdown.new(rend, {
                              disable_indented_code_blocks: true,
                              fenced_code_blocks: true, footnotes: true,
                              strikethrough: true, superscript: true,
                              autolink: true, tables: true, underline: true
                            })
  end
end

# A utility class to package paragraph information for the view
class ClientParagraph
  attr_accessor :avatar
  attr_accessor :beenseen
  attr_accessor :children
  attr_accessor :content
  attr_accessor :count
  attr_accessor :created_at
  attr_accessor :id
  attr_accessor :message_id
  attr_accessor :next_id
  attr_accessor :parent_id
  attr_accessor :ts
  attr_accessor :updated_at
  attr_accessor :user_id
  attr_accessor :when
  attr_accessor :who

  def initialize(helpers, paragraph, seen, count)
    user = User.select { |u| u.id == paragraph.user_id }.first
    paragraph.attributes.keys.each do |k|
      v = paragraph.attributes[k]
      #instance_variable_set(k, v) unless v.nil?
    end
    self.avatar = helpers.avatar 100, user
    self.beenseen = !seen.empty?
    self.content = paragraph.content
    self.count = count
    self.created_at = paragraph.created_at
    self.id = paragraph.id
    self.message_id = paragraph.message_id
    self.next_id = paragraph.next_id
    self.parent_id = paragraph.parent_id
    self.ts = paragraph.created_at.to_formatted_s(:db)
    self.updated_at = paragraph.updated_at
    self.user_id = paragraph.user_id
    self.when = helpers.time_ago_in_words(paragraph.created_at)
    self.who = user
  end
end
