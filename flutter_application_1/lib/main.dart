import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SnakeGameState(),
      child: MaterialApp(
        title: 'Snake Game',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: SnakeGamePage(),
      ),
    );
  }
}

class SnakeGameState extends ChangeNotifier {
  static const int _rowCount = 20;
  static const int _columnCount = 20;
  List<Point> _snake = [Point(0, 0), Point(0, 1)];
  Point _food = Point(5, 5);
  String _direction = 'right';
  Timer? _timer;
  bool _isGameOver = false;

  List<Point> get snake => _snake;
  Point get food => _food;
  bool get isGameOver => _isGameOver;

  SnakeGameState() {
    _startGame();
  }

  void _startGame() {
    _snake = [Point(0, 0), Point(0, 1)];
    _direction = 'right';
    _isGameOver = false;
    _generateFood();
    _timer = Timer.periodic(Duration(milliseconds: 300), (timer) {
      _moveSnake();
    });
  }

  void _moveSnake() {
    if (_isGameOver) return;

    var newHead = _getNewHead();

    if (_checkCollision(newHead)) {
      _isGameOver = true;
      _timer?.cancel();
      notifyListeners();
      return;
    }

    _snake.add(newHead);

    if (newHead == _food) {
      _generateFood();
    } else {
      _snake.removeAt(0);
    }

    notifyListeners();
  }

  Point _getNewHead() {
    var currentHead = _snake.last;
    switch (_direction) {
      case 'up':
        return Point(currentHead.x, currentHead.y - 1);
      case 'down':
        return Point(currentHead.x, currentHead.y + 1);
      case 'left':
        return Point(currentHead.x - 1, currentHead.y);
      case 'right':
      default:
        return Point(currentHead.x + 1, currentHead.y);
    }
  }

  bool _checkCollision(Point point) {
    return point.x < 0 ||
        point.y < 0 ||
        point.x >= _columnCount ||
        point.y >= _rowCount ||
        _snake.contains(point);
  }

  void _generateFood() {
    _food = Point(
      _randomInt(0, _columnCount - 1),
      _randomInt(0, _rowCount - 1),
    );

    while (_snake.contains(_food)) {
      _food = Point(
        _randomInt(0, _columnCount - 1),
        _randomInt(0, _rowCount - 1),
      );
    }
  }

  int _randomInt(int min, int max) {
    return min + (max - min) * (DateTime.now().millisecondsSinceEpoch % 1000) ~/ 1000;
  }

  void changeDirection(String newDirection) {
    if (_isOppositeDirection(newDirection)) return;
    _direction = newDirection;
  }

  bool _isOppositeDirection(String newDirection) {
    if (_direction == 'up' && newDirection == 'down') return true;
    if (_direction == 'down' && newDirection == 'up') return true;
    if (_direction == 'left' && newDirection == 'right') return true;
    if (_direction == 'right' && newDirection == 'left') return true;
    return false;
  }

  void restartGame() {
    _startGame();
    notifyListeners();
  }
}

class SnakeGamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var gameState = context.watch<SnakeGameState>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: SnakeGameState._columnCount,
                    ),
                    itemBuilder: (context, index) {
                      final x = index % SnakeGameState._columnCount;
                      final y = index ~/ SnakeGameState._rowCount;
                      final point = Point(x, y);

                      final isSnake = gameState.snake.contains(point);
                      final isFood = gameState.food == point;

                      return Container(
                        margin: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: isSnake
                              ? Colors.green
                              : isFood
                                  ? Colors.red
                                  : Colors.white,
                        ),
                      );
                    },
                    itemCount:
                        SnakeGameState._rowCount * SnakeGameState._columnCount,
                  ),
                ),
              ),
            ),
          ),
          if (gameState.isGameOver)
            Text(
              'Game Over!',
              style: TextStyle(fontSize: 32, color: Colors.white),
            ),
          if (gameState.isGameOver)
            ElevatedButton(
              onPressed: gameState.restartGame,
              child: Text('Restart'),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  context,
                  icon: Icons.arrow_upward,
                  onPressed: () {
                    gameState.changeDirection('up');
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  context,
                  icon: Icons.arrow_back,
                  onPressed: () {
                    gameState.changeDirection('left');
                  },
                ),
                SizedBox(width: 50),
                _buildControlButton(
                  context,
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    gameState.changeDirection('right');
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  context,
                  icon: Icons.arrow_downward,
                  onPressed: () {
                    gameState.changeDirection('down');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(BuildContext context,
      {required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Icon(icon, color: Colors.white),
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(20),
        backgroundColor: Colors.green, 
      ),
    );
  }
}

class Point {
  final int x;
  final int y;

  Point(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
