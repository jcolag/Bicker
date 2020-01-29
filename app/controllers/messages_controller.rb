require 'redcarpet'
require 'rubypants'

class MessagesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_message, only: [:show, :edit, :update, :destroy]

  # GET /messages
  # GET /messages.json
  def index
    @messages = Message.all.order('created_at DESC')
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    paragraphs = Paragraph.select { |p|
      p.message_id == @message.id and p.parent_id.nil?
    }
    if paragraphs.count == 0
      @paragraphs = Array.new
      return
    end
    last = paragraphs.select { |p| p.parent_id.nil? and  p.next_id.nil? }
    lastp = last.first
    paragraphs.delete lastp
    lastp = format_paragraph lastp
    plist = Array.new(1, lastp)
    while paragraphs.count > 0 do
      nextl = paragraphs.select { |p| p.next_id == lastp.id }
      nextp = nextl.first
      paragraphs.delete nextp
      nextp = format_paragraph nextp
      plist.push nextp
      lastp = nextp
    end
    @paragraphs = plist.reverse
  end

  # GET /messages/new
  def new
    @message = Message.new
    @categories = Category
      .select { |c| c.of == 'message' }
      .collect { |c| [ c.name, c.id ] }
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages
  # POST /messages.json
  def create
    params = message_params
    pars = split_paragraphs(params)
    msg = params.except(:content)
    prev_par = nil
    block_par = nil

    if pars.count == 0
      respond_to do |format|
        format.html { redirect_to new_message_path, error: 'Message text is empty.' }
        format.json { render json: [ "Message text is empty" ], status: :unprocessable_entity }
      end
      return
    end
    
    if params[:subject] == ''
      params[:subject] = nil
    end

    @message = Message.new(msg)

    respond_to do |format|
      if @message.save
        pars.reverse_each do |p|
          if block_par.nil? and
            (p.start_with?('```') or
              p.start_with?('~~~') or
              p.start_with?('|')
            )
            block_par = p + "\n"
          elsif
            (
              !block_par.nil? and
              block_par.start_with?('`') and
              !p.start_with?('```') and
              !p.start_with?('~~~')
            ) or (
              !block_par.nil? and
              block_par.start_with?('|') and
              p.start_with?('|')
            )
            block_par += p + "\n"
          else
            # Flush the buffered table
            if !block_par.nil? and block_par.start_with?('|')
              block_par = block_par.split("\n").reverse.join("\n")
              par = {
                :message_id => @message.id,
                :parent_id => nil,
                :next_id => prev_par ? prev_par.id : nil,
                :user_id => @message.user_id,
                :content => block_par
              }
              prev_par = Paragraph.new(par)
              if prev_par.save
                Rails.logger.debug('Paragraph was successfully created.')
              else
                Rails.logger.warn(prev_par.errors.to_yaml)
              end
              block_par = nil
            end
            par = {}
            if p.start_with?('```') or p.start_with?('~~~')
              block_par += p + "\n"
              lines = block_par.split("\n").reverse.join("\n")
              par = {
                :message_id => @message.id,
                :parent_id => nil,
                :next_id => prev_par ? prev_par.id : nil,
                :user_id => @message.user_id,
                :content => lines
              }
            else
              par = {
                :message_id => @message.id,
                :parent_id => nil,
                :next_id => prev_par ? prev_par.id : nil,
                :user_id => @message.user_id,
                :content => p
              }
            end
            prev_par = Paragraph.new(par)
            if prev_par.save
              Rails.logger.debug('Paragraph was successfully created.')
            else
              Rails.logger.warn(prev_par.errors.to_yaml)
            end
            block_par = nil
          end
        end

        format.html { redirect_to @message, notice: 'Message was successfully created.' }
        format.json { render :show, status: :created, location: @message }
      else
        @message = Message.new
        @content = pars.join("\n")
        @categories = Category
          .select { |c| c.of == 'message' }
          .collect { |c| [ c.name, c.id ] }
        format.html { render :new, notice: @message.errors }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    ps = sortParagraph Paragraph.select { |p|
      p.message_id == @message.id and p.parent_id.nil?
    }
    ps.each { |p| p.destroy }
    @message.destroy
    respond_to do |format|
      format.html { redirect_to messages_url, notice: 'Message was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
       params
         .require(:message)
         .permit(
           :subject,
           :content,
           :version,
           :user_id,
           :category_id
         )
    end
    
    def split_paragraphs msg
      msg[:content].split(/[\r\n]/).select { |line| line.length > 0 }
    end
    
    def format_paragraph paragraph
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
      paragraph.content = html
        .sub('<p>', '')
        .reverse.sub('</p>'.reverse, '')
        .reverse
      if !paragraph.content.starts_with?('<code>') and
         !paragraph.content.starts_with?('<table>') and
         !paragraph.content.starts_with?(/<h[1-6]/)
        paragraph.content = paragraph.content
          .gsub(
            /(\.|,|!|\?|:|\(|\)|&|;|\/|&ndash;|&mdash;|&hellip;)/m,
            "\n".concat('\1').concat("\n")
          )
          .gsub(/(<a [^<]*<[^>]*>)/) { |match|
            match.gsub(/\n/) { |inner|
              ""
            }
          }
          .gsub(/(<[^>]*>)/) { |match|
            match.gsub(/\n/) { |inner|
              ""
            }
          }
          .split("\n")
        Rails.logger.debug(paragraph.content)
      else
        paragraph.content = [ paragraph.content ];
      end
      paragraph
    end

    def sortParagraph pars, start = nil, found = []
      return found if pars.length == 0
      if !start
        which = nil
        while pars.length > 0
          pars.each_index do |i|
            if pars[i].next_id == which
              p = pars.delete_at(i)
              which = p.id
              found.unshift(p)
              break
            end
          end
        end
        return found
      end
      which = nil
      pars.each_index do |i|
        if pars[i].id == start
          which = i
          break
        end
      end
      return found if !which
      p = pars.delete_at(which)
      found << p
      return sortParagraph(pars, found.last.next_id, found)
    end
end
