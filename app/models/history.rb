class History < ActiveRecord::Base
	self.primary_keys = :aid, :uuid
end
