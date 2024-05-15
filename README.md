# pping (pollere passive ping)

_pping_ is a linux/macOS/BSD command line tool to measure network
latency via passive monitoring of active connections.  Unlike _ping_,
pping doesn't inject traffic to determine RTT (Round-Trip Time) -- it
reports the per-packet RTT experienced by normal application traffic.
Unlike transport state monitoring tools like _ss_ which can only measure
RTT at the sending endpoint, pping can measure RTT at the sender,
receiver or anywhere on a connection's path (for example, an OpenWrt
home border router could easily monitor the RTT of all traffic to and
from the Internet).

For more information on pping, please visit http://pollere.net/pping.html

For on-going work that incorporates the pping approach within an ISP, see: https://github.com/thebracket/cpumap-pping

## Compiling ##

### Prerequisites

[pping](https://github.com/pollere/pping/) depends on
the [libtins](http://libtins.github.io/) packet parsing library
which should be [downloaded](http://libtins.github.io/download/) and
built or installed first.

静态编译`libtins`:
```Shell
# (assuming sources are put in ~/src)
cd ~/src
git clone https://github.com/mfontanini/libtins.git
cd libtins
mkdir build
cd build
cmake ../ -DLIBTINS_BUILD_SHARED=0 -DLIBTINS_ENABLE_CXX11=1 \
 -DLIBTINS_ENABLE_ACK_TRACKER=0 -DLIBTINS_ENABLE_WPA2=0 \
 -DCMAKE_INSTALL_PREFIX=`dirname $PWD`
make
make install
```

静态编译 libpcap (静态和动态库都编译):
```Shell
wget http://www.tcpdump.org/release/libpcap-1.10.0.tar.gz
tar -zxvf libpcap-1.10.0.tar.gz
cd libpcap-1.10.0

./configure

sudo make install
```

安装`glibc`和`libstdc++`的静态库:
```Shell
yum install glibc-static libstdc++-static
```


## Building


在上一个步骤，`libtins`被默认安装到了`/usr/local`, 所以`Makefile`中LIBTINS变量应该确保设置为`/usr/local`:
```Shell
LIBTINS = /usr/local
```

确保静态编译:
```Shell
#LIBTINS = $(HOME)/src/libtins
LIBTINS = /usr/local
CPPFLAGS += -I$(LIBTINS)/include
LDFLAGS += -L$(LIBTINS)/lib $(LIBTINS)/lib/libtins.a -static -ltins -lpcap
CXXFLAGS += -std=c++14 -g -O3 -Wall

pping:  pping.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -o pping pping.cpp $(LDFLAGS)

clean:
	rm pping
```


然后`make`就可以静态编译`pping`了。

检查编译好的`pping`有没有依赖动态库:
```Shell
[root@vps3 pping]# readelf -d pping

There is no dynamic section in this file.
```

## Examples ##

`pping -i` _interface_ `  ` monitors tcp traffic on _interface_ and reports
each packet's RTT to stdout. For example
   `pping -i en0    ` (Mac OS)
   `pping -i wlp2s0 ` (Ubuntu 17.04)

`pping -r` _pcapfile_ `  ` prints the RTT of tcp packets captured
with _tcpdump_ or _wireshark_ to _pcapfile_.

There are a few flags that control how long pping will capture and/or how
many packets it will capture, the output format, and a bpf filter for
what packets to capture. For example, to see the RTT of next 100
tcp packets from netflix or youtube:
```Shell
   pping -i en0 -c 100 -f 'net 45.57 or 74.125'
```
`pping -h`, `pping --help`, or just `pping` describes the flags.

Since pping outputs one line per packet, if it's being run on a busy
interface its output should be redirected to a file or piped to a
summarization or plotting utility. In the latter case, the `-m`
(machine-friendly output format) might be useful.


## Output to Mongo database ##

pping can be set up to output to a Mongo database. The compile flag USE_DB
must be set and the mongo c++ library installed
(https://mongodb.github.io/mongo-cxx-driver/). Once a mongo database instance
is running, pping is invoked with the -d flag and given the uri. If this is
not of interest, don't compile with the USE_DB flag.
