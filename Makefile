CC = gcc
CFLAGS = -O2 -fopenmp

FC = gfortran-4.9
FFLAGS = -O2 -fopenmp

all: stream_gem5.out stream.out

stream_gem5.out: stream_gem5.o m5op_x86.o
	$(CC) $(CFLAGS) -static -o $@ -lrt $^

stream_gem5.o: stream_gem5.c m5op.h
	$(CC) $(CFLAGS) -c -DM5 -o $@ $<

stream.out: stream_gem5.c
	$(CC) $(CFLAGS) -o $@ $<

stream_f.exe: stream.f mysecond.o
	$(CC) $(CFLAGS) -c mysecond.c
	$(FC) $(FFLAGS) -c stream.f
	$(FC) $(FFLAGS) stream.o mysecond.o -o stream_f.exe

stream_c.exe: stream.c
	$(CC) $(CFLAGS) stream.c -o stream_c.exe

clean:
	$(RM) stream_gem5.out stream_f.exe stream_c.exe stream_gem5.p stream.o mysecond.o

# an example of a more complex build line for the Intel icc compiler
stream.icc: stream.c
	icc -O3 -xCORE-AVX2 -ffreestanding -qopenmp -DSTREAM_ARRAY_SIZE=80000000 -DNTIMES=20 stream.c -o stream.omp.AVX2.80M.20x.icc
