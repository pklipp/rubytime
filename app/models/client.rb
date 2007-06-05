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

class Client < ActiveRecord::Base
    has_many :projects, :dependent => :destroy
    has_many :invoices, :dependent => :destroy
    has_many :clients_logins, :dependent => :destroy

    # validators
    validates_presence_of :name, :description
    validates_uniqueness_of :name

    def Client.find_active
        Client.find(:all, :conditions => "is_inactive = 0", :order => "name")
    end

    def active_text
        is_inactive ? "NO" : "YES"
    end

end
