#!usr/bin/perl -w
use strict;


############### Xin Wang 04/11/2017 ##############

#system"pbsnodes -l all > /public/software/bin/tmp/node.info";    ###### remove 04/11/2017
my $all_out = `pbsnodes -l all`;

################$node{node3}[0] node state  $node{node3}[1] cpu_used $node{node3}[2] cpu number $node{node3}[3] loadave $node{node3}[4] physmeme $node{node3}[5] availemem $node{node3}[6] color 
my %nodes;
my @server;
#open IN,"<","/public/software/bin/tmp/node.info";
my @all_list = split(/\n/, $all_out);
for my $all_line(@all_list){
	chomp($all_line);
	my @line=split(/\s+/,$all_line);
	push @server,$line[0];
	$nodes{$line[0]}[0]=$line[1];
}
close IN;

my $nodes_number = keys %nodes;


#print"There are total 19 nodes in the system\n";


#system"echo -e \"\e[40;31m full-load  \e[40;32m  free  \e[40;33m  partly-used  \e[40;37m down/offline  \e[m \"";
#print"----------------------------------------------------------------------------------------------------\n";

#system"echo -e \"\e[41;37m node-name     cpu-infor     load-average       physmem                   availmem/totalmem \e[m \"";

#open IN,"<","node3.info";

#my @server = ("cu01","cu02","cu03","cu04","cu05","cu06","cu07","fat01");
for my $i(0..($nodes_number-1)){
	#system "pbsnodes node$i > /public/software/bin/tmp/node$i.info";        ##### remove 04/11/2017
	my $node_out = `pbsnodes $server[$i]`;
	my @node_list = split(/\n/, $node_out);
	my $cpu_used=0;
	my($loadave, $ncpus, $physmem, $availmem, $totalmem);
	#$nodes{"node$i"}=0;
	#print"node$i\t";
	#open IN,"<","/public/software/bin/tmp/node$i.info";
	for my $node_line(@node_list){
		chomp($node_line);
		if($node_line=~/jobs/ && $node_line!~/status/){
			if($node_line =~/\d+\-\d+\/\d+/){
				my @job_run = split/\,/,$node_line;
				for my $j(@job_run){
					my @job_infor = split/\//,$j;
					my @cpu_count = split/\-/,$job_infor[0];
					my $cpu_count = $cpu_count[1] - $cpu_count[0] +1;
					$cpu_used=$cpu_used + $cpu_count;	
				}
			}
			else{
				my $cpu_count=($node_line=~tr/\,/N/);
				$cpu_used=$cpu_count+1;
			}
		}
			
			#print"$cpu_used\n";
		elsif($node_line=~/status/){
			#print"$_\n";
			($loadave, $ncpus, $physmem, $availmem,$totalmem) = $node_line =~ /loadave=(.*),ncpus\=(\d+),physmem\=(\d+)kb\,availmem\=(\d+)kb,totmem\=(\d+)kb/;
			#print"$loadave\t$ncpus\t$physmem\t$availmem\n";
			#my($loadave, $ncpus, $physmem, $availmem) = $_ =~ /loadave\=(\d+)\,ncpus\=(\d+)\,physmem\=(\d+)kb\,availmem\=(\d+)kb/;
			#print"$loadave\t$ncpus\t$physmem\t$availmem\n";
		}
		else{
			#print"$cpu_used\n";
		}
	}
	$nodes{"$server[$i]"}[1]=$cpu_used;
	$nodes{"$server[$i]"}[2]=$ncpus;
	$nodes{"$server[$i]"}[3]=$loadave;
	$nodes{"$server[$i]"}[4]=$physmem;
	$nodes{"$server[$i]"}[5]=$availmem;
	$nodes{"$server[$i]"}[6]=$totalmem;
	my $color=37;
	if($nodes{"$server[$i]"}[0]=~/down/ || $nodes{"$server[$i]"}[0]=~/offline/){
		$color=37;
	}
	elsif($nodes{"$server[$i]"}[1]==0){
		$color=32;
	}
	elsif($nodes{"$server[$i]"}[1]==$nodes{"$server[$i]"}[2]){
		$color=31;
	}
	elsif(($nodes{"$server[$i]"}[1]!=0) && ($nodes{"$server[$i]"}[1]!=$nodes{"$server[$i]"}[2])){
		$color=33;
	}
	$nodes{"$server[$i]"}[7]=$color;
	#system"echo -e \"\e\[40\;$nodes{\"node$i\"}[7]m node$i\t\t$nodes{\"node$i\"}[1]\/$nodes{\"node$i\"}[2]\t\t$nodes{\"node$i\"}[3]\t\t$nodes{\"node$i\"}[4] KB\t\t$nodes{\"node$i\"}[5] KB / $nodes{\"node$i\"}[6] KB\e\[m \"";
	#print OUT"echo -e \"\e\[40\;$nodes{\"node$i\"}[7]m $nodes{\"node$i\"}[1]\/$nodes{\"node$i\"}[2] $nodes{\"node$i\"}[3] $nodes{\"node$i\"}[4] $nodes{\"node$i\"}[5]\e\[m \"";
}



#print"There are total 19 nodes in the system\n";
system"echo -e \"\e[41;37m There are total $nodes_number nodes in the system \e[m \"";
print"\n";
system"echo -e \"\e[40;31m full-load  \e[40;32m  free  \e[40;33m  partly-used  \e[40;37m down/offline  \e[m \"";
print"----------------------------------------------------------------------------------------------------\n";

system"echo -e \"\e[41;37m node-name     cpu-infor     load-average       physmem                   availmem/totalmem \e[m \"";
for my $i(0..($nodes_number-1)){
	system"echo -e \"\e\[40\;$nodes{\"$server[$i]\"}[7]m $server[$i]\t\t$nodes{\"$server[$i]\"}[1]\/$nodes{\"$server[$i]\"}[2]\t\t$nodes{\"$server[$i]\"}[3]\t\t$nodes{\"$server[$i]\"}[4] KB\t\t$nodes{\"$server[$i]\"}[5] KB / $nodes{\"$server[$i]\"}[6] KB\e\[m \"";
}

#system"rm /public/software/bin/tmp/*.info";
####added by wangxin 2016.05.04
print"\n";

my $name;
#system"whoami | "

open IN,"whoami |";
while (my $line = <IN>) {
	chomp $line;
	$name=$line;
}
close IN;

system"echo -e \"\e[35m USER_NAME  $name\e[m \"";

#print"$name\n";
open IN,"who |";
while (my $line = <IN>) {
	chomp $line;
	if($line=~/$name/){
		#system"echo -en \"\e[35m $line\e[m \"";
		system"echo -e \"\e[35m $line\e[m \"";	
	}
}
close IN;
print"job_id\t\t\tjob_name\t\tjob_state\t\tqueue\t\tnodes\t\tppn\t\twalltime\t\texec_nodes\n";
#system"echo -e \"\e\[41;37m job_id       job_name      job_state      queue       nodes       ppn       walltime \e\[m \"";
my ($job_id, $job_name, $job_state, $queue, $nodes, $ppn, $walltime,$ex_node)=("","","","","","","","");

open IN,"qstat -u $name -f |";
if($name eq "root"){
	close IN;
	open IN,"qstat -f |";
}

while (my $line = <IN>) {
	if($line=~/Job Id/){
		#print"$job_id\t\t$job_name\t\t$job_state\t\t$queue\t\t$nodes\t\t$ppn\t\t$walltime\t\t$ex_node\n";
		if($job_state eq "Q"){
			$nodes = " ";
			$queue = " ";
			$ex_node = " ";
		}
		system"echo -e \"\e\[35m $job_id\t\t$job_name\t\t$job_state\t\t$queue\t\t$nodes\t\t$ppn\t\t$walltime\t\t$ex_node\e\[m \"";
		($job_id, $job_name, $job_state, $queue, $nodes, $ppn, $walltime)=(0,0,0,0,0,0,0);
		($job_id) = $line =~/Job Id: (.*)/;
		#print"$job_id\n";
	}
	else{
		if($line=~/Job_Name \=/){
			($job_name) = $line =~/Job_Name \= (.*)/;	
			$job_name=(sprintf "%-20s",$job_name);
		}
		elsif($line=~/job_state \=/){
			($job_state) = $line =~/job_state \= (.*)/;	
		}
		elsif($line=~/queue \=/){
			($queue) = $line =~/queue \= (.*)/;	
		}
		elsif($line=~/Resource_List\.nodes/){
			($nodes, $ppn) = $line =~/Resource_List\.nodes \= (\d+)\:ppn\=(\d+)/;
		}
		elsif($line=~/Resource_List\.walltime/){
			($walltime) = $line =~/Resource_List\.walltime \= (.*)/;	
			#print"$walltime";
		}
		elsif($line=~/exec_host/){
			my $temp = $line;
			$temp =~s/exec_host = //;
			my @ex_node = split/\//,$temp;
			$ex_node=$ex_node[0];
		}
		#print"$walltime\n";
		#print"$job_id\t$job_name\t$job_state\t$queue\t$nodes\t$ppn\t$walltime\n";
	}
}
close IN;
system"echo -e \"\e\[35m $job_id\t\t$job_name\t\t$job_state\t\t$queue\t\t$nodes\t\t$ppn\t\t$walltime\t\t$ex_node\e\[m \"";
#print"$job_id\t\t$job_name\t\t$job_state\t\t$queue\t\t$nodes\t\t$ppn\t\t$walltime\t\t$ex_node\n";







