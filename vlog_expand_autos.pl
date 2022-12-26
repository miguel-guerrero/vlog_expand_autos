#!/usr/bin/perl
# ------------------------------------------------------------------------------
# (c) Miguel Guerrero 2022-present
# See ./LICENSE for licensing terms
# ------------------------------------------------------------------------------

# command line option defaults
my $verbose = 1;
my $dstDir = ".";
my $inFileName = "-";
my $outFileName = "-";
# end of command line option defaults

my $debug = 0;

# --- get the path of the executable
my $execPath = &getPath($0);

&parseCmdLineArgs;
&processOne($inFileName, $outFileName);

exit(0);

#--------------------------------------------
# Process a single file
#--------------------------------------------
sub processOne {
   my ($fileIn, $fileOut) = @_;
   my $outIsTmp = $fileOut eq "-";
   if  ($outIsTmp) {
       $fileOut = "tmp_autoexpand_$$"
   }
   if ($fileIn ne $fileOut) {
       &sys("cp $fileIn $fileOut");
   }
   &sys("emacs --no-site-file --no-init-file --batch "  # --no-autoloads
       ."-l ${execPath}verilog-mode.el $fileOut -f verilog-auto -f save-buffer");

   # remove emacs back-up file
   &sys_rc("rm -f ${fileOut}~");

   # if sending to stdout, print and remove temporary file that was used for it
   if  ($outIsTmp) {
       &sys("cat $fileOut");
       &sys("rm -f $fileOut");
   }
}


#--------------------------------------------
# Syntax info
#--------------------------------------------
sub usage {

   my ($rc) = @_;

   print<<EOF

 Expand verilog mode autos in emacs in batch mode

 USAGE: $0 [options] fileName

     fileName : Input file. If - or not give, stdin is used

     -o f     : Output filename. If - or not given, stdout is used
     -d  dir  : Destination directory for resulting file (def $dstDir)
     -h       : Display this message
     -q       : Quiet mode

EOF
;
   exit($rc);
}


#--------------------------------------------
# Parses the commane line arguments
#--------------------------------------------
sub parseCmdLineArgs () {
   my $i = 0;
   while ($i <= $#ARGV) {
      my $opt = $ARGV[$i];
      my $flag= ($opt =~ s/^-no/-/) ? 0 : 1;

      if    ($opt eq "-q")   { $verbose = 0; }
      elsif ($opt eq "-d")   { $dstDir = $ARGV[++$i]; }
      elsif ($opt eq "-o")   { $outFileName = $ARGV[++$i]; }
      elsif ($opt eq "-h")   { &usage(0); }
      elsif ($opt =~ /^-/) {
         print STDERR "ERROR: Unknown option $ARGV[$i]\n";
         &usage(1);
      }
      else {
          $inFileName = $opt;
      }
      $i++;
   }
   if ($inFileName eq "-") {
       $inFileName = "/dev/stdin";
   }
}

#--------------------------------------------
# File name utility functions
#--------------------------------------------

sub getPath {
   my $path = shift;
   if ($path =~ /\//) {
      $path =~ s/^(.*\/)(.*)/\1/;
   }
   else {
      $path = "";
   }
   return $path
}

#--------------------------------------------
# General utility functions
#--------------------------------------------

# execute an external command, must succeed or will die with error
sub sys {
   my ($cmd) = @_;
   print "$cmd\n" if $debug;
   my $rc = system("$cmd");
   if ($rc) {
      die("ERROR: [" . pwd() . "] executing \"$cmd\"\n");
   }
}


# execute an external command, return the return code
sub sys_rc {
   my ($cmd) = @_;
   print "$cmd\n" if $debug;
   my $rc = system("$cmd");
   return $rc;
}

# execute an external command, return its stdout
sub backquote {
   my ($cmd) = @_;
   print "\`$cmd\`" if $debug;
   my $txt = `$cmd`;
   print " -> $txt\n" if $debug;
   return $txt;
}
