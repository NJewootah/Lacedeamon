require 'spec_helper'
require 'httparty'
require 'yaml'

describe 'LaceAPI' do 

  let(:lace){LaceAPI.new()}

	describe 'The LaceAPI creates a todo list' do
    it "should import data from the yaml file" do
      lace.import('Spec/item_list.yml')

      expect(lace.data[0]["title"]).to eq('Nini static Tester')
      expect(lace.data[0]["due"]).to eq('01/01/15')
    end

    it "should creates todo list items" do
      lace.import('Spec/item_list.yml')
      lace.create()
      expect(lace.items[0]).to be_a(Integer)
    end
  end

  describe 'The LaceAPI updates a todo list' do
    it "should get todo list items" do
      lace.get(1204)

      expect(lace.get(1204)["id"]).to eq(1204)
      expect(lace.get(1204)["title"]).to eq('Nini static Tester')
    end
  end

  it "should update some details of todo list items" do
    lace.patch(1204,'title','Nini Static Tester')
    expect(lace.get(1204)["title"]).to eq('Nini Static Tester')
  end

end