use Test::More tests => 3;
use v5.14;
use warnings;

use_ok( 'UAV::Pilot::Wumpus::Server' );
use_ok( 'UAV::Pilot::Wumpus::Server::Backend' );

eval "use HiPi::BCM2835::I2C";
SKIP: {
    skip "HiPi module not installed, skipping Raspberry Pi", 1 if $@;
    use_ok( 'UAV::Pilot::Wumpus::Server::Backend::RaspberryPiI2C' );
}
