class CreateScoringEventTypes < ActiveRecord::Migration[7.2]
  def up
    create_table :scoring_event_types do |t|
      t.string  :key,          null: false
      t.string  :label,        null: false
      t.integer :points,       null: false, default: 0
      t.boolean :is_elimination, null: false, default: false
      t.boolean :is_winner,      null: false, default: false
      t.timestamps
    end

    add_index :scoring_event_types, :key, unique: true

    # Seed all existing event types
    types = [
      { key: "survived_week",       label: "Survived the Week",               points:  1 },
      { key: "right_vote_premerge", label: "Right Vote (Pre-Merge)",          points:  1 },
      { key: "right_vote_postmerge",label: "Right Vote (Post-Merge)",         points:  2 },
      { key: "reward_1st",          label: "Won Reward (1st)",                points:  2 },
      { key: "reward_2nd",          label: "Won Reward (2nd)",                points:  1 },
      { key: "team_immunity_1st",   label: "Team Immunity (1st)",             points:  2 },
      { key: "team_immunity_2nd",   label: "Team Immunity (2nd)",             points:  1 },
      { key: "found_idol",          label: "Found Idol/Advantage",            points:  3 },
      { key: "journey",             label: "Went on Journey",                 points:  1 },
      { key: "shot_in_dark",        label: "Shot in the Dark",                points:  5 },
      { key: "idol_play",           label: "Played Idol Successfully",        points:  5 },
      { key: "advantage_play",      label: "Played Advantage Successfully",   points:  3 },
      { key: "voted_out",           label: "Voted Out",                       points: -3, is_elimination: true },
      { key: "voted_out_with_idol", label: "Voted Out with Idol/Advantage",   points: -2, is_elimination: true },
      { key: "lost_vote",           label: "Lost Their Vote",                 points: -1 },
      { key: "quit",                label: "Quit",                            points: -5, is_elimination: true },
      { key: "gained_advantage",    label: "Gained Advantage",                points:  2 },
      { key: "individual_immunity", label: "Won Individual Immunity",         points:  3 },
      { key: "med_evac",            label: "Medical Evacuation",              points: -3, is_elimination: true },
      { key: "taken_on_reward",     label: "Taken on Reward",                 points:  1 },
      { key: "quote_of_week",       label: "Quote of the Week",               points:  2 },
      { key: "survivor_record",     label: "Set Survivor Record",             points:  5 },
      { key: "potw_top3",           label: "Player of the Week Top 3",        points:  2 },
      { key: "ftc_won_fire",        label: "FTC: Won Fire",                   points:  3 },
      { key: "ftc_lost_fire",       label: "FTC: Lost Fire",                  points: -3 },
      { key: "ftc_brought",         label: "FTC: Brought to Final",           points:  1 },
      { key: "ftc_winner",          label: "FTC: Winner",                     points:  2, is_winner: true },
      { key: "ftc_survived_final5", label: "FTC: Survived Final 5",           points:  1 },
    ]

    now = Time.current
    types.each do |t|
      execute <<~SQL
        INSERT INTO scoring_event_types (key, label, points, is_elimination, is_winner, created_at, updated_at)
        VALUES (#{quote(t[:key])}, #{quote(t[:label])}, #{t[:points]}, #{t[:is_elimination] ? 1 : 0}, #{t[:is_winner] ? 1 : 0}, '#{now}', '#{now}')
      SQL
    end
  end

  def down
    drop_table :scoring_event_types
  end
end
