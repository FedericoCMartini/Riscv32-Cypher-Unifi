#!/bin/perl

my $table = `cat ./scripts/dump`; #you'll need to paste the addresses here from ripes disassemble

while(<>)
{
    my $line = $_;
    if ($line =~ /.*_jump_table:/) {
        
        my @symbols = ( $line =~ /\w*_case_\w*/g);
        foreach (@symbols)
        {
            my $name = $_;
            my ($symbol_hex) = $table =~ /([\da-f]*)\s*<$name>:/;

            $line =~ s/$name/0x$symbol_hex/;
        }
    }
    unless ( $line =~ /^\s*#\s*$/) { #skips line where it's just a '#'
        print $line;
    }
}
