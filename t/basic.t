use Test::More;
use strict;

use_ok('Config::Origami');

ok(my $c = Config::Origami->new(config_path => "t/config/basic"), "new");
is($c->{name}, 'basic defaults', 'check basic loading');

ok($c = Config::Origami->new(config_path => "t/config/override"), "new");
is($c->{name}, 'basic defaults override', 'check basic overriding');
is($c->{deep}->{name}, 'deep override', 'deep override');

done_testing;
