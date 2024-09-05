```cpp
#include <iostream>
#include <ctime>
#include <cstdio>
#include <cstdint>
#include <omp.h>
#include <cmath>

#define DOUBLE_EPSILON 1e-2

#define DOUBLE_LEQ(a, b) ((a) < (b) + DOUBLE_EPSILON)

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

template< typename T >
struct Vector2
{
    T x, y;

    Vector2(T _x, T _y) { x = _x; y = _y;}
    T magnitude_sq() { return (x * x + y * y); }
    void print() { std::cout << "<" << x << " , " << y << ">\n"; }
};

void ChunkGenerator( 
	double radius, 
	uint64_t points_count, 
	uint64_t* in_circle, 
	uint64_t* in_square 
    )
{
    double diameter = 2 * radius;
    uint64_t local_in_circle = 0;

    // Do until `points_count` points have spawned in the circle
    while ( local_in_circle < points_count ) {
	Vector2<double> random_point(
		( std::rand() / static_cast< double >( RAND_MAX ) ) * diameter - radius,
		( std::rand() / static_cast< double >( RAND_MAX ) ) * diameter - radius
		);

	// random_point.print();

	if ( DOUBLE_LEQ( random_point.magnitude_sq(), radius * radius ) ) {
	    ( *in_circle )++;
	    local_in_circle++;
	}
	( *in_square )++;
    }
}

void sequential_pi_calculator( 
	double radius, 
	uint64_t points_per_chunk, 
	uint64_t iterations
    )
{
    uint64_t in_circle = 0;
    uint64_t in_square = 0;

    Timer timer;

    timer.reset();
    for ( uint64_t i = 0; i < iterations; i++ ) {
	ChunkGenerator( radius, points_per_chunk, &in_circle, &in_square );
    }

    double pi_val = 4 * in_circle / ( double )in_square;
    double error = 100 * std::abs( M_PI - pi_val ) / M_PI;

    printf("Iterations: %d, Radius: %f, Points Generated Per Chunk: %d\n",
	    iterations,	    radius,	points_per_chunk);
    printf("Calculated PI %f value: %f with absolute error of %f%\n",
			M_PI, pi_val,	error);
    timer.log( "Sequantial Calculation took" );
}

void parallel_pi_calculator( 
	double radius, 
	uint64_t points_per_chunk, 
	uint64_t iterations
    )
{
    uint64_t in_circle = 0;
    uint64_t in_square = 0;

    Timer timer;

    timer.reset();

    #pragma omp parallel shared( in_circle, in_square )
    {
	#pragma omp for reduction( + : in_circle, in_square )
	for ( uint64_t i = 0; i < iterations; i++ ) {
	    uint64_t lIn_circle = 0;
	    uint64_t lIn_square= 0;
	    ChunkGenerator( radius, points_per_chunk, &lIn_circle, &lIn_square );

	    in_circle += lIn_circle;
	    in_square += lIn_square;
	}
    }

    double pi_val = 4 * in_circle / ( double )in_square;
    double error = 100 * std::abs( M_PI - pi_val ) / M_PI;

    printf("Iterations: %d, Radius: %f, Points Generated Per Chunk: %d\n",
	    iterations,	    radius,	points_per_chunk);
    printf("Calculated PI %f value: %f with absolute error of %f%\n",
			M_PI, pi_val,	error);
    timer.log( "Parallel Calculation took" );
}

int main()
{
    std::srand( std::time( nullptr ) );

    sequential_pi_calculator( 100, 10000, 100 );
    parallel_pi_calculator( 100, 10000, 100 );
}
```
