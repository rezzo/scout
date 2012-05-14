# landing pages

get "/item/:interest_type/:item_id" do
  interest_type = params[:interest_type].strip
  item_id = params[:item_id].strip

  interest = item_interest_for item_id, interest_type

  erb :show, :layout => !pjax?, :locals => {
    :interest => interest,
    :interest_type => interest_type,
    :item_id => item_id
  }
end

get "/fetch/item/:interest_type/:item_id" do
  interest_type = params[:interest_type].strip
  item_id = params[:item_id].strip
  subscription_type = interest_data[interest_type]['adapter']

  unless item = Subscriptions::Manager.find(subscription_type, item_id)
    halt 404 and return
  end

  interest = item_interest_for item_id, interest_type

  erb :"subscriptions/#{subscription_type}/_show", :layout => false, :locals => {
    :item => item,
    :interest => interest,
    :interest_type => interest_type
  }
end


helpers do
  def item_interest_for(item_id, interest_type)
    if logged_in?
      current_user.interests.find_or_initialize_by(
        :in => item_id, 
        :interest_type => interest_type
      )
    else
      Interest.new(
        :in => item_id, 
        :interest_type => interest_type
      )
    end
  end
end