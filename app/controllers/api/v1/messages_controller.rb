# frozen_string_literal: true

# API Namespace
module Api
  module V1
    # Controller for the Messages API
    class MessagesController < Api::V1::BaseController
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

      def reply
        para_id = params[:paraId].to_i
        offset = params[:offset].to_i
        message = params[:message].strip
        paragraph = Paragraph.find(para_id)
        first_part = paragraph.content[0..offset].strip
        last_part = paragraph.content[offset + 1..-1].strip

        if message.empty?
          respond_with 'Reply message is empty'
          return
        end

        # Split the paragraph if the split isn't at the end
        unless last_part.empty?
          fragment = Paragraph.new
          fragment.message_id = paragraph.message_id
          fragment.next_id = paragraph.next_id
          fragment.user_id = paragraph.user_id
          fragment.parent_id = paragraph.parent_id
          fragment.content = last_part
          fragment.split = false
          fragment.save

          paragraphs = Paragraph.select do |p|
            p.parent_id == paragraph.id
          end
          paragraphs.each do |p|
            p.parent_id = fragment.id
            p.save
          end

          paragraph.next_id = fragment.id
          paragraph.content = first_part
          paragraph.split = true
          paragraph.save
        end

        rpars = Message.split_paragraphs message
        block_par = nil
        prev_par = nil
        children = []

        rpars.reverse_each do |p|
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

        result = Message.get_paragraphs current_user,
                                        helpers,
                                        paragraph.message_id,
                                        nil
        result = Message.unroll_paragraphs result
        respond_with result
      end

      private

      def message_params
        params.require(:message).permit(:id, :name, :description)
      end
    end
  end
end
