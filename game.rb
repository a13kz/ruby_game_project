require 'ruby2d'
set title: "SPACE EVADERS"

# File: game.rb
# Author: Alexander Bohre
# Date: 2025-05-08
# Description: This program is a space game with the goal of collecting as many 'coins' as possible with the help of 'power_ups' while simultaneously avoding 'astorids'

@width = 1000.0
@height = 800.0
set width: @width
set height: @height

# Player
@player_size = 25
@middle_x = @width/2
@middle_y = @height/2
@health = 10
@current_collisions = []
@difficulty_interval = 25
@speed = 5

# Astroids
@astroids = []
@last_astroid_frame = 0
@astroid_amount = 10
@astroid_size = 20
@astroid_amount_total = 0
@astroid_speed = 5
@last_total_astroid = 0

# Bullets
@bullets = []
@last_bullet_frame = 0
@bullet_amount = 10 
@bullet_size = 12.5
@bullet_speed = 7.5

# Power ups
@power_ups = []
@power = false
@max_power_ups = 3
@max_power_up_time = 2.5
@start_time = 0

# Coins
@coins = []
@coin_amount = 0
@max_coins = 10
@coin_counter = 0

# Global booleans for the state of the program
@active = false
@start = true
@stop = false

# menu
@selected_element = 'resume'
@menu_alternatives = ['resume','menu','quit']
@selected_index = 0

# This class represents the player
# Its position can dynamically be changed
class Player
    attr_accessor :x, :y, :square
    # Initialize the player with position and size
        def initialize(x,y,size)
            @square = Square.new(
                color: 'red',
                x: x,
                y: y,
                size: size,
            )
        end
end

# This class represents coin
class Coin
    attr_accessor :x, :y, :size, :square, :destroyed
    # Initialize the coin with position
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

# This class represents the coin counter for what amount of coins that have been collected
# Its text can dynamically be changed
class Counter
    attr_accessor :counter
    # Initialize the counter
    def initialize()
        @counter = Text.new("Points:0",size: 40, y: Window.height-75, x: 0, color: 'blue')
    end
end

# This class represents the healthbar
# Its width can dynamically be changed
class Healthbar
    attr_accessor :bar, :width, :health

    # Initilizing the background and bar for the healthbar with width
    def initialize(width)
        @bar = Rectangle.new(
        x:0,
        y:0,
        width:100,
        height:10,
        color:'white'
        )
        @health = Rectangle.new(
        x:0,
        y:0,
        width:100,
        height:10,
        color:'red'
        )
    end

end

# This class represents the astroids
# It can move in the x-axis

class Astroid
    attr_accessor :x, :y, :size, :square, :destroyed
    
    # Initialize the astroid with position and size
    def initialize(x, y, size)
    @destroyed = false
    @square = Square.new(
    x: x,
    y: y,
    size: size
    )
    end
    
    # Moves astroid with speed in x-axis
    # Parameter: speed
    def move(speed)
        @square.x +=speed #moves astorid
    end
end

# This class represents the bullet
# It can move in x-axis

class Bullet
    attr_accessor :x, :y, :size, :square, :destroyed
    # Initialize the bullet with position and size
    def initialize(x, y, size)
    @destroyed = false
    @square = Square.new(
    x: x,
    y: y,
    size: size
    )
    end
    # Moves astroid with speed in x-axis
    # Parameter: speed
    def move(speed)
        @square.x -=speed
    end
end

# This class represents the Power_up
class Power_up
    attr_accessor :square, :destroyed
    # Initialize the Power_up with position
    def initialize(x,y)
        @destroyed = false
        @square = Square.new(
            x: x,
            y: y,
            size: 40,
            color: 'orange'
        )
    end
end

# This class represents the start screen
class Start_screen
    attr_accessor :text, :title, :info

    # Initialize the Start_screen
    def initialize()
        @title = Text.new('SPACE EVADERS', size: 72, y: 40, color: 'white')
        @info = Text.new('Press space to start', size: 30, y: 425, color: 'white')
        @text = Text.new(
        "Start",
        size: 60
        )
        @title.x = (Window.width - @title.width) / 2
        @info.x = (Window.width - @info.width) / 2
        @text.x = (Window.width - @text.width) / 2
        @text.y = (Window.height - @text.height) / 2
    end
end

# This class represents the menu
class Menu
    attr_accessor :resume, :menu_text, :quit
    # Initialize the menu
    def initialize()
        @resume = Text.new('Resume', size: 30, y: 425, color: 'white')
        @menu_text = Text.new('Menu',size: 30, y: 450)
        @quit = Text.new('Quit',size: 30, y: 475)
    end
end

# This class represents the End screen
class End
    attr_accessor :text
    # Initialize the End screen
    def initialize()
        @text = Text.new(
        "GAME OVER YOU GOT:0",
        size: 60
        )
        @text.x = (Window.width - @text.width) / 2
        @text.y = (Window.height - @text.height) / 2
    end
end

# Carries out the action selected when in the menu
# Parameters:
# - choice
# Returns: void
def choose(choice)
    if @selected_element == 'menu'
        @menu = false
        start()
        @active = false
        @menu_visual.resume.remove
        @menu_visual.menu_text.remove
        @menu_visual.quit.remove
    elsif @selected_element == 'quit'
        exit
    elsif @selected_element == 'resume'
        @active = true
        @menu = false
        @menu_visual.resume.remove
        @menu_visual.menu_text.remove
        @menu_visual.quit.remove
    end
end

# Stop carries out what will happen when the game is over
# Parameters:
# - void
# Returns: void
def stop()
    @active = false
    @stop = true
    @end_text = End.new() # New instance of class End
    @end_text.text.text = "GAME OVER YOU GOT:#{@coin_counter}".to_s # shows text of amount of coins collected in total
end


# Carries out the operations from when the game starts
# Parameters: Void
# Return: Void
def start()
    @counter.counter.text = "Points:0"
    @coin_counter = 0
    @last_total_astroid = 0
    @astroid_speed = 5
    @health = 10
    @bar.bar.remove
    @bar.health.remove
    @bar.health.width = 100
    @player.square.remove
    @player.square.y = 100
    @player.square.x = 100
    @hp = 100
    @astroids.each do |astroid|
        astroid.square.remove # remove grapic from each instance of Astorid in array @astorids
    end
    @power_ups.each do |power_up|
        power_up.square.remove # remove grapic from each instance of Power_up in array @power_ups
    end
    @coins.each do |coin|
        coin.square.remove # remove grapic from each instance of Coin in array @coins
    end
    # clear arrays of data
    @astroids = []
    @power_ups = []
    @coins = []
    @start = true
    @start_screen.title.add
    @start_screen.text.add
    @start_screen.info.add
end


# Calculates damage from collision with astroid and removes the astorid in the collision
# Parameters:
# - astroid: instance of the class Astorid
# Returns: Void
def hurt(astroid)
    astroid.destroyed = true
    @health-=1
    @bar.health.width-=10
end

# Instantiates class Astroid
# Parameters: Void
# Returns: Void
def spawn_astroid()
    # makes sure not to many astorids are in frame
    if @last_astroid_frame + @astroid_amount < Window.frames
        @astroid_amount_total +=1
        x = -1
        y = rand(0..@height)
        @astroids.push(Astroid.new(x,y,@astroid_size)) # adds new instance to Array
        @last_astroid_frame = Window.frames
    end
end

# Instantiates class Bullet
# Parameters: 
# - x: Integer for x-axis
# - y: Integer for y-axis
# Returns: Void

def spawn_bullet(x,y)
    # makes sure not to many bullets are in frame
    if @last_bullet_frame + @bullet_amount < Window.frames
        @bullets.push(Bullet.new(x,y,@bullet_size)) # adds new instance of Bullet to array
        @last_bullet_frame = Window.frames
    end
end

# Instantiates class Coin
# Parameters: Void
# Returns: Void
def spawn_coin()
    x = rand(0..width)
    y = rand(0..height)
    @coins.push(Coin.new(x,y)) # adds new instance of Coin to array
    @coin_amount+=1
end

# Instantiates class Power_up
# Parameters: Void
# Returns: Void
def spawn_power_up()
    x = rand(0..width)
    y = rand(0..height)
    @power_ups.push(Power_up.new(x,y)) # adds new instance of Coin to array
end

# Check if 'player' is not outside the width or height of the screen
# - player: instance of class 'Player'
# Returns: Void
def border_check(player)
    distance = @player_size
    if player.square.x+distance >= @width # check if against right wall
        if !@current_collisions.include?("right") # check if player previously has been against right wall
            @current_collisions << "right" # adds 'right' to array @current_collisions if it has not previously been against the wall
        end
    else
        i = 0
        while i <@current_collisions.length
            if @current_collisions[i] == "right"
                @current_collisions.delete_at(i) # remove 'right' from array if not against right wall
            end
            i+=1
        end
    end
    if player.square.x <= 0 # check if against right wall
        if !@current_collisions.include?("left") # check if player previously has been against right wall
            @current_collisions << "left" # adds 'left' to array @current_collisions if it has not previously been against the wall
        end
    else
        i = 0
        while i <@current_collisions.length
            if @current_collisions[i] == "left"
                @current_collisions.delete_at(i) # remove 'left' from array if not against right wall
            end
            i+=1
        end
    end
        if player.square.y+distance >= @height # check if against down wall
            if !@current_collisions.include?("down") # check if player previously has been against down wall
                @current_collisions << "down" # adds 'down' to array @current_collisions if it has not previously been against the wall
            end
        else
            i = 0
            while i <@current_collisions.length 
                if @current_collisions[i] == "down"
                    @current_collisions.delete_at(i) # remove 'down' from array if not against right wall
                end
                i+=1
            end
        end
    if player.square.y <= 0 # check if against upper wall
        if !@current_collisions.include?("up") # check if player previously has been against upper wall
            
            @current_collisions << "up" # adds 'up' to array @current_collisions if it has not previously been against the wall
        end
    else
        i = 0
        while i <@current_collisions.length
            if @current_collisions[i] == "up"
                @current_collisions.delete_at(i) # remove 'up' from array if not against right wall
            end
            i+=1
        end
    end
end


# Carries out the operations from when the game is paused
# Parameters: Void
# Return: Void
def menu()
    if @menu
        @active = false
        @menu_visual.resume.add
        @menu_visual.menu_text.add
        @menu_visual.quit.add
    else
        @menu_visual.resume.remove
        @menu_visual.menu_text.remove
        @menu_visual.quit.remove
        @active = true
    end
end

# Check if two objects are colliding
# Parameters:
# - obj1: instance of class
# - obj2: instance of class
# - obj1_size: Integer for the size of obj1
# - obj2_size: Integer for the size of obj1
# Returns: Void
def collision_check(obj1,obj2, obj1_size,obj2_size)
    if obj1.square.x - obj1_size <= obj2.square.x and obj1.square.x + obj1_size >= obj2.square.x # Check if x-coordinate of obj1 and obj2 are in range of eachothers size
        if obj1.square.y - obj1_size <= obj2.square.y and obj1.square.y + obj1_size >= obj2.square.y # Check if y-coordinate of obj1 and obj2 are in range of eachothers size
            return true
        end
    end
    return false
end

# Check if any instance of class Astorid have been in collision and what of its instances that exist.
# Parameters: Void
# Returns: Void
def check_astroids()

    @astroids.each do |astroid| # Check each @astorids element
        astroid.move(@astroid_speed) 
        if collision_check(@player,astroid,@player_size,@astroid_size) # check if astroid have collided with player
            hurt(astroid)
            astroid.square.remove
        end
        
        @bullets.each do |bullet| # Check each @bullets element
            if collision_check(bullet,astroid,@bullet_size,@astroid_size) # check if astroid have collided with player
                astroid.destroyed = true
                bullet.destroyed = true
                bullet.square.remove
                astroid.square.remove
            end
        end
    end

   
    @astroids = @astroids.select do |astroid| # Loop over @astorids array of instances of class Astorid and only select instances inside the confines and not with 'destroyed'
        astroid.square.x >= 0 && 
        astroid.square.x <= @width && 
        astroid.square.y >= 0 && 
        astroid.square.y <= @height &&
        !astroid.destroyed
    end

end

# Check if any instance of class Bullet have been in collision and what of its instances that exist.
# Parameters: Void
# Returns: Void
def check_bullets()
    @bullets.each do |bullet|
        bullet.move(@bullet_speed)
        if bullet.square.x < -10
            bullet.square.remove
        end
    end
    @bullets = @bullets.select do |bullet| # Loop over @bullets array of instances of class Astorid and only select instances inside the confines and not with 'destroyed'
        bullet.square.x >= -10 && 
        !bullet.destroyed
    end
end


# Check how far the game has gone on and adjust the difficulty based on it
# Parameters: Void
# Returns: Void
def check_difficulty()
    if @last_total_astroid + @difficulty_interval < @astroid_amount_total
        @astroid_speed+=1
        @last_total_astroid = @astroid_amount_total 
    end
end

# Check if any instance of class Coin have been in collision and what of its instances that exist.
# Parameters: Void
# Returns: Void
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

# Check if any instance of class Power_up have been in collision and what of its instances that exist.
# Parameters: Void
# Returns: Void
def check_power_ups()
    @power_ups = @power_ups.select do |power_up|
        !power_up.destroyed
    end
    @power_ups.each do |power_up|
        if collision_check(@player,power_up,@player_size,20)
            @start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
            @power_up = true
            power_up.square.remove
            power_up.destroyed = true
        end
    end
    if Process.clock_gettime(Process::CLOCK_MONOTONIC) - @start_time > @max_power_up_time # Calculating for how long the power up lasts
        @power_up = false
    end 

end
# Listens for escape presses and activates/deactivates menu accordingly
on :key_down do |event|
    if !@start && !@stop
        case event.key
        when 'escape'
            @menu = !@menu
            menu()
        end
    end
end

# Listens for key presses when inside menu
on :key_down do |event|
    if @menu
        case event.key
        when 'up'
            @selected_index -=1
            @selected_element = @menu_alternatives[@selected_index % @menu_alternatives.length] # choose @selected_element and wrap if index is outside range
        when 'down' 
            @selected_index +=1
            @selected_element = @menu_alternatives[@selected_index % @menu_alternatives.length] # choose @selected_element and wrap if index is outside range
        when 'return'
            choose(@selected_index)
        end
    end
end

# Listens for key presses and preforms actions on the player accordingly
on :key_held do |event|
    if @active && !@start
        case event.key
        when 'space'
            spawn_bullet(@player.square.x,@player.square.y)
        when 'up'
            if !@current_collisions.include?("up") # if not currently in colliding with upper wall
                @player.square.y -= @speed
            end
        when 'down' 
            if !@current_collisions.include?("down") # if not currently in colliding with down wall
                @player.square.y += @speed
            end
        when 'left'
            if !@current_collisions.include?("left") # if not currently in colliding with left wall
                @player.square.x -= @speed
            end
        when 'right' 
            if !@current_collisions.include?("right") # if not currently in colliding with right wall
                @player.square.x += @speed
            end
        end
    end
end

# Listens after spacebar to start game from start menu
on :key_up do |event|
    if @start
        case event.key
        when 'space'
            @active = true
            @start = false
            # removes and adds graphics
            @player.square.add
            @bar.bar.add
            @bar.health.add
            @start_screen.title.remove
            @start_screen.text.remove
            @start_screen.info.remove
        end
    end
end

# Instaniating classes
@start_screen = Start_screen.new()
@player = Player.new(1,1,@player_size)
@counter = Counter.new()
@bar = Healthbar.new(100)
@menu_visual = Menu.new

# Hiding menu visuals
@menu_visual.resume.remove
@menu_visual.menu_text.remove
@menu_visual.quit.remove


# update
update do
    # check which element is highlighted
    if @selected_element == 'resume' 
        @menu_visual.resume.color = 'red'
        @menu_visual.quit.color = 'white'
        @menu_visual.menu_text.color = 'white'
    elsif @selected_element == 'quit'
        @menu_visual.resume.color = 'white'
        @menu_visual.quit.color = 'red'
        @menu_visual.menu_text.color = 'white'
    elsif @selected_element == 'menu'
        @menu_visual.resume.color = 'white'
        @menu_visual.quit.color = 'white'
        @menu_visual.menu_text.color = 'red'
    end
    if @active
        # calls on functions
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
        if @power_ups.length < @max_power_ups
            spawn_power_up()
        end

        if @power_up
            @speed = 10
        else
            @speed = 5
        end

        if @health <= 0
            stop()
        end
    elsif @start
        start()
    end
end

show
