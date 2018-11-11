#!/usr/bin/env perl

use strict;
use warnings;
use File::Temp qw(tempfile);

die "usage: $0 [opts-to-diff] <file1> <file2>\n"
     if @ARGV < 2;

my $fn2 = reformat(pop @ARGV);
my $fn1 = reformat(pop @ARGV);

exec 'diff', @ARGV, $fn1, $fn2;
die "failed to execute diff:$!";

sub reformat {
    my $fn = shift;
    my @in_blocks = split /\n{2,}/, do {
        open my $fh, '<', $fn
            or die "failed to open $fn:$!";
        local $/;
        <$fh>;
    };
    my @out_blocks = map { do {
       my @lines = split /\n/, $_;
       (
           (sort grep { /^:/ } @lines),
           (grep { /^content-length\t/ } @lines),
           (grep { !/^(?::|content-length\t)/ } @lines),
           "",
       )
    } } @in_blocks;
    my ($tmpfh, $tmpfn) = tempfile;
    print $tmpfh join "\n", @out_blocks;
    $tmpfn;
}
