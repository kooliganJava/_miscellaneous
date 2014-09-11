#!/usr/bin/perl

use warnings;
use strict;

use WWW::Mechanize;
use CGI;

my $cgi = CGI->new();
my $form = $cgi->Vars;

my $agent = WWW::Mechanize->new(
	#cookie_jar => undef,
	agent_alias => 'Windows IE 6',
	autocheck => 1,
	noproxy => 1,
	#onwarn => \&func,
	#onerror => \&func,
	quiet => 0,
	#stack_depth => $value
	);



$agent->get('http://www.cna.com');
#print $agent->content();

#$agent->post('https://sourceselfservice2.ceridian.com/login.asp?FormID=FrmMain2&CompanyName=f5networks,
#								[ "TxtPassword"	=> "fty7kjue^!((",
#									"TxtUser"	=> "k.fuller@f5.com",
#									"x"	=> "10",
#									"y"	=> "11" 
#								] ');
                           
print "Base is " . $agent->base . "\n";
print "Is HTML? " . $agent->is_html() . "\n";
print "Page title is " . $agent->title() . "\n";
print "Response code " . $agent->status() . "\n";
print "URI " . $agent->uri() . "\n";
print "Content Type " . $agent->content_type() . "\n";
print "______________HEADERS__________________ " . "\n";
	$agent->dump_headers();
print "Images " . "\n";
	$agent->dump_images();
#print "_" . $agent->___() . "\n";

print "__________Find ALL LINKs__________\n";
my @fal = $agent->find_all_links();
foreach my $i (@fal) {
	print $i->url."\n"; 
}

print "__________SUBMITs__________\n";
my @s = $agent->find_all_submits();
foreach my $j (@s) {
	print $j."\n"; 
}

print "__________FORMs__________\n";
my @af = $agent->forms();
foreach my $jj (@af) {
	print "Action -->" . $jj->action."\n"; 
	print "Method -->" . $jj->method."\n";
	#my @I=$jj->inputs;
	foreach my $q ($jj->inputs) {
		print $q->name . "\t" . $q->type  . "\t" .   $q->value  .  "\t" ;
		#my @PV = $q->possible_value;
		#foreach my $Q (@PV) {
		#	print $Q . "\t";
		#}
		print "\n";
	}
	print "_________________" . "\n";
}

#$agent->form_number('1	');
#$agent->agent('Mozilla');
#$agent->field('user',$form->{user});
#$agent->field('password',$form->{password});
#$agent->submit();
#$agent->get('https://www.cnacentral.com/cnac/servlet/CHomeServlet?user='.$form->{user}.'&styleid=225596&checkcookies=1');
#print "Content-type: text/plain\n\n";
#print $agent->content();