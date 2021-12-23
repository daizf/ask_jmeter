# 采用Docker方式测试
## 镜像构建
- 构建镜像
进入到docker目录根据Dockerfile构建镜像
```sh
cd docker/
docker build -t jmeter:5.4.2 .
```
## 单机模式
- 将test_plan/docker-test.jmx挂载到容器中

```sh
➜ mkdir /tmp/jmeter
➜ cp test/docker-test.jmx /tmp/jmeter
➜ docker run -it --rm -v /tmp/jmeter:/data jmeter:5.4.2 jmeter -n -t /data/docker-test.jmx -l /data/result.jlt -e -o /data/result
START Running Jmeter Server on Thu Dec 23 03:39:03 UTC 2021
JVM_ARGS=-Xmn66m -Xms264m -Xmx264m
Dec 23, 2021 3:39:05 AM java.util.prefs.FileSystemPreferences$1 run
INFO: Created user preferences directory.
Creating summariser <summary>
Created the tree successfully using /data/docker-test.jmx
Starting standalone test @ Thu Dec 23 03:39:06 UTC 2021 (1640230746227)
Waiting for possible Shutdown/StopTestNow/HeapDump/ThreadDump message on port 4445
summary =   5728 in 00:00:13 =  431.0/s Avg:   858 Min:    33 Max:  1966 Err:  2905 (50.72%)
Tidying up ...    @ Thu Dec 23 03:39:20 UTC 2021 (1640230760096)
... end of run
```
- 查看测试报告
```sh
➜ tree /tmp/jmeter -L 3
/tmp/jmeter
├── docker-test.jmx
├── result
│   ├── content
│   │   ├── css
│   │   ├── js
│   │   └── pages
│   ├── index.html
│   ├── sbadmin2-1.0.7
│   │   ├── README.md
│   │   ├── bower.json
│   │   ├── bower_components
│   │   ├── dist
│   │   └── less
│   └── statistics.json
└── result.jlt

9 directories, 6 files
```

## 集群模式（分布式）
- 创建3个JMeter Server作为施压机
```sh
➜  docker run -it -d --name server1 jmeter:5.4.2
➜  docker run -it -d --name server2 jmeter:5.4.2
➜  docker run -it -d --name server3 jmeter:5.4.2
```

- 获取JMeter Server容器列表(IP)
```sh
➜  docker inspect --format '{{ .Name }} => {{ .NetworkSettings.IPAddress }}'  $(docker ps -q)

/server3 => 172.17.0.4
/server2 => 172.17.0.3
/server1 => 172.17.0.2
```
  
- 执行如下命令将压测任务分发到上面的JMeter Server中
```sh
➜  mkdir /tmp/jmeter-cluster
➜  cp test/docker-test.jmx /tmp/jmeter-cluster/
➜  docker run -it --rm -v /tmp/jmeter-cluster:/data jmeter:5.4.2 jmeter -n -t /data/docker-test.jmx -l /data/result.jlt -e -o /data/result -R 172.17.0.2,172.17.0.3,172.17.0.4
START Running Jmeter Server on Thu Dec 23 03:49:42 UTC 2021
JVM_ARGS=-Xmn96m -Xms384m -Xmx384m
Dec 23, 2021 3:49:44 AM java.util.prefs.FileSystemPreferences$1 run
INFO: Created user preferences directory.
Creating summariser <summary>
Created the tree successfully using /data/docker-test.jmx
Configuring remote engine: 172.17.0.2
Configuring remote engine: 172.17.0.3
Configuring remote engine: 172.17.0.4
Starting distributed test with remote engines: [172.17.0.4, 172.17.0.2, 172.17.0.3] @ Thu Dec 23 03:49:45 UTC 2021 (1640231385905)
Remote engines have been started:[172.17.0.4, 172.17.0.2, 172.17.0.3]
Waiting for possible Shutdown/StopTestNow/HeapDump/ThreadDump message on port 4445
summary +   4203 in 00:00:13 =  332.4/s Avg:  1698 Min:    60 Max:  6629 Err:  3610 (85.89%) Active: 1469 Started: 1499 Finished: 30
summary +   1674 in 00:00:07 =  245.2/s Avg:  2685 Min:   162 Max:  6980 Err:  1456 (86.98%) Active: 0 Started: 1500 Finished: 1500
summary =   5877 in 00:00:19 =  301.8/s Avg:  1979 Min:    60 Max:  6980 Err:  5066 (86.20%)
Tidying up remote @ Thu Dec 23 03:50:06 UTC 2021 (1640231406963)
... end of run
```
- 查看测试报告
```sh
➜  tree /tmp/jmeter-cluster -L 3
/tmp/jmeter-cluster
├── docker-test.jmx
├── result
│   ├── content
│   │   ├── css
│   │   ├── js
│   │   └── pages
│   ├── index.html
│   ├── sbadmin2-1.0.7
│   │   ├── README.md
│   │   ├── bower.json
│   │   ├── bower_components
│   │   ├── dist
│   │   └── less
│   └── statistics.json
└── result.jlt

9 directories, 6 files
```

- 清理资源
```sh
➜  rm -rf /tmp/jmeter
➜  rm -rf /tmp/jmeter-cluster
➜  docker rm -f server1 server2 server3
```