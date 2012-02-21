require 'fixjour'
require 'faker'

# Default point lies in staten island, default region outlines staten island

Fixjour :verify => false do
  define_builder(FeaturePoint) do |klass, overrides|
    if !overrides[:the_geom] && !overrides[:nil_the_geom]
      create_regions unless Region.any?
      result = ActiveRecord::Base.connection.execute "select ST_Centroid(the_geom) from regions where id=#{Region.last.id}"
      overrides[:the_geom] = result.first["st_centroid"]
    end
    
    overrides.send(:delete, :nil_the_geom)
    
    klass.new({}) # nothing required except the geom, default set above
  end
  
  define_builder(Vote) do |klass, overrides|
    klass.new({
      :supportable => new_feature_point
    })
  end
  
  define_builder(Comment) do |klass, overrides|
    klass.new({
      :commentable => new_feature_point,
      :comment => Faker::Lorem.sentences
    })
  end
  
  define_builder(Region) do |klass, overrides|
    klass.new({ })
  end
  
  define_builder(FeatureRegion) do |klass, overrides|
    
    klass.new({
      :feature => new_feature_point, 
      :region  => new_region
    })
  end
  
  define_builder(User) do |klass, overrides|
    klass.new({
      :email => Faker::Internet.email
    })
  end
  
  define_builder(Admin) do |klass, overrides|
    klass.new({
      :email => Faker::Internet.email, 
      :password => 'password', 
      :password_confirmation => 'password',
      :level => 100
    })
  end
  
  define_builder(LocationType) do |klass, overrides|
    klass.new({
      :name => Faker::Lorem.words(1)
    })
  end
  
  define_builder(FeatureLocationType) do |klass, overrides|
    klass.new({
      :feature => new_feature_point,
      :location_type => new_location_type
    })
  end
  
  define_builder(Page) do |klass, overrides|
    klass.new({
      :author => create_admin,
      :title => Faker::Lorem.sentence,
      :slug => Faker::Internet.domain_word,
      :status => Page::StatusOptions.first
    })
  end
  
  define_builder(ActivityItem) do |klass, overrides|
    klass.new({
      :subject => create_comment
    })
  end
  
  define_builder(Shapefile) do |klass, overrides|
    klass.new({
      :kind => Faker::Lorem.words,
      :name_field => Faker::Internet.domain_word,
      :data => File.new(Rails.root + 'spec/fixtures/nybb_10cav.zip')
    })
  end
end

# Fixjour.verify!