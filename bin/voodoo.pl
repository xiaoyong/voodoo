#!/usr/bin/perl
# Last updated at Fri Oct 22 15:07:17 CST 2010
# xiaoyong (solary.sh@gmail.com)
use strict;
use CGI;

my $parameter = "/usr/bin/time -f %e locate -l 1000 -d ";
my $query = CGI->new;

# Determine databases to search
my @candidate = qw(student share extprog intprog ports);
my @database;

for (@candidate) {
	push(@database, $_) if defined $query->param($_);
}

if (@database == 0) {
	catch_error("You must specify at least one search field!");
}else {
	for (@database) {
		$parameter .= "/home/xiaoyong/data/locate/picb_$_.db:";
	}
}

$parameter =~ s/:$//;

# Determine whether case sensitive
if ($query->param("case") ne "on") {
	$parameter .= " -i";
}

# Determine whether use regexp
if ($query->param("regexp") eq "on") {
	$parameter .= " --regex";
}

# Add query keyword
if ($query->param("keyword") =~ /^\s*$/) {
	catch_error("Keyword Empty!");
} else {
    (my $keyword = $query->param("keyword")) =~ s/(^\s+)|(\s+$)//g;
    if ($query->param("regexp") ne "on") {
        if ($keyword !~ /\*/) {
            $keyword =~ s/\s+/*/g;
            $keyword = "*$keyword*";
        }
    }
	$parameter .= " " . $keyword;
}

open LOG, ">>", "/home/xiaoyong/data/log/voodoo.log" or die "Can't write to voodoo.log: $!";
chomp(my $log = `date -u '+%Y-%m-%d %H:%M'`);
$log .= "\t" . $query->param("keyword") . "\n";
print LOG $log;
close LOG;
(my $count = `wc -l /home/xiaoyong/data/log/voodoo.log`) =~ s/^(\d+).*/$1/;
$count =~ s/\s//g;
$count .= ($count =~ /11$/) ? "th" :
	($count =~ /12$/) ? "th" : 
	($count =~ /13$/) ? "th" : 
	($count % 10) == 1 ? "st" : 
	($count % 10) == 2 ? "nd" :
	($count % 10) == 3 ? "rd" : "th";

# Output update info of the database 
(my $date = `stat -c %y /home/xiaoyong/data/locate/picb_share.db`) =~ s/(\S+).*/$1/;
chomp $date;
print $query->header(-type=>'text/html',
	-charset=>'UTF-8'),
	$query->start_html(-title=>'Voodoo Search Results',
		-head=>'<link rel="stylesheet" type="text/css" href="/css/voodoo.css" />',
	),
	"<p style=\"text-align:center; font-size:10pt;\">Voodoo's <span style=\"color:red; font-family:monospace\">$count</span> Search<br />";

# Execute command
my @tmp = `$parameter 2>&1`;
chomp (my $time = pop @tmp);
my @output;

# Get rid of unwanted items
my $i = 1;
for (@tmp) {
	chomp;
	next if /(~$)|(\/\.)|(\.app\/)|(^Command exited with non-zero status 1$)|(\/src\/)|(\/include\/)|(\/build\/)/;
	push @output, "<span style=\"font-size:10pt; font-family:monospace; color: gray;\">" . "&nbsp;" x (length(scalar @tmp) - length($i)) . "$i. </span><a href=\"file://$_\">$_</a><br />\n";
	$i++;
}

# Output NO. of items found and time usage info
print "Hit <span style=\"color:red;font-family:monospace;\">", scalar @output, "</span> entries within <span style=\"color:red; font-family:monospace;\">$time</span> seconds<br />Database last updated on <span style=\"color:red; font-family:monospace\">$date</span>\n</p><p class=\"result\">";

# Output final results
if (@output == 0) {
	print "<span style=\"color:red\">Oops! No result found!</span>";
} else {
	print @output; 
}
print "</p>\n";
print $query->end_html;

# Catch errors 
sub catch_error {
	my $words = shift;
	print $query->header(-type=>'text/html',
		-charset=>'UTF-8'),
		$query->start_html(-title=>'Error Report');
	print "<script type=\"text/javascript\">
		alert(\"$words\");
		//history.go(-1);
		window.location = 'http://voodoo.xiaoyong.org/';
		</script>";
	print $query->end_html;
	exit;
}
