use strict;
use warnings;

use lib './t/lib';
use Test::Clipboard;
my %map = qw(
    linux Xclip
    freebsd Xclip
    netbsd Xclip
    openbsd Xclip
    dragonfly Xclip
    Win32 Win32
    cygwin Win32
    darwin MacPasteboard
);

use_ok 'Clipboard::Xclip';
use_ok 'Clipboard';

if (exists $ENV{SSH_CONNECTION} && Clipboard::Xclip::xclip_available()) {
    $map{Win32}  = 'Xclip';
    $map{cygwin} = 'Xclip';
}

is(Clipboard->find_driver($_), $map{$_}, $_) for keys %map;

my $drv = Clipboard->find_driver($^O);
ok(exists $INC{"Clipboard/$drv.pm"}, "Driver-check ($drv)");


eval {
    local %ENV = %ENV;
    delete $ENV{DISPLAY};
    Clipboard->find_driver('NonOS')
};
like($@, qr/is not yet supported/, 'find_driver correctly fails with no DISPLAY');

my $display_drv = do {
    local %ENV = %ENV;
    $ENV{DISPLAY} = ':0.0';
    Clipboard->find_driver('NonOS')
};
is $display_drv, 'Xsel', 'driver is Xclip on unknown OS with DISPLAY set';
is($Clipboard::driver, "Clipboard::$drv", "Actually loaded $drv");
my $silence_stupid_warning = $Clipboard::driver;
