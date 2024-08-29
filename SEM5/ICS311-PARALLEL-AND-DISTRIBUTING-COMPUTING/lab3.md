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
