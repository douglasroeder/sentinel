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

  it 'should use class name as Entity name if not specified' do
    class Contact
      include Sentinel::Model
    end

    expect(Contact.entity_name).to eql('Contact')
  end

  it "should have dynamic fields" do
    test = TestClass.new

    expect(TestClass.new).to respond_to(:name)
  end

  describe '.find' do
    let(:find_response) do
      { Id: '123', Name: 'John Doe', Email: 'johndoe@example.org', Telephone: '(11) 9999-8833' }
    end

    before :each do
      client_mock = double
      allow(Sentinel).to receive(:client) { client_mock }
      response_mock = mock_find_and_query_response(find_response)
      allow(client_mock).to receive(:find).with('Contact', 123) { response_mock }
    end

    it 'should instance a new Model object' do
      test = TestClass.find(123)

      expect(test.name).to eql('John Doe')
      expect(test.id).to eql('123')
    end
  end

  describe '.query' do
    describe 'when successful' do
      let(:row_1) do
        { Id: '123', Name: 'John Doe', Email: 'johndoe@example.org', Telephone: '(11) 9999-8833' }
      end

      let(:row_2) do
        { Id: '124', Name: 'Doe John', Email: 'doejohn@example.org', Telephone: '(11) 9999-3388' }
      end

      before :each do
        client_mock = double

        allow(Sentinel).to receive(:client) { client_mock }
        response_mock = [mock_find_and_query_response(row_1), mock_find_and_query_response(row_2)]

        allow(client_mock).to receive(:query) { response_mock }

        @results = TestClass.query('query')
      end

      it 'should fetch an Array with 2 results' do
        expect(@results.size).to eql(2)
      end
    end

    describe 'when unsuccessful' do
      let(:row) do
        { Id: '124', Name: 'Doe John', Email: 'doejohn@example.org', Telephone: '(11) 9999-3388' }
      end

      before :each do
        client_mock = double

        allow(Sentinel).to receive(:client) { client_mock }
        response_mock = mock_find_and_query_response(row)
        allow(response_mock).to receive(:Id) { raise }

        allow(client_mock).to receive(:query) { [response_mock] }
      end

      it 'should raise exception' do
        expect {
          TestClass.query('query')
        }.to raise_exception(Sentinel::InvalidFieldMappingError)
      end
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

  context 'when saving entity' do
    describe 'a new entity row' do
      let(:valid_data) do
        { name: 'John Doe', email: 'johndoe@example.org', telephone: '(11) 9996-26655' }
      end

      it 'should create a new row' do
        client_mock = double
        expect(client_mock).to receive(:create)
        allow(Sentinel).to receive(:client) { client_mock }

        test = TestClass.new
        test.name = "John Doe"
        test.save
      end

      it 'should be possible create passing all data attributes' do
        client_mock = double
        expect(client_mock).to receive(:create)
        allow(Sentinel).to receive(:client) { client_mock }

        TestClass.create(valid_data)
      end

      describe 'when successfuly on create' do
        it 'should return true' do
          client_mock = double
          allow(client_mock).to receive(:create) { true }
          allow(Sentinel).to receive(:client) { client_mock }

          expect( TestClass.create(valid_data)).to eql(true)
        end
      end

      describe 'when unsuccessfuly on create' do
        it 'should return false' do
          client_mock = double
          allow(client_mock).to receive(:create) { raise }
          allow(Sentinel).to receive(:client) { client_mock }

          expect( TestClass.create(valid_data)).to eql(false)
        end
      end
    end

    describe 'an existing entity row' do
      let(:valid_data) do
        { name: 'Fritz' }
      end

      it 'should update exising row' do
        client_mock = double
        expect(client_mock).to receive(:update)
        allow(Sentinel).to receive(:client) { client_mock }

        test = TestClass.new
        test.id = '123'
        test.name = 'Fritz'
        test.save
      end

      it 'should be possible to update passing Id and data attributes' do
        client_mock = double
        expect(client_mock).to receive(:update)
        allow(Sentinel).to receive(:client) { client_mock }

        TestClass.update(123, valid_data)
      end

      describe '#update_attributes' do
        let(:attrs) do
          { id: '123', name: 'Fritz' }
        end

        it 'should update entity passing a Hash object' do
          client_mock = double
          expect(client_mock).to receive(:update)
          allow(Sentinel).to receive(:client) { client_mock }

          test = TestClass.new
          test.update_attributes(attrs)
        end
      end

      describe 'when successfuly on update' do
        it 'should return true' do
          client_mock = double
          allow(client_mock).to receive(:update) { true }
          allow(Sentinel).to receive(:client) { client_mock }

          expect( TestClass.update(123, valid_data)).to eql(true)
        end
      end

      describe 'when unsuccessfuly on update' do
        it 'should return false' do
          client_mock = double
          allow(client_mock).to receive(:update) { raise }
          allow(Sentinel).to receive(:client) { client_mock }

          expect( TestClass.update(123, valid_data)).to eql(false)
        end
      end
    end
  end

  describe 'removing a row from the entity' do
    it 'should remove the row' do
      client_mock = double
      expect(client_mock).to receive(:destroy).with('Contact', 123)
      allow(Sentinel).to receive(:client) { client_mock }

      TestClass.destroy(123)
    end

    describe 'when successfuly on removing' do
      it 'should return true' do
        client_mock = double
        allow(client_mock).to receive(:destroy) { true }
        allow(Sentinel).to receive(:client) { client_mock }

        expect( TestClass.destroy(123)).to eql(true)
      end
    end

    describe 'when unsuccessfuly on update' do
      it 'should return false' do
        client_mock = double
        allow(client_mock).to receive(:destroy) { raise }
        allow(Sentinel).to receive(:client) { client_mock }

        expect( TestClass.destroy(123)).to eql(false)
      end
    end
  end

  private
  def mock_find_and_query_response(attrs)
    response_mock = double

    attrs.keys.each do |key|
      allow(response_mock).to receive(key) { attrs[key] }
    end

    return response_mock
  end
end
