package Config::Origami;
use Moose;
use JSON;
use File::Slurp qw(read_file);
use Sys::Hostname qw(hostname);
use Clone ();

use namespace::clean -except => 'meta';

my $json = JSON->new->relaxed(1);

has config_path => (
   isa => 'Str',
   is  => 'ro',
);

sub BUILD {
    my $self = shift;
    my $config = {};
    $config = $self->_load_file( $config, $self->config_path . "/defaults.json");
    $config = $self->_load_file( $config, $self->config_path . "/defaults-override.json", 1);
    
    for my $k (keys %$config) {
        $self->can($k)
          ? $self->$k($config->{$k})
          : $self->{$k} = $config->{$k};
    }
    return $self;
}

sub _load_file {
    my ($self, $config, $file, $optional) = @_;
    return $config if $optional and !-f $file;
    my $data = $json->decode(scalar read_file($file));
    return _hash_merge($config, $data);
}

# $h = hash_merge($h1, $h2);
# $h = hash_merge($h1, $h2, $h3, ...);
sub _hash_merge {
    # Do a deep copy of arguments, to avoid sharing
    my @h = @{ Clone::clone(\@_) };
    # Merge them from left to right
    my $h = shift @h;
    __hash_merge($h, $_) for @h;
    return $h;
}

sub __hash_merge {
    my ($h1, $h2) = @_;
    keys %$h2;    # reset iter
    while (my ($k, $v) = each %$h2) {
        if (ref($v) eq 'HASH' and ref($h1->{$k}) eq 'HASH') {
            __hash_merge($h1->{$k}, $v);
        }
        else {
            $h1->{$k} = $v;
        }
    }
}

__PACKAGE__->meta->make_immutable;

local ($Config::Origami::VERSION) = ('devel') unless defined $Config::Origami::VERSION;

1;

__END__

=pod

=head1 NAME

Config::Origami - Layered JSON configuration

=head1 SYNOPSIS

    use Config::Origami;
    my $config = Config::Origami->new(config_path => 'some/path');
    my $port = $config->{port};

or

    package My::Config;
    use Moose;
    extends 'Config::Origami';

    has port => (
        isa => 'Num',
        is  => 'rw',
    );

    around BUILDARGS => sub {
        my ($orig, $class) = (shift, shift);
        return $class->$orig(config_path => 'config/', @_);
    };


    package My::App;
    use My::Config;

    my $config = My::Config->new;
    say "Going to listen on port ", $config->port;

   

=head1 DESCRIPTION

=head1 METHODS

=over4

=item ...

=back

=head1 AUTHOR

Ask Bjørn Hansen, C<< <ask at develooper.com> >>.  Based on code
developed for Solfo, Inc by Graham Barr and Adriano Ferreira.

=head1 BUGS

Please report any bugs or feature requests to the issue tracker at
L<http://github.com/solfo/Config-Origami/issues>.

The Git repository is available at
L<http://github.com/solfo/Config-Origami>


=head1 COPYRIGHT & LICENSE

Copyright 2010 Ask Bjørn Hansen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut


=cut
