yum install -y gcc zlib zlib-devel
wget ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.7-p330.tar.gz
tar xvf ruby-1.8.7-p330.tar.gz
cd ruby-1.8.7-p330
./configure --enable-pthread
make
make install