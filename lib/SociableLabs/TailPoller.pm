package SociableLabs::TailPoller;

use 5.0;
use strict;
use warnings;

require Exporter;
use AutoLoader qw(AUTOLOAD);
use File::Spec;
use SociableLabs::Base;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use SociableLabs::TailPoller ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
    get_latest_lines	
);

our $VERSION = '1.02';


sub get_latest_lines {
    my $_start_time = time();
    my $filename = shift;
    my $state_prefix = shift;
    my $print_only = shift;
    my @logdata = ();
    
    unless ( -r $filename ) {
        print STDERR "Unable to read from $filename.  Does the path exist?\n";
        return(undef);
    }
    my $state_file = _get_state_file( $filename, $state_prefix );
    my ( $inode, $position ) = _get_last_read_metadata( $state_file, $filename );
    
    my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($filename);
    if ( $ino != $inode ) {
        debug_print "File rollover detected...";
        $position = 0;
    }
    
    debug_print "Reading INODE: $inode, POS: $position";
    
    open( LOGFILE, $filename ) || die "Unable to read from $filename\n";
    seek LOGFILE, $position, 0;
    if ( $print_only ) {
        debug_print "Outputting direct to STDOUT";
        foreach my $line ( <LOGFILE> ) {
            print $line;
        }
    } else {
        @logdata = <LOGFILE>;    
    }
    
    my $last_read = tell LOGFILE;
    close(LOGFILE);
    
    _update_state_file( $state_file, $ino, $last_read );
    debug_print "Took " . ( time() - $_start_time ) . " second(s) to process " . scalar( @logdata ) . " lines";
    return( \@logdata );
}

sub _update_state_file {
    my $write_to = shift;
    my $_ino = shift;
    my $_pos = shift;
    
    debug_print "Updating state file $_ino:$_pos";
    open( STATEFILE, ">$write_to" ) || die "Unable to update state file at $write_to\n\n";
    print STATEFILE "$_ino:$_pos";
    close( STATEFILE );    
}

sub _get_file_extents {
    my $filename = shift;
    my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($filename);
    open( EXTENTS, $filename ) || die "Unable to read from file at $filename\n\n";
    seek EXTENTS, 0, 2;
    my $pos = tell EXTENTS;
    close(EXTENTS);
    return( $ino, $pos );    
}

sub _get_last_read_metadata {
    my $state_file = shift;
    my $filename = shift;
    unless ( -f $state_file ) {
        debug_print "No state file detected. Initializing...";
        return( _get_file_extents( $filename ) );
    }
    
    open( STATEFILE, "$state_file" ) || die "Unable to read from state file $state_file\n\n";
    my $metadata = <STATEFILE>;
    close(STATEFILE);
    
    my ( $_ino, $_pos ) = split( /:/, $metadata );
    unless ( 
        ( defined( $_ino ) && $_ino =~ /^\d+$/ ) &&
        ( defined( $_pos ) && $_pos =~ /^\d+$/ )
    ) {
        die "Bad data found in statefile $state_file:\n$metadata\n\n";
    }
    
    debug_print "Read from state file $_ino:$_pos";
    return( $_ino, $_pos );
}

sub _get_state_file {
    my $filename = shift;
    my $prefix = shift;
    $prefix = '' unless ( defined( $prefix ) );
    
    my $state_file = File::Spec->rel2abs($filename);
    $state_file =~ s/\//_/g;
    return( "/tmp/${prefix}$state_file." . getpwuid($<) );
}
1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

SociableLabs::TailPoller - Perl extension for blah blah blah

=head1 SYNOPSIS

  use SociableLabs::TailPoller;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for SociableLabs::TailPoller, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Ross Del Duca, E<lt>delducra@apple.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Ross Del Duca

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.3 or,
at your option, any later version of Perl 5 you may have available.


=cut
