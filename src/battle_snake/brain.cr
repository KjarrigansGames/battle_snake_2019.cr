require "json"
require "./math"

module BattleSnake
  DIRECTIONS = {
    up: Point.new(0, -1),
    right: Point.new(1, 0),
    down: Point.new(0, 1),
    left: Point.new(-1, 0)
  }

  class Game
    JSON.mapping( id: String )

    def replay_link
      "https://play.battlesnake.io/games/#{self.id}"
    end
  end

  class Snake
    JSON.mapping(
      id: String,
      name: String,
      health: Int32,
      body: { type: Array(Point) }
    )

    def head
      body.first
    end

    def tail
      body.last
    end
  end

  class Board
    JSON.mapping(
      height: Int32,
      width: Int32,
      food: { type: Array(Point) },
      snakes: { type: Array(Snake) }
    )

    def initialize(@height, @width, @food, @snakes)
    end

    def nearest_food(point : Point)
      list = {} of Int32 => Array(Point)
      food.each do |pos|
        list[pos.distance_to(point)] ||= [] of Point
        list[pos.distance_to(point)] << pos
      end
      distance = list.keys.sort.first
      list[distance].sample
    end

    def blocked?(point : Point)
      return true if point.x < 0 || point.y < 0
      return true if point.x >= self.width || point.y >= self.height

      snakes.find do |snake|
        snake.body.find do |part|
          point == part
        end
      end
    end
  end

  class BattleField
    JSON.mapping(
      game: { type: Game },
      turn: Int32,
      board: { type: Board },
      you: { type: Snake }
    )

    def next_turn
      target = board.nearest_food(you.head)
      puts "Nearest Food: #{target}"

      direction = you.head.direction_of(target).find do |dir|
        !board.blocked?(you.head + DIRECTIONS[dir])
      end
      puts "Heading #{direction}"

      { move: direction }
    end
  end
end
