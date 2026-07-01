#!/bin/perl

#ARGV[0] -> SRC FILE
#ARGV[1] -> BINARY
#ARGV[2] -> DESTINATION

my $table = `riscv64-linux-gnu-nm $ARGV[1]`;
my $file = $ARGV[0];
# my $pattern = '/([0-9a-f]*)(?{ $symbol_hex = $^N })\s*([td])(?{ $symbol_section = $^N })\s*(\w*)(?{ $symbol_name = $^N })/';
# use re 'eval';

# rename($file, $file . '.bak');
open(IN, '<' . $file) or die $!;
open(OUT, '>' . $ARGV[2]) or die $!;
while(<IN>)
{
    my $line = $_;
    if ($line =~ /.*_jump_table:/) {
        # $_ =~ s/blue/red/g;
        my @symbols = ( $line =~ /\w*_case_\w*/g);
        foreach (@symbols)
        {
            my $name = $_;
            my ( $symbol_hex ) = $table =~ /([\da-f]*)\s*t\s*$name/;
            # my ( $symbol_hex, @rest ) = $table_line =~ /([0-9a-f]*)(?{ $symbol_hex = $^N })\s*([td])(?{ $symbol_section = $^N })\s*(\w*)(?{ $symbol_name = $^N })/; 
            $line =~ s/$name/0x$symbol_hex/;
        }
        # system "echo " . $line;
    }
    print OUT $line;
}
close(IN);
close(OUT);

# system "rm -f " . $file;
# rename($file . '.bak', $file);

# system "rm -f " . $file . '.bak';

# cmd = `riscv64-linux-gnu-nm $1 | awk '/^$2$/ {print $1}'`