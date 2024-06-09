# Line Server Problem

## Project Overview

This project implements a file processing system using Ruby and Sinatra server by [Falcon](https://github.com/socketry/falcon). The `FileProcessor` class is designed to handle large files efficiently by using a sparse index and a connection pool to manage file access. The system provides an endpoint to fetch specific lines from a file.

## How the System Works

The system is designed to efficiently read specific lines from a potentially very large file. It uses the following key components and strategies:

1. __Sparse Index:__ Instead of indexing every line, the system indexes every Nth line (sparse factor). This significantly reduces the memory footprint for large files with many lines.
2. __Connection Pool:__ Uses a connection pool to manage file handles efficiently, allowing concurrent access with minimal overhead.
3. __Dynamic Sparse Factor:__ The sparse factor is dynamically determined based on the file size to maintain a balance between index size and access efficiency.
4. __HTTP Endpoint:__ Provides an endpoint (`/lines/:line_number`) to fetch specific lines from the file. The endpoint validates input to ensure that line numbers are positive integers.
5. __Falcon:__ Serves Sinatra with Falcon, a multi-fiber rack-compatible HTTP server, where each request is executed within a lightweight fiber and can block on up-stream requests without stalling the entire server process.

## Example Usage

1. Install the Dependencies:
```bash
/build.sh
```

2. Start the Application:
```bash
./run.sh <path to text file>
```

3. Fetch a Line:
```bash
curl http://localhost:9292/lines/3000
```

## Prerequisites
- Ruby 3.3 installed on your system.

## Running Tests
To run the tests, use the following command:
```bash
bundle exec rspec
```

## How the System Will Perform with Different File Sizes

### 1 GB File:
- __Index Size:__ The index will be relatively small and easily fit into memory.
- __Performance:__ Fast access times for fetching lines due to the small index size and manageable file access.

### 10 GB File:
- __Index Size:__ The index will still be reasonable in size. For example, if indexing every 1MB, the index will have around 10,000 entries.
- __Performance:__ Slightly slower than the 1 GB file due to more data to scan between sparse index points, but still efficient.

### 100 GB File:
- __Index Size:__ The index size grows larger but remains manageable with proper memory allocation.
- __Performance:__ Access times will be longer due to the larger file and more data to scan, but the sparse indexing helps keep it within acceptable limits.

## How the System Will Perform with Different User Loads

### 100 Users:
- __Performance:__ The system can handle this load comfortably. The connection pool and efficient indexing ensure quick responses.
- __Concurrency:__ The connection pool can handle concurrent file accesses without significant delays.

### 10,000 Users:
- __Performance:__ The system will start experiencing more load, but with adequate hardware and tuning, it can still perform well.
- __Concurrency:__ The connection pool may need to be scaled, and additional resources may be required to maintain performance.

### 1,000,000 Users:
- __Performance:__ This load is extremely high and will require significant scaling of infrastructure..
- __Concurrency:__ Horizontal scaling (adding more servers) and possibly distributed file systems will be needed to handle this load efficiently.

## Performance Analysis with Apache Benchmark (ab)
I used Apache Benchmark to evaluate the performance of the system under different loads with a text file of 256MB. Here are the results of the tests:

### Test 1: 5000 Requests with Concurrency of 111
```bash
ab -n 5000 -c 111 http://localhost:9292/lines/50000
```

- __Requests per second:__ 13558.33 [#/sec]
- __Time per request:__ 8.187 [ms] (mean)
- __Transfer rate:__ 3574.95 [Kbytes/sec]
- __Connection times:__
  - __Connect:__ 0-8 ms
  - __Processing:__ 2-38 ms
  - __Waiting:__ 1-37 ms
  - __Total:__ 3-42 ms

### Test 2: 10000 Requests with Concurrency of 111
```bash
ab -n 10000 -c 111 http://localhost:9292/lines/50000
```

- __Requests per second:__ 14976.97 [#/sec]
- __Time per request:__ 7.411 [ms] (mean)
- __Transfer rate:__ 3949.00 [Kbytes/sec]
- __Connection times:__
  - __Connect:__ 0-65 ms
  - __Processing:__  2-72 ms
  - __Waiting:__ 1-70 ms
  - __Total:__ 4-72 ms

### Test 3: 5000 Requests with Concurrency of 500
```bash
ab -n 5000 -c 500 http://localhost:9292/lines/50000
```

- __Result:__ The test failed with apr_socket_recv: Connection reset by peer (54) indicating the server could not handle the high concurrency.

### Test 3: 20000 Requests with Concurrency of 1000
```bash
ab -n 20000 -c 1000 http://localhost:9292/lines/50000
```

- __Result:__ The test failed with apr_socket_recv: Connection reset by peer (54) indicating the server could not handle the high concurrency.

### Performance Summary
- The system performs well under moderate to high loads (up to 10000 requests with 111 concurrent users).
- The performance starts to degrade significantly with higher concurrency levels (500 and above), leading to connection resets and failed requests.

### Scaling Strategies

To handle increased load and improve performance, we could consider the following strategies:

1. Caching
  - Implement caching for frequently requested lines to reduce file access times.
  - Use an in-memory cache like Redis or Memcached to store line data.
2. Horizontal Scaling:
  - Deploy multiple instances of the Sinatra application behind a load balancer.
  - Use containerization (Docker) and orchestration tools (Kubernetes) to manage and scale instances.
3. Optimizing Connection Pooling:
  - Tune the connection pool size and timeout settings to better handle concurrent file access.
4. Improving Indexing:
  - Optimize the sparse index to balance memory usage and access times better.
  - Consider preloading the index into memory at startup for faster access.
5. Using a Distributed File System:
  - For very large files and high concurrency, we could consider using a distributed file system that supports efficient parallel access.
6. Database Solution:
  - Store file lines in a database to enable efficient querying and indexing.
  - Use a relational database (e.g., PostgreSQL) or a NoSQL database (e.g., MongoDB) to store lines.


## What documentation, websites, papers, etc did you consult in doing this assignment?
- [Under the Hood: “Slurping” and Streaming Files in Ruby](https://blog.appsignal.com/2018/07/10/ruby-magic-slurping-and-streaming-files.html)
- [Processes Have File Descriptors](https://workingwithruby.com/wwup/fds/#:~:text=Descriptors%20Represent%20Resources&text=In%20Ruby%2C%20open%20resources%20are,to%20get%20access%20to%20it.)
- [Connection Pool in Ruby](https://www.visuality.pl/posts/easy-introduction-to-connection-pool-in-ruby)
- [Load testing an API with Apache Benchmark or JMeter](https://medium.com/@harrietty/load-testing-an-api-with-apache-benchmark-or-jmeter-24cfe39d3a23)
- [Falcon Sinatra Example](https://github.com/socketry/falcon-example-sinatra)
- [Working efficiently with large files in Ruby](https://tjay.dev/howto-working-efficiently-with-large-files-in-ruby/)
- [Sparse Index](https://www.dremio.com/wiki/sparse-index/#:~:text=Unlike%20Dense%20Index%2C%20which%20maintains,and%20performance%20in%20database%20systems.)

## What third-party libraries or other tools does the system use? How did you choose each library or framework you used?
1. [connection_pool](https://github.com/mperham/connection_pool)
  Provides a generic connection pool for managing reusable resources, like database connections or file handles. The connection_pool gem is used to manage file handles efficiently. By pooling file handles, the system can handle concurrent access to the file without opening and closing the file repeatedly, improving performance and resource management.
2. [falcon](https://github.com/socketry/falcon)
  Falcon is a high-performance web server for Ruby applications, built on asynchronous I/O. Falcon is chosen for its high performance and ability to handle asynchronous I/O, making it suitable for handling high-concurrency web requests. This is particularly useful when serving a large number of simultaneous requests. Additionally, it was a personal choice to give Falcon a spin and explore its capabilities.
3. [sinatra](https://github.com/sinatra/sinatra)
  Sinatra is a lightweight web application library and domain-specific language written in Ruby.  Sinatra is chosen for its simplicity and ease of use. It allows for quick setup and straightforward routing, making it ideal for creating a small web service to serve the file processing API.

## How long did you spend on this exercise? If you had unlimited more time to spend on this, how would you spend it and how would you prioritize each item?
I spent approximately 4 hours on this exercise. During this time, I focused on setting up the project, implementing the `FileProcessor` class first with native approach and then improving it with sparse indexing and a connection pool, writing RSpec tests, configuring the Sinatra application, and performing initial performance testing using Apache Benchmark (ab).

If I had unlimited more time to spend on this exercise, I would prioritize the following items:

### In-Depth Research and Optimization:
 - Conduct more in-depth research on different sparse indexing algorithms and their performance characteristics. Experiment with various sparse factors and indexing strategies to find the optimal balance between memory usage and access speed.
 - Investigate and implement advanced asynchronous I/O techniques to improve the performance and scalability of the file access operations.

 ### Memory Profiling and Performance Testing:
 - Conduct detailed memory profiling tests to compare different implementations of the `FileProcessor` class.
 - Conduct detailed memory profiling tests to compare different implementations of the FileProcessor class. Use tools like memory_profiler and ruby-prof to identify memory usage patterns and optimize accordingly.

 ### Caching Strategies:
 - Implement in-memory caching using Redis or Memcached to store frequently accessed lines and reduce the need for repeated file I/O operations.

 ## If you were to critique your code, what would you have to say about it?

 ### Strengths:
 - The use of `connection_pool` to manage file handles is efficient and helps in handling concurrent access to the file without the overhead of opening and closing files repeatedly.
 - The implementation of dynamic sparse indexing based on file size is a smart approach to balance memory usage and access efficiency.
 - Using Sinatra for routing is straightforward and keeps the web service lightweight and easy to maintain.
 - The code includes basic error handling for invalid line numbers and file access errors, which enhances its robustness.

 ### Areas for Improvement
 - Basic error handling is implemented, but it can be improved.
 - The code is not fully optimized for high concurrency scenarios, as indicated by the failed high-concurrency tests.
 - Explore asynchronous processing and better concurrency handling using libraries like `async` or improving the connection pool configuration.
 - There is no caching mechanism implemented, which can lead to repeated file access for frequently requested lines.
 - Basic RSpec tests are written, but they may not cover all edge cases and performance scenarios.
