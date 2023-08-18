# frozen_string_literal: true

class Cursor
  attr_reader :starting_after, :ending_before, :email, :limit

  def initialize(opts = {})
    @starting_after = opts[:starting_after]
    @ending_before = opts[:ending_before]
    @email = opts[:email]
    @limit = opts.fetch(:limit, 10).to_i
  end

  def call
    relation = User
    # combine and return filters into a single ActiveRecord relation
    filters.reduce(relation) do |rel, filter|
      send(filter, rel) || rel
    end
  end

  def filters
    %i[after_filter
       before_filter
       email_filter
       limit_filter]
  end

  def after_filter(collection)
    return if starting_after.blank?

    user_after = User.find starting_after
    collection.where('registered_at > ?', user_after.registered_at)
  end

  def before_filter(collection)
    return if ending_before.blank?

    user_before = User.find ending_before
    collection.where('registered_at < ?', user_before.registered_at)
  end

  def email_filter(collection)
    collection.where('email ilike ?', "%#{email}%") if email.present?
  end

  def limit_filter(collection)
    raise Errors::LimitRangeError unless limit.between?(1, 100)

    collection.limit(limit).order(registered_at: :desc, id: :asc)
  end
end
