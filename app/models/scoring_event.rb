class ScoringEvent < ApplicationRecord
  belongs_to :contestant
  belongs_to :week

  validate :event_type_must_exist

  scope :for_week,       ->(week)       { where(week: week) }
  scope :for_contestant, ->(contestant) { where(contestant: contestant) }

  after_create  :sync_contestant_status
  after_destroy :sync_contestant_status

  def event_type_record
    @event_type_record ||= ScoringEventType.find_by(key: event_type)
  end

  def point_value
    event_type_record&.points || 0
  end

  def label
    event_type_record&.label || event_type.to_s.humanize
  end

  def self.points_for_contestant_week(contestant_id, week_id)
    where(contestant_id: contestant_id, week_id: week_id).sum { |e| e.point_value }
  end

  private

  def event_type_must_exist
    return if event_type.blank?
    unless ScoringEventType.exists?(key: event_type)
      errors.add(:event_type, "is not a recognized event type")
    end
  end

  def sync_contestant_status
    c = contestant
    all_events = c.scoring_events.includes(:week)
    types_used = all_events.map(&:event_type)

    winner_keys      = ScoringEventType.where(is_winner: true).pluck(:key)
    elimination_keys = ScoringEventType.where(is_elimination: true).pluck(:key)

    if types_used.any? { |t| winner_keys.include?(t) }
      c.update_columns(status: Contestant.statuses[:winner], eliminated_week: nil)
    elsif (elim_event = all_events.find { |e| elimination_keys.include?(e.event_type) })
      c.update_columns(status: Contestant.statuses[:eliminated], eliminated_week: elim_event.week.number)
    else
      c.update_columns(status: Contestant.statuses[:active], eliminated_week: nil)
    end
  end
end
