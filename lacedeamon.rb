require 'yaml'

class LaceAPI
  require 'httparty'
  attr_accessor :data,:items

  def initialize
  end

  def import(yml)
    file = File.open(yml)
    @data = YAML.load(file)
  end

  def create()
    @items = []
    @data.each do |i|
      values = HTTParty.post "http://lacedeamon.spartaglobal.com/todos", query:{title: i["title"],due: i["due"]}
      @items << values["id"]
    end
  end

  def get(id)
    values = HTTParty.get "http://lacedeamon.spartaglobal.com/todos/#{id}"
    return values
  end

  def patch(id,key,value)
    values = HTTParty.put "http://lacedeamon.spartaglobal.com/todos/#{id}", query:{title: key,due: value}
  end
end

lace = LaceAPI.new()
#lace.import('Spec/item_list.yml')
#lace.create
#puts lace.items
#puts lace.get(1204)
lace.patch(1204,'Nini static Tester','01/01/15')
puts lace.get(1204)



