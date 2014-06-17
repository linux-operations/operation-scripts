#!/bin/bash

# 安装redis的脚本

test -d redis && echo "redis exist, install abort." && exit -1
mkdir redis
cd redis

redis=redis-2.6.14

# 下载并解压缩
wget http://redis.googlecode.com/files/$redis.tar.gz
tar -xf $redis.tar.gz
rm -f $redis.tar.gz

# 编译
cd $redis
make
cd ..

# 修改配置文件
cp $redis/redis.conf .
sed -i 's/daemonize no/daemonize yes/' redis.conf
sed -i 's/pidfile .*/pidfile .\/redis.pid/' redis.conf

# 创建启动和停止文件
cat > start.sh << EOF
#!/bin/bash
./$redis/src/redis-server ./redis.conf
EOF
chmod +x start.sh

cat > stop.sh << EOF
kill \`cat redis.pid\`
EOF
chmod +x stop.sh
