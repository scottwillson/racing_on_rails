module PostsHelper

  # Build links to archived posts
  # FIXME this needs to rewritten
  def archive_navigation(mailing_list, month, year)
    if mailing_list.dates
      nav = Builder::XmlMarkup.new(:indent=>2)
      nav.div({:class => "top_margin archive_navigation centered last"}) { |nav|
        nav.div {
          for y in (mailing_list.dates.first.year)..(mailing_list.dates.last.year)
            if y != year
              nav.a(y, :href => url_for(
                :controller => "posts", 
                :mailing_list_name => @mailing_list.name, 
                :action => "list", 
                :year => y, 
                :month => month)
              )
            else
              nav.span(:class => "archive_navigation") {
                nav.text!(y.to_s)
              }
            end
          end
        }
        nav.div({ :class => "centered" }) {
          if has_previous(month, year, mailing_list)
            y = year
            m = month - 1
            if m < 1
              y = y - 1
              m = 12
            end
            nav.a("[Previous]", :href => url_for(:year => y, :month => m))
          else
            nav.span(:class => "archive_navigation last") {
              nav.text!("[Previous]")
            }
          end
          
          for m in 1..12
            if (m != month and (year < mailing_list.dates.last.year or m <= mailing_list.dates.last.month))
              nav.a(Time::RFC2822_MONTH_NAME[m - 1], :href => url_for(
                :controller => "posts", 
                :mailing_list_name => @mailing_list.name, 
                :action => "list", 
                :year => year, 
                :month => m)
              )
            else
              nav.span(:class => "archive_navigation") {
                nav.text!(Time::RFC2822_MONTH_NAME[m - 1])
              }
            end
          end
          
          if has_next(month, year, mailing_list)
            y = year
            m = month + 1
            if m > 12
              y = y + 1
              m = 1
            end
            nav.a("[Next]", :href => url_for(:year => y, :month => m))
          else
            nav.span(:class => "archive_navigation") {
              nav.text!("[Next]")
            }
          end
        }
      }.html_safe
    else
      nav = Builder::XmlMarkup.new(:indent=>2)
      nav.div({:class => "archive_navigation"}) {
        nav.text!("[Previous]")
        nav.text!("[Next]")
      }.html_safe
    end
  end
  
  def has_previous(month, year, mailing_list)
    return false if mailing_list.dates.first.nil?
    mailing_list.dates.first.year < year or (mailing_list.dates.first.year == year and mailing_list.dates.first.month < month)
  end
  
  def has_next(month, year, mailing_list)
    return false if mailing_list.dates.last.nil?
    year < mailing_list.dates.last.year or (mailing_list.dates.last.year == year and mailing_list.dates.last.month > month)
  end
  
  def post_navigation(post)
    previous_post = Post.first(
      :conditions => ["mailing_list_id = ? and date < ?", post.mailing_list.id, post.date], 
      :order => "date desc", 
      :limit => 1
    )
    next_post = Post.first(
      :conditions => ["mailing_list_id = ? and date > ?", post.mailing_list.id, post.date], 
      :order => "date asc", 
      :limit => 1
    )      
    nav = Builder::XmlMarkup.new(:indent=>2)
    nav.div({:class => "top_margin archive_navigation"}) {
      nav.div {
        month = post.date.month
        month_name = Time::RFC2822_MONTH_NAME[month - 1]
        year = post.date.year
        nav.a("View #{month_name} #{year} Archives", :href => url_for(
          :controller => "posts", 
          :mailing_list_name => post.mailing_list.name, 
          :action => "list", 
          :year => year, 
          :month => month)
        )
        
        if previous_post
          nav.a("[Previous]", :href => url_for(:id => previous_post.id))
        else
          nav.span(:class => "archive_navigation") {
            nav.text!("[Previous]")
          }
        end
        
        if next_post
          nav.a("[Next]", :href => url_for(:id => next_post.id))
        else
          nav.span(:class => "archive_navigation") {
            nav.text!("[Next]")
          }
        end
      }
    }.html_safe
  end
end
