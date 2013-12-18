# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl SociableLabs-TailPoller.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;
use Data::Dumper;
$| = 1;

use Test::More tests => 5;
BEGIN { use_ok('SociableLabs::TailPoller') };

my $tmp_filename = '/tmp/tailPoller-testing.' . time();

diag "Using temp file: $tmp_filename\n";
open(TMPFILE, ">$tmp_filename");

print TMPFILE "1\n2\n"; 
close( TMPFILE );

my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($tmp_filename);

my @expected = (); 
my $result = get_latest_lines( $tmp_filename );
is_deeply( $result, \@expected, 'No data on initial read' );

open( TMPFILE, ">>$tmp_filename" );
print TMPFILE "3\n4\n";
close(TMPFILE);

@expected = ( "3\n", "4\n" ); # Picking up \n left off in test above
$result = get_latest_lines( $tmp_filename );
is_deeply( $result, \@expected, 'Get second data data' );

diag "Rolling over file";
rename( $tmp_filename, "$tmp_filename.1" );

open( TMPFILE, ">$tmp_filename" );
print TMPFILE "99\n100\n";
close(TMPFILE);

@expected = ( "99\n", "100\n" );
$result = get_latest_lines( $tmp_filename );
is_deeply( $result, \@expected, 'Init on rollover' );

open( TMPFILE, ">>$tmp_filename" );
print TMPFILE "199\n1100\n";
close(TMPFILE);

@expected = ( "199\n", "1100\n" );
$result = get_latest_lines( $tmp_filename );
is_deeply( $result, \@expected, 'Continue after rollover' );

unlink( $tmp_filename );
unlink( "$tmp_filename.1" );
