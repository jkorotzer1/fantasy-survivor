class FixPreviousTribesEncoding < ActiveRecord::Migration[7.2]
  def up
    conn = ActiveRecord::Base.connection

    rows = conn.exec_query("SELECT id, previous_tribes FROM contestants WHERE previous_tribes IS NOT NULL")

    rows.each do |row|
      id  = row["id"]
      raw = row["previous_tribes"]
      next if raw.nil?

      outer = JSON.parse(raw) rescue nil
      next unless outer

      # Entries may be plain strings or string-encoded JSON — unwrap everything.
      entries = outer.is_a?(Array) ? outer : [outer]

      normalized = entries.flat_map do |t|
        if t.is_a?(String)
          inner = JSON.parse(t) rescue nil
          if inner.nil?
            [{ "name" => t, "from" => nil, "to" => nil }]
          elsif inner.is_a?(Array)
            inner
          else
            [inner]
          end
        else
          [t]
        end
      end

      updated = normalized.map do |t|
        t.is_a?(Hash) && t["from"].nil? && t["to"].nil? ? t.merge("from" => 1, "to" => 3) : t
      end

      # Use single-quote escaping (SQLite style) to avoid serializer interference.
      new_json = JSON.generate(updated)
      escaped  = new_json.gsub("'", "''")
      conn.execute("UPDATE contestants SET previous_tribes = '#{escaped}' WHERE id = #{id.to_i}")
    end
  end

  def down
    # not reversible
  end
end
