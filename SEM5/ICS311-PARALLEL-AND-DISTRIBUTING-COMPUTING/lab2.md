# Gowrish I 2022BCS0155

# LAB 1

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
    for (int i = 0; i < ARR_SIZE; i++) {
        arr[i] = rand() % 1000;
    }

#ifdef PARALLEL
    parallel_bubble_sort(arr, ARR_SIZE);
#else
    sequential_bubble_sort(arr, ARR_SIZE);
#endif
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

    std::cout << "Using " << omp_get_max_threads() << " Threads" << std::endl;

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

#### Output

```console
Using 12 Threads
[SIZE: 10]	    1.412e-06	0.000947931
[SIZE: 100]	    8.7889e-05	0.000698251
[SIZE: 1000]	0.00771212	0.00669482
[SIZE: 10000]	0.739259	0.134833
[SIZE: 50000]	19.1999	    5.33304
```

#### Benchmark

| Size of Array | Sequential in seconds | Parallel in seconds |
|---------------|-----------------------|---------------------|
|10             |  1.453e-06            |  0.000473912        |  
|100            |  0.000108827          |  0.00086741         |   
|1000           |  0.00776502           |  0.00767423         |
|10000          |  0.736298             |  0.120619           | 
|50000          |  20.6958              |  3.90075            | 

### Calculate Value of Pi

$\int_{0}^{1}\frac{4}{1+x^2}dx$

```cpp
#include <iostream>
#include <functional>
#include <cassert>
#include <chrono>
#include <cmath>

#include <omp.h>

class Timer {
    public:
	void reset() {
	    curr = Clock::now();
	}
	double elapsed() const {
	    return std::chrono::duration_cast<Second>(Clock::now() - curr).count();
	}

    private:
	using Clock = std::chrono::high_resolution_clock;
	using Second = std::chrono::duration<double, std::ratio<1> >;
	std::chrono::time_point<Clock> curr{ Clock::now() };
};

double area_func(double x) {
    return 4.0 / (1 + x * x);
}

double integrate(const std::function<double(double)>& generator, double lower_limit, double higher_limit, double dx) {
    assert(lower_limit <= higher_limit);

    double value = 0;
    double size = higher_limit - lower_limit;
    double rect_count = (int) (size / dx);
    for (int i = 0; i < rect_count; i++) {
        double x = lower_limit + i * dx;
        value += generator(x) * dx;
    }

    return value;
}

double parallel_integrate(const std::function<double(double)>& generator, double lower_limit, double higher_limit, double dx) {
    assert(lower_limit <= higher_limit);

    double value = 0;
    double size = higher_limit - lower_limit;
    int rect_count = (int) (size / dx);

    #pragma omp parallel for reduction(+:value)
    for (int i = 0; i < rect_count; i++) {
        double x = lower_limit + i * dx;
        value += generator(x) * dx;
    }

    return value;
}

int main() {
    Timer timer;
    std::vector<double> dx_values = {1e0, 1e-1, 1e-2, 1e-3, 1e-4, 1e-5, 1e-6, 1e-7, 1e-8};

    std::cout << "Using " << omp_get_max_threads() << " Threads" << std::endl;

    for (int i = 0; i < dx_values.size(); i++) {
        double dx = dx_values[i];

        timer.reset();
        double pi_seq = integrate(area_func, 0.0, 1.0, dx);
        auto t1 = timer.elapsed();

        timer.reset();
        double pi_par = parallel_integrate(area_func, 0.0, 1.0, dx);
        auto t2 = timer.elapsed();

        std::cout << dx << "\t" << pi_seq << "\t" << t1 << "\t" << pi_par << "\t" << t1 << std::endl;
    }
}
```

#### Output

```console
Using 12 Threads
1       4       3.61e-07        4       0.000721069
0.1     3.23993 8.01e-07        3.23993 1.7284e-05
0.01    3.15158 4.148e-06       3.15158 1.3746e-05
0.001   3.14259 4.1681e-05      3.14259 1.7564e-05
0.0001  3.14169 0.000381284     3.14169 0.000129139
1e-05   3.14158 0.00382948      3.14158 0.000351958
1e-06   3.14159 0.0289401       3.14159 0.00541477
1e-07   3.14159 0.27464         3.14159 0.0383328
1e-08   3.14159 2.73214         3.14159 0.397813
```

#### Benchmark

| Rectangle width (dx) | PI in sequential| Time for sequential | PI in parallel | Time for parallel |
|----------------------|-----------------|---------------------|----------------|-------------------|
| 1                    | 4               | 3.51e-07            |    4           | 0.00216247        |
| 0.1                  | 3.23993         | 5.41e-07            |    3.23993     | 0.000155264       |
| 0.01                 | 3.15158         | 3.897e-06           |    3.15158     | 0.000317573       |
| 0.001                | 3.14259         | 3.8373e-05          |    3.14259     | 4.6662e-05        |
| 0.0001               | 3.14169         | 0.000381558         |    3.14169     | 8.3504e-05        |
| 1e-05                | 3.14158         | 0.00382509          |    3.14158     | 0.000352621       |
| 1e-06                | 3.14159         | 0.0290141           |    3.14159     | 0.00671049        |
| 1e-07                | 3.14159         | 0.274438            |    3.14159     | 0.00671049        |
| 1e-08                | 3.14159         | 2.74175             |    3.14159     | 0.387032          |

# LAB 3

### Program 1

Write an OpenMP program with C++ that estimates the value of pi (𝜋) using a following function and apply Simpson’s 1/3 rd rule.

$Area=\int_{b}^{a}f(x)dx, where f(x)=\frac{4}{1+x^2} , a=0,b=1,n=100,500,1000$

#### Simpson's Rule

$\int_{b}^{a}f(x)dx \cong \frac{b-a}{3n}\left[ f(x_{0}) +4\cdot\sum_{i=1;i=odd}^{n-1}f(x_{i}+2\cdot\sum_{i=2;i=even}^{n-1}f(x_{i})+f(x_{n}) \right]$

The following components are to be shown

1. Write the serial version program to estimate the value of pi (𝜋). Test the result with classical integration value. Calculate the execution time by using the library function omp_get_wtime().

    __Code__
    
    ```cpp
    #include <iostream>
    #include <functional>
    #include <cstdint>
    #include <cstdio>
    #include <string>
    #include <omp.h>
    #include <iomanip>
    
    typedef std::function<double(double)> Generator;
    
    class Timer {
    public:
        Timer() {
    	this->reset();
        }
    
        void reset() {
    	m_Time = omp_get_wtime();
        }
    
        double elapsed() {
    	double now = omp_get_wtime();
    	return now - m_Time;
        }
    
        void log(std::string msg) {
    	double time = this->elapsed();
    	std::cout << "[TIMER] " 
    		  << msg << " : " 
    		  << time
    		  << "s" << std::endl;
        }
    private:
        double m_Time;
    };
    
    double simpson_rule_serial(double start, double end, Generator generator, uint32_t precision)
    {
        double spacing = ((end - start) / (double)precision);
        auto x = [start, spacing](uint32_t index) {
    	return start + index * spacing;
        };
    
        double sum = 0.0F;
    
        // First Term
        sum += generator(x(0));
    
        // Odd sum
        double odd_sum = 0.0F;
        for (uint32_t i = 1; i <= precision - 1; i += 2) {
    	odd_sum += generator(x(i));
        }
        sum += 4.0 * odd_sum;
    
        // Even sum
        double even_sum = 0.0F;
        for (uint32_t i = 2; i <= precision - 2; i += 2) {
    	even_sum += generator(x(i));
        }
        sum += 2.0 * even_sum;
    
        // Last Term
        sum += generator(x(precision));
    
        // Final Multiplier
        sum *= spacing / 3;
    
        return sum;
    }
    
    
    int identify_machine()
    {
        printf("Detected %d Processor(s)\n", omp_get_num_procs());
        printf("Max %d Threads(s) Available\n", omp_get_max_threads());
    
        int thread_count = -1;
        while (!(0 < thread_count && thread_count <= omp_get_max_threads())) {
    	std::cout << "Enter number of threads to use: ";
    	std::cin >> thread_count;
    	if (0 < thread_count && thread_count <= omp_get_max_threads()) {
    	    omp_set_num_threads(thread_count);
    	    break;
    	} else {
    	    std::cout << "Invalid thread count entered " << thread_count << std::endl;
    	}
        }
        return thread_count;
    }
    
    int main()
    {
        Timer timer;
        auto pi_function = [](double x) {
    	return 4 / (double)(1 + x * x);
        };
    
        int thread_count = identify_machine();
    
        printf("Using %d threads...\n", thread_count);
    
        uint32_t precision = 1e8;
    
        timer.reset();
        double pi_serial = simpson_rule_serial(0, 1, pi_function, precision);
        std::cout << "PI in serial = " 
    	      << std::setprecision(15)
    	      << pi_serial 
    	      << std::endl;
        timer.log("Serial execution took");
    }
    ```
    
    __Output__
    
    ```console
    Detected 12 Processor(s)
    Max 12 Threads(s) Available
    Enter number of threads to use: 12
    Using 12 threads...
    PI in serial = 3.14159265358944
    [TIMER] Serial execution took : 2.81654947599964s
    ```

2. Write the parallel version program to estimate the same. Test the result with classical integration value and by (a). It includes number of threads involved and the area calculated by which thread number. Calculate the execution time by using the library function omp_get_wtime().

    __Code__
    
    ```cpp
    #include <iostream>
    #include <functional>
    #include <cstdint>
    #include <cstdio>
    #include <string>
    #include <omp.h>
    #include <iomanip>
    
    typedef std::function<double(double)> Generator;
    
    class Timer {
    public:
        Timer() {
    	this->reset();
        }
    
        void reset() {
    	m_Time = omp_get_wtime();
        }
    
        double elapsed() {
    	double now = omp_get_wtime();
    	return now - m_Time;
        }
    
        void log(std::string msg) {
    	double time = this->elapsed();
    	std::cout << "[TIMER] " 
    		  << msg << " : " 
    		  << time
    		  << "s" << std::endl;
        }
    private:
        double m_Time;
    };
    
    double simpson_rule_parallel(double start, double end, Generator generator, uint32_t precision) {
        double spacing = ((end - start) / (double)precision);
        auto x = [start, spacing](uint32_t index) {
    	return start + index * spacing;
        };
    
        double sum = 0.0F;
    
        // First Term
        sum += generator(x(0));
    
        // Odd sum
        double odd_sum = 0.0F;
        double even_sum = 0.0F;
    
        #pragma omp parallel shared(precision, sum)
        {
    	#pragma omp for reduction( + : odd_sum )
    	for (uint32_t i = 1; i <= precision - 1; i += 2) {
    	    odd_sum += generator(x(i));
    	}
    
    	#pragma omp for reduction( + : even_sum )
    	for (uint32_t i = 2; i <= precision - 2; i += 2) {
    	    even_sum += generator(x(i));
    	}
        }
    
        sum += 4.0 * odd_sum + 2.0 * even_sum;
    
        // Last Term
        sum += generator(x(precision));
    
        // Final Multiplier
        sum *= spacing / 3;
    
        return sum;
    }
    
    double simpson_rule_serial(double start, double end, Generator generator, uint32_t precision)
    {
        double spacing = ((end - start) / (double)precision);
        auto x = [start, spacing](uint32_t index) {
    	return start + index * spacing;
        };
    
        double sum = 0.0F;
    
        // First Term
        sum += generator(x(0));
    
        // Odd sum
        double odd_sum = 0.0F;
        for (uint32_t i = 1; i <= precision - 1; i += 2) {
    	odd_sum += generator(x(i));
        }
        sum += 4.0 * odd_sum;
    
        // Even sum
        double even_sum = 0.0F;
        for (uint32_t i = 2; i <= precision - 2; i += 2) {
    	even_sum += generator(x(i));
        }
        sum += 2.0 * even_sum;
    
        // Last Term
        sum += generator(x(precision));
    
        // Final Multiplier
        sum *= spacing / 3;
    
        return sum;
    }
    
    
    int identify_machine()
    {
        printf("Detected %d Processor(s)\n", omp_get_num_procs());
        printf("Max %d Threads(s) Available\n", omp_get_max_threads());
    
        int thread_count = -1;
        while (!(0 < thread_count && thread_count <= omp_get_max_threads())) {
    	std::cout << "Enter number of threads to use: ";
    	std::cin >> thread_count;
    	if (0 < thread_count && thread_count <= omp_get_max_threads()) {
    	    omp_set_num_threads(thread_count);
    	    break;
    	} else {
    	    std::cout << "Invalid thread count entered " << thread_count << std::endl;
    	}
        }
        return thread_count;
    }
    
    int main()
    {
        Timer timer;
        auto pi_function = [](double x) {
    	return 4 / (double)(1 + x * x);
        };
    
        int thread_count = identify_machine();
    
        printf("Using %d threads...\n", thread_count);
    
        uint32_t precision = 1e8;
    
        timer.reset();
        double pi_serial = simpson_rule_serial(0, 1, pi_function, precision);
        std::cout << "PI in serial = " 
    	      << std::setprecision(15)
    	      << pi_serial 
    	      << std::endl;
        timer.log("Serial execution took");
    
        timer.reset();
        double pi_parallel = simpson_rule_parallel(0, 1, pi_function, precision);
        std::cout << "PI in parallel = " 
    	      << std::setprecision(15)
    	      << pi_parallel 
    	      << std::endl;
        timer.log("Parallel execution took");
    }
    ```
    
    __Output__
    
    ```console
    Detected 12 Processor(s)
    Max 12 Threads(s) Available
    Enter number of threads to use: 5
    Using 5 threads...
    PI in serial = 3.14159265358944
    [TIMER] Serial execution took : 2.75547154200103s
    PI in parallel = 3.14159265358966
    [TIMER] Parallel execution took : 0.62808093700005s
    ```

3. Identify the line of statement which leads the race condition. Race condition occurs when the multiple threads accessing a shared variable. If it exists how will you handle this problem? Use appropriate OpenMP clauses such as critical, atomic, ordered, Sections and find the solution. Test the result with classical integration value and by (a) and (b). Calculate the execution time for critical, atomic, ordered, Sections clauses by using the library function omp_get_wtime().

    ```cpp
    double simpson_rule_parallel_critical(double start, double end, Generator generator, uint32_t precision) {
        double spacing = ((end - start) / (double)precision);
        auto x = [start, spacing](uint32_t index) {
            return start + index * spacing;
        };
    
        double sum = 0.0F;
    
        #pragma omp parallel shared(precision, sum)
        {
            #pragma omp for
            for (uint32_t i = 1; i <= precision - 1; i += 2) {
                double temp = generator(x(i));
                #pragma omp critical
                {
                    sum += 4.0 * temp;
                }
            }
    
            #pragma omp for
            for (uint32_t i = 2; i <= precision - 2; i += 2) {
                double temp = generator(x(i));
                #pragma omp critical
                {
                    sum += 2.0 * temp;
                }
            }
        }
    
        sum += generator(x(0)) + generator(x(precision));
        sum *= spacing / 3.0;
    
        return sum;
    }
    
    double simpson_rule_parallel_atomic(double start, double end, Generator generator, uint32_t precision) {
        double spacing = ((end - start) / (double)precision);
        auto x = [start, spacing](uint32_t index) {
            return start + index * spacing;
        };
    
        double sum = 0.0F;
    
        #pragma omp parallel shared(precision, sum)
        {
            #pragma omp for
            for (uint32_t i = 1; i <= precision - 1; i += 2) {
                double temp = generator(x(i));
                #pragma omp atomic
                sum += 4.0 * temp;
            }
    
            #pragma omp for
            for (uint32_t i = 2; i <= precision - 2; i += 2) {
                double temp = generator(x(i));
                #pragma omp atomic
                sum += 2.0 * temp;
            }
        }
    
        sum += generator(x(0)) + generator(x(precision));
        sum *= spacing / 3.0;
    
        return sum;
    }
    
    double simpson_rule_parallel_ordered(double start, double end, Generator generator, uint32_t precision) {
        double spacing = ((end - start) / (double)precision);
        auto x = [start, spacing](uint32_t index) {
            return start + index * spacing;
        };
    
        double sum = 0.0F;
    
        #pragma omp parallel shared(precision, sum)
        {
            #pragma omp for ordered
            for (uint32_t i = 1; i <= precision - 1; i += 2) {
                double temp = generator(x(i));
                #pragma omp ordered
                sum += 4.0 * temp;
            }
    
            #pragma omp for ordered
            for (uint32_t i = 2; i <= precision - 2; i += 2) {
                double temp = generator(x(i));
                #pragma omp ordered
                sum += 2.0 * temp;
            }
        }
    
        sum += generator(x(0)) + generator(x(precision));
        sum *= spacing / 3.0;
    
        return sum;
    }
    
    double simpson_rule_parallel(double start, double end, Generator generator, uint32_t precision) {
        double spacing = ((end - start) / (double)precision);
        auto x = [start, spacing](uint32_t index) {
    	return start + index * spacing;
        };
    
        double sum = 0.0F;
    
        // First Term
        sum += generator(x(0));
    
        // Odd sum
        double odd_sum = 0.0F;
        double even_sum = 0.0F;
    
        #pragma omp parallel shared(precision, sum)
        {
    	#pragma omp for reduction( + : odd_sum )
    	for (uint32_t i = 1; i <= precision - 1; i += 2) {
    	    odd_sum += generator(x(i));
    	}
    
    	#pragma omp for reduction( + : even_sum )
    	for (uint32_t i = 2; i <= precision - 2; i += 2) {
    	    even_sum += generator(x(i));
    	}
        }
    
        sum += 4.0 * odd_sum + 2.0 * even_sum;
    
        // Last Term
        sum += generator(x(precision));
    
        // Final Multiplier
        sum *= spacing / 3;
    
        return sum;
    }
    ```
    
    __Output__
    
    ```console
    Detected 12 Processor(s)
    Max 12 Threads(s) Available
    Enter number of threads to use: 10
    Using 10 threads...
    PI in serial = 3.14159265358944
    [TIMER] Serial execution took : 2.77507608699852s
    PI in parallel (critical) = 3.14159265359004
    [TIMER] Parallel (critical) execution took : 14.4866989049988s
    PI in parallel (atomic) = 3.14159265358992
    [TIMER] Parallel (atomic) execution took : 3.20636564099914s
    PI in parallel (ordered) = 3.14159265358995
    [TIMER] Parallel (ordered) execution took : 3.4326813610005s
    PI in parallel (reduction) = 3.14159265358981
    [TIMER] Parallel (reduction) execution took : 0.608498552999663s
    ```

#### Results

| Execution Type       | Calculated PI value | Time Taken in seconds |
|----------------------|---------------------|-----------------------|
| Serial               |  3.14159265358944   | 2.66738621900004      |
|Parallel (Critical)   |  3.14159265359018   | 19.2036709250006     |
|Parallel (Atomic)     | 3.14159265359035    | 3.82193632400049     |
|Parallel (Ordered)    | 3.14159265358995    | 3.47913229900041     |
|Parallel (Reduction)  | 3.14159265358984    | 0.745230704000278    |

### Program 2

Write an openMP program with C++ that illustrates the following OpenMP clause with its various types.

schedule clause: It allows to specify how the iterations of the loop should be scheduled, i.e., allocated to threads. The various types of schedule are as follows.

- Write an openMP program with C++ that calculate the sum of the first N natural numbers using for loop. (Serial Version) Try the following on parallel version of the code.

    __Code__

    ```cpp
    #include <iostream>
    #include <omp.h>
    
    class Timer {
    public:
        Timer() {
    	this->reset();
        }
    
        void reset() {
    	m_Time = omp_get_wtime();
        }
    
        double elapsed() {
    	double now = omp_get_wtime();
    	return now - m_Time;
        }
    
        void log(std::string msg) {
    	double time = this->elapsed();
    	std::cout << "[TIMER] " 
    		  << msg << " : " 
    		  << time
    		  << "s" << std::endl;
        }
    private:
        double m_Time;
    };
    
    uint64_t sum_all(uint64_t n) {
        uint64_t sum = 0;
        for (uint64_t i = 0; i < n; i++) {
    	sum += i;
        }
        return sum;
    }
    
    int main() {
        Timer timer;
    
        timer.reset();
        sum_all(1e9);
        timer.log("Serial execution took ");
    }
    ```
    
    __Output__

    ```console
    [TIMER] Serial execution took  : 1.41841s
    ```
- schedule (static), schedule (static, C) where C – number of chunks to tasks. Each chunk contains C contiguous iterations.

    ```cpp
    uint64_t sum_all_static(uint64_t n) {
        uint64_t sum = 0;
        #pragma omp parallel for reduction(+:sum) schedule(static)
        for (uint64_t i = 0; i < n; ++i) {
            sum += i;
        }
        return sum;
    }

    uint64_t sum_all_static_chunk(uint64_t n, int chunk_size) {
        uint64_t sum = 0;
        #pragma omp parallel for reduction(+:sum) schedule(static, chunk_size)
        for (uint64_t i = 0; i < n; ++i) {
            sum += i;
        }
        return sum;
    }
    ```
- schedule (dynamic), schedule (dynamic, C)

    ```cpp
    uint64_t sum_all_dynamic(uint64_t n) {
        uint64_t sum = 0;
        #pragma omp parallel for reduction(+:sum) schedule(dynamic)
        for (uint64_t i = 0; i < n; ++i) {
            sum += i;
        }
        return sum;
    }

    uint64_t sum_all_dynamic_chunk(uint64_t n, int chunk_size) {
        uint64_t sum = 0;
        #pragma omp parallel for reduction(+:sum) schedule(dynamic, chunk_size)
        for (uint64_t i = 0; i < n; ++i) {
            sum += i;
        }
        return sum;
    }
    ```
- schedule (guided), schedule (guided, C)

    ```cpp
    uint64_t sum_all_guided(uint64_t n) {
        uint64_t sum = 0;
        #pragma omp parallel for reduction(+:sum) schedule(guided)
        for (uint64_t i = 0; i < n; ++i) {
            sum += i;
        }
        return sum;
    }
    
    uint64_t sum_all_guided_chunk(uint64_t n, int chunk_size) {
        uint64_t sum = 0;
        #pragma omp parallel for reduction(+:sum) schedule(guided, chunk_size)
        for (uint64_t i = 0; i < n; ++i) {
            sum += i;
        }
        return sum;
    }
    ```

__Final Code__

```cpp
#include <iostream>
#include <omp.h>
#include <cstdint>

class Timer {
public:
    Timer() {
        this->reset();
    }

    void reset() {
        m_Time = omp_get_wtime();
    }

    double elapsed() {
        double now = omp_get_wtime();
        return now - m_Time;
    }

    void log(std::string msg) {
        double time = this->elapsed();
        std::cout << "[TIMER] " 
                  << msg << " : " 
                  << time
                  << "s" << std::endl;
    }
private:
    double m_Time;
};

uint64_t sum_all_serial(uint64_t n) {
    uint64_t sum = 0;
    for (uint64_t i = 0; i < n; ++i) {
        sum += i;
    }
    return sum;
}

uint64_t sum_all_static(uint64_t n) {
    uint64_t sum = 0;
    #pragma omp parallel for reduction(+:sum) schedule(static)
    for (uint64_t i = 0; i < n; ++i) {
        sum += i;
    }
    return sum;
}

uint64_t sum_all_static_chunk(uint64_t n, int chunk_size) {
    uint64_t sum = 0;
    #pragma omp parallel for reduction(+:sum) schedule(static, chunk_size)
    for (uint64_t i = 0; i < n; ++i) {
        sum += i;
    }
    return sum;
}

uint64_t sum_all_dynamic(uint64_t n) {
    uint64_t sum = 0;
    #pragma omp parallel for reduction(+:sum) schedule(dynamic)
    for (uint64_t i = 0; i < n; ++i) {
        sum += i;
    }
    return sum;
}

uint64_t sum_all_dynamic_chunk(uint64_t n, int chunk_size) {
    uint64_t sum = 0;
    #pragma omp parallel for reduction(+:sum) schedule(dynamic, chunk_size)
    for (uint64_t i = 0; i < n; ++i) {
        sum += i;
    }
    return sum;
}

uint64_t sum_all_guided(uint64_t n) {
    uint64_t sum = 0;
    #pragma omp parallel for reduction(+:sum) schedule(guided)
    for (uint64_t i = 0; i < n; ++i) {
        sum += i;
    }
    return sum;
}

uint64_t sum_all_guided_chunk(uint64_t n, int chunk_size) {
    uint64_t sum = 0;
    #pragma omp parallel for reduction(+:sum) schedule(guided, chunk_size)
    for (uint64_t i = 0; i < n; ++i) {
        sum += i;
    }
    return sum;
}

int main() {
    uint64_t n = 1e9;
    Timer timer;

    // Serial Execution
    timer.reset();
    sum_all_serial(n);
    timer.log("Serial execution took");

    // Static Schedule
    timer.reset();
    sum_all_static(n);
    timer.log("Static schedule took");

    // Static Schedule with Chunk Size
    int chunk_size = 1000;
    timer.reset();
    sum_all_static_chunk(n, chunk_size);
    timer.log("Static schedule with chunk size took");

    // Dynamic Schedule
    timer.reset();
    sum_all_dynamic(n);
    timer.log("Dynamic schedule took");

    // Dynamic Schedule with Chunk Size
    timer.reset();
    sum_all_dynamic_chunk(n, chunk_size);
    timer.log("Dynamic schedule with chunk size took");

    // Guided Schedule
    timer.reset();
    sum_all_guided(n);
    timer.log("Guided schedule took");

    // Guided Schedule with Chunk Size
    timer.reset();
    sum_all_guided_chunk(n, chunk_size);
    timer.log("Guided schedule with chunk size took");

    return 0;
}
```

```console
[TIMER] Serial execution took : 1.17382s
[TIMER] Static schedule took : 0.160601s
[TIMER] Static schedule with chunk size took : 0.165052s
[TIMER] Dynamic schedule took : 10.0197s
[TIMER] Dynamic schedule with chunk size took : 0.189753s
[TIMER] Guided schedule took : 0.192321s
[TIMER] Guided schedule with chunk size took : 0.184942s
```
