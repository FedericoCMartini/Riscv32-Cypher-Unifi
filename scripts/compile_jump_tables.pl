#!/bin/perl

my $table = `riscv64-linux-gnu-nm ./bin/$ARGV[0]`;
my $file = "./asm/" . $ARGV[0] . ".s";
# my $pattern = '/([0-9a-f]*)(?{ $symbol_hex = $^N })\s*([td])(?{ $symbol_section = $^N })\s*(\w*)(?{ $symbol_name = $^N })/';
# use re 'eval';

rename($file, $file . '.bak');
open(IN, '<' . $file . '.bak') or die $!;
open(OUT, '>' . $file) or die $!;
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

system "rm -f " . $file . '.bak';

# cmd = `riscv64-linux-gnu-nm $1 | awk '/^$2$/ {print $1}'`