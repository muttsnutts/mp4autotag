class Tag
  def Tag::create_tag
    rtn = {
      	"Name" => {"optstr" => "-s", "value" => ""},
      	"Artist" => {"optstr" => "-a", "value" => ""},
      	"Composer" => {"optstr" => "-w", "value" => ""},
      	"Encoded with" => {"optstr" => "-E", "value" => ""},
      	"Encoded by" => {"optstr" => "-e", "value" => ""},
      	"Release Date" => {"optstr" => "-y", "value" => ""},
      	"Album" => {"optstr" => "-A", "value" => ""},
      	"Track" => {"optstr" => "-t", "value" => "1"},
      	"Tracks" => {"optstr" => "-T", "value" => "1"},
      	"Disk" => {"optstr" => "-d", "value" => "1"},
      	"Disks" => {"optstr" => "-D", "value" => "1"},
      	"Genre" => {"optstr" => "-g", "value" => ""},
      	"Grouping" => {"optstr" => "-G", "value" => ""},
      	"BPM" => {"optstr" => "-b", "value" => "0"},
      	"Comments" => {"optstr" => "-c", "value" => ""},
      	"Album Artist" => {"optstr" => "-R", "value" => ""},
      	"Copyright" => {"optstr" => "-C", "value" => ""},
      	"HD Video" => {"optstr" => "-H", "value" => 1},
      	"Media Type" => {"optstr" => "-i", "value" => ""},
      	"TV Show" => {"optstr" => "-S", "value" => ""},
      	"TV Network" => {"optstr" => "-N", "value" => ""},
      	"TV Episode Number" => {"optstr" => "-o", "value" => ""},
      	"Short Description" => {"optstr" => "-m", "value" => ""},
      	"Long Description" => {"optstr" => "-l", "value" => ""},
      	"TV Episode" => {"optstr" => "-M", "value" => ""},
      	"TV Season" => {"optstr" => "-n", "value" => ""},
      	"cnID" => {"optstr" => "-I", "value" => "0"},
      	"Lyrics" => {"optstr" => "-L", "value" => ""},
      }
    return rtn
  end
end