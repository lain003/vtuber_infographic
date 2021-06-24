namespace :youtube do
  task :main => :environment do
    key = "AIzaSyDvbSdj50CFsAucNuEEMYyYUQkC5oJqTKQ"
    Youtuber.where("rank <= 1000").find_each do |youtuber|
      p youtuber.name
      s = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails&id=" + youtuber.youtube_id + "&key=" + key
      output = JSON.parse(Net::HTTP.get(URI.parse(s)))
      list_id = output["items"][0]["contentDetails"]["relatedPlaylists"]["uploads"]
      default_url = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=" + list_id + "&maxResults=50&key="+key

      url = default_url
      loop do
        json = JSON.parse(Net::HTTP.get(URI.parse(url)))
        json["items"].each do |item|
          video_id = item["snippet"]["resourceId"]["videoId"]
          movie = Movie.find_or_initialize_by(youtube_movie_id: video_id,youtuber_id: youtuber.id)
          movie.save

          channel_ids = get_channel_ids_link(item["snippet"]["description"])
          linked_youtubers = Youtuber.where(:youtube_id => channel_ids)
          linked_youtubers.each do |linked_youtuber|
            link = Link.find_or_initialize_by(youtuber_id: linked_youtuber.id, movie_id: movie.id)
            link.save
          end
        end
        next_page_token = json["nextPageToken"]
        if next_page_token.nil?
          break
        else
          url = default_url + "&pageToken=" + next_page_token
        end
      end
    end
  end

  task :create_png => :environment do
    target_rank = 100
    gv = Gviz.new(:G)
    gv.global layout: "fdp",ranksep: 10

    declaration_node_and_subgraph(gv,target_rank)
    link_nodes(gv)

    gv.save :sample, :png
  end

  def link_nodes(gv)
    Youtuber.where("rank <= " + target_rank.to_s).find_each do |youtuber|
      links = Link.select("DISTINCT links.youtuber_id").joins(:movie).where("movies.youtuber_id": youtuber.id)
      linked_youtuber_ids = links.map{|link| link.youtuber_id}
      linked_youtuber_ids.each do |linked_youtuber_id|
        next if youtuber.id == linked_youtuber_id
        gv.add youtuber.id.to_s.to_sym => linked_youtuber_id.to_s.to_sym
      end
    end
  end

  def declaration_node_and_subgraph(gv,target_rank)
    linked_youtuber_ids = Link.joins(:movie => :youtuber).where("youtubers.rank <= " + target_rank.to_s).pluck("youtuber_id").uniq
    rank_youtuber_ids = Youtuber.where("rank <= " + target_rank.to_s).pluck("id")
    all_youtuber_ids = (linked_youtuber_ids + rank_youtuber_ids).uniq.sort

    Youtuber.where(id: all_youtuber_ids).group_by{|i| i.office_id}.each do |office_id, youtubers|
      if office_id.nil?
        youtubers.each do |youtuber|
          gv.node youtuber.id.to_s.to_sym, label:"", image:'thumbnail/' + youtuber.id.to_s + '.jpg',shape: 'Msquare'
        end
      else
        gv.subgraph(("cluster" + office_id.to_s).to_sym) do
          office = Office.find(office_id)
          global label:office.name, image:'thumbnail/office/' + office_id.to_s + '.png'
          youtubers.each do |youtuber|
            node youtuber.id.to_s.to_sym, label:"", image:'thumbnail/' + youtuber.id.to_s + '.jpg',shape: 'Msquare'
          end
        end
      end
    end
  end

  def get_channel_ids_link(description)
    urls = description.scan(%r{https?://www\.youtube\.com/channel[\w_.!*\/')(-]+})
    channel_ids = []
    urls.each do |url|
      channel_id = URI.split(url)[5].split("/")[2]
      channel_ids << channel_id
    end
    channel_ids.uniq!
    return channel_ids
  end
end
