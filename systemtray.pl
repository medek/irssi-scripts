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
		$systray->set_from_pixbuf($noalert);
		$systray->set_blinking(0);
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
		$systray->set_from_pixbuf($alert);
		$systray->set_blinking(1);
	}

	if($status == 3)
	{
		$systray->set_from_pixbuf($hilight);
		$systray->set_blinking(1);
	}

	if($status == 0)
	{
		$systray->set_from_pixbuf($noalert);
		$systray->set_blinking(0);
	}
}

sub on_load {
	build_icons();
	$systray = Gtk2::StatusIcon->new_from_pixbuf($noalert);
	$systray->set_tooltip('Irssi');
	$timer = Irssi::timeout_add(200, 'window_processing', undef);
	Irssi::signal_add('focus change', 'sig_focus');
}

sub UNLOAD {
	Irssi::signal_remove('focus change', 'sig_focus');	
	Irssi::timeout_remove($timer);
	$systray->set_visible(0);
	$systray->destroy();
	$noalert->destroy();
	$alert->destroy();
	$hilight->destroy();
}


sub build_icons {
	my $loader = Gtk2::Gdk::PixbufLoader->new;
	$loader->write(decode_base64(
'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'));
	$loader->close;
	$noalert = $loader->get_pixbuf;

	$loader = Gtk2::Gdk::PixbufLoader->new;
	$loader->write(decode_base64(
'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
QmCC'));
	$loader->close;
	$alert = $loader->get_pixbuf;

	$loader = Gtk2::Gdk::PixbufLoader->new;
	$loader->write(decode_base64(
'iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBI
WXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH3AkKFzYv8CHtOAAAEtdJREFUeNrtnXmUHMV9xz/de2m1
uzpWxy7a1WqRtB4JsVIMQpzmkpBtDiMuyyZYdmJC7OQtOWzHfjkgDsYvMcQXzzbg2BFI5rIs8zAR
AYyBYIgRlyIOsZHCJSyE0Lnac7anK39U90xvb/Uxs9OzMzv9e6/f9HRXd1fX71u/q35VDeVFpxLT
CNLL7H2villevjQZ2BE3Q/lSOyCAtrgpylMFLLN+L4jZXp4AWG79ro7ZXp4AOMn6XQBUxawvPzpk
2QC9wLS4OcqLGgADMK3tlLhJyksFdAAVgGZtn4hZX150uSX+7e1o3CTlJQHmu/7XA38Qs798AOC0
+oX1+4WY/eUDgGHHvmaBYC0wJQZA+QHABsE04IsxAMoTALYq+GwMgPKgfsUxDVgEXBJbAhOfznG5
gc5tB1AZN9HEphYgpWC+HRk8LW6iiU+DPlJgJ+WXHVV29IYPAARxnsCEp0c8GG9av7stw7CsqKKM
3rUTON3DGwAZFBoAno77ysSkywJUgAkcBprjppqYtCAAAPa2OW6qiUmTgTdDSAEDGSCKaQLSAyGl
wCtATTk0SCn4vlVAY57u9ViIMgJYAlwZ95fioBpgG/AEsG6MRtrSkBLAjhBOjZu/OGiJgznDwHpy
y+xtdPn+QduP4qYvHjoNSDqY0w/cahl32dDhLKSAIDOfIKYioC6XiBbA28BFWdzjxyEBYG9xYKjI
aJMHozYBM0Ncf14WzDctqbMg4J4NMVsKR3MVYtyWBgeAlfjH9Nss9ZGNFFgfUKdTiZNMC0pf89HZ
AvgPYIbHtRrwTpYASAa4oius558Vs6Yw1BLCePsA+KTH9b/OEgAC+IpPfT5MZt7hspg9haEnQjLu
p0Cd69pbcwDA2z6qpdNR7l3kxJOYIqavhvDn7fN7GZn2tTYHABjAQo+6LHaVfYY4zzByWp1FQMd2
GzcgI4vHZcl8+zmf9qhLh6LsbTGLoqXjswCAc+uz1ILIYfuJR12O9ZAYJ8Rsio5aXQEhkWOvzqb8
Lo+6tHtc8yJFvhpJKWfCDiNTvXPN49NyKO+1wpiKycLyDk6JARBd3SvIzPYtBHn15koPwAgfVzQG
wBipNseePFaarTjmlzwSAyAimj5Oz52rOLbIR23MwDsqGQNgDNQ+Ts9VhYRX+pSvAJpiAOSf5o/T
c+sUx84LuCYGQAS0iPGZyeMGwBKC1x+eHQMg/zReizy54/wXhwBiDAAPXboFSOR4fec41Xu2y8i7
NsQ1IgbAaDqIHDp9Hbg+y2tnWD75eDTsYsf+hpD6fZCYlLSZTNh0I+EnY5xIbuHffGzbkBNJ7yR8
SHldzGo1XexqqKcIt3TbleMIgFy2T8UqQE2PIvP47IY6A3gNmBVwXamNsg2FLFdZbgDoBx4ns4gz
yHSvFwNcqw+XGACSIcvNKTS4i8EN3KSwmFuRS7os86hzRzFb1mMAQBPw+XIDwDOu/7YkqAB+p+jt
7cj8/1JazsUMWW4tZbpWkWoFL9u6HnI1yuoSMwAFcHbIzthrlZ9RThIA1NO27R5eDfwCuML6vyJP
zxQFDNKkQpRZRibM3FRuAAhalqUGuAe4Gjg5T8/UrNiDVgAQhAHAlx37jZQZrSB8jl6S3PMA3dvH
gOcLoAKCQJsgXPbxhJUAe7IwlKryaAA2MTJDeLyMwK+71F5HuQFgvGLlZyHj+X0RexVGgO6/2HXs
Q+UGgGQBDTKnEXgS8gNSPx/Hd18PTHIdm0+ZUR3ZT9nOxzaIHN+vZWRIOt/buR7vfS3qAaVdFGgV
12KRAAK5TGuhqQb5wYgB4NsRPkdl1S8BbnbpfpumUKAFqoopI2i86nKpxYAbgZcjUkNtCr2/He+c
hhrKZJ1Cm2ZZhtJ4ROkOOnTw6RE9434roNVueR1HAsr3A/PKCQAJ1F/0GOsWZvq4gRyBtOlH5DZ3
0O8ZKUvNhL1mGO+p6EUtdnO9X2NEbphmWfn7fc5XkAkzA/yN1QO1PNZBV1j6flRJgXID8g2AXyGX
YZuV5XVRju4dAn4TUObPHftHgT9j/IebS/LjFbvJhGt/hnoShYr+JUIdvxE5hhCkc91L0D7N+I0e
GoVSAfmmlxj9GZa1Ia57JcLG/JwFxOGAcu4VQdvzbAtksw0hF50oOfqJxws9gEx3UlFFxI1p96R7
Asr9qaJu3xgnCdCHehKqTXmLEeTbBnjeI8hzkdXLz1acjxLpSUunA/y7oz4qOl5x7DaCxymiyCsY
wjuRdCn+k1HHlU4JITa/4wLex8foYu1k5CLS7p7knEa+0ec+WzzeKYwt8CDQk0cJ8KYVN1AFlIYo
4qTYmfivxm0Do9vhe//tGBvrGuQycKpzhxm5mvgsn3jD6x7v9E2Cl5Rf4Hy/lXq9eHhSQgyCEHV1
QrS0CJFIZLaWFiHq6sQgiEcnLRIf1evdbfSSoh7TgLcsg7VoVcB+4NkA10YghztfBdYgl2zLlUzg
Py1jU0UpRmbkfgCciXrcwWuh6Q88xL4AXkB+gn7JykmLeB40kUjwaEcLq+dBTSIBra1Q75pPWl8P
ra3UJBKsmid4qKMFkUiwDVg1abGGXGzSTZus6OA+8jhuEkX8/Z8D9KENginAL8nM8smFeizm7/K4
xxFGJ2M8jfyY9H6X7u73eMb7Hu9gAn98d+d1l6SOnf/LR+bBiYlETg68XX5ZIsHD8wSpBQvPv7vz
usscRX7m0PvvET7NfFwA8CL+CRD2O2uK/VyeZX/7V3WPox7XPYsckNnmOPauR9lhldE3p7LpPpFI
/M/a5L2b9eoqXbdxZJqZX8OQv6rNMEafB3QEemWFvjZ57yaRSIhFVcfc4OokjxdzJNBu9NcLZHNs
sH4fyyGatgc5ydSe3n2XR7la94H7qRh+Z0HjJwWI9AP8GOs8bp9TgcQw3GJS7Gib/PdbZGqA/aj7
SiHc+NfAv0bMfIHMnfs/ZB79O4z+fMxryHUEgnLyOiwJoNKt15BZ9lW8gaa1Jz40suGSyQxTR1go
Jugh+piznGlCZSVUV4940T3d3bRKm6ZWIZWKSgKATLHqjxgAvcihXJDZPFs9DLswIN/pY1hZoKpE
VFVJ5tvMNgzo7c0AwK/nq/577SeT8r6WRNBMkzmJBEZdA19t+1ZeM4WiAsBu5PLqUdKwK1iiUgOT
yG4UTkVNAKKhFjF/vmS+rksm9fePZKxK1LuPOcv5nTdNCYLBQdB1NNOkYk5zxdcmb9p9y9Jb9GIH
AMi5/lGKf8MlCu9RRORqGPva/XO3ATQ3Z5jf25vpoX6MDMNwlxE46lxvrwSaroOuM1UcmXGm8eTD
pQCA70Z4b81ivhMAuyx7QHMBYEyzbH5VMWXlUsu9Q9ehp0f2yiCL3svy9zpm38NpUNpbf798rlQH
Wmfq5VVPL/ncHcUOgB2WNxDVuLrKxfsSoyd5nJ3rA25benPLhQuPadZs5vf3Z5jvpcf9JIHf5nWd
0ybo7ZXqADjN+O91t3fe1FbMAAC4I0JPQ2W0/doyCJ3P/ESuD7hy6K5dadGcTMLhw6MZo+rJQVJA
BR4/KWHT4cPymZaLeFVy45uJFUIrZgBsjvDeKleoD7l4k5NyGjhZ33njqXX0TUqL5L17w/XaIAng
Bwrn9cmk3Nzn9u4F00QzTW0Sg/rfDXzjzGKMAzjpSeAjETzrKWRcX0UHkKOAmgWKVuTAUHgrM5HI
qJH9+6X4zQe5fX5nnMDu7c7z6a6qZ/5PmQIzM0MXWne3VqwSAGS+fRRTsP2CId9zAG4yWX5o+gdL
v5v5wJRhjBb9bos+G70fFBvwsyvs8wcPjoga3t5507nFDICtyEGbsCgVAf/T8Tefe3wbOWhiS7m6
bCp8ovHCX47o/X5Wu2kihod99b5IpTyPi+HhUedFKpU5Bun/6U0I2Lcvo+NSL3UVMwAOk93kSw24
wVIdToNOKPS9X5TwRsf/6mwqfHJq6xVpcdvTQ0oI382ErM4Lx3F7G3aVdx5zlrO3tEoyTZanXlhT
zADAYmgqCzVwp+W+NQN/obDsIXjA6adkxvJDh6U3dP7T6rTOHRxkSAgMK+pkKBhhOH4N13HVZn+N
2nBd63cv1bkhITIBIuCuzusvLGYAvI0cbAmrBv7E1sDA95EJpecxMlPm9hBu4oUWeN4NW9Epomel
sIG6b196FMn0YC4+zDJ9AOP331A8x1QAjL170y7hVHFkdTEDIAzDnLSWkR9oSlo+/gnI5WTOQ47+
hbE/zg1QFyNotrlvrgYapsnAwEC6x3oxLOkBDDNEL/a6zgy4p73fZ9keGmizzA9aih0At5IZvQsy
AucBf+Vx/jkLDGFpezaVnCn2p7//Y3r0Rj+muKVCUC/2AlRSAQbVMUe9O4odAAeRU8fCxib+MVv3
LR80x9yTbkg/hquYaSp0fBjAqO5LAGjSKsgyVpvM9+cXOwBwWeZBUmAS8INCA2AyA/W2dW0oepsf
840A/e8HGq9yyYDnOepdVwoA2InMvxchpICGzIVbzThRGOMuTO82fABgBNgAfvcx8vCO47Eqx01Z
BoVuY3SqV2SUpGrIdgONAEYFMddUqAX3vhlgawR5EY56J0sFAE8Cv80iKNSOnE1UENqrN7/hDjeq
GJ30YVY2uj+MreBXxqZ92uy3SgUA9hc0UlmUv4YCrZ33vta0A4Xv7+65uHqhn1sY1r8PCgSNigPY
AStgnz57Z6kAAGRK9oNZSAGQM4Dqoq7YEW3qmwIEus4UH8s8qQBG0uU94KHT8QgumQHxAbdrWm8B
QIDo0RreKSUA2NOxj4QMDwvkLOI7o67YIW36i5oFuqkzZgT2XCOEle+lPvx6vVccwAm26dOn2z1E
O6DNfK6UAAByytWXCTdUbJe5FPU8/vxVSm++z3YDmTkTXSF2jRAMDBNDUPVwQ/EcldqpBJg9Ox0H
eE+fszGX9y2GdWjuJ/P1MC2EJBDAqajnAeSF/nfxBc91mLuWAxzo7k6vZK07ft2kOu88puptpk+v
NBX7TmoGmqxk1V36gpc6dmw5odQkgE1/iBy710ICVrdAUxtVhX5becY/CBCYJjOamtK63fQI85oK
g9DwMBS9rHh3sAnXvlsVNM2aJXMHQDxTedoNpRQHcFMfcoHGviyuOQZ4JLIKafWPAZrQdcG0abQF
BG0MH/2u8v39DD2ne5n0sCVaARobEbouAK1Hm/pgKQMA5IoYHyOzWmgYo/AM4FtRVKZre9fw5qpL
r8YaFZx17LGjgjdexiE5xgHCRhoHgWPmzbN1v3Z/1Zovdm3vynmuYLGtRXceMpO4PiQINOAq5Pz5
vFJihdC3HVnWW8PQJA003n2Xp/v6Rul3FHaB6dO7TIWu99P57v+n19ZCWxsChEGl0Tn1lcndWzWj
1CWATY8ikzhMB5ODPIONRLBoUvdWzby3eu0q2yWktZWF+A/tJl0620uUB7mJXvH/+QBtbWnX7+7q
T68aC/OLUQLY1Ioc80+E9A4GgI8SwXzEl4+79PElqVfPsoGwo7ubvYoerzt6lJGlp4CPh2Gfnw0s
6ehIB3669cSzi3c8cOpY36+YlyNtQGYRhf3w8lFgVRTu4duLV+2Ya+5OaKapoevs7O7mLcsX9xPX
fm6cFzjc19lG32LL5RMgfq+17Jr7+m/yEhrXixgAR5Ffz1qDnPRJgFpoQH6FdE2+K/JQ1cfPHKZq
WFiTMzoSCY63DDIzwIhLEi5XAA+VsshmvuXyGVQaD1ZfeGa+3q1UFiSuRub6f4rMVzX9VMNVyCVf
8jYZ5TtLfzj9mqHbd9cyUGdPEx/q7uaJEEEbt1Fohuh5OnLaU63NfF1niJqBO2o+2/6F7V/aV24A
sKkCuA6ZL1jPyDkD7v3vI1PK80qHF510YIroaXQ23FPd3el5Z3pAlC9ILejI5Idz7Cnp2Cte1h1Z
PvWFxu6tmpnP99FLDAAp4Hrkqh0nAg8xcm1/4fAOrkWuqFWVzwpsqF7X/N47A2+Y9iNNk490dHBR
QwONlloISgtTbYPIBMgLGho4p6MjHeM30dilL3x+fc0fzc4380tRAqioGViOTP9ew+i1h1+0jMND
eXrej4GrL69Z8NbP2yvbR+mh/fs5dOAAr5PJW9cVPd9mfLul56fPmDFiwqd9301Vl6274pVvboiq
8SYCAFT2wsXIxSBPtNznHuRMo91juO8xVuSx31IvrwL87rjP3LsitfUKQNMsiTBixu+ePfQdPcpB
68LJyCVL6hoaYI5jAXXrOpvxWytO+sXJr228POrGmogAUHkHCQsIY1lj71jkDCelGP6vJZ//t6Wp
7ZdMFT2NIsuGtcv30HDolcrjHzz91fXrCtU45QCAgtEtS2/RB7WaqR2pnZ85f3jLzZUYVVoA41NU
GFuqzv/K7/WWO1NUHu7a3mUWss4xAKIFREUlwzOrRXJWBakpOma1iZ5MUdGT1Ko/MKja37W9KxW3
VEwxxRRTTDHFFFNMBaX/BxqpVwXfNj1GAAAAAElFTkSuQmCC'));
	$loader->close;
	$hilight = $loader->get_pixbuf;
}

Irssi::settings_add_bool('systemtray', 'systemtray_goto_status', 1);
Irssi::settings_add_bool('systemtray', 'systemtray_update', 1);
