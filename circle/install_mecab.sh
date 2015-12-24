#!/bin/bash
 
if [ ! -e /usr/local/bin/mecab ]; then
  # Remove mecab
  sudo apt-get remove mecab
 
  # Install mecab
  cd /var/tmp
  curl -O https://mecab.googlecode.com/files/mecab-0.996.tar.gz
  tar zxfv mecab-0.996.tar.gz
  cd mecab-0.996
  ./configure
  make
  sudo make install
 
  # load mecab.so
  sudo sh -c "echo '/usr/local/lib' >> /etc/ld.so.conf"
  sudo ldconfig
 
  # Install mecab-ipadic
  cd /var/tmp
  curl -O https://mecab.googlecode.com/files/mecab-ipadic-2.7.0-20070801.tar.gz
  tar zxfv mecab-ipadic-2.7.0-20070801.tar.gz
  cd mecab-ipadic-2.7.0-20070801
  ./configure --with-charset=utf8
  make
  sudo make install
fi
