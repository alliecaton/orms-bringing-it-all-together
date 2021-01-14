class Dog 

    attr_accessor :id, :name, :breed

    def initialize(hash)
        hash.each do |key,value|
            self.send(("#{key}="), value)
        end
    end 

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY, 
                name TEXT, 
                breed TEXT
            );
        SQL
        DB[:conn].execute(sql)
    end 

    def self.drop_table 
        sql= <<-SQL
            DROP TABLE IF EXISTS dogs;
        SQL
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else 
        sql= <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?,?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)[0]
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
        end
    end 

    def self.create(hash)   
        dog = Dog.new(hash)
        dog.save 
        dog
    end 

    def self.new_from_db(array)
        dog = Dog.new(id: array[0], name: array[1], breed: array[2])
    end

    def self.find_by_id(id)
        sql = <<-sql
            SELECT * 
            FROM dogs 
            WHERE id = ?
        sql
        array = DB[:conn].execute(sql, id)[0]
        self.new_from_db(array)
    end

    def self.find_or_create_by(hash)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
        if !dog.empty?
            dog_info = dog[0]
            new_dog = Dog.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
        else 
            new_dog = self.create(hash)
        end
    end

    def self.find_by_name(name)
        sql = <<-sql
        SELECT * 
        FROM dogs 
        WHERE name = ?
    sql
    array = DB[:conn].execute(sql, name)[0]
    self.new_from_db(array)
    end

    def update 
        sql= <<-sql
            UPDATE dogs 
            SET name = ?, breed = ?
        sql
        DB[:conn].execute(sql, self.name, self.breed)
    end     

end 