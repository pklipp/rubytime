# ************************************************************************
# Ruby Time
# Copyright (c) 2006 Lunar Logic Polska sp. z o.o.
# 
# Permission is hereby granted, free of charge, to any person obtaining a 
# copy of this software and associated documentation files (the 
# "Software"), to deal in the Software without restriction, including 
# without limitation the rights to use, copy, modify, merge, publish, 
# distribute, sublicense, and/or sell copies of the Software, and to 
# permit persons to whom the Software is furnished to do so, subject to 
# the following conditions:
# 
# The above copyright notice and this permission notice shall be included 
# in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# ************************************************************************


module ApplicationHelper

  # Changes minutes as an integer to hour format hh:mm
  def hour_format(minutes)
    array = minutes.divmod(60)
    array[0].to_s + ":" + (100 + array[1]).to_s.slice(1, 2)
  end

  def paginate_me(collection)
     will_paginate collection
  rescue NoMethodError
     return nil
  end

  def back_link(tag_type = :p)
    if request.env['HTTP_REFERER']
      link = link_to('Back', request.env['HTTP_REFERER'])
      tag_type.nil? ? link : content_tag(tag_type, link)
    end
  end

  def rss_feed_url(feed, options = {})
    params = {:action => 'rss', :id => feed.id, :format => options[:format] || 'rss'}
    params[:key] = feed.secret_key if feed.authentication == 'key'
    url_for params
  end

end
