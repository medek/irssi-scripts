use strict;
use vars qw($VERSION %IRSSI);
use Irssi;
use Gtk2::TrayIcon;
use Gtk2 -init;
use MIME::Base64;
my $status = 0;
my $focused = 0;
my $iwin;
my $timer;

my $systray; 
my $noalert;
my $alert;
my $hilight;
my $image;
on_load();

$VERSION = "0.02";
%IRSSI = (
	authors 	=> 'Gavin Massey',
	contact 	=> 'mdk@mystacktrace.org',
	name 		=> 'systemtray.pl',
	description 	=> 'persistant alert icon in the system tray',
	license 	=> 'GNU General Public License',
	url 		=> 'https://github.com/medek/irssi-scripts',
);

sub sig_focus {
	$focused = @_[0];
	if($focused == 1)
	{
		$image->set_from_pixbuf($noalert);
		if(Irssi::settings_get_bool('systemtray_goto_status') == 1)
		{
			if($iwin != undef)
			{
				$iwin->set_active();
			}
		}
		return;	
	}
	else
	{
		$status = -1;
		if(Irssi::settings_get_bool('systemtray_goto_status') == 1)
		{
			$iwin = Irssi::active_win;
			Irssi::active_win->{active_server}->command("WINDOW goto (status)");	
		}
	}
}

sub window_processing {
	if(Irssi::settings_get_bool('systemtray_update') != 1 || $focused == 1)
	{
		return;
	}
	
	my $old_status = $status;
	$status = 0;
	foreach my $win (Irssi::windows())
	{
		if($win->{data_level} > 1 && $win->{data_level} > $status)
		{
			$status = $win->{data_level};
		}
	}

	if($old_status == $status)
	{
		return;
	}

	if($status == 2)
	{
		$image->set_from_pixbuf($alert);
	}

	if($status == 3)
	{
		$image->set_from_pixbuf($hilight);
	}

	if($status == 0)
	{
		$image->set_from_pixbuf($noalert);
	}
}

sub on_load {
	$systray = Gtk2::TrayIcon->new("irssi");
	build_icons();
	$image = Gtk2::Image->new_from_pixbuf($noalert);
	$systray->add($image);
	$systray->show_all;
	$timer = Irssi::timeout_add(200, 'window_processing', undef);
	Irssi::signal_add('focus change', 'sig_focus');
}

#this is probably wrong...
sub unload {
	Irssi::signal_remove('focus change', 'sig_focus');	
	Irssi::timeout_remove($timer);
	$systray->hide_all;
}


sub build_icons {
	my $loader = Gtk2::Gdk::PixbufLoader->new;
	$loader->write(decode_base64(
'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBI
WXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH3AkIFxECxTLLowAAAP9JREFUOMul0kErhFEUBuCHMcmg
yIJIKRY2ysbWUrGahbKaXyBZieIfyD+Yn6BkY6ssLKeUlaTsZEGixkafzVFf3O8zxtnce8/73vu+
59xTURwzsb6XcPSWYItY9o9YwkU3F/sxEvusWxfPWMctWpj+pdwfcR7qGR6xgN1OmrgW63wuN4gm
ZlMPVBK5FsZQxQuGMYVL1PBQ9LV9UeuX9Q+c5M5neA1OsoTrHNjGUSjv4wmrGMJkUeOaoZphA9sY
QAOb35wkHRzH+QZ30YM2TkP5MHj3RQ56QmEngVWxF/hK2f/XgzSRwN5w1ckQNeKR0VxuCwd/mcYa
5nKzMl5E/ARYmDKKHcFjQgAAAABJRU5ErkJggg=='));
	$loader->close;
	$noalert = $loader->get_pixbuf;

	$loader = Gtk2::Gdk::PixbufLoader->new;
	$loader->write(decode_base64(
'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBI
WXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH3AkIFxAq6ZxSGAAAAY5JREFUOMul0j1rVFEQBuDn3Lub
zZdxg0pEDSgiLoJoEbVTsVOxEGIREMFfYeFv8A9IOksFLURYG0WDIpEoKigisdMYQlT8SLJ7c6/N
iSxxN0ocOMycmTkz7ztnUp1lZ9SLa+RI1ogdxFH/IYfwYD0PK6hGu1gvis8YxTtMYfgvdP+Qe7F7
gVnsx6V/GeKpqGstvj6MY3e7Amkb3xQ2oYyv2IDteIRezHT62lLkugJ9GTdb7nfwLea0pfCqJbiA
K7HzZcwnycDJrp59/b0DJ2qru67IBB5G+yK24hhGh3aN1wcGz42FUFYo7oak+2mSJIffPAlFK4Ib
EdFbTMcZLAzX6s/6N54Za2ZfNLM5zeacrPFhJM+z06sR1KMex2Q8uvuP71j88VL4zbaQIy1vOY/b
rQUKnI2DuxanrVTumlnOvsvzJSEEFEUISagU+US7PbiFC/iIQXj9ODxP03Qyz+Zljdkia3wKlZ69
P5NSz1UIHTaxF9viKqfYvGdk6UBj8f2RUqk63Vcduv7ifmjAL6jscWkCj6rNAAAAAElFTkSuQmCC'
));
	$loader->close;
	$alert = $loader->get_pixbuf;

	$loader = Gtk2::Gdk::PixbufLoader->new;
	$loader->write(decode_base64(
'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBI
WXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH3AkJABYU33I6pQAAAXRJREFUOMulkjtLA1EQhb91zduI
TwKJAaPFLkHRRtJZG7ERBRvzG2wEQTsLG/UfpBNtLOzENAmIWChEEBuD2BqU+CD4SGIci9zAolmV
OM25d+bO45w7OvbWr/Dthze0/BAbBcb5h40Bh80kuoAOdZZmp3gAZoErIAuEf6H7zTKquwC3wDCw
9BcRJxWaFp8PSAKDjQroDXxZoBtwAE+AHwgBx4AXyNt9baviWh+9CuxZ7vtAUb1pSOHCEnwFNlXn
FeBe09rjo9BmuqOmnXBJ1VWAOWAB8ACJdbe5I4GASDgsEgpJzoifmjHRvhaYUMmXaokWAVa7ZobE
7xfRdRGHo4Yul2xHV6a+UkhZJjkFNgAivUbfXbFIoVqlUKnUsFRioJybrwuHZeumlXBbSm3ePe35
RyV7S42jOEDLa4EjOy0Sqlhn3ZF2Rk7SICn4OAB5cfqfjZg4ATSbIl4gqFZZB3q2jOUR381ZrNwW
vF4zkrvnGa0M8AnN13JSuXsiGwAAAABJRU5ErkJggg=='));
	$loader->close;
	$hilight = $loader->get_pixbuf;
}

Irssi::settings_add_bool('systemtray', 'systemtray_goto_status', 1);
Irssi::settings_add_bool('systemtray', 'systemtray_update', 1);
Irssi::signal_add_first('command script unload', 'unload');
