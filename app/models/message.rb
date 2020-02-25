# frozen_string_literal: true

# rubocop:todo Style/Documentation
class Message < ApplicationRecord # rubocop:todo Metrics/ClassLength
  belongs_to :category
  belongs_to :user
  validates :subject, presence: true

  def self.split_paragraphs(msg)
    msg.split(/[\r\n]/).reject(&:empty?)
  end

  # rubocop:todo Naming/MethodName
  # rubocop:todo Metrics/MethodLength
  def self.unrollParagraphs(paragraphs) # rubocop:todo Metrics/AbcSize
    return [] if paragraphs.empty?

    last = paragraphs.select { |p| p.next_id.nil? }
    lastp = last.first
    unless lastp.children.empty?
      lastp.children = unrollParagraphs lastp.children
    end
    paragraphs.delete lastp
    plist = Array.new(1, lastp)
    until paragraphs.empty?
      nextl = paragraphs.select { |p| p.next_id == lastp.id }
      nextp = nextl.first
      paragraphs.delete nextp
      unless nextp.children.empty?
        nextp.children = unrollParagraphs nextp.children
      end
      plist.push nextp
      lastp = nextp
    end
    plist.reverse
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Naming/MethodName

  # rubocop:todo Naming/MethodName
  # rubocop:todo Metrics/MethodLength
  # rubocop:todo Metrics/AbcSize
  def self.getParagraphs(who, helpers, message, parent)
    result = []
    # rubocop:todo Metrics/BlockLength
    paragraphs = Paragraph.select do |p|
      (p.message_id == message) && (p.parent_id == parent)
    end
    paragraphs.map do |p, count|
      seen = Beenseen.select do |s|
        (s.paragraph_id == p.id) && (s.user_id == who.id)
      end
      if seen.empty?
        see = Beenseen.new
        see.user_id = who.id
        see.paragraph_id = p.id
        see.save
      end
      user = User.select { |u| u.id == p.user_id }.first
      pp = ClientParagraph.new
      p = formatParagraph p
      pp.avatar = helpers.avatar 100, user
      pp.beenseen = !seen.empty?
      pp.children = getParagraphs who, helpers, message, p.id
      pp.content = p.content
      pp.count = count
      pp.created_at = p.created_at
      pp.id = p.id
      pp.message_id = p.message_id
      pp.next_id = p.next_id
      pp.parent_id = p.parent_id
      pp.ts = p.created_at.to_formatted_s(:db)
      pp.updated_at = p.updated_at
      pp.user_id = p.user_id
      pp.when = helpers.time_ago_in_words(p.created_at)
      pp.who = user
      result.push pp
    end
    # rubocop:enable Metrics/BlockLength
    result
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Naming/MethodName

  # rubocop:todo Metrics/PerceivedComplexity
  # rubocop:todo Metrics/CyclomaticComplexity
  # rubocop:todo Naming/MethodName
  # rubocop:todo Metrics/MethodLength
  def self.formatParagraph(paragraph) # rubocop:todo Metrics/AbcSize
    return if paragraph.nil?

    rend = Redcarpet::Render::HTML.new(
      escape_html: true,
      hard_wrap: true,
      prettify: true,
      safe_links_only: true,
      with_toc_data: true
    )
    mark = Redcarpet::Markdown.new(rend, {
                                     autolink: true,
                                     disable_indented_code_blocks: true,
                                     fenced_code_blocks: true,
                                     footnotes: true,
                                     strikethrough: true,
                                     superscript: true,
                                     tables: true,
                                     underline: true
                                   })
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
      paragraph.content = [paragraph.content]
    end
    paragraph
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Naming/MethodName
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
end
# rubocop:enable Style/Documentation
