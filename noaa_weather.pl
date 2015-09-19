#!/usr/bin/perl -w
use strict;
use LWP::Simple;


# Nick Agro 9/18/2015
# Perl script to obtain current weather conditions from NOAA's website
# uses regex pattern matching and substitution to parse data from html file


print "\n\nCurrent weather conditions from NOAA for Mount Sinai, NY:\n";

my $htmlpage = get('http://cell.weather.gov/port_mp_ns.php?select=3&CityName=Mount%20Sinai&site=OKX&State=NY&warnzone=NYZ078') or die "Couldn't fetch NOAA weather conditions";

 open (MYFILE, '> noaa_conditions.html'); # > is write, >> is append
 print MYFILE $htmlpage;
 close (MYFILE); 


my $conditions;
$conditions = ' ';
my %w=();

$w{IsRaining} = "0";
$w{IsSnowing} = "0";
$w{IsFoggy} = "0";
$w{BaromDelta} = " ";
$w{Clouds} = ' ';


$w{WindAvgDir} = ' ';
$w{WindAvgSpeed} = ' ';
$w{WindGustSpeed}= ' ';

$w{DewOutdoor}= ' ';

open (MYFILE, "noaa_conditions.html");
 while (<MYFILE>) {

	if ( (not ($_ =~ /html>/)) and (not ($_ =~ /<div align="center">/)) and (not ($_ =~ /div>/)) and (not ($_ =~ /form>/)) and (not ($_ =~ /meta/)) and (not ($_ =~ /body>/)) and (not ($_ =~ /Current Local Conditions at:/)) and (not ($_ =~ /Mac Arthur Airport/)) and (not ($_ =~ /Lat:/)) and (not ($_ =~ /National Weather Service/)) and (not ($_ =~ /Mount Sinai/)) and (not ($_ =~ /Area Forecast Discussion/)) ){ #and (not ($_ =~ /<hr>/))  ) {
		$conditions = "$conditions $_";
		} 

 }
 close (MYFILE); 

$conditions =~ s/mi.<hr>/mi.<br>/;
$conditions =~ s/Service<hr>/Service<br>/;

#print "NOAA conditions were processed";
#print "conditions processed= $conditions";

 $w{BaromSea} = $1 if $conditions =~ /Barometer:\s([\d\.]+) in./;
 #print "w{BaromSea} $w{BaromSea}\n";

 $w{BaromDelta} = $1 if $conditions =~ /(rising|falling|steady)/;
 #print "w{BaromDelta}= $w{BaromDelta}\n";


if ($conditions =~ m/Weather:\s*(.*?)<br>/i) {
	#print "conditions match";
	$w{Conditions} = lc($1); # lc converts to lowercase
	}

	$w{IsRaining} = ($conditions =~ /rain|drizzle|thunder|downpour/i);
	$w{IsRaining} = '0' if $w{IsRaining} ne '1';
	$w{IsSnowing} = ($conditions =~ /snow/i);
	$w{IsSnowing} = '0' if $w{IsSnowing} ne '1';
	$w{IsFoggy} = ($conditions =~ /fog/i);
	$w{IsFoggy} = '0' if $w{IsFoggy} ne '1';
	
#print "$conditions";
#print "w{IsRaining}= $w{IsRaining}\n";
#print "w{IsSnowing}= $w{IsSnowing}\n";
#print "w{IsFoggy}= $w{IsFoggy}\n";

#print "$w{IsFoggy}, $w{IsRaining}";

if ($conditions =~ / weather:\s*(clear|cloudy|partly cloudy|mostly cloudy|sunny|mostly sunny|partly sunny|drizzle|light drizzle|overcast|a few clouds)/i) {
	$w{Clouds} = lc($1);
	}

#print "w{Clouds}= $w{Clouds}\n";


		if ($conditions =~ /calm/i) {
			$w{WindAvgSpeed} = 0;
			$w{WindAvgDir} = undef;
		} else {
			if ($conditions =~ m/Wind Speed:\s*(\w*)\s(\d*)\s/ ) { #space, dir, space, speed, space, MPH, G speed
				$w{WindAvgDir} = $1;
				$w{WindAvgSpeed} = $2;
			}
			if ($conditions =~ m/Wind Speed:\s*(\w*)\s(\d*)\sG\s(\d*)/ ) { #space, dir, space, speed, space, MPH, G speed
				$w{WindGustSpeed}= $3;
				
			}
		}
		#print "w{WindAvgDir} $w{WindAvgDir}\n";
		#print "w{WindAvgSpeed} $w{WindAvgSpeed}\n";
		#print "w{WindGustSpeed} $w{WindGustSpeed}\n";


	$w{TempOutdoor}  = $1 if $conditions =~ /Temperature:\s(\d+)&/i;
	#print "w{TempOutdoor} $w{TempOutdoor}";

	$w{HumidOutdoor}  = $1 if $conditions =~ /Humidity:\s(\d+)\s%/i;
	#print "w{HumidOutdoor} $w{HumidOutdoor}";

	$w{DewOutdoor}  = $1 if $conditions =~ /Dewpoint:\s(\d+)&/i;
	#print "w{DewOutdoor} $w{DewOutdoor}";


#$noaa_conditions = $conditions;
print "temperature = $w{TempOutdoor}\n";
print "wind average speed = $w{WindAvgSpeed}\n";
print "wind average direction = $w{WindAvgDir}\n";
print "wind gust speed = $w{WindGustSpeed}\n";
print "humidity = $w{HumidOutdoor}\n";
print "dewpoint = $w{DewOutdoor}\n";
print "barometer =$w{BaromSea}\n";

print "is raining = $w{IsRaining}\n";
print "is snowing = $w{IsSnowing}\n";
print "is foggy = $w{IsFoggy}\n";
print "clouds = $w{Clouds}\n";

#print %w


