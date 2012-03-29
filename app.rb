#!/usr/bin/env ruby

require 'rubygems'
require 'twitter'
require 'highline/import'

puts
header = "Who unfollowed this user on twitter?"
puts header
puts "=" * header.length
puts

username = ask("Username: ") {|q| q.default = "michalvalasek" }
filename = "storage/#{username}.txt"
if File.exists?(filename)
  modtime = File.mtime(filename)
  puts "Last save: #{modtime}"
else
  puts "Nothing saved yet for this username"
end
save_state = ['Y','y'].include? ask("Save current state? [y/N] ")

archive_file = File.open(filename,'a+')

begin
  last_followerIds = Marshal.load archive_file.read
rescue
  last_followerIds = []
end

puts "Fetching followers for: @#{username} ..."

cursor = "-1"
followerIds = []
while cursor != 0 do
  followers = Twitter.follower_ids(username, :cursor => cursor)

  cursor = followers.next_cursor
  followerIds += followers.ids
  sleep(2)
end

if save_state
  archive_file.rewind
  archive_file.write Marshal.dump(followerIds)
end
archive_file.close

unfollowed = last_followerIds - followerIds
if unfollowed.empty?
  puts "\nNobody unfollowed since last save."
else
  puts "\nUnfollowed by:"
  unfollowed.each { |i| u = Twitter.user(i); puts "@#{u.screen_name} - #{u.name}" }
end
puts