#
#  TwittRb2Delegate.rb
#  TwittRb2
#
#  Created by phuesler on 20.04.10.
#  Copyright (c) 2010 huesler informatik. All rights reserved.
#

class TwittRb2Delegate
  attr_accessor :credentialsWindow, :mainWindow
  attr_accessor :usernameField, :passwordField
  attr_accessor :username, :password
  attr_accessor :tableView, :statusLabel
  attr_accessor :updates
  attr_accessor :reloadButton
  
  def initialize
    @timeline = []
  end
  
  def applicationDidFinishLaunching(notification)
    NSApp.beginSheet(credentialsWindow,
                    modalForWindow:mainWindow,
                    modalDelegate:nil,
                    didEndSelector:nil,
                    contextInfo:nil)
    @twitterEngine = MGTwitterEngine.alloc.initWithDelegate(self)
  end
  
  def submitCredentials(sender)
    self.username = usernameField.stringValue
    self.password = passwordField.stringValue
    hideCredentialsWindow(sender)
    reload(self)
  end
  
  def cancelCredentials(sender)
    hideCredentialsWindow(sender)
  end
  
  def reload(sender)
    @twitterEngine.setUsername(username, password:password)
    @twitterEngine.getFollowedTimelineSinceID(0, startingAtPage:0, count:20)
  end
  
  def sendUpdate(sender)
    @twitterEngine.sendUpdate(sender.stringValue)
    sender.setTitleWithMnemonic("")
  end
  
  def statusesReceived(statuses, forRequest:identifier)
    # return if it was a status update
    return if statuses.count == 1 and statuses.first["source_api_request_type"] == 5
    
     @timeline = []
     statuses.each do |status|
       image = NSImage.alloc.initWithContentsOfURL(NSURL.URLWithString(status['user']['profile_image_url']))
       @timeline << {user: image,  tweet: status["text"]}
     end
     self.tableView.reloadData
  end
  
  def numberOfRowsInTableView(tableView)
    @timeline.size
  end
  
  def tableView(tableView, objectValueForTableColumn: column, row: row)
    return @timeline[row].valueForKey(column.identifier.to_sym)
  end
  
  private
  
  def hideCredentialsWindow(sender)
    NSApp.endSheet(credentialsWindow)
    credentialsWindow.orderOut(sender)
  end
end