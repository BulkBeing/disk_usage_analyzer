#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;

die "
Usage: perl $0 <directory name>
Example: perl $0 /home

" if (not defined $ARGV[0]);

my $start_path = $ARGV[0];

my %dir_name_size;

#return size of a directory if its greater than 1GB
#Input: full Directory path
#Return value: size of dir. 0 if its less than 1GB 
sub get_dir_size{
    my $path = shift;
    $path = quotemeta($path);
    $path =~ s|\\/|/|g;
    my $dir_size = qx(du -s --si $path);
    if($dir_size =~ m/^(\S+)G\s/){
        $dir_size = $1;
        return $dir_size if defined $dir_size;
    }
    return 0;
}

#Get list of sub directories for a given parent directory
#Input : Parent directory (full path)
#Return value : list of sub directories (each with full path)
sub get_subdir_list{
    my $parent = shift;
    my @subdirs;
    opendir(my $DIR, $parent);
    while(my $entry = readdir $DIR){
        next if $entry eq '.' or $entry eq '..';
        my $full_path = $parent . '/' . $entry;
        next unless -d $full_path;
        push @subdirs, $full_path;
    }
    closedir($DIR);
    return \@subdirs;
}



sub populate_dir_size{
    my $path = shift;
    my $sub_dirs = get_subdir_list($path);
    my %sub_dir_sizes;
    my $sum_subdir_sizes = 0;
    my $parent_size = get_dir_size($path);
    if ($parent_size > 0){
        foreach my $entry (@$sub_dirs){
            my $dir_size = get_dir_size($entry);
            $sub_dir_sizes{$entry} = $dir_size if $dir_size > 0;
        }
        foreach my $size (values %sub_dir_sizes){
            $sum_subdir_sizes += $size;
        }
        if ($parent_size - $sum_subdir_sizes > 1){
            $dir_name_size{$path} = $parent_size;
        }
    }
    foreach my $sub_dir (keys %sub_dir_sizes){
        populate_dir_size($sub_dir);
    }
    

}

populate_dir_size($start_path);

#Only needed if there is something to print.
if (scalar(keys %dir_name_size) > 0){
    printf "\n%5s\t%-s\n","Size", "Directory";
    printf "%5s\t%-s\n", "-" x 4, "-"x9;
}
foreach my $dir_name (sort {$dir_name_size{$b} <=> $dir_name_size{$a}} keys %dir_name_size){
    printf "%5s\t%-s\n", $dir_name_size{$dir_name} . "G", $dir_name;
}