require 'ruby2d'
set title: "game"

@width = 500.0
@height = 500.0
set width: @width
set height: @height

@speed = 5
@player_size = 20
@middle_x = @width/2
@middle_y = @height/2
@health = 3

@astroids = []
@last_astoid_frame = 0
@astorid_amount = 15
@astroid_size = 20

    
@player = Square.new(
    color: 'red',
    x: 40,
    y: 10,
    size: @player_size,
)


class Astroid
    attr_accessor :x, :y, :size

    def initialize(x, y, size)
    
      @square = Square.new(
      x: x,
      y: y,
      size: size
      )
    end
    def move(speed)
        @square.x += speed
    end

end

def collision_check(player,obj)
    obj_dist = obj.size/2
        if player.y >= obj.y-obj_dist and player.y <= obj.y+obj_dist && player.x >= obj.x-obj_dist and player.x <= obj.x+obj_dist
            obj.remove
        end
end

def hurt()
    @health-=1
end

def spawn_astroid()
    if @last_astoid_frame + @astorid_amount < Window.frames
        x = -
        y = rand(0..@height)
        @astroids.push(Astroid.new(x,y,@astroid_size))
        @last_astoid_frame = Window.frames
    end
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


on :key_held do |event|
    case event.key
    when 'up'
        @player.y -= @speed
        #p @player.y
    when 'down'
        @player.y += @speed
        #p @player.y
    when 'left'
        @player.x -= @speed
        #p @player.x
    when 'right'
        @player.x += @speed
        #p @player.x
    end
end


#@astroids.push(Astroid.new(-5,rand(0..@height)))

update do
    spawn_astroid()
    @astroids.each do |astroid|
        astroid.move(5)
        p astroid.square
        collision_check(@player,@square)
    end
end
show
