# frozen_string_literal: true

require 'redcarpet'
require 'rubypants'

# The message controller
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
    paragraphs = Message.get_paragraphs current_user, helpers, @message.id, nil
    @paragraphs = Message.unroll_paragraphs paragraphs
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
  def create
    params = message_params
    pars = Message.split_paragraphs(params[:content])
    msg = params.except(:content)
    prev_par = nil
    block_par = nil

    if pars.empty?
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

    respond_to do |format|
      if @message.save
        pars.reverse_each do |p|
          if block_par.nil? &&
             (p.start_with?('```') ||
               p.start_with?('~~~') ||
               p.start_with?('|')
             )
            block_par = p + "\n"
          elsif (
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
                next_id: prev_par ? prev_par.id : nil,
                user_id: @message.user_id,
                content: block_par
              }
              prev_par = Paragraph.create_new(par)
              if prev_par.save
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
                next_id: prev_par ? prev_par.id : nil,
                user_id: @message.user_id,
                content: lines
              }
            else
              par = {
                message_id: @message.id,
                parent_id: nil,
                next_id: prev_par ? prev_par.id : nil,
                user_id: @message.user_id,
                content: p
              }
            end
            prev_par = Paragraph.create_new(par)
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

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
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
    ps = sort_paragraph(Paragraph.select do |p|
      (p.message_id == message) && (p.parent_id == parent)
    end)
    ps.each do |p|
      delete_paragraphs message, p.id
      Beenseen.select { |b| b.paragraph_id == p.id }.each(&:destroy)
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

  def sort_paragraph(pars, _start = nil, found = [])
    return found if pars.empty?

    which = nil
    until pars.empty?
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
end
