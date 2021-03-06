use DBI;
use DateTime;
use Config::Simple;

STDOUT->autoflush(1);

my @authorarray;

readDBconfig();



my $dbh = DBI->connect("DBI:Pg:dbname=$dbName;host=$dbHost", "$dbUser", "$dbPassword", {'RaiseError' => 1});

my $usersQuery = $dbh->prepare("SELECT author FROM $dbUsersTable GROUP BY author HAVING sum(posts) > 1000 ORDER BY sum(posts) DESC");
$usersQuery->execute();

while (my $resultHash = $usersQuery->fetchrow_hashref()) {

	push (@authorarray, $resultHash->{'author'});

}


print "hater,hatee,magnitude\n";
foreach (@authorarray) {

	$hater = $_;
	my $hatersQuery = $dbh->prepare("SELECT reply_to_author, sum(post_depth) / COUNT(*) as angry, Count(*) as replies FROM ishdata WHERE author = '$hater' AND root_post_id not in (select post_id from gamethreads) GROUP BY reply_to_author HAVING reply_to_author <> '' AND COUNT(*) > 15 AND sum(post_depth) / count(*) > 6 ORDER BY COUNT(*) DESC");
	$hatersQuery->execute();	
	while (my $resultHash = $hatersQuery->fetchrow_hashref()) {
		
		$hatee = $resultHash->{'reply_to_author'};
		
		$timesrepliedtohatee = $resultHash->{'replies'};
		$repliesfromhatee =  $dbh->selectrow_array("SELECT COUNT(*) FROM $dbTable WHERE author = '$hatee' AND reply_to_author = '$hater' AND root_post_id not in (select post_id from gamethreads)", undef, @params);
		
		$magnitude = $timesrepliedtohatee - $repliesfromhatee;
		
		print "$hater,$hatee,$magnitude\n";
		
	}


}



sub readDBconfig {

	$dbConfig = new Config::Simple();
	$dbConfig->read('database.conf');

	$dbHost = $dbConfig->param("dbhost");
	$dbName = $dbConfig->param("dbname");
	$dbTable = $dbConfig->param("dbtable");
	$dbUser = $dbConfig->param("dbuser");
	$dbPassword = $dbConfig->param("dbpasswd");
	$dbUsersTable = $dbConfig->param("dbusertable");

}
