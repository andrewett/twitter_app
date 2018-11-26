class EpicenterController < ApplicationController
  before_action :authenticate_user!, except: [:show_user, :tag_tweets]

  def feed
    @tweet = Tweet.new
    @following_tweets = following_tweets
    @following_count = current_user.following.count
    @followers_count = User.all.select { |user| user.following.include?(current_user.id) }.count
    @trending = Tag.all.sort_by { |tag| tag.tweets.count }.reverse.take(3)
    @top_tweeter = User.all.sort_by { |user| user.tweets.count }.reverse[0]
  end

  def following_tweets
    Tweet.order(created_at: :desc).select do |tweet|
      current_user.following.include?(tweet.user_id) || current_user.id == tweet.user_id
    end
  end

  def show_user
    set_user
    @following_count = @user.following.count
    @followers_count = followers.count
  end

  def now_following
    current_user.following.push(params[:id].to_i)
    save_and_redirect
  end

  def unfollow
    current_user.following.delete(params[:id].to_i)
    save_and_redirect
  end

  def tag_tweets
    @tag = Tag.find(params[:id])
  end

  def all_users
    @users = User.order(:username)
  end

  def following
    set_user
    @users = User.all.select { |user| @user.following.include?(user.id) }
  end

  def followers
    set_user
    @users = User.all.select { |user| user.following.include?(@user.id) }
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def save_and_redirect
    current_user.save
    redirect_to show_user_path(id: params[:id])
  end
end
