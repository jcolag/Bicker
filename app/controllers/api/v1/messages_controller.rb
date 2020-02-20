class Api::V1::MessagesController < Api::V1::BaseController
  def index
    respond_with Message.all
  end

  def create
    respond_with :api, :v1, Message.create(message_params)
  end

  def destroy
    respond_with Message.destroy(params[:id])
  end

  def update
    message = Message.find(params["id"])
    message.update_attributes(message_params)
    respond_with message, json: message
  end

  def reply
    paraId = params[:paraId].to_i
    offset = params[:offset].to_i
    message = params[:message].strip
    paragraph = Paragraph.find(paraId)
    firstPart = paragraph.content[0..offset].strip
    lastPart = paragraph.content[offset + 1..-1].strip

    if message.length == 0
      args = {
        message:  "Reply message is empty",
        status:  "ERROR"
      }
      respond_with args
      return
    end

    # Split the paragraph if the split isn't at the end
    if lastPart.length > 0
      fragment = Paragraph.new
      fragment.message_id = paragraph.message_id
      fragment.next_id = paragraph.next_id
      fragment.user_id = paragraph.user_id
      fragment.parent_id = paragraph.parent_id
      fragment.content = lastPart
      fragment.split = false
      fragment.save

      Paragraph.select { |p|
        p.parent_id == paragraph.id
      }.each { |p|
        p.parent_id = fragment.id
        p.save
      }

      paragraph.next_id = fragment.id
      paragraph.content = firstPart
      paragraph.split = true
      paragraph.save
    end

    rpars = split_paragraphs message
    block_par = nil
    prev_par = nil
    children = []

    rpars.reverse_each do |p|
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
            :message_id => paragraph.message_id,
            :parent_id => paragraph.id,
            :next_id => prev_par ? prev_par.id : nil,
            :user_id => current_user.id,
            :content => block_par
          }
          prev_par = Paragraph.new par
          prev_par.save
          children.push prev_par
          block_par = nil
        end
        par = {}
        if p.start_with?('```') or p.start_with?('~~~')
          block_par += p + "\n"
          lines = block_par.split("\n").reverse.join("\n")
          par = {
            :message_id => paragraph.message_id,
            :parent_id => paragraph.id,
            :next_id => prev_par ? prev_par.id : nil,
            :user_id => current_user.id,
            :content => lines
          }
        else
          par = {
            :message_id => paragraph.message_id,
            :parent_id => paragraph.id,
            :next_id => prev_par ? prev_par.id : nil,
            :user_id => current_user.id,
            :content => p
          }
        end
        prev_par = Paragraph.new par
        prev_par.save
        children.push prev_par
        block_par = nil
      end
    end

    args = {
      after: fragment,
      before: paragraph,
      children: children,
      message: params[:message],
      offset: params[:offset],
      paraId: params[:paraId],
    }
    respond_with args
  end

  private

  def split_paragraphs msg
    msg.split(/[\r\n]/).select { |line| line.length > 0 }
  end

  def message_params
    params.require(:message).permit(:id, :name, :description)
  end
end
