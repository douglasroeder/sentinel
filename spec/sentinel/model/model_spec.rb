require 'spec_helper'

RSpec.describe Sentinel::Model do
  class TestClass
    include Sentinel::Model

    set_sentinel_table 'Contact'

    field :Name, alias: :name
    field :Email, alias: :email
    field :Telephone, alias: :telephone
  end

  it { expect(TestClass.entity_name).to eql('Contact') }

  it "should have dynamic fields" do
    test = TestClass.new

    expect(TestClass.new).to respond_to(:name)
  end

  describe '.find' do
    before :each do
      client_mock = double
      allow(Sentinel).to receive(:client) { client_mock }

      response_mock = double
      allow(response_mock).to receive(:Name) { 'John Doe' }
      allow(response_mock).to receive(:Email) { 'johndoe@example.org' }
      allow(response_mock).to receive(:Telephone) { '(11) 9999-8833' }

      allow(client_mock).to receive(:find).with('Contact', 123) { response_mock }
    end

    it 'should instance a new Model object' do
      test = TestClass.find(123)

      expect(test.name).to eql('John Doe')
    end
  end

  describe '#attrs' do
    it 'should generate attributes hash' do
      test = TestClass.new
      test.name = 'John Doe'
      test.email = 'johndoe@example.org'
      test.telephone = '(11) 9999-8833'

      expect(test.attrs.keys).to include(:Name)
    end
  end

  context 'saving model' do
    describe 'new entity row' do
      it 'should create a new row' do
        client_mock = double
        expect(client_mock).to receive(:create)
        allow(Sentinel).to receive(:client) { client_mock }

        test = TestClass.new
        test.save
      end
    end

    describe 'existing entity row' do
      it 'should update exising row' do
        client_mock = double
        expect(client_mock).to receive(:update)
        allow(Sentinel).to receive(:client) { client_mock }

        test = TestClass.new
        test.id = '123'
        test.name = 'Fritz'
        test.save
      end
    end
  end
end
