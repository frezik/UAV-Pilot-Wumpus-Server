use Test::More tests => 4;
use v5.14;
use warnings;

use_ok( 'UAV::Pilot::Wumpus::Server' );
use_ok( 'UAV::Pilot::Wumpus::Server::Backend' );
use_ok( 'UAV::Pilot::Wumpus::Server::Backend::Logger' );

eval "use HiPi::BCM2835::I2C";
SKIP: {
    skip "HiPi module not installed, skipping Raspberry Pi", 1 if $@;
    use_ok( 'UAV::Pilot::Wumpus::Server::Backend::RaspberryPiI2C' );
}
