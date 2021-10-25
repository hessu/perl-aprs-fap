
# object decoding
# Tue Dec 11 2007, Hessu, OH7LZB

use Test;

BEGIN { plan tests => 12 + 10 + 5 };
use Ham::APRS::FAP qw(parseaprs);

my $srccall = "OH2KKU-1";
my $dstcall = "APRS";
my $comment = "Kaupinmaenpolku9,open M-Th12-17,F12-14 lcl";
# Compressed format
my $aprspacket = "$srccall>" . pack('H*', "415052532C54435049502A2C7141432C46495253543A3B5352414C20485120202A3130303932377A533025452F5468345F612020414B617570696E6D61656E706F6C6B75392C6F70656E204D2D546831322D31372C4631322D3134206C636C");
my %h;
my $retval = parseaprs($aprspacket, \%h);

ok($retval, 1, "failed to parse an object packet");
ok($h{'resultcode'}, undef, "wrong result code");
ok($h{'type'}, 'object', "wrong packet type");

ok($h{'objectname'}, 'SRAL HQ  ', "wrong object name");
ok($h{'alive'}, 1, "wrong alive bit");

# timestamp test has been disabled, because it cannot be
# done this way - the timestamp in the packet is not
# fully specified, so the resulting value will depend
# on the time the parsing is executed.
# ok($h{'timestamp'}, 1197278820, "wrong timestamp");

ok($h{'symboltable'}, 'S', "incorrect symboltable parsing");
ok($h{'symbolcode'}, 'a', "incorrect symbolcode parsing");

ok(sprintf('%.4f', $h{'latitude'}), "60.2305", "incorrect latitude parsing (northern)");
ok(sprintf('%.4f', $h{'longitude'}), "24.8790", "incorrect longitude parsing (eastern)");
ok(sprintf('%.3f', $h{'posresolution'}), "0.291", "incorrect position resolution");
ok($h{'phg'}, undef, "incorrect PHG parsing");
ok($h{'comment'}, $comment, "incorrect comment parsing");

##### Second object, regular APRS position

$aprspacket = "$srccall>$dstcall:;LEADER   *092345z4903.50N/07201.75W>088/036";
%h = ();
$retval = parseaprs($aprspacket, \%h);

ok($retval, 1, "failed to parse an object packet");
ok($h{'resultcode'}, undef, "wrong result code");
ok($h{'type'}, 'object', "wrong packet type");

ok($h{'objectname'}, 'LEADER   ', "wrong object name");
ok($h{'alive'}, 1, "wrong alive bit");

ok(sprintf('%.4f', $h{'latitude'}), "49.0583", "incorrect latitude parsing (northern)");
ok(sprintf('%.4f', $h{'longitude'}), "-72.0292", "incorrect longitude parsing (eastern)");
ok(sprintf('%.3f', $h{'posresolution'}), "18.520", "incorrect position resolution");
ok($h{'phg'}, undef, "incorrect PHG parsing");
ok($h{'comment'}, undef, "incorrect comment parsing");

# killed:
$aprspacket = "$srccall>$dstcall:;LEADER   _092345z4903.50N/07201.75W>088/036";
%h = ();
$retval = parseaprs($aprspacket, \%h);

ok($retval, 1, "failed to parse an object packet");
ok($h{'resultcode'}, undef, "wrong result code");
ok($h{'type'}, 'object', "wrong packet type");

ok($h{'objectname'}, 'LEADER   ', "wrong object name");
ok($h{'alive'}, 0, "wrong alive bit");

