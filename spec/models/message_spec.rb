# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'Paragraph splitting' do
    it 'works on empty' do
      result = Message.split_paragraphs ''
      expect(result).to eq([])
    end

    it 'splits each line' do
      multiple_lines = "1\n2\n3\n4\n5"
      array = %w[1 2 3 4 5]
      result = Message.split_paragraphs multiple_lines
      expect(result).to eq(array)
    end

    it 'splits each line by carriage returns' do
      multiple_lines = "1\r2\r3\r4\r5"
      array = %w[1 2 3 4 5]
      result = Message.split_paragraphs multiple_lines
      expect(result).to eq(array)
    end

    it "checks that letters aren't accidentally used" do
      multiple_lines = 'abcdefghijklmnopqrstuvwxyz'
      result = Message.split_paragraphs multiple_lines
      expect(result).to eq([multiple_lines])
    end

    it 'eliminates empty lines' do
      multiple_lines = "\n\n1\n2\n\n\n\n3\n\n\n4\n5\n\n\n\n\n"
      array = %w[1 2 3 4 5]
      result = Message.split_paragraphs multiple_lines
      expect(result).to eq(array)
    end
  end

  context 'with setup completed' do
    before(:context) do
      @category = Category.new
      @category.name = 'Test Category'
      @category.save

      name = (0...8).map { ('a'..'z').to_a[rand(26)] }.join
      @user = User.new
      @user.login = name
      @user.email = name + '@test.invalid'
      @user.password = 'test password'
      @user.save
    end

    it 'is invalid without valid attributes' do
      expect(Message.new).to_not be_valid
    end

    it 'is valid with valid attributes' do
      message = Message.new
      message.category_id = @category.id
      message.user_id = @user.id
      message.subject = 'Test Message'
      expect(message).to be_valid
    end

    describe 'Unrolling paragraphs' do
      it 'works on nil' do
        result = Message.unroll_paragraphs nil
        expect(result).to eq([])
      end

      it 'works on empty' do
        result = Message.unroll_paragraphs []
        expect(result).to eq([])
      end

      context 'with a message tree' do
        before(:context) do
          @line_texts = ['Line #5', 'Line #4', 'Line #3', 'Line #2', 'Line #1']
          @message = Message.new
          @message.category_id = @category.id
          @message.user_id = @user.id
          @message.subject = 'Test Message'
          @message.save

          @no_replies = []
          last_p = nil
          @line_texts.each do |l|
            paragraph = Paragraph.new
            paragraph.message_id = @message.id
            paragraph.next_id = last_p
            paragraph.user_id = @user.id
            paragraph.content = l
            paragraph.save
            cp = ClientParagraph.new Helper.new, paragraph, [], @no_replies.length
            cp.children = []
            @no_replies.push cp
            last_p = paragraph.id
          end

          @w_replies = []
        end

        it 'organizes a linear message' do
          list = Message.unroll_paragraphs @no_replies.shuffle
          text = list.map(&:content)
          expect(text).to eq(@line_texts.reverse)
        end

        it 'organizes a message with replies' do
        end
      end
    end

    describe 'Finding the next paragraph' do
      pending "add some examples to (or delete) #{__FILE__}"
    end

    describe 'Loading paragraphs' do
      pending "add some examples to (or delete) #{__FILE__}"
    end

    describe 'Testing paragraph children' do
      pending "add some examples to (or delete) #{__FILE__}"
    end

    describe 'Marking paragraphs as seen' do
      pending "add some examples to (or delete) #{__FILE__}"
    end

    describe 'Formatting paragraphs' do
      pending "add some examples to (or delete) #{__FILE__}"
    end

    describe 'Initialize formatting' do
      pending "add some examples to (or delete) #{__FILE__}"
    end
  end
end

class Helper
  def avatar(_size, _user)
    ''
  end

  def time_ago_in_words(_ago)
    ''
  end
end
