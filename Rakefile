task :create_upstream do
  sh "git remote add upstream https://github.com/Quit/mwForum.git"
end

task :merge_upstream do
  sh "git fetch upstream"
  sh "git checkout master"
  sh "git merge upstream/master"
end

task :push_upstream do
  sh "git push origin master"
  # The awesome thing about GitHub allowing me to check out Subversion is how
  # easy it is to manage mwf and cgi-bin/mwf separately.
  sh "ssh $PROJECTS_HOST 'cd #{ENV['PROJECTS_ROOT']}/libgosu.org/mwf && svn upgrade && svn update'"
  sh "ssh $PROJECTS_HOST 'cd #{ENV['PROJECTS_ROOT']}/libgosu.org/cgi-bin/mwf && svn upgrade && svn update && perl upgrade.pl'"
end

task :default => [:merge_upstream, :push_upstream]
