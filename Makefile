CC = gcc
CFLAGS = -O2 -fopenmp

FC = gfortran-4.9
FFLAGS = -O2 -fopenmp

ASIZES := 1000 2000 3000 4000 5000 6000 7000 8000 9000 10000
M5OUTS := $(addprefix stream_gem5.,$(addsuffix .out,$(ASIZES)))
COUTS := $(addprefix stream.,$(addsuffix .out,$(ASIZES)))

all: stream_gem5.out stream.out $(M5OUTS) $(COUTS)

stream_gem5.out: stream_gem5.o m5op_x86.o
	$(CC) $(CFLAGS) -static -o $@ -lrt $^

stream_gem5.%.out: stream_gem5.%.o m5op_x86.o
	$(CC) $(CFLAGS) -static -o $@ -lrt $^

stream_gem5.%.o: stream_gem5.c m5op.h
	$(CC) $(CFLAGS) -c -DM5 -DSTREAM_ARRAY_SIZE=$* -o $@ $<

stream_gem5.o: stream_gem5.c m5op.h
	$(CC) $(CFLAGS) -c -DM5 -o $@ $<

stream.out: stream_gem5.c
	$(CC) $(CFLAGS) -o $@ $<

stream.%.out: stream_gem5.c
	$(CC) $(CFLAGS) -DSTREAM_ARRAY_SIZE=$* -o $@ $<

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
