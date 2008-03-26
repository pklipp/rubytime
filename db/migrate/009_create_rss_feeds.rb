# ************************************************************************
# Ruby Time
# Copyright (c) 2006 Lunar Logic Polska sp. z o.o.
# 
# This code is licensed under the MIT license.
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

class CreateRssFeeds < ActiveRecord::Migration

  def self.up
    create_table :rss_feeds do |t|
      t.integer :owner_id, :null => false
      t.string :owner_type, :null => false
      t.string :secret_key
      t.string :authentication, :null => false, :default => 'http'
    end

    add_index :rss_feeds, [:owner_id, :owner_type], :unique => true

    create_table :rss_feed_elements do |t|
      t.references :rss_feed, :null => false
      t.integer :project_id
      t.integer :role_id
      t.integer :user_id
    end

    add_index :rss_feed_elements, :rss_feed_id
  end

  def self.down
    remove_index :rss_feeds, [:owner_id, :owner_type]
    drop_table :rss_feeds
    remove_index :rss_feed_elements, :rss_feed_id
    drop_table :rss_feed_elements
  end
end
