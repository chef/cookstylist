module Cookstylist
  class Worker
    def self.perform(install_id)
      Cookstylist::Installation.new(install_id).repos.each do |repo_data|
        repo = Cookstylist::Repo.new(repo_data)
        puts "#{repo_data[:full_name]}:"
        Log.debug "  looks_like_cookbook?: #{repo.looks_like_cookbook?}"
        Log.debug "  fork?: #{repo.fork?}"
        next if repo.fork? || !repo.looks_like_cookbook?

        Log.debug "  Cloned to #{repo.clone}"

        Log.info "  Running Cookstyle against the local repo"

        # if there's already a branch pushed up for this release of cookstyle then
        # we've already run for this version and we can skip to the next repo
        next if repo.cookstyle_branch_exists?

        repo.checkout_cookstyle_branch
        corrector = Cookstylist::Corrector.new(repo.local_path)
        corrector.run
        Log.info "  #{corrector.summary["offense_count"]} offenses detected!"

        next unless repo.dirty?

        Log.info "  Opening pull request to upstream & closing old PRs"
        pr = Cookstylist::Pullrequest.new(repo, corrector)
        pr.open && pr.close_existing
      end
    end
  end
end