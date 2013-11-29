##
## Put me in ~/.irssi/scripts, and then execute the following in irssi:
##
##       /load perl
##       /script load notify
##

use strict;
use Irssi;
use vars qw($VERSION %IRSSI);
use HTML::Entities;
$VERSION = "0.01";
%IRSSI = (
    authors     => 'Luke Macken, Paul W. Frields, Gavin Massey',
    contact     => 'lewk@csh.rit.edu, stickster@gmail.com, mdk@mystacktrace.org',
    name        => 'notify.pl',
    description => 'Use libnotify to alert user to hilighted messages',
    license     => 'GNU General Public License',
    url         => 'http://lewk.org/log/code/irssi-notify',
);
my $focus = 0;

#Irssi::settings_add_str('notify', 'notify_icon', 'gtk-dialog-info');
Irssi::settings_add_str('notify', 'notify_time', '5000');
Irssi::settings_add_bool('notify', 'notify_enabled', 1);

sub sanitize {
  my ($text) = @_;
  encode_entities($text);
  return $text;
}

sub sig_focus {
	$focus = @_[0];
}

sub notify {
    my ($server, $summary, $message, $override) = @_;

    return if(Irssi::settings_get_bool('notify_enabled') != 1
		|| ($focus != 0 && $override == 0));
    # Make the message entity-safe
    $summary = sanitize(Irssi::strip_codes($summary));
    $message = sanitize(Irssi::strip_codes($message));

    my $cmd = "EXEC - notify-send" .
#	" -i " . Irssi::settings_get_str('notify_icon') .
	" -t " . Irssi::settings_get_str('notify_time') .
	" -- '" . $summary . "'" .
	" '" . $message . "'";

    $server->command($cmd);
}
 
sub print_text_notify {
    my ($dest, $text, $stripped) = @_;
    my $server = $dest->{server};

    return if (!$server || !($dest->{level} & MSGLEVEL_HILIGHT));
    my $sender = $stripped;
    $sender =~ s/^\<.([^\>]+)\>.+/\1/ ;
    $stripped =~ s/^\<.[^\>]+\>.// ;
    my $summary = $dest->{target} . ": " . $sender;
    notify($server, $summary, $stripped, 0);
}

sub message_private_notify {
    my ($server, $msg, $nick, $address) = @_;

    return if (!$server);
    notify($server, "Private message from ".$nick, $msg, 0);
}

sub dcc_request_notify {
    my ($dcc, $sendaddr) = @_;
    my $server = $dcc->{server};

    return if (!$dcc);
    notify($server, "DCC ".$dcc->{type}." request", $dcc->{nick}, 1);
}

#this is because actions in a pm don't get notified
sub message_irc_action {
    my ($server, $msg, $nick, $address, $target) = @_;
    return if(!$server);
    if(!$server->ischannel($target)) {
        notify($server, "PM action", $nick . " " . $msg, 0);
    }
}

sub user_joined {
	my($server, $nick, $user, $host, $realname, $awaymsg) = @_;
	notify($server, "$nick has joined", "$nick!$user\@$host", 1);
}

sub user_left {
	my($server, $nick, $user, $host, $realname, $awaymsg) = @_;
	notify($server, "$nick has left", "$nick!$user\@$host", 1);
}

sub user_away_change {
	my($server, $nick, $user, $host, $realname, $awaymsg) = @_;
	my $summery = length($awaymsg) > 0 ? "$nick is away" : "$nick is back";
	notify($server, $summery, $awaymsg, 1);
}

Irssi::signal_add_first('focus change', 'sig_focus');
Irssi::signal_add('print text', 'print_text_notify');
Irssi::signal_add('message private', 'message_private_notify');
Irssi::signal_add('message irc action', 'message_irc_action');
Irssi::signal_add('dcc request', 'dcc_request_notify');
Irssi::signal_add('notifylist joined', 'user_joined');
Irssi::signal_add('notifylist left', 'user_left');
Irssi::signal_add('notifylist away changed', 'user_away_change');

