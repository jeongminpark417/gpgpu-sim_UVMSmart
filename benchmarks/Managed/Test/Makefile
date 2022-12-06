#!/usr/bin/make

default:
	nvcc -g -Wno-deprecated-gpu-targets test.cu -lcudart -o test

clean:
	rm -rf test gpgpusim_power_report* _cuobjdump_* *.txt
