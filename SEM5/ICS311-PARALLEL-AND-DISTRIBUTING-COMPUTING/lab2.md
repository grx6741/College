# LAB 1

## Gowrish I 2022BCS0155

### Write OpenMP program in C to parallelize bubble sort

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <time.h>
#include <omp.h>

// #define LOG(x) printf("%d:[%s = %d]\n", __LINE__, #x, (x))
#define LOG(x)

#define thread_no omp_get_thread_num

#define ARR_SIZE 30000
#define MAX_THREADS omp_get_max_threads()

void swap(int* a, int* b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

void sequential_bubble_sort(int* arr, int size) {
    bool sorted = false;
    while (!sorted) {
        sorted = true;
        for (int j = 0; j < size - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                swap(arr + j, arr + j + 1);
                sorted = false;
            }
        }
    }
}

// Merge two sorted halves of an array
void merge_two_sorted(int* arr1, int* arr2, int s1, int s2) {
    int* temp = (int*)malloc((s1 + s2) * sizeof(int));
    int i = 0, j = 0, k = 0;

    while (i < s1 && j < s2) {
        if (arr1[i] <= arr2[j]) {
            temp[k++] = arr1[i++];
        } else {
            temp[k++] = arr2[j++];
        }
    }

    while (i < s1) temp[k++] = arr1[i++];
    while (j < s2) temp[k++] = arr2[j++];

    memcpy(arr1, temp, (s1 + s2) * sizeof(int));
    free(temp);
}

void parallel_bubble_sort(int* arr, int size) {
    int start, end;
    int chunk_size;
    int remaining;

    #pragma omp parallel shared(arr, size, remaining) private(start, end, chunk_size)
    {
        chunk_size = (size / MAX_THREADS);
        remaining  = (size % MAX_THREADS);
        start = thread_no() * chunk_size;

        if (thread_no() == MAX_THREADS - 1) {
            chunk_size += remaining;
        }

        end = start + chunk_size - 1;

        // printf("Thread ID %d\t: %d, [%d -- %d] \n", thread_no(), chunk_size, start, end);
        sequential_bubble_sort(arr + start, chunk_size);
    }

    // printf("---\n");

    // Merging sorted sections in pairs
    int thread_count = MAX_THREADS / 2;

    while (thread_count > 0) {
        #pragma omp parallel shared(arr, size, remaining) private(start, chunk_size)
        {
            int thread_id = thread_no();
            if (thread_id < thread_count) {
                chunk_size = (size / MAX_THREADS);
                remaining  = (size % MAX_THREADS);

                start = thread_id * 2 * chunk_size;

                if (thread_id == thread_count - 1) {
                    chunk_size += remaining;
                }

                // printf("Merging by Thread ID %d: [%d -- %d] with [%d -- %d]\n", thread_id, start, start + chunk_size - 1, start + chunk_size, start + 2 * chunk_size - 1);

                merge_two_sorted(arr + start, arr + start + chunk_size, chunk_size, chunk_size);
            }
        }

        thread_count /= 2;
    }
}

int main(int argc, char** argv) {
    srand(time(NULL));
    int* arr = malloc(sizeof(int) * ARR_SIZE);
    // printf("Unsorted Array\t: ");
    for (int i = 0; i < ARR_SIZE; i++) {
        arr[i] = rand() % 1000;
        // if (i % 10 == 0 && i != 0) printf(", ");
        // printf("%d ", arr[i]);
    }
    // printf("\n");

#ifdef PARALLEL
    parallel_bubble_sort(arr, ARR_SIZE);
#else
    sequential_bubble_sort(arr, ARR_SIZE);
#endif

    // printf("Sorted Array\t: ");
    for (int i = 0; i < ARR_SIZE; i++) {
        // if (i % 10 == 0 && i != 0) printf(", ");
        // printf("%d ", arr[i]);
    }
    // printf("\n");

    free(arr);
    return 0;
}
```

To compile for serial bubble sort

```bash
gcc -o main main.c -lm -fopenmp
time ./main # To measure the time of program execution
```

```console
real	0m2.600s
user	0m2.599s
sys	0m0.000s
```

To compile for parallel bubble sort

```bash
gcc -o main main.c -lm -fopenmp -DPARALLEL
time ./main # To measure the time of program execution
```

```console
real	0m0.045s
user	0m0.506s
sys	0m0.001s
```

#### Results

| Execution | Time in ms |
|-----------|------------|
| Sequential| 2.600      |
| Parallel  | 0.045      |

# LAB 2

### Write Bubble sort in sequential and parallel mode

```cpp
#include <iostream>
#include <vector>
#include <chrono>
#include <cstdio>
#include <algorithm>
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

std::vector<int> par_bubble_sort(std::vector<int> arr) {
    bool sorted = false;
    while (!sorted) {
        sorted = true;

        // Even phase
        #pragma omp parallel for reduction(&:sorted)
        for (int i = 0; i < arr.size() - 1; i += 2) {
            if (arr[i] > arr[i + 1]) {
                std::swap(arr[i], arr[i + 1]);
                sorted = false;
            }
        }

        // Odd phase
        #pragma omp parallel for reduction(&:sorted)
        for (int i = 1; i < arr.size() - 1; i += 2) {
            if (arr[i] > arr[i + 1]) {
                std::swap(arr[i], arr[i + 1]);
                sorted = false;
            }
        }
    }
    return arr;
}

int main()
{
    Timer timer;
    std::vector<int> sizes = {10, 100, 1000, 10000, 50000};
    for (int i = 0; i < sizes.size(); i++) {
	int size = sizes[i];
	std::vector<int> arr(size);
	for (int i = 0; i < size; i++) {
	    arr[i] = rand() % 100;
	}

	timer.reset();

	std::vector<int> sorted_arr = seq_bubble_sort(arr);
	auto t1 = timer.elapsed();

	timer.reset();

	std::vector<int> another_sorted_arr = par_bubble_sort(arr);

	auto t2 = timer.elapsed();

	printf("[SIZE: %d]\t", size);
	std::cout << t1 << "\t" << t2 << std::endl;
    }
}
```

#### Benchmark

| Size of Array | Sequential in seconds | Parallel in seconds |
|------|----------------|----------------------------|
|10    |  1.453e-06     |  0.000473912  |  
|100   |  0.000108827   |  0.00086741   |   
|1000  |  0.00776502    |  0.00767423   |
|10000 |  0.736298      |  0.120619     | 
|50000 |  20.6958       |  3.90075      | 
