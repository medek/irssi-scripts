use strict;
use vars qw($VERSION %IRSSI);
use Irssi;

$VERSION = "0.01";
%IRSSI = (
	authors 	=> 'Gavin Massey',
	contact 	=> 'mdk@mystacktrace.org',
	name 		=> 'focus.pl',
	description 	=> 'gives irssi some notion of window focus',
	license 	=> 'GNU General Public License',
	url 		=> 'https://github.com/medek/irssi-scripts',
);

my $focus = 0;
my $win_id;
my $signal_config_hash = { "focus change" => [ qw(int) ] };
my $timer;
sub get_focused_id {
	open(DIR, "xdpyinfo | grep focus|");
	my $out = "";
	while(<DIR>)
	{
		$out = $out . $_;
	}
	close(DIR);
	$out =~ m/focus:.*?(0x[0-9a-f]*)/;
	return $1;
}

sub focus_processing {
	my $old_focus = $focus;
	$focus = 0;
	if(get_focused_id() eq $win_id)
	{
		$focus = 1;
	}

	if($focus == $old_focus)
	{
		return;
	}
	Irssi::signal_emit("focus change", $focus);
}

#This is here because we have to wait a little
sub deferred_setup {
	Irssi::signal_remove('window created', 'deferred_setup');
	$win_id = get_focused_id();
	$timer = Irssi::timeout_add(200, 'focus_processing', undef);
}

sub UNLOAD {
	Irssi::timeout_remove($timer);
}

sub get_new_id {
	$win_id = get_focused_id();
}
Irssi::signal_register($signal_config_hash);
Irssi::signal_add('window created', 'deferred_setup');
Irssi::command_bind('focus_get_new_id', 'get_new_id');
