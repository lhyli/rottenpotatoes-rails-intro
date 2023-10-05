class Movie < ActiveRecord::Base
  @all_ratings = ['G','PG','PG-13','R']
  
  def self.with_ratings(ratings_list)
    if ratings_list.nil?||ratings_list.empty?
      all
    else
      where(rating: ratings_list)
    end
  end
  
  def self.all_ratings
    return @all_ratings
  end

end
