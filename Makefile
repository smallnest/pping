# should only need to change LIBTINS to the libtins install prefix
# (typically /usr/local unless overridden when tins built)
#LIBTINS = $(HOME)/src/libtins
LIBTINS = /usr/local
CPPFLAGS += -I$(LIBTINS)/include
LDFLAGS += -L$(LIBTINS)/lib $(LIBTINS)/lib/libtins.a -static -ltins -lpcap
CXXFLAGS += -std=c++14 -g -O3 -Wall

pping:  pping.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -o pping pping.cpp $(LDFLAGS)

clean:
	rm pping