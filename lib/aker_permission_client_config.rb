module AkerPermissionClientConfig
  def check_permissions?(role, user_email)
  	mapping = {read: :r, write: :w, execute: :x}  	
  	permissions.any? do |permission|
  	  (permission.permitted == user_email) && (permission.send(mapping[role]))
  	end
  end

  def self.included(base)
  	base.instance_eval do
	  def self.authorize!(role, resource, user_email)
	  	raise CanCan::AccessDenied.new("Not authorized!", role, resource) unless user_email
		if resource.kind_of? String
		  instance = where(id: resource).includes(:permissions).first
		else
		  instance = resource
		end
		unless instance.check_permissions?(role, user_email)
		  raise CanCan::AccessDenied.new("Not authorised to perform #{role} on #{instance.class.to_s} #{instance.id}", 
		  	role, instance)
		end
	  end
	end
  end
end