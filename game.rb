require 'ruby2d'
set title: "game"


@width = 500.0
@height = 500.0
set width: @width
set height: @height

@damage_astroids = []

@player_size = 20
@middle_x = @width/2
@middle_y = @height/2
@health = 10

@astroids = []
@last_astoid_frame = 0
@astorid_amount = 15
@astroid_size = 20

@coins = []
@coin_amount = 0
@max_coins = 10

class Player
    attr_accessor :x, :y, :square, :speed
        def initialize(x,y,size)
            @speed = 5
            @square = Square.new(
                color: 'red',
                x: x,
                y: y,
                size: size,
            )
        end
end

class Coin
    attr_accessor :x, :y, :size
    def initialize(x,y)
        @coin = Square.new(
        x: x,
        y: y,
        size: 20,
        color:'yellow'
    )
    end
end

class Healthbar
    attr_accessor :bar, :width
    def initialize(width)
        @health = Rectangle.new(
        x:0,
        y:0,
        width:100,
        height:10,
        color:'white'
        )
        @bar = Rectangle.new(
        x:0,
        y:0,
        width:100,
        height:10,
        color:'red'
        )
    end

end

class Astroid
    attr_accessor :x, :y, :size, :square, :destroyed
    
    def initialize(x, y, size)
    @destroyed = false
      @square = Square.new(
      x: x,
      y: y,
      size: size
      )
    end
    
    def move(speed)
        @square.x +=speed
    end
    #def collision_check(player)
    #    square_dist = @square.size/2
    #        if player.y >= @square.y-square_dist and player.y <= @square.y+square_dist && player.x >= @square.x-square_dist and player.x <= @square.x+square_dist
    #            @square.remove
    #        end
    #end


end

def stop()
    puts "Bättre lycka nästa gång"
    exit()
end

def hurt(astroid)
    astroid.destroyed = true
    @health-=1
    @bar.bar.width-=10
end

def spawn_astroid()
    if @last_astoid_frame + @astorid_amount < Window.frames
        x = -1
        y = rand(0..@height)
        @astroids.push(Astroid.new(x,y,@astroid_size))
        @last_astoid_frame = Window.frames
    end
end

def spawn_coin()
    x = rand(0..width)
    y = rand(0..height)
    @coins.push(Coin.new(x,y))
    @coin_amount+=1
end
@current_collisions = []
def border_check(player)
    distance = @player_size
    if player.square.x+distance >= @width
        if !@current_collisions.include?("right")
            @current_collisions << "right"
        end
    else
        i = 0
        while i <@current_collisions.length
            if @current_collisions[i] == "right"
                   @current_collisions.delete_at(i)
            end
            i+=1
        end
    end
    if player.square.x <= 0
        if !@current_collisions.include?("left")
            @current_collisions << "left"
        end
    else
        i = 0
        while i <@current_collisions.length
            if @current_collisions[i] == "left"
                @current_collisions.delete_at(i)
            end
            i+=1
        end
    end
        if player.square.y+distance >= @height
            if !@current_collisions.include?("down")
                @current_collisions << "down"
            end
    else
        i = 0
        while i <@current_collisions.length
            if @current_collisions[i] == "down"
                   @current_collisions.delete_at(i)
            end
            i+=1
        end
    end
    if player.square.y <= 0
        if !@current_collisions.include?("up")
            i = 0
            @current_collisions << "up"
            while i <@current_collisions.length
                if@current_collisions[i] == "down"
                       @current_collisions.delete_at(i)
                end
                i+=1
            end
        end
    else
        i = 0
        while i <@current_collisions.length
            if @current_collisions[i] == "up"
                   @current_collisions.delete_at(i)
            end
            i+=1
        end
    end
    #@current_collisions.clear()
end

def collision_check(obj1,obj2, obj1_size,obj2_size)
    if obj1.square.x - obj1_size <= obj2.square.x and obj1.square.x + obj1_size >= obj2.square.x
        if obj1.square.y - obj1_size <= obj2.square.y and obj1.square.y + obj1_size >= obj2.square.y
            return true
        end
    end
    return false
end


#p @player
@player = Player.new(10,10,10)
@bar = Healthbar.new(100)



on :key_held do |event|
    case event.key
    
    when 'up'
        if !@current_collisions.include?("up")
            @player.square.y -= @player.speed
        end
    when 'down' 
        if !@current_collisions.include?("down")
            @player.square.y += @player.speed
        end
    when 'left'
        if !@current_collisions.include?("left")
            @player.square.x -= @player.speed
        end
    when 'right' 
        if !@current_collisions.include?("right")
            @player.square.x += @player.speed
        end
    end
end

def check_astroids()
    @astroids.each do |astroid|
        astroid.move(5)
        if collision_check(@player,astroid,@player_size,@astroid_size)
            hurt(astroid)
            astroid.square.remove
        end
    end
    @astroids = @astroids.select do |astroid|
        astroid.square.x >= 0 && 
        astroid.square.x <= @width && 
        astroid.square.y >= 0 && 
        astroid.square.y <= @height &&
        !astroid.destroyed

    end
end
def check_coins()

end

update do
    spawn_astroid()
    check_astroids()
    check_coins()
    border_check(@player)
    if @coin_amount < @max_coins
        spawn_coin()
    end
    if @health <= 0
        stop()
    end
    

end

show
