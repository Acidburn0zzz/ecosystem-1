class IngestStats
  def self.from_file(filename)
    self.run JSON.parse File.read(filename)
  end

  def self.run(data)
    ParsedLog.transaction do

      ParsedLog.bulk_insert do |t|
        data.fetch("files").each do |filename|
          t.add(filename: filename, parsed_at: data.fetch("ran_at"))
        end
      end

      Stat.bulk_insert do |t|
        data.fetch("stats").each do |time, name_map|
          name_map.each do |name, value_map|
            value_map.each do |value, count|
              t.add(date: time, key: name, value: value, count: count)
            end
          end
        end
      end

    end
  end
end