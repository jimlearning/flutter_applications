import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'counter_provider.g.dart';

@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
}

class MySingleton {
  // Static private instance of the class.
  static final MySingleton _instance = MySingleton._internal();

  // Factory constructor to return the single instance.
  factory MySingleton() {
    return _instance;
  }

  // Private named constructor.
  MySingleton._internal() {
    // Initialization logic can go here.
    print("MySingleton instance created.");
  }

  // Example method.
  void doSomething() {
    print("MySingleton is doing something.");
  }
}

// Usage:
void main() {
  MySingleton singleton1 = MySingleton();
  MySingleton singleton2 = MySingleton();

  print(identical(singleton1, singleton2)); // Output: true (same instance)

  singleton1.doSomething(); // Output: MySingleton is doing something.
}