require 'ruby2d'
set title: "game"


@width = 500.0
@height = 500.0
set width: @width
set height: @height


@player_size = 20
@middle_x = @width/2
@middle_y = @height/2
@health = 3

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


#def collision_check(obj)
#    p obj.size
#    square_dist = obj.size/2
#        if @player.y >= obj.y-square_dist and @player.y <= obj.y+square_dist && @player.x >= obj.x-square_dist and @player.x <= obj.x+square_dist
#            obj.remove
#        end
#end

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

class Astroid
    attr_accessor :x, :y, :size, :square

    def initialize(x, y, size)
    
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



def hurt()
    @health-=1
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

def border_check(player)
    distance = @player_size
    p player.x
    if player.x+distance >= @width
        return true
    end
    if player.x <= 0
        return true
    end
        if player.y+distance >= @height
        return true
    end
    if player.y <= 0
        return true
    end
    return false
end

def collision_check(obj1,obj2, obj1_size,obj2_size)
    if obj1.square.x - obj1_size <= obj2.square.x and obj1.square.x + obj1_size >= obj2.square.x
        return true
    end
    return false
end


#p @player
@player = Player.new(10,10,10)



on :key_held do |event|
    case event.key
    when 'up'
        @player.square.y -= @player.speed
        #p @player.y
    when 'down'
        @player.square.y += @player.speed
        #p @player.y
    when 'left'
        @player.square.x -= @player.speed
        #p @player.x
    when 'right'
        @player.square.x += @player.speed
        #p @player.x
    end
end


#@astroids.push(Astroid.new(-5,rand(0..@height)))

update do
    spawn_astroid()
    if @coin_amount < @max_coins
        spawn_coin()
    end
    @astroids.each do |astroid|
        astroid.move(5)
        #astroid.collision_check(@player)
        if collision_check(@player,astroid,@player_size,@astroid_size)
            astroid.square.remove
        end
    end

end

show
