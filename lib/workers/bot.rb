class RunBot
  @queue = "bots"

  def self.perform(id)
    puts id
  end
end
