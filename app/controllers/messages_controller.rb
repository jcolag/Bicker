require 'redcarpet'
require 'rubypants'

# rubocop:todo Style/Documentation
# rubocop:todo Metrics/ClassLength
class MessagesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_message, only: %i[show edit update destroy]

  # GET /messages
  # GET /messages.json
  def index
    @messages = Message.all.order('created_at DESC')
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    paragraphs = Message.getParagraphs current_user, helpers, @message.id, nil
    @paragraphs = Message.unrollParagraphs paragraphs
  end

  # GET /messages/new
  def new
    @message = Message.new
    @categories = Category
                  .select { |c| c.of == 'message' }
                  .collect { |c| [c.name, c.id] }
  end

  # GET /messages/1/edit
  def edit; end

  # POST /messages
  # POST /messages.json
  # rubocop:todo Metrics/PerceivedComplexity
  # rubocop:todo Metrics/MethodLength
  # rubocop:todo Metrics/AbcSize
  def create # rubocop:todo Metrics/CyclomaticComplexity
    params = message_params
    pars = Message.split_paragraphs(params[:content])
    msg = params.except(:content)
    prev_par = nil
    block_par = nil

    if pars.count == 0
      respond_to do |format|
        format.html do
          redirect_to new_message_path,
                      error: 'Message text is empty.'
        end
        format.json do
          render json: ['Message text is empty'],
                 status: :unprocessable_entity
        end
      end
      return
    end

    params[:subject] = nil if params[:subject] == ''

    @message = Message.new(msg)

    respond_to do |format| # rubocop:todo Metrics/BlockLength
      if @message.save
        pars.reverse_each do |p| # rubocop:todo Metrics/BlockLength
          if block_par.nil? &&
             (p.start_with?('```') ||
               p.start_with?('~~~') ||
               p.start_with?('|')
             )
            block_par = p + "\n"
          elsif
            ( # rubocop:todo Layout/ConditionPosition
              !block_par.nil? &&
              block_par.start_with?('`') &&
              !p.start_with?('```') &&
              !p.start_with?('~~~')
            ) || (
              !block_par.nil? &&
              block_par.start_with?('|') &&
              p.start_with?('|')
            )
            block_par += p + "\n"
          else
            # Flush the buffered table
            if !block_par.nil? && block_par.start_with?('|')
              block_par = block_par.split("\n").reverse.join("\n")
              par = {
                message_id: @message.id,
                parent_id: nil,
                # rubocop:todo Metrics/BlockNesting
                next_id: prev_par ? prev_par.id : nil,
                # rubocop:enable Metrics/BlockNesting
                user_id: @message.user_id,
                content: block_par
              }
              prev_par = Paragraph.new(par)
              if prev_par.save # rubocop:todo Metrics/BlockNesting
                Rails.logger.debug('Paragraph was successfully created.')
              else
                Rails.logger.warn(prev_par.errors.to_yaml)
              end
              block_par = nil
            end
            par = {}
            if p.start_with?('```') || p.start_with?('~~~')
              block_par += p + "\n"
              lines = block_par.split("\n").reverse.join("\n")
              par = {
                message_id: @message.id,
                parent_id: nil,
                # rubocop:todo Metrics/BlockNesting
                next_id: prev_par ? prev_par.id : nil,
                # rubocop:enable Metrics/BlockNesting
                user_id: @message.user_id,
                content: lines
              }
            else
              par = {
                message_id: @message.id,
                parent_id: nil,
                # rubocop:todo Metrics/BlockNesting
                next_id: prev_par ? prev_par.id : nil,
                # rubocop:enable Metrics/BlockNesting
                user_id: @message.user_id,
                content: p
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

        format.html do
          redirect_to @message,
                      notice: 'Message was successfully created.'
        end
        format.json do
          render :show,
                 status: :created,
                 location: @message
        end
      else
        @message = Message.new
        @content = pars.join("\n")
        @categories = Category
                      .select { |c| c.of == 'message' }
                      .collect { |c| [c.name, c.id] }
        format.html { render :new, notice: @message.errors }
        format.json do
          render json: @message.errors,
                 status: :unprocessable_entity
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update # rubocop:todo Metrics/MethodLength
    respond_to do |format|
      if @message.update(message_params)
        format.html do
          redirect_to @message,
                      notice: 'Message was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit }
        format.json do
          render json: @message.errors,
                 status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    delete_paragraphs @message.id
    @message.destroy
    respond_to do |format|
      format.html do
        redirect_to messages_url,
                    notice: 'Message was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  def reply
    format.json { head :no_content, status: :ok }
  end

  private

  def delete_paragraphs(message, parent = nil)
    # rubocop:todo Lint/AmbiguousBlockAssociation
    ps = sortParagraph Paragraph.select { |p|
      (p.message_id == message) && (p.parent_id == parent)
    }
    # rubocop:enable Lint/AmbiguousBlockAssociation
    ps.each do |p|
      delete_paragraphs message, p.id
      Beenseen.select { |b| b.paragraph_id == p.id }.each { |b| b.destroy }
      p.destroy
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_message
    @message = Message.find(params[:id])
  end

  # Never trust parameters from the scary internet,
  # only allow the white list through.
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

  # rubocop:todo Naming/MethodName
  # rubocop:todo Metrics/MethodLength
  def sortParagraph(pars, _start = nil, found = [])
    return found if pars.length == 0

    which = nil
    while pars.length > 0
      pars.each_index do |i|
        next unless pars[i].next_id == which

        p = pars.delete_at(i)
        which = p.id
        found.unshift(p)
        break
      end
    end
    found
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Naming/MethodName
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Style/Documentation

class ClientParagraph # rubocop:todo Style/Documentation
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
end
