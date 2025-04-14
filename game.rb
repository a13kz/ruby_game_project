require 'ruby2d'
set title: "SPACE EVADERS"


@width = 1000.0
@height = 800.0
set width: @width
set height: @height

@damage_astroids = []

@player_size = 25
@middle_x = @width/2
@middle_y = @height/2
@health = 10

@astroids = []
@last_astoid_frame = 0
@astorid_amount = 15
@astroid_size = 20

@bullets = []
@last_bullet_frame = 0
@bullet_amount = 10
@bullet_size = 12.5
@bullet_speed = 5

@coins = []
@coin_amount = 0
@max_coins = 10
@coin_counter = 0

@active = true
@menu = false

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
    attr_accessor :x, :y, :size, :square, :destroyed
    def initialize(x,y)
    @destroyed = false
        @square = Square.new(
        x: x,
        y: y,
        size: 20,
        color:'yellow'
    )
    end
end

class Scoreboard
    attr_accessor :text, :board
    def initialize()
        @board = "Coins:"
        @text = Text.new(
        @board,
        x: 10, y: 10,
        size: 20,
        color: 'white',
        z: 10
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
end

class Bullet
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
        @square.x -=speed
    end
end

class Menu
    attr_accessor :square

    def initialize()
        @title = Text.new('SPACE EVADERS', size: 72, y: 40, color: 'red')
        @square = Square.new(
            x: 10,
            y: 10,
            size: 100
            )
        #@text.x = (Window.width - @text.width) / 2
    end
end

class Start
    

end
@coin_counter = 1
@scores = File.readlines("Highscores")




def stop()
    pos = find_index(@scores,@coin_counter)
    p pos
    p @scores[pos]
    if pos == false
        exit()
    end
    @scores.insert(pos,@coin_counter)
    @scores.pop
    fil = File.open("Highscores", "w")
    fil.puts @scores
    fil.close
    exit()
end

def find_index(arr,score)
    i = arr.length
    if arr[i].to_i >= score
        return false
    end
    while i > 0
        if arr[i].to_i >= score
            p arr[i]
            return i+1
        end
        i -=1
    end
    return i
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

def spawn_bullet(x,y)
    if @last_bullet_frame + @astorid_amount < Window.frames
        @bullets.push(Bullet.new(x,y,@bullet_size))
        @last_bullet_frame = Window.frames
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
end

def menu()
    @active = false
    puts @active
    menu = Menu.new

    if !@menu
        @active = true
    end
end

def collision_check(obj1,obj2, obj1_size,obj2_size)
    if obj1.square.x - obj1_size <= obj2.square.x and obj1.square.x + obj1_size >= obj2.square.x
        if obj1.square.y - obj1_size <= obj2.square.y and obj1.square.y + obj1_size >= obj2.square.y
            return true
        end
    end
    return false
end
def check_astroids()
    @astroids.each do |astroid|
        astroid.move(5)
        if collision_check(@player,astroid,@player_size,@astroid_size)
            hurt(astroid)
            astroid.square.remove
        end
        @bullets.each do |bullet|
            if collision_check(bullet,astroid,@bullet_size,@astroid_size)
                astroid.destroyed = true
                bullet.destroyed = true
                bullet.square.remove
                astroid.square.remove
            end
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

def check_bullets()
    @bullets.each do |bullet|
        bullet.move(@bullet_speed)
        if bullet.square.x < -10
            bullet.square.remove
        end
    end
    @bullets = @bullets.select do |bullet|
        bullet.square.x >= -10 && 
        !bullet.destroyed
    end
end

def check_coins()    
    
    @coins = @coins.select do |coin|
        !coin.destroyed
    end
    @coins.each do |coin|
        if collision_check(@player,coin,@player_size,20)
            coin.square.remove
            @coin_counter+=1
            coin.destroyed = true
        end
    end

end

@player = Player.new(10,10,@player_size)
@bar = Healthbar.new(100)

on :key_down do |event|
    case event.key
    when 'escape'
        puts @menu
        @menu = !@menu
        menu()
    end
end

on :key_held do |event|
    if @active
        case event.key
        when 'space'
            spawn_bullet(@player.square.x,@player.square.y)
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
end



update do
    if @active
        spawn_astroid()
        check_bullets()
        check_astroids()
        check_coins()
        border_check(@player)
        if @coins.length < @max_coins
            spawn_coin()
        end
        if @health <= 0
            stop()
        end
    end
end

show
