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
------------|------------
| Sequential| 2.600      |
| Parallel  | 0.045      |
