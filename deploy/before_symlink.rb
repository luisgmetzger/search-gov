rails_env = new_resource.environment["RAILS_ENV"]

# Make sure the DB exists before doing anything else
dgsearch_rails_database :usasearch do
  create_dir release_path
  user 'search'
  group 'www-data'
end

# JavaScript dependency management will be moved to usasearch-cookbooks in https://cm-jira.usa.gov/browse/SRCH-3631
execute 'Install JavaScript dependencies and pre-compile assets' do
  cwd release_path
  environment NODE_ENV: 'production'
  command "sudo su search -c 'yarn install --production && RAILS_ENV=#{rails_env} bundle exec rake assets:precompile'"
end

# A very small subset of the assets need to be available
# without digest fingerprints in their filenames - assets
# that live "in the wild" and can't be updated whenever
# our asset fingerprints change.
run <<COMPILE
  cd #{release_path}/public/assets && \
  for js in sayt_loader_libs sayt_loader stats; do cp ${js}-*.js ${js}.js && cp ${js}-*.js.gz ${js}.js.gz; done && \
  for css in sayt; do cp ${css}-*.css ${css}.css && cp ${css}-*.css.gz ${css}.css.gz; done && \
  for png in bootstrap/glyphicons-halflings bootstrap/glyphicons-halflings-white; do cp ${png}-*.png ${png}.png; done && \
  find . -type f -perm 600 | xargs --no-run-if-empty chmod 644
COMPILE
