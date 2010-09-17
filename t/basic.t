use Test::More;
use strict;

use_ok('Config::Origami');

ok(my $c = Config::Origami->new(config_path => "t/basic_config"), "new");
is($c->{name}, 'basic defaults', 'check basic loading');

done_testing;
