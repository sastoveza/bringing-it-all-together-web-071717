require 'pry'

class Dog

attr_accessor :name, :breed, :id

	def initialize(args)
		@id = nil
		args.each do |key, value| 
			self.send("#{key}=", value)
		end


		# @name = args [:name]
		# @breed = args [:breed]
	end

	def self.create_table
		sql = <<-SQL
			CREATE TABLE IF NOT EXISTS dogs (
				id INTEGER PRIMARY KEY,
					name TEXT,
					breed TEXT
		)
		SQL
		DB[:conn].execute(sql)
	end

	def self.drop_table
		sql = <<-SQL
			DROP TABLE dogs;
		SQL

		DB[:conn].execute(sql)
	end

	def save
		sql = <<-SQL
			INSERT INTO dogs (name, breed) 
			VALUES (?, ?)
		SQL
		DB[:conn].execute(sql, self.name, self.breed)
		self.id = DB[:conn].execute("SELECT last_insert_rowid() from dogs")[0][0]
		self
	end

	def self.create(args)
		dog = self.new(args)
		dog.save
	end

	def self.find_by_id(id)
		sql = <<-SQL
			SELECT * FROM dogs 
			WHERE id = ?
		SQL
		result = DB[:conn].execute(sql, id).first
		self.new_from_db(result)
	end

	def self.find_or_create_by(args)
		sql = <<-SQL
			SELECT * FROM dogs 
			WHERE name = ?
			AND breed = ?
			LIMIT 1
		SQL
		result = DB[:conn].execute(sql, args[:name], args[:breed]).first

			if result == nil || result.empty?
				self.create(args)
			else
				self.new_from_db(result)
			end
	end

	def self.new_from_db(row)
		dogs = Dog.new(id: row[0], name: row[1], breed: row[2])
	end

	def self.find_by_name(name)
		sql = <<-SQL
			SELECT * FROM dogs 
			WHERE name = ?
		SQL
		result = DB[:conn].execute(sql, name).first
		self.new_from_db(result)
	end

	def update
		sql = <<-SQL
			UPDATE dogs 
			SET name = ?, breed = ?
			WHERE id = ?
		SQL
		DB[:conn].execute(sql, self.name, self.breed, self.id)
	end



end
