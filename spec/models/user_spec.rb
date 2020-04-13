# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is valid with valid attributes' do
    name = (0...8).map { ('a'..'z').to_a[rand(26)] }.join
    user = User.new
    user.login = name
    user.email = name + '@test.invalid'
    user.password = 'test password'
    expect(user).to be_valid
  end

  describe 'user predicates' do
    it 'checks admin' do
      pending "add some examples to (or delete) #{__FILE__}"
      raise
    end

    it 'checks non-admin' do
      pending "add some examples to (or delete) #{__FILE__}"
      raise
    end

    it 'checks client' do
      pending "add some examples to (or delete) #{__FILE__}"
      raise
    end

    it 'checks non-client' do
      pending "add some examples to (or delete) #{__FILE__}"
      raise
    end
  end
end
