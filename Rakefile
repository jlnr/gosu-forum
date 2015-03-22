task :create_upstream do
  sh "git remote add upstream https://github.com/Quit/mwForum.git"
end

task :merge_upstream do
  sh "git fetch upstream"
  sh "git checkout master"
  sh "git merge upstream/master"
end
