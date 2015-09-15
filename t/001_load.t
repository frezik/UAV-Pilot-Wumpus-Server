use Test::More tests => 3;
use v5.14;
use warnings;

use_ok( 'UAV::Pilot::Wumpus::Server' );
use_ok( 'UAV::Pilot::Wumpus::Server::Backend' );
use_ok( 'UAV::Pilot::Wumpus::Server::Backend::RaspberryPiI2C' );
