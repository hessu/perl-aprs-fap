
# Test position encoder
# 2016, Hessu, OH7LZB

use Test;

BEGIN { plan tests => 4 };
use Ham::APRS::FAP qw(make_position);

# check north/south, east/west and roundings for coordinates
ok(make_position(63.06716666666667, 27.6605, undef, undef, undef, '/#'),
	'6304.03N/02739.63E#', 'Basic position, northeast, no speed/course/alt');

ok(make_position(-23.64266666666667, -46.797, undef, undef, undef, '/#'),
	'2338.56S/04647.82W#', 'Basic position, southwest, no speed/course/alt');

# optional speed/course and altitude
ok(make_position(52.364, 14.1045, 83.34, 353, 95.7072, '/>'),
	'5221.84N/01406.27E>353/045/A=000314', 'Basic position, northeast, has speed/course/alt');

ok(make_position(52.364, 14.1045, undef, undef, 95.7072, '/>'),
	'5221.84N/01406.27E>/A=000314', 'Basic position, northeast, no speed/course, has alt');

