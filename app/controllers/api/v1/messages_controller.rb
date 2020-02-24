# rubocop:todo Style/Documentation
# rubocop:todo Metrics/ClassLength
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
    message = Message.find(params['id'])
    message.update_attributes(message_params)
    respond_with message, json: message
  end

  # rubocop:todo Metrics/PerceivedComplexity
  # rubocop:todo Metrics/MethodLength
  # rubocop:todo Metrics/AbcSize
  def reply # rubocop:todo Metrics/CyclomaticComplexity
    paraId = params[:paraId].to_i # rubocop:todo Naming/VariableName
    offset = params[:offset].to_i
    message = params[:message].strip
    # rubocop:todo Naming/VariableName
    paragraph = Paragraph.find(paraId)
    # rubocop:enable Naming/VariableName
    # rubocop:todo Naming/VariableName
    firstPart = paragraph.content[0..offset].strip
    # rubocop:enable Naming/VariableName
    # rubocop:todo Naming/VariableName
    lastPart = paragraph.content[offset + 1..-1].strip
    # rubocop:enable Naming/VariableName

    if message.length == 0
      respond_with 'Reply message is empty'
      return
    end

    # Split the paragraph if the split isn't at the end
    if lastPart.length > 0 # rubocop:todo Naming/VariableName
      fragment = Paragraph.new
      fragment.message_id = paragraph.message_id
      fragment.next_id = paragraph.next_id
      fragment.user_id = paragraph.user_id
      fragment.parent_id = paragraph.parent_id
      # rubocop:todo Naming/VariableName
      fragment.content = lastPart
      # rubocop:enable Naming/VariableName
      fragment.split = false
      fragment.save

      Paragraph.select do |p|
        p.parent_id == paragraph.id
      end.each do |p|
        p.parent_id = fragment.id
        p.save
      end

      paragraph.next_id = fragment.id
      # rubocop:todo Naming/VariableName
      paragraph.content = firstPart
      # rubocop:enable Naming/VariableName
      paragraph.split = true
      paragraph.save
    end

    rpars = Message.split_paragraphs message
    block_par = nil
    prev_par = nil
    children = []

    rpars.reverse_each do |p| # rubocop:todo Metrics/BlockLength
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
            message_id: paragraph.message_id,
            parent_id: paragraph.id,
            next_id: prev_par ? prev_par.id : nil,
            user_id: current_user.id,
            content: block_par
          }
          prev_par = Paragraph.new par
          prev_par.save
          children.push prev_par
          block_par = nil
        end
        par = {}
        if p.start_with?('```') || p.start_with?('~~~')
          block_par += p + "\n"
          lines = block_par.split("\n").reverse.join("\n")
          par = {
            message_id: paragraph.message_id,
            parent_id: paragraph.id,
            next_id: prev_par ? prev_par.id : nil,
            user_id: current_user.id,
            content: lines
          }
        else
          par = {
            message_id: paragraph.message_id,
            parent_id: paragraph.id,
            next_id: prev_par ? prev_par.id : nil,
            user_id: current_user.id,
            content: p
          }
        end
        prev_par = Paragraph.new par
        prev_par.save
        children.push prev_par
        block_par = nil
      end
    end

    result = Message.getParagraphs current_user, helpers, paragraph.message_id, nil
    result = Message.unrollParagraphs result
    respond_with result
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity

  private

  def message_params
    params.require(:message).permit(:id, :name, :description)
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Style/Documentation
