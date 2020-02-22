class Message < ApplicationRecord
  belongs_to :category
  belongs_to :user
  validates :subject, :presence => true

  def self.split_paragraphs msg
    msg.split(/[\r\n]/).select { |line| line.length > 0 }
  end

  def self.unrollParagraphs paragraphs
    if paragraphs.count == 0
      return Array.new
    end
    last = paragraphs.select { |p| p.next_id.nil? }
    lastp = last.first
    if lastp.children.count > 0
      lastp.children = unrollParagraphs lastp.children
    end
    paragraphs.delete lastp
    plist = Array.new(1, lastp)
    while paragraphs.count > 0 do
      nextl = paragraphs.select { |p| p.next_id == lastp.id }
      nextp = nextl.first
      paragraphs.delete nextp
      if nextp.children.count > 0
        nextp.children = unrollParagraphs nextp.children
      end
      plist.push nextp
      lastp = nextp
    end
    plist.reverse
  end

  def self.getParagraphs who, helpers, message, parent
    result = []
    paragraphs = Paragraph.select { |p|
      p.message_id == message and p.parent_id == parent
    }.map { |p, count|
      seen = Beenseen.select { |s|
        s.paragraph_id == p.id and s.user_id == who.id
      }
      if seen.count == 0
        see = Beenseen.new()
        see.user_id = who.id
        see.paragraph_id = p.id
        see.save
      end
      user = User.select { |u| u.id == p.user_id }.first
      pp = ClientParagraph.new()
      p = formatParagraph p
      pp.avatar = helpers.avatar 100, user
      pp.beenseen = seen.count > 0 ? true : false
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
    }
    result
  end

  def self.formatParagraph paragraph
    if paragraph.nil?
      return
    end

    rend = Redcarpet::Render::HTML.new(
      escape_html: true,
      hard_wrap: true,
      prettify: true,
      safe_links_only: true,
      with_toc_data: true,
    )
    mark = Redcarpet::Markdown.new(rend, extensions = {
      :autolink => true,
      :disable_indented_code_blocks => true,
      :fenced_code_blocks => true,
      :footnotes => true,
      :strikethrough => true,
      :superscript => true,
      :tables => true,
      :underline => true,
    })
    if paragraph.content.starts_with?('```') or
       paragraph.content.starts_with?('~~~')
      paragraph.content = mark.render paragraph.content
      return paragraph
    end
    if paragraph.content.starts_with? '#'
      # Demote each header
      paragraph.content = '#' + paragraph.content
    end
    content = paragraph.content
    escaped = CGI::escapeHTML content
    escaped.gsub! '&quot;', '"'
    escaped.gsub! '&#39;', "'"
    punct = RubyPants.new(escaped, 3).to_html
    html = mark.render punct
    content = html
      .sub('<p>', '')
      .reverse.sub('</p>'.reverse, '')
      .reverse
    if !content.starts_with?('<code>') and
       !content.starts_with?('<table>') and
       !content.starts_with?(/<h[1-6]/)
      content = content
        .gsub(
          /(\.|,|!|\?|:|\(|\)|&|;|\/|&ndash;|&mdash;|&hellip;)/m,
          "\n".concat('\1').concat("\n")
        )
        .gsub(/(<a [^<]*<[^>]*>|<[^>]*>|&[A-Za-z]*;|&\n*#[0-9]*\n*;)/) { |match|
          match.gsub(/\n/) { |inner| "" }
        }
        .split("\n")
      if paragraph.split
        if content.count == 1
          content += " "
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
      paragraph.content = [ paragraph.content ];
    end
    paragraph
  end
end
