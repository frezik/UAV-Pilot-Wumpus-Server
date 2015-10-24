package UAV::Pilot::Wumpus::Server::Backend::Spektrum;
use v5.14;
use Moose;
use namespace::autoclean;
use UAV::Pilot::Wumpus::Server::Backend;
use UAV::Pilot::Wumpus::PacketFactory;
use Device::Spektrum::Packet;
use Device::SerialPort;
use Time::HiRes;


has '_serial' => (
    is => 'ro',
    isa => 'Device::SerialPort',
);
has 'ch_name_map' => (
    is => 'ro',
    isa => 'HashRef[Str]',
    default => sub {{
        throttle => 1,
        aileron => 2,
        elevator => 3,
        rudder => 4,
        gear => 5,
        aux1 => 6,
        aux2 => 7,
    }},
);
has 'throttle' => (
    is => 'rw',
    isa => 'Int',
);
has 'aileron' => (
    is => 'rw',
    isa => 'Int',
);
has 'elevator' => (
    is => 'rw',
    isa => 'Int',
);
has 'rudder' => (
    is => 'rw',
    isa => 'Int',
);
has 'gear' => (
    is => 'rw',
    isa => 'Int',
);
has 'aux1' => (
    is => 'rw',
    isa => 'Int',
);
has 'aux2' => (
    is => 'rw',
    isa => 'Int',
);
has '_last_packet_sent_time' => (
    is => 'rw',
    isa => 'ArrayRef[Int]',
);
has 'ch1_max_out' => (
    is      => 'ro',
    isa     => 'Int',
    default => SPEKTRUM_HIGH,
);
has 'ch1_min_out' => (
    is      => 'ro',
    isa     => 'Int',
    default => SPEKTRUM_LOW,
);
has 'ch2_max_out' => (
    is      => 'ro',
    isa     => 'Int',
    default => SPEKTRUM_HIGH,
);
has 'ch2_min_out' => (
    is      => 'ro',
    isa     => 'Int',
    default => SPEKTRUM_LOW,
);
has 'ch3_max_out' => (
    is      => 'ro',
    isa     => 'Int',
    default => SPEKTRUM_HIGH,
);
has 'ch3_min_out' => (
    is      => 'ro',
    isa     => 'Int',
    default => SPEKTRUM_LOW,
);
has 'ch4_max_out' => (
    is      => 'ro',
    isa     => 'Int',
    default => SPEKTRUM_HIGH,
);
has 'ch4_min_out' => (
    is      => 'ro',
    isa     => 'Int',
    default => SPEKTRUM_LOW,
);
has 'ch5_max_out' => (
    is      => 'ro',
    isa     => 'Int',
    default => SPEKTRUM_HIGH,
);
has 'ch5_min_out' => (
    is      => 'ro',
    isa     => 'Int',
    default => SPEKTRUM_LOW,
);
has 'ch6_max_out' => (
    is      => 'ro',
    isa     => 'Int',
    default => SPEKTRUM_HIGH,
);
has 'ch6_min_out' => (
    is      => 'ro',
    isa     => 'Int',
    default => SPEKTRUM_LOW,
);
has 'ch7_max_out' => (
    is      => 'ro',
    isa     => 'Int',
    default => SPEKTRUM_HIGH,
);
has 'ch7_min_out' => (
    is      => 'ro',
    isa     => 'Int',
    default => SPEKTRUM_LOW,
);
has 'ch8_max_out' => (
    is      => 'ro',
    isa     => 'Int',
    default => SPEKTRUM_HIGH,
);
has 'ch8_min_out' => (
    is      => 'ro',
    isa     => 'Int',
    default => SPEKTRUM_LOW,
);

with 'UAV::Pilot::Wumpus::Server::Backend';


sub BUILDARGS
{
    my ($class, $args) = @_;

    my $port = delete $args->{port};
    my $serial = $class->_init_serial_port( $port );
    $args->{'_serial'} = $serial;

    return $args;
}

sub BUILD
{
    my ($self) = @_;
    $self->_reset_last_packet_sent_time;
    return $self;
}


sub _packet_request_startup
{
    my ($self, $packet) = @_;
    $self->_set_started( 1 );
    return 1;
}

sub _packet_radio_trims
{
    # Ignore
}

sub _packet_radio_out
{
    my ($self, $packet, $server) = @_;
    $self->_logger->info( 'Got radio out packet: ' . ref($packet) );

    my %ch_name_map = %{ $self->ch_name_map };
    foreach my $ch_name (keys %ch_name_map ) {
        my $ch_num = $ch_name_map{$ch_name};
        my $map_ch_call = '_map_ch' . $ch_num . '_value';
        my $ch_call = 'ch' . $ch_num . '_out';

        my $ch_value = $self->$map_ch_call( $server, $packet->$ch_call );
        $ch_value = sprintf '%.0f', $ch_value; # Round off
        $self->$ch_name( $ch_value );
    }

    my $packet = Device::Spektrum::Packet->new({
        throttle => $self->throttle,
        aileron => $self->aileron,
        elevator => $self->elevator,
        rudder => $self->rudder,
        gear => $self->gear,
        aux1 => $self->aux1,
        aux2 => $self->aux2,
    });
    $self->_serial->write( $packet->encode_packet );
    $self->_reset_last_packet_sent_time;

    return 1;
}


sub _init_serial_port
{
    my ($class, $port) = @_;

    my $serial = Device::SerialPort->new( $port ) or die "Can't open serial port: $^E\n";
    $serial->baudrate( 115_200 );
    $serial->parity( 'none' );
    $serial->databits(8);
    $serial->stopbits(1);
    $serial->write_settings or die "Can't write settings: $^E\n";

    return $serial;
}

sub _reset_last_packet_sent_time
{
    my ($self) = @_;
    $self->_last_packet_sent_time([ Time::HiRes::gettimeofday ]);
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

