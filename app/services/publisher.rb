
class Publisher
  def self.publish(tenant_name, message)
    channel_name = "channel_#{tenant_name}" # Generate a unique channel name based on tenant or context
    $redis.publish(channel_name, message.to_json)
  end
end
