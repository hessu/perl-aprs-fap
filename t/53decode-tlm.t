
# telemetry decoding
# Wed Mar 12 16:22:53 EET 2008

use Test;

BEGIN { plan tests => 21 };
use Ham::APRS::FAP qw(parseaprs);

my $srccall = "SRCCALL";
my $dstcall = "APRS";

# Classic packet, but one floating point value too
my $aprspacket = "$srccall>$dstcall:T#324,000,038,257,255,50.12,01000001";

my %h;
my $retval = parseaprs($aprspacket, \%h);

ok($retval, 1, "failed to parse a telemetry packet");
ok($h{'resultcode'}, undef, "wrong result code");

ok(defined $h{'telemetry'}, 1, "no telemetry data in rethash");

my %t = %{ $h{'telemetry'} };

ok($t{'seq'}, 324, "wrong sequence number parsed from telemetry");
ok($t{'bits'}, '01000001', "wrong bits parsed from telemetry");
ok(defined $t{'vals'}, 1, "no value array parsed from telemetry");

my(@v) = @{ $t{'vals'} };
ok($v[0], "0", "wrong value 0 parsed from telemetry");
ok($v[1], "38", "wrong value 1 parsed from telemetry");
ok($v[2], "257", "wrong value 2 parsed from telemetry");
ok($v[3], "255", "wrong value 3 parsed from telemetry");
ok($v[4], "50.12", "wrong value 4 parsed from telemetry");

#
# Test floating-point and negative values, relaxed rules according to
# proposal from Kenneth:
# https://github.com/PhirePhly/aprs_notes/blob/master/telemetry_format.md
$aprspacket = "$srccall>$dstcall:T#1,-1,2147483647,-2147483648,0.000001,-0.0000001,01000001";
%h = ();
$retval = parseaprs($aprspacket, \%h);

ok($retval, 1, "failed to parse a relaxed telemetry packet");
ok($h{'resultcode'}, undef, "wrong result code");
%t = %{ $h{'telemetry'} };

ok($t{'seq'}, 1, "wrong sequence number parsed from relaxed telemetry");
ok($t{'bits'}, '01000001', "wrong bits parsed from relaxed telemetry");
ok(defined $t{'vals'}, 1, "no value array parsed from relaxed telemetry");

my(@v) = @{ $t{'vals'} };
ok($v[0], "-1", "wrong value 0 parsed from relaxed telemetry");
ok($v[1], 2147483647, "wrong value 1 parsed from relaxed telemetry");
ok($v[2], -2147483648, "wrong value 2 parsed from relaxed telemetry");
ok($v[3], 0.000001, "wrong value 3 parsed from relaxed telemetry");
ok($v[4], -0.0000001, "wrong value 4 parsed from relaxed telemetry");

