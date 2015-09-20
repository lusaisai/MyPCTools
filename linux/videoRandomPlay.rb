#! /usr/bin/ruby

class VideoRandomPlay
  @@TRY_TIMES = 15

  def initialize( player, videoDir )
    @player = player
    @videoDir = videoDir
    @files = Dir.glob( File.expand_path(videoDir) + "/**/*" )
    raise "Empty Directory #{videoDir} ..." if @files.count == 0
  end
  
  def choose
    @@TRY_TIMES.times do
      @videoFile =  @files.sample
      return self if @videoFile.end_with?( 'avi', 'mp4', 'rm', 'rmvb', 'wmv', 'iso', 'mkv', 'mpg', 'mpeg', 'vob', 'mov' )
    end
    raise "No video files found in #{@@TRY_TIMES} times ..."
  end
  
  def play
    puts "Playing file #{@videoFile} ..."
    system( "#{@player} '#{@videoFile}' > /dev/null 2>&1 &" )
  end
    
end

abort "#{__FILE__} <Video Directory>" if ARGV.length != 1

player = "smplayer"
videoDir = ARGV[0]

vrp = VideoRandomPlay.new( player, videoDir )
vrp.choose.play
