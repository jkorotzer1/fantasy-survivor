class AddEmojisToScoringEventTypeLabels < ActiveRecord::Migration[7.2]
  LABELS = {
    "survived_week"        => "🏝️ Survived the Week",
    "right_vote_premerge"  => "🗳️ Right Vote (Pre-Merge)",
    "right_vote_postmerge" => "🗳️ Right Vote (Post-Merge)",
    "reward_1st"           => "🏆 Won Reward (1st)",
    "reward_2nd"           => "🎁 Won Reward (2nd)",
    "team_immunity_1st"    => "🛡️ Team Immunity (1st)",
    "team_immunity_2nd"    => "🛡️ Team Immunity (2nd)",
    "found_idol"           => "🗿 Found Idol/Advantage",
    "journey"              => "⛵ Went on Journey",
    "shot_in_dark"         => "🎲 Shot in the Dark",
    "idol_play"            => "⚡ Played Idol Successfully",
    "advantage_play"       => "🃏 Played Advantage Successfully",
    "voted_out"            => "🪦 Voted Out",
    "voted_out_with_idol"  => "🤦 Voted Out with Idol/Advantage",
    "lost_vote"            => "🚫 Lost Their Vote",
    "quit"                 => "🚪 Quit",
    "gained_advantage"     => "🎴 Gained Advantage",
    "individual_immunity"  => "🏅 Won Individual Immunity",
    "med_evac"             => "🚑 Medical Evacuation",
    "taken_on_reward"      => "🎟️ Taken on Reward",
    "quote_of_week"        => "💬 Quote of the Week",
    "survivor_record"      => "📜 Set Survivor Record",
    "potw_top3"            => "⭐ Player of the Week Top 3",
    "ftc_won_fire"         => "🔥 FTC: Won Fire",
    "ftc_lost_fire"        => "💨 FTC: Lost Fire",
    "ftc_brought"          => "🤝 FTC: Brought to Final",
    "ftc_winner"           => "👑 FTC: Winner",
    "ftc_survived_final5"  => "🖐️ FTC: Survived Final 5",
  }.freeze

  def up
    LABELS.each do |key, label|
      execute "UPDATE scoring_event_types SET label = #{quote(label)} WHERE key = #{quote(key)}"
    end
  end

  def down
    # Revert to labels without emojis
    originals = {
      "survived_week"        => "Survived the Week",
      "right_vote_premerge"  => "Right Vote (Pre-Merge)",
      "right_vote_postmerge" => "Right Vote (Post-Merge)",
      "reward_1st"           => "Won Reward (1st)",
      "reward_2nd"           => "Won Reward (2nd)",
      "team_immunity_1st"    => "Team Immunity (1st)",
      "team_immunity_2nd"    => "Team Immunity (2nd)",
      "found_idol"           => "Found Idol/Advantage",
      "journey"              => "Went on Journey",
      "shot_in_dark"         => "Shot in the Dark",
      "idol_play"            => "Played Idol Successfully",
      "advantage_play"       => "Played Advantage Successfully",
      "voted_out"            => "Voted Out",
      "voted_out_with_idol"  => "Voted Out with Idol/Advantage",
      "lost_vote"            => "Lost Their Vote",
      "quit"                 => "Quit",
      "gained_advantage"     => "Gained Advantage",
      "individual_immunity"  => "Won Individual Immunity",
      "med_evac"             => "Medical Evacuation",
      "taken_on_reward"      => "Taken on Reward",
      "quote_of_week"        => "Quote of the Week",
      "survivor_record"      => "Set Survivor Record",
      "potw_top3"            => "Player of the Week Top 3",
      "ftc_won_fire"         => "FTC: Won Fire",
      "ftc_lost_fire"        => "FTC: Lost Fire",
      "ftc_brought"          => "FTC: Brought to Final",
      "ftc_winner"           => "FTC: Winner",
      "ftc_survived_final5"  => "FTC: Survived Final 5",
    }
    originals.each do |key, label|
      execute "UPDATE scoring_event_types SET label = #{quote(label)} WHERE key = #{quote(key)}"
    end
  end
end
