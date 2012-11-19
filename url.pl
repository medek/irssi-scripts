use strict;
use vars qw($VERSION %IRSSI);
use Irssi;
require URI::Find;

$VERSION = "0.01";
%IRSSI = (
	authors 	=> 'Gavin Massey',
	contact 	=> 'mdk@mystacktrace.org',
	name 		=> 'url.pl',
	description 	=> 'id urls for easy opening in browser',
	license 	=> 'GNU General Public License',
	url 		=> 'https://github.com/medek/irssi-scripts',
);

my @urls;
my $curr_id = 0;
my $finder;
sub uri_callback
{
	my ($uri, $orig_uri) = @_;
	my $temp_id = $curr_id;
	$urls[$curr_id] = $uri;
	$curr_id++;
	
	if($curr_id == Irssi::settings_get_int('url_max_id'))
	{
		$curr_id = 0;
	}
	return "$orig_uri [$temp_id]"
}


sub url_command
{
	my ($data, $server, $witem) = @_;
	my @args = split(/ /, $data);
	my $browser = Irssi::settings_get_str('url_browser');
	my $url = $urls[int $args[0]];
	if($url eq '')
	{
		return;
	}
	Irssi::command("exec - $browser \"$url\" > /dev/null 2> /dev/null");
}

sub privmsg_sig
{
	my ($server, $data, $nick, $address) = @_;
	my ($target, $text) = split(/ :/, $data, 2);

	if($finder->find(\$text) == 0)
	{
		return;
	}

	$data = "$target :$text";

	Irssi::signal_continue($server, $data, $nick, $address);
}

$finder = URI::Find->new(\&uri_callback);
Irssi::command_bind('url', 'url_command');
Irssi::settings_add_str('url', 'url_browser', 'x-www-browser');
Irssi::settings_add_int('url', 'url_max_id', 40);
Irssi::signal_add_first('event privmsg', 'privmsg_sig');

