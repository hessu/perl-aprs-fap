
# Test position encoder
# 2016, Hessu, OH7LZB

use Test;

BEGIN { plan tests => 3 + 2 + 4 + 4 + 3 + 4 };
use Ham::APRS::FAP qw(make_position make_timestamp);

# check north/south, east/west and roundings for coordinates
ok(make_position(63.06716666666667, 27.6605, undef, undef, undef, '/#'),
	'!6304.03N/02739.63E#', 'Basic position, northeast, no speed/course/alt');

ok(make_position(-23.64266666666667, -46.797, undef, undef, undef, '/#', { with_messaging => 0 } ),
	'!2338.56S/04647.82W#', 'Basic position, southwest, no speed/course/alt');

# check for rounding causing values of 60 minutes (should be instead 59.99)
ok(make_position(22.9999999, -177.9999999, undef, undef, undef, '/#'),
	'!2259.99N/17759.99W#', 'Basic position minute rounding, no speed/course/alt');

# optional speed/course and altitude
ok(make_position(52.364, 14.1045, 83.34, 353, 95.7072, '/>'),
	'!5221.84N/01406.27E>353/045/A=000314', 'Basic position, northeast, has speed/course/alt');

ok(make_position(52.364, 14.1045, undef, undef, 95.7072, '/>'),
	'!5221.84N/01406.27E>/A=000314', 'Basic position, northeast, no speed/course, has alt');

# timestamp and messaging tests, need to build the test cases on the fly with
# current time because there is limited range in the APRS packet timestmap
# values
my $reftime = time();
my $reftime_hms = $reftime - 555;
my $reftime_dhm = $reftime - 1000000;
my $expected_time_hms = make_timestamp($reftime_hms, 1);
my $expected_time_dhm = make_timestamp($reftime_dhm, 0);
# timestamp HMS
ok(make_position(52.364, 14.1045, 83.34, 353, 95.7072, '/>', { 'timestamp' => $reftime_hms, 'with_messaging' => 0 } ),
	'/' . $expected_time_hms . '5221.84N/01406.27E>353/045/A=000314', 'Basic position, northeast, has speed/course/alt, timestamp HMS');
# timestamp DHM with messaging
ok(make_position(52.364, 14.1045, 83.34, 353, 95.7072, '/>', { 'timestamp' => $reftime_dhm, 'with_messaging' => 1 } ),
	'@' . $expected_time_dhm . '5221.84N/01406.27E>353/045/A=000314', 'Basic position, northeast, has speed/course/alt, timestamp DHM and messaging');
# no timestamp, but with messaging
ok(make_position(52.364, 14.1045, 83.34, 353, 95.7072, '/>', { 'with_messaging' => 1 } ),
	'=5221.84N/01406.27E>353/045/A=000314', 'Basic position, northeast, has speed/course/alt, with messaging');
# current timestamp, should be HMS, without messaging, but due to
# potential timing issues don't really check the actual timestamp
ok(make_position(52.364, 14.1045, 83.34, 353, 95.7072, '/>', { 'timestamp' => 0, 'with_messaging' => 0 } ),
	'm|^/\d{6}h5221.84N/01406.27E>353/045/A=000314$|', 'Basic position, northeast, has speed/course/alt, current timestamp and without messaging');

# ambiguity
ok(make_position(52.364, 14.1045, undef, undef, undef, '/>', { 'ambiguity' => 1 }),
	'!5221.8 N/01406.2 E>', 'Basic position, northeast, ambiguity 1');
ok(make_position(52.364, 14.1045, undef, undef, undef, '/>', { 'ambiguity' => 2 }),
	'!5221.  N/01406.  E>', 'Basic position, northeast, ambiguity 2');
ok(make_position(52.364, 14.1045, undef, undef, undef, '/>', { 'ambiguity' => 3 }),
	'!522 .  N/0140 .  E>', 'Basic position, northeast, ambiguity 3');
ok(make_position(52.364, 14.1045, undef, undef, undef, '/>', { 'ambiguity' => 4 }),
	'!52  .  N/014  .  E>', 'Basic position, northeast, ambiguity 4');

# DAO
ok(make_position(39.15380036630037, -84.62208058608059, undef, undef, undef, '/>', { 'dao' => 1 }),
	'!3909.22N/08437.32W>!wjM!', 'DAO position, US');
# DAO rounding
ok(make_position(39.9999999, -84.9999999, undef, undef, undef, '/>', { 'dao' => 1 }),
	'!3959.99N/08459.99W>!w{{!', 'DAO position, US');
# DAO with speed, course, altitude, comment
ok(make_position(48.37314835164835, 15.71477838827839, 62.968, 321, 192.9384, '/>', { 'dao' => 1, 'comment' => 'Comment blah' }),
	'!4822.38N/01542.88E>321/034/A=000633Comment blah!wr^!', 'DAO position, EU');


# compressed
ok(make_position(-89.99914, -179.86234, 62.968, 14, 192.9384, '/>', { 'compression' => 1, 'comment' => 'Comment blah' }),
	'!/{zxE!$0,>%OA/A=000633Comment blah', 'compressed position 1');
ok(make_position(-12.37314, 138.71477, 2.968, 359, 1924.9384, '/>', { 'compression' => 1, 'comment' => 'Comment blah' }),
	'!/Te/xqSI">!-A/A=006315Comment blah', 'compressed position 2');
ok(make_position(37.19524, -90.49542, 123.968, 115.8, -892.9384, '/>', { 'compression' => 1, 'comment' => 'Comment blah' }),
	'!/;`"c7YX(>>XA/A=-02930Comment blah', 'compressed position 3');
ok(make_position(63.62342, 179.99977, 453.968, 243.2, undef, '/>', { 'compression' => 1, 'comment' => 'Comment blah' }),
	'!/.?>B{z{P>^iAComment blah', 'compressed position 4');
