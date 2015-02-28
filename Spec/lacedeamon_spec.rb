require 'spec_helper'
require 'httparty'
require 'yaml'

describe 'Lacedeamon API' do 
  let(:url){"http://lacedeamon.spartaglobal.com/todos/"}
  let(:title){"Nini Tester"}
  let(:due){"2015/03/03"}
  let(:newT){"Nini Changer"}
  let(:newD){"2014/04/04"}
  let(:post){HTTParty.post(url, query:{title: title, due: due})}
  let(:getall){HTTParty.get(url)}

	describe 'Positive' do

    it "should GET items" do
      r = getall
      expect(r.code).to eq(200)
      expect(r.message).to eq("OK")
    end

    it "should PUT items" do
      r = post
      d = HTTParty.put url+"#{r["id"]}", query:{title: newT,due: newD}
      expect(d.code).to eq(200)
      expect(d.message).to eq("OK")
      HTTParty.delete url+"#{r["id"]}"
    end

    it "should POST items" do
      r = post
      expect(r.code).to eq(201)
      expect(r.message).to eq("Created")
      expect(r["title"]).to eq(title)
      HTTParty.delete url+"#{r["id"]}"
    end

    it "should PATCH items" do
      r = post
      d = HTTParty.patch url+"#{r["id"]}", query:{title: newT}
      expect(d.code).to eq(200)
      expect(d.message).to eq("OK")
      HTTParty.delete url+"#{r["id"]}"
    end

    it "should DELETE items" do
      r = post
      d = HTTParty.delete url+"#{r["id"]}"
      expect(d.code).to eq(204)
      expect(d.message).to eq("No Content")
    end

    it "should create items using the wrong date format" do
      r = HTTParty.post(url, query:{title: title,due: "Oct"})
      expect(r.code).to eq(201)
      expect(r.message).to eq("Created")
      HTTParty.delete url+"#{r["id"]}"
    end

    it "should create multiple items imported from a YAML file" do
      file = File.open('item_list.yml')
      data = YAML.load(file)
      r = []

      data.each do |i|
        r << HTTParty.post(url, query:{title: i["title"],due: i["due"]})
      end

      r.each do |i|
        expect(i.code).to eq(201)
        expect(i.message).to eq("Created")
        HTTParty.delete url+"#{i["id"]}"
      end
    end

  end

  describe 'Negative' do

    it "should throw an error when deleting a collection" do
      d = HTTParty.delete url
      expect(d.code).to eq(405)
      expect(d.message).to eq("Method Not Allowed")
    end

    it "should throw an error when deleting a non-existant item" do
      d = HTTParty.delete url+"500"
      expect(d.code).to eq(404)
      expect(d.message).to eq("Not Found")
    end

    it "should throw an error when creating an item without a date" do
      d = HTTParty.post(url, query:{title: title})
      expect(d.code).to eq(422)
      expect(d.message).to eq("Unprocessable Entity")
    end

    it "should throw an error when reading an item that doesn't exist" do
      d = HTTParty.get(url+"500")
      expect(d.code).to eq(404)
      expect(d.message).to eq("Not Found")
    end

    it "should throw an error when creating an item within an existing object" do
      r = post
      d = HTTParty.post(url+"#{r["id"]}", query:{title: newT,due: newD})
      expect(d.code).to eq(405)
      expect(d.message).to eq("Method Not Allowed")
      HTTParty.delete url+"#{r["id"]}"
    end

    it "should throw an error when creating an item within a non-existant object" do
      d = HTTParty.post(url+"500", query:{title: newT,due: newD})
      expect(d.code).to eq(405)
      expect(d.message).to eq("Method Not Allowed")
    end

    it "should throw an error when updating items without date parameter using PUT" do
      r = post
      d = HTTParty.put url+"#{r["id"]}", query:{title: newT}
      expect(d.code).to eq(422)
      expect(d.message).to eq("Unprocessable Entity")
      HTTParty.delete url+"#{r["id"]}"
    end

  end
end