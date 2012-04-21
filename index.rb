require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'json'

=begin
 * data result=> [[language,num-job]]
 * example: [
              ['java', 300],
              ['test', 500]
            ] 
=end



=begin
 * Get the page from a url
=end

def getPage(agent, url)
  return agent.get url
end


def getResult(agent, page, jobKeyword, jobLocation)
  form=page.form_with(:id=>'jobsearch')
  form.fields[0].value= jobKeyword
  form.fields[1].value= jobLocation
  return agent.submit form
end

def getCount(htmlContent)
  dom= Nokogiri::HTML(htmlContent, 'UTF-8')
  countResult=0
  count=dom.xpath('//div[@id="searchCount"]').first.text
  if count=~/of (\d+,?\d+)/
    countResult=$1
    if countResult=~/(\d+),(\d+)/
      countResult=$1+$2
    end
  end
  return countResult
end

def crawl(url, keywords, cities)
  agent=Mechanize.new
  data=Array.new
  page=getPage agent, url
  cities.each do |city|
    language=Array.new
    keywords.each do |keyword|
      language.push(Array[keyword, getCount(getResult(agent, page, keyword, city).body).to_i])
    end
    data.push(Array[city, language])
  end  
  return data
end

keywords=['java', 'php', 'ruby', 'C#','python', 'C++', 'android', 'IOS', '.net']
agent=Mechanize.new
url="http://www.indeed.com"

city=['TN','CA','NY']

url="http://www.indeed.com"
data= crawl(url, keywords,city)

def to_json(data)
  jsonresult='{'
  data.each do |item|
    jsonresult<<('"'+item[0]+'": {')
    item[1].each do |state| 
      if state!= item[1].last
        jsonresult<<('"'+state[0]+'": '+state[1].to_s+',')
      else 
          jsonresult<<('"'+state[0]+'": '+state[1].to_s)
      end
    end
    if item!= data.last
      jsonresult<<'},'
    else
      jsonresult<<'}'
    end
    
  end
  jsonresult<<'}'
  return jsonresult
end

def to_Hash(data)
  
  hashed_data= Hash[data]
  
  hashed_data.each do |key, value|
    hashed_data[key]=Hash[value]
  end
  #josonresult='{'
  #data.
  return hashed_data
end

def to_json_languageFormat(json)
  json=to_Hash(json)
  cached=Array.new
  newHashed_data= Hash.new
  json.each do |key, value|
     value.each do |k,v|
       tempHash=Hash.new
       tempHash[key]=v
       if cached.include? k
         newHashed_data[k]=newHashed_data[k].merge tempHash
       else
         newHashed_data[k]= tempHash
         cached<<k
       end
       
       
     end
  end
  return newHashed_data
end
print to_json_languageFormat(data)
#puts ''

#print to_Hash(data)
#puts "this separate the data"

#print data
=begin
data.each do |entry|
  print entry
  puts ''
end
=end

