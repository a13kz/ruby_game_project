require 'ruby2d'
set title: "SPACE EVADERS"


@width = 1000.0
@height = 800.0
set width: @width
set height: @height

@player_size = 25
@middle_x = @width/2
@middle_y = @height/2
@health = 10

@astroids = []
@last_astroid_frame = 0
@astroid_amount = 10
@astroid_size = 20
@astroid_amount_total = 0
@astroid_speed = 5
@last_total_astroid = 0

@bullets = []
@last_bullet_frame = 0
@bullet_amount = 10 
@bullet_size = 12.5
@bullet_speed = 7.5

@power_ups = []
@power = false

@coins = []
@coin_amount = 0
@max_coins = 10
@coin_counter = 0

@active = false
@start = true
@stop = false

@current_collisions = []
@scores = File.readlines("Highscores")

@difficulty_interval = 25

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

class Counter
    attr_accessor :counter
    def initialize()
        @counter = Text.new("Points:0",size: 40, y: Window.height-75, x: 0, color: 'blue')
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

class Power_up
    attr_accessor :square, :destroyed
    def initialize(x,y)
        @destroyed = false
        @square = Square.new(
            x: x,
            y: y,
            size: 4,
            color: 'red'
        )
    end
end

class Start_screen
    attr_accessor :text, :title, :info
    def initialize()
        @title = Text.new('SPACE EVADERS', size: 72, y: 40, color: 'white')
        @info = Text.new('Press space to start', size: 30, y: 425, color: 'white')
        @text = Text.new(
        "Start",
        size: 60
        )
        leaderboard = File.readlines("Highscores")
        leaderboard.each do |score|
            Text.new(
                score,
                size: 10
            )
        end
        @leaderboard = Text.new(File.readlines("Highscores"),size: 20) 
        @title.x = (Window.width - @title.width) / 2
        @info.x = (Window.width - @info.width) / 2
        @text.x = (Window.width - @text.width) / 2
        @text.y = (Window.height - @text.height) / 2
    end
end

class Menu
    attr_accessor :square, :title

    def initialize()

        @square = Square.new(
            x: 10,
            y: 10,
            size: 100
            )
    end
end

class End
    attr_accessor :text
    def initialize()
        @text = Text.new(
        "GAME OVER YOU GOT:0",
        size: 60
        )
        @text.x = (Window.width - @text.width) / 2
        @text.y = (Window.height - @text.height) / 2
    end
end



def stop()
    @active = false
    @stop = true
    pos = find_index(@scores,@coin_counter)
    if pos == false
        @end_text = End.new()
        @end_text.text.text = "GAME OVER YOU GOT:#{@coin_counter}".to_s
    else
        @end_text = End.new()
        @end_text.text.text = "GAME OVER YOU GOT:#{@coin_counter}".to_s
        @scores.insert(pos,@coin_counter)
        @scores.pop        
        fil = File.open("Highscores", "w")
        fil.puts @scores
        fil.close

    end
end

def find_index(arr,score)
    i = arr.length
    if arr[i].to_i >= score
        return false
    end
    while i > 0
        if arr[i].to_i >= score
            return i+1
        end
        i -=1
    end
    return i
end
    @start_screen = Start_screen.new()
def start()

end

def hurt(astroid)
    astroid.destroyed = true
    @health-=1
    @bar.bar.width-=10
end

def spawn_astroid()
    if @last_astroid_frame + @astroid_amount < Window.frames
        @astroid_amount_total +=1
        x = -1
        y = rand(0..@height)
        @astroids.push(Astroid.new(x,y,@astroid_size))
        @last_astroid_frame = Window.frames
    end
end

def spawn_bullet(x,y)
    if @last_bullet_frame + @bullet_amount < Window.frames
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
def spawn_power_up()
    x = rand(0..width)
    y = rand(0..height)
    @power_ups.push(Power_up.new(x,y))
end


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

@menu_visual = Menu.new
@menu_visual.square.remove
#@menu_visual.title.remove

def menu()
    puts @active    
    if @menu
        @active = false
        @menu_visual.square.add
        #@menu_visual.title.add
    else
        @menu_visual.square.remove
        #@menu_visual.title.remove
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
        astroid.move(@astroid_speed)
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
@last_total_astroid = 0
def check_difficulty()
    if @last_total_astroid + @difficulty_interval < @astroid_amount_total
        @astroid_speed+=1
        @last_total_astroid = @astroid_amount_total 
    end
end

@counter = Counter.new()


def check_coins()
    @coins = @coins.select do |coin|
        !coin.destroyed
    end
    @coins.each do |coin|
        if collision_check(@player,coin,@player_size,20)
            coin.square.remove
            @coin_counter+=1
            @counter.counter.remove
            @counter.counter.text = "Points:#{@coin_counter}".to_s
            @counter.counter.add
            coin.destroyed = true
        end
    end

end
def check_power_ups()
    @power_ups = @power_ups.select do |power_up|
        !power_up.destroyed
    end
    @power_ups.each do |power_up|
        if collision_check(@player,power_up,@player_size,20)
            power_up.square.remove
            power_up.destroyed = true
        end
    end

end

@player = Player.new(10,10,@player_size)
@bar = Healthbar.new(100)

on :key_down do |event|
    if !@start && !@stop
        case event.key
        when 'escape'
            puts @menu
            @menu = !@menu
            menu()
        end
    end
end

on :key_held do |event|
    if @active && !@start
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


on :key_held do |event|
    if @start
        case event.key
        when 'space'
            @active = true
            @start = false
            @start_screen.title.remove
            @start_screen.text.remove
            @start_screen.info.remove
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
        check_difficulty()
        spawn_astroid()
        check_bullets()
        check_astroids()
        check_coins()
        check_power_ups()
        border_check(@player)

        if @coins.length < @max_coins
            spawn_coin()
        end
        if @power_ups.length < @max_coins
            spawn_power_up()
        end
        if @health <= 0
            stop()
        end
    elsif @start
        start()
    end
end

show
