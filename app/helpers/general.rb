# general display helpers
module Helpers
  module General

    def notification_radio_for(type, checked, default = false)
      name = {
        "email_immediate" => "Email immediately",
        "email_daily" => "Email once a day",
        "sms" => "SMS",
        "none" => "None",
        nil => "None",
        "" => "None"
      }[type]

      name << " (Default)" if default
      
      "<input type=\"radio\" name=\"notifications\" class=\"notifications\" value=\"#{type}\" #{"checked" if checked}/>
      <span>#{name}</span>"
    end

    def search_types
      [
        ["Everything", :all],
        ["Bills in Congress", :federal_bills],
        ["State Bills", :state_bills,],
        ["Federal Regulations", :regulations],
        ["Speeches in Congress", :speeches]
      ]
    end

    def interest_name(interest, quotes = false)
      Deliveries::Manager.interest_name interest, quotes
    end

    def interest_path(interest)
      Deliveries::Manager.interest_path interest
    end

    def filters_short(subscription)
      subscription.filters.map do |field, value|
        "<span>#{subscription.filter_name field, value}</span>"
      end.join(", ")
    end

    def hide_search
      content_for(:hide_search) { true }
    end

    def set_home
      content_for(:home) { true }
    end

    def search?
      request.path =~ /^\/search\//
    end

    def home?
      content_from :home
    end

    def show_data?
      !api_key.nil?
    end

    def api_key
      if current_user and current_user.api_key
        current_user.api_key
      elsif params[:hood] == "up"
        config[:demo_key]
      end
    end

    def developer_search_url(subscription)
      subscription.search_url :api_key => api_key
    end

    def developer_find_url(interest_type, item_id)
      adapter = Subscription.adapter_for interest_data[interest_type]['adapter']
      adapter.url_for_detail item_id, :api_key => api_key
    end

    def errors_for(object)
      if object and object.errors
        object.errors.map do |field, msg|
          "<div class=\"error\">#{msg}</div>"
        end.join
      end
    end

    # don't give me empty strings
    def content_from(symbol)
      content = yield_content symbol
      content.present? ? content : nil
    end

    def flash_for(types)
      partial "partials/flash", :engine => "erb", :locals => {:types => types}
    end

    def recent_searches
      partial "partials/recent_searches", :engine => "erb"
    end

    def follow_button(item)
      interest_type = interest_adapters[item.subscription_type]
      partial "partials/follow_item", :engine => "erb", :locals => {:item => item, :interest_type => interest_type}
    end

    def truncate_more(tag, text, max)
      truncated = truncate text, max
      if truncated == text
        text
      else
        "<span class=\"truncated\" data-tag=\"#{tag}\">
          #{truncated}
          <a href=\"#\" class=\"untruncate\">More</a>
        </span>
        <span class=\"untruncated\" data-tag=\"#{tag}\">#{text}</span>"
      end
    end

    def button(text)
      "<button>
        <span>#{text}</span>
      </button>"
    end

    def safe_capitalize(string)
      words = string.split(" ")
      words.each {|word| word[0..0] = word[0..0].upcase}
      words.join(" ")
    end

    def rss_date(time)
      time.strftime "%a, %d %b %Y %H:%M:%S %z"
    end

    def rss_encode(link)
      link.gsub "&", "&amp;"
    end

    def html_date(time)
      time.strftime "%Y-%m-%d"
    end
    
    def h(text)
      Rack::Utils.escape_html(text)
    end
    
    def form_escape(string)
      string.to_s.gsub "\"", "&quot;"
    end

    def js_escape(string)
      URI.decode(string.to_s).gsub "\"", "\\\""
    end
    
    def id_escape(id)
      id.gsub(" ", "_").gsub("|", "__").gsub(".", "__")
    end
    
    def long_date(time)
      time.strftime "%B #{time.day}, %Y" # remove 0-prefix
    end

    def short_date(time)
      time.strftime "%m-%d-%Y"
    end
    
    def just_date(date)
      date.strftime "%b #{date.day}, %Y"
    end

    def just_date_year(date)
      just_date date
    end
    
    def very_short_date(time)
      time.strftime "%m/%d"
    end
    
    def zero_prefix(number)
      number.to_i < 10 ? "0#{number}" : number.to_s
    end
    
  end
end