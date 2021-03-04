class Movie < ActiveRecord::Base
    def self.with_ratings(ratings_list)
        if ratings_list.empty?
            return Movie.all
        end
            return Movie.where(rating: ratings_list)
    end
end