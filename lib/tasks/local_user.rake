require 'net/http'
require 'open-uri'

key = ""
$userlocal_url_top = "https://virtual-youtuber.userlocal.jp"
namespace :local_user do
  task :crawler_vtuber => :environment do
    MAX_RANK = 1000
    PER_PAGE = 50
    max_page = MAX_RANK / PER_PAGE + 1

    (1..max_page).each do |page|
      userlocal_url = $userlocal_url_top + "/document/ranking?page=" + page.to_s
      doc = Nokogiri::HTML.parse(Net::HTTP.get(URI.parse(userlocal_url)),nil,nil)
      doc.css("table.table-ranking tr").each do |table_ranking|
        localuser_id,name,rank = get_name_etc(table_ranking)
        youtuber = Youtuber.find_or_initialize_by(userlocal_id: localuser_id)
        next unless youtuber.id.nil?
        p localuser_id

        url = $userlocal_url_top + "/user/" + localuser_id
        channel_id,office = get_channel_id_and_office_find_or_create(url, key)

        next if channel_id.nil?

        youtuber.youtube_id = channel_id
        youtuber.name = name
        youtuber.rank = rank
        youtuber.office_id = office.id unless office.nil?
        youtuber.save
        download_thumbnail(channel_id,key,youtuber.id)
      end
    end
  end

  task :refresh_thumbnail => :environment do
    Youtuber.find_each do |youtuber|
      p youtuber.id
      download_thumbnail(youtuber.youtube_id,key,youtuber.id)
    end
  end

  # @param table_element
  # @return [string,string,integer]
  def get_name_etc(table_element)
    link_url = table_element.attribute("data-href").value
    localuser_id = link_url.match("/user/").post_match
    name = table_element.css(".col-name .no-propagation").text.delete("/[\r\n\s]/")
    rank = table_element.css(".col-name strong")[0].text.delete("位")
    return localuser_id,name,rank
  end

  # @param url string
  # @param key string
  # @return [string,Office]
  def get_channel_id_and_office_find_or_create(url, key)
    def office_find_or_create(doc)
      office_a = doc.css(".box-office a")[0]
      return nil if office_a.nil?

      link = office_a.attributes["href"].value
      userlocal_id = link.match(/=.*/).to_s[1..-1]
      office = Office.where(userlocal_id: userlocal_id).first
      return office unless office.nil?

      redirect_url = Net::HTTP.get_response(URI($userlocal_url_top + link))["location"]
      doc2 = Nokogiri::HTML.parse(Net::HTTP.get(URI.parse(redirect_url)),nil,nil)
      office_dom = doc2.css(".box-office-info .subject")[0]
      return nil if office_dom.nil?##たまに正式な所属事務所じゃない時がある
      name = office_dom.text
      office = Office.create(userlocal_id: userlocal_id, name: name)

      thumbnail_url = doc2.css(".box-office-info img")[0]["src"]
      file_path = "thumbnail/office/" + office.id.to_s + File.extname(thumbnail_url)
      open(file_path, 'wb') do |file|
        file << open(thumbnail_url).read
      end

      return office
    end

    channel_id = ""
    doc2 = Nokogiri::HTML.parse(Net::HTTP.get(URI.parse(url)),nil,nil)
    office = office_find_or_create(doc2)
    doc2.css(".card-video").each do |card_video|
      example_movie_id = card_video["data-id"]
      url = "https://www.googleapis.com/youtube/v3/videos?part=snippet&id=" + example_movie_id + "&key=" + key
      doc2 =JSON.parse(Net::HTTP.get(URI.parse(url)))
      items = doc2["items"]
      if items.length == 0
        next
      end
      channel_id = items[0]["snippet"]["channelId"]
    end
    if channel_id == ""
      p "Not Found Channel_id"
      return nil
    end
    return channel_id,office
  end

  def download_thumbnail(channel_id, key, model_id)
    url = "https://www.googleapis.com/youtube/v3/channels?part=snippet&id="+channel_id.to_s+"&key="+key
    doc2 =JSON.parse(Net::HTTP.get(URI.parse(url)))
    thumbnail_url = doc2["items"][0]["snippet"]["thumbnails"]["default"]["url"]

    file_path = "thumbnail/" + model_id.to_s + '.jpg'
    open(file_path, 'wb') do |file|
      file << open(thumbnail_url).read
    end
  end
end
