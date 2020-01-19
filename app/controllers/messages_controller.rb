require 'redcarpet'
require 'rubypants'

class MessagesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_message, only: [:show, :edit, :update, :destroy]

  # GET /messages
  # GET /messages.json
  def index
    @messages = Message.all
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    mark = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})
    paragraphs = Paragraph.select { |p|
      p.message_id == @message.id && p.parent_id.nil?
    }
    last = paragraphs.select { |p| p.parent_id.nil? &&  p.next_id.nil? }
    lastp = last.first
    lastp.content = mark.render RubyPants.new(CGI::escapeHTML(lastp.content)).to_html
    plist = Array.new(1, lastp)
    paragraphs.delete lastp
    while paragraphs.count > 0 do
      nextl = paragraphs.select { |p| p.next_id == lastp.id }
      nextp = nextl.first
      nextp.content = mark.render RubyPants.new(CGI::escapeHTML(nextp.content)).to_html
      paragraphs.delete nextp
      plist.push nextp
      lastp = nextp
    end
    @paragraphs = plist.reverse
  end

  # GET /messages/new
  def new
    @message = Message.new
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

    @message = Message.new(msg)

    respond_to do |format|
      if @message.save
        pars.reverse_each do |p|
          par = {
            :message_id => @message.id,
            :parent_id => nil,
            :next_id => prev_par ? prev_par.id : nil,
            :user_id => @message.user_id,
            :content => p
          }
          prev_par = Paragraph.new(par)
          if prev_par.save
            Rails.logger.debug('Paragraph was successfully created.')
          else
            Rails.logger.warn('====')
            Rails.logger.warn(prev_par.errors.to_yaml)
            Rails.logger.warn('====')
          end
        end

        format.html { redirect_to @message, notice: 'Message was successfully created.' }
        format.json { render :show, status: :created, location: @message }
      else
        format.html { render :new }
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
       params.require(:message).permit(:subject, :content, :version, :user_id, :category_id)
    end
    
    def split_paragraphs msg
      msg[:content].split(/[\r\n]/).select { |line| line.length > 0 }
    end
end
