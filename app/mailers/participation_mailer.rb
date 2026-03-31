class ParticipationMailer < ApplicationMailer
  def pick_reminder(user, week)
    @week = week
    @season = week.season
    mail(to: user.email, subject: "It's almost time for Survivor!")
  end
end
