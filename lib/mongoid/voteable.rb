require 'mongoid'

module Mongoid
  module Voteable

    extend ActiveSupport::Concern

    included do
      field :votes, :type => Integer, :default => 0
      field :voters, :type => Array, :default => []
      field :voted, :type => Array, :default => []
    end

    def vote(amount, voter)
      id = voter_id(voter)
      unless voted?(id)
        self.inc :votes, amount.to_i
        self.push :voters, id
        voter.push :voted, self._id
      end
    end

    def voted?(voter)
      id = voter_id(voter)
      voters.include?(id)
    end

    def vote_count
      voters.count
    end

    module InstanceMethods

      def voted_by
        self.class.where(:_id => {"$in" => self.voters}).only(:_slugs, :avatar, :name, :_id)
      end

    end

    private

    def voter_id(voter)
      if voter.respond_to?(:_id)
        voter._id
      else
        voter
      end
    end
  end

end
