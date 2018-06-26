class Event < ActiveRecord::Base
  belongs_to :user
  has_many :users, through: :user_event, source: :events

  geocoded_by :location
  after_validation :geocode
  before_save :validate_time

  validates :description, :date, :location, presence: true, length: { minimum: 10, maximum: 100}
  validates :start_time, :end_time, presence: true
  validates  :title, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 5, maximum: 25}
  validates_date :date, :on_or_after => lambda { Date.tomorrow }, :on_or_after_message => "cannot be past or today's date"

end