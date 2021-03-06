class DeactivationsController < ApplicationController
  class FailedToActivate < StandardError; end
  class CannotDeactivateRepoWithSubscription < StandardError; end

  respond_to :json

  before_action :check_for_subscription

  def create
    if activator.deactivate
      analytics.track_deactivated(repo)
      render json: repo, status: :created
    else
      report_exception(
        FailedToActivate.new('Failed to deactivate repo'),
        user_id: current_user.id, repo_id: params[:repo_id]
      )
      head 502
    end
  end

  private

  def activator
    RepoActivator.new(repo: repo, github_token: github_token)
  end

  def repo
    @repo ||= current_user.repos.find(params[:repo_id])
  end

  def github_token
    session.fetch(:github_token)
  end

  def check_for_subscription
    if repo.subscription
      raise CannotDeactivateRepoWithSubscription
    end
  end
end
