- Program 1
```cpp
  #include <iostream>
#include <vector>
#include <chrono>

#include <omp.h>

class Timer {
  public:
    void reset();
    double elapsed() const;
    void end();

  private:
    using Clock = std::chrono::high_resolution_clock;
    using Second = std::chrono::duration<double, std::ratio<1> >;
    std::chrono::time_point<Clock> curr{ Clock::now() };
};

void Timer::reset() {
    curr = Clock::now();
}

double Timer::elapsed() const {
    return std::chrono::duration_cast<Second>(Clock::now() - curr).count();
}

void Timer::end() {
    std::cout << "Took " << this->elapsed() << "s" << std::endl;
    this->reset();
}

void print_vector(std::vector<int> arr)
{
    for (int x : arr)
    {
        std::cout << x << ", ";
    }

    std::cout << std::endl;
}

std::vector<int> seq_bubble_sort(std::vector<int> arr)
{
    while (true)
    {
        bool sorted = true;
        for (int i = 0; i < arr.size() - 1; i++)
        {
            bool inOrder = (arr[i] <= arr[i + 1]);
            if (!inOrder)
            {
                int temp = arr[i];
                arr[i] = arr[i + 1];
                arr[i + 1] = temp;
            }
            sorted &= inOrder;
        }
        if (sorted) break;
    }
    return arr;
}

std::vector<int> par_bubble_sort( std::vector<int> arr ) {
    while (true) {
        int iter = 0;
        #pragma omp parallel for
        for (int i = 0; i < 2; i++) {

        }
    }
    return arr;
}

int main()
{
    Timer timer;
    int size = 1000;
    std::vector<int> arr(size);
    for (int i = 0; i < size; i++) {
        arr[i] = rand() % 100;
    }
    std::cout << "Ready" << std::endl;
    std::vector<int> sorted_arr = seq_bubble_sort(arr);
    timer.end();
}
```
