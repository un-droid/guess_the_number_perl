use strict;
use warnings;
use diagnostics;
use feature 'say';
use DateTime;
  
my $dt   = DateTime->now;   # Stores current date and time as datetime object
my $date = $dt->ymd;   # Retrieves date as a string in 'yyyy-mm-dd' format
my $time = $dt->hms;   # Retrieves time as a string in 'hh:mm:ss' format
my $currentTime = "$date $time";   # creates 'yyyy-mm-dd hh:mm:ss' string
my $secret;
my $triesLeft;
my $maxnum;
my $minNum;
my $tries;
my $logFile;
my $guess;
my $try;

#logger function
sub updateLog{
	#my $logFile = 'log.txt';
	open(my $fh, '>>',  $logFile) or die "Could not open file '$logFile'";
	say $fh $currentTime . ' '. $_[0]; #write to the log
	close $fh; #close the file after done writing log
}

#as the name suggests, lets load some configuration to the app
sub loadConfig{
	say "Loading config, please wait...";
	#read config file
	my $config=do("./config.pl");
	die "Error parsing config file: $@" if $@;
	die "Error reading config file: $!" unless defined $config;

	#set the configuration data to local variables
	$maxnum = $config->{maxNum};
	$tries = $config->{tries};
	$logFile = $config->{logPath};
	$minNum = $config->{minNum};
	updateLog("Read config file successfuly!");
	guessTheNumber();
}

#game logic
sub guessTheNumber {
  
  updateLog("Game started");
  #$secret = int rand $maxnum;
  $secret = $minNum + int(rand($maxnum - $minNum));
  updateLog("Secret number generated". ': '. $secret);
  
  GUESS:  # start of the loop here
  for $try (1 .. $tries) {
    say "Guess a number between $minNum and $maxnum:";

    chomp($guess = <STDIN> );
	$guess =~ s/^\s+|\s+$//g; #trim whitespaces
	if (not $guess =~ /^[0-9]+$/) { #make sure the guess is indeed a natural number
	  say qq(Your guess "$guess" was not a number.); 
	  updateLog("User entered an INVALID input". ': '. $guess);
	  redo GUESS; #redo the iteration without incrementing the tries counter
	}
	
	updateLog("User entered a valid input". ': '. $guess);
    if ($guess == $secret) {
      say "CORRECT! you guessed $secret successfuly! You were able to guess in $try tries.";
	  updateLog("User guessed the secret with the correct number of ". ': '. $guess);
      return 1; # exit the function 
    } elsif ($guess < $secret) {
      say "Your guess was too low.";
	  updateLog("Guess was too low ". ': '. $guess);
    } elsif ($guess > $secret) {
      say "Your guess was too high.";
	  updateLog("Guess was too high ". ': '. $guess);
    }
    $triesLeft = $tries - $try;
    say "You have ", $triesLeft, " tries left."; # each round the tries number is 'recalculated'
	updateLog("User has ". $triesLeft . ' tries left');
  }

  say "You failed to guess the correct number $secret in $tries guesses."; #only runs when user is not able to guess
  updateLog("User failed to guess the secret number ($secret) :(");
  return 0;
}

loadConfig();