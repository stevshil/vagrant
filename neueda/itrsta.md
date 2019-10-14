# ITRS Trading Application
This document defines how to run the ITRS trading application all in one VM.

## Prerequisites
This VM requires Internet access to be able to install.

## Starting or building the VM
```
vagrant up itrsta
```

## Logging on to the VM
```
vagrant ssh itrsta
```

For Windows you will need to enable Putty or have Cygwin installed

## What is installed?
The system will have the following installed on completion;
* ITRS gateway and a netprobe
  * The gateway will be listening on port 55801
  * The 2 netprobes are on ports 55803
* MySQL client and Connector C for ITRS netprobe to communicate with MySQL
  * For checking anything on the MySQL docker container
* Java 1.8 openjdk
* itrs SVR4 start/stop script, this will stop or start both the gateway server and 2 netprobes
  * service itrs stop
  * service itrs start
* Docker
  * From docker itself, not the OS one
  * Adds the vagrant user to the docker group so containers can be controlled by the default user
* Compiled version of Martin Bond's trading Application
* A script to run the trading application

## Starting the trading application
Once Vagrant has completed the installation of the server you will need to do the following steps;
* Stop the VM
* bin/stoptimesync.sh ITRS
  * This script turns off the date/time sync between your computer and the VM, which is required to run the system when there is not a valid license.  The date in the VM should be set back to before October 2015
  * If you are using Windows you may want to run the command inside the script on the Command line, which will require knowing where the VBoxManage command is
* Start the VM
  * ```vagrant up itrsta```
* Log in to the VM
  * ```vagrant ssh itrsta```
* Start the trading applicaion so that the MySQL and ActiveMQ Docker containers are downloaded and running (this has to be done before changing the date, otherwise Docker won't pull the container images).
  * ```/opt/trade-app/runapp```
* While the App is up add the 2 queues to ActiveMQ
  * In a web browser enter into the address bar;
    * http://localhost:8161
    * Click on Manage ActiveMQ broker
    * Login using admin/admin
    * Click Queues at the top menu
    * Add the following queues;
      * tradeQueue
        * This queue may already be there
      * tradeTopic
* You should be able to check that the app is running by typing the following into your web browser;
  * http://localhost:8080/trades/list
* Shut down the VM
  * ```init 0```
* Start the VM
  * ```vagrant up itrsta```
* Log in to the VM
  * ```vagrant ssh itrsta```
* Stop ITRS
  * ```service itrs stop```
* Set the date back, e.g. to 6th July 2015 12:40
  * sudo date 070612402015
* Start ITRS
  * ```service itrs start```
* Start the trading application
  * ```/opt/trade-app/runapp```

ITRS server and the trading app should now be ready.

**NOTE:** After these steps you will only need to run the application if the VM is already built.  Steps to running the VM if you've shut it down;
* vagrant up itrsta
* vagrant ssh itrsta
* ifup enp0s8
* /opt/trade-app/runapp

## ITRS Desktop client
You should be able to run the ITRS Active Console either on your laptop using;
* localhost:55801

Or from a Windows VM with the Active Console where the VM should have a private network adapter attached to **intnet** and an IP address manually set to 192.168.1.100

**NOTE:** you may need to start the enp0s8 network interface on the itrsta VM (but only if you cannot see it with ifconfig);
* ```sudo ifup enp0s8```

If using a Windows VM then you will need to set your ITRS gateway configuration to;
* 192.168.1.200:55801

## What can I monitor
MySQL has been configured to work with ITRS as the Connector C library is installed and a symlink for libmysqlclient_r.so has been created in /usr/lib64.  This allows the SQL Toolkit to work.

The trading application has JMX expose as well as JSON REST APIs, see Martin's BitBucket repo for the API.

You should also be able to monitor MySQL and ActiveMQ since the containers will appear as native processes to the VM.

The application is started in /tmp/trade-app and a log file called trade-record.log can be monitored.  Since the App runs with a foreground process the terminal will need to remain open where the trade app runs from.

### Application URLs
* Trading statistics
  * http://localhost:8080/trades/stats
  * Output
    ```
    {"totalTrades":2,"activeTrades":2,"placedTrades":2,"cancelledTrades":0,"deniedTrades":0,"rejectedTrades":0,"settledTrades":0}
    ```
* List trades
  * http://localhost:8080/trades/list
  * Output
    ```
    [{"id":1,"transid":"2017010108030000000","stock":{"ticker":"FTSE.AA","symbol":null,"market":null,"description":null},"ptime":1483259400000,"price":297.0,"volume":2000,"buysell":"B","state":"P","stime":1483259400000},{"id":2,"transid":"2017010108030000001","stock":{"ticker":"NYSE.C","symbol":null,"market":null,"description":null},"ptime":1483259400000,"price":58.0,"volume":8000,"buysell":"S","state":"P","stime":1483259400000}]
    ```
* EOD reconciliation
  * http://localhost:8080/trades/reconcile
  * Output
    ```
    {"count":174}
    ```

### JMX Connection
service:jmx:rmi:///jndi/rmi://<TARGET_MACHINE>:<RMI_REGISTRY_PORT>/jmxrmi

Ref:
* https://docs.oracle.com/cd/E19717-01/819-7758/gcnqf/index.html
* http://activemq.apache.org/jmx.html
* https://resources.itrsgroup.com/docs/geneos/Netprobe/api/jmx-server.html

If you need a local JMX client;
* wget  http://crawler.archive.org/cmdline-jmxclient/cmdline-jmxclient-0.10.3.jar

Then create the following shell script;
```
#!/bin/bash

cmdLineJMXJar=./cmdline-jmxclient-0.10.3.jar
user=-
password=-
jmxHost=localhost
port=9990

#No User and password so pass '-'
echo "Available Operations for com.neueda.trade.jmx:name=TradeStats"
java -jar ${cmdLineJMXJar} ${user}:${password} ${jmxHost}:${port} com.neueda.trade.jmx:name=TradeStats

echo "Executing XML update..."
java -jar ${cmdLineJMXJar} - ${jmxHost}:${port} com.neueda.trade.jmx:name=TradeStats ActiveTrades
```

From the **TradeStats** you have the following Attributes;
* ActiveTrades
* CancelledTrades
* DeniedTrades
* PlacedTrades
* RejectedTrades
* SettledTrades
* TotalTrades

#### Some JMX Gateway configuration
These settings only need to be done if not using Vagrant to install ITRS Geneos;

##### Enabling the netprobe to use JMX
For JMX to work the Netprobe must know where the JRE is so you will need to set JAVA_HOME;
export JAVA_HOME=/usr/lib/jvm/jre

You may also need to locate and link the following 2 files into the Netprobe directory (done by Vagrant automatically);
* libjvm.so
* tzdb.dat

![ITRS JMX configuration](pix/JMX-Config.png)

Values;
* serviceURL = service:jmx:rmi:///jndi/rmi://localhost:9990/jmxrmi
* Aliases
  * Name = $1
  * Value = com.neueda.trade.jmx:name=TradeStats
* Options/columns
  * Label = ActiveTrades
  * Row Template = $1.ActiveTrades

### Upgraded ITRS Netprobe;
If you have the latest ITRS netprobe then you can use the geneos-plugins.jar to test if ITRS is capable of retrieving your JMX attributes.
```
java -jar geneos-plugins.jar jmx Generic rmi:///jndi/rmi localhost 9990 4000 jmxrmi com.neueda.trade.jmx:name=TradeStats
```
The above command can be run inside the netprobe installation directory.

## Cloning
Once the VM has been created through Vagrant once you can then export the VM so that it can be used on other systems through VirtualBox, or even VMWare Player.

### Step for exporting;
* Click file
* Select Export Appliance
* Select the NeuedaC VM name
* Click Next
* Set the location of where you want the file to be created
* Click Next
* Click Export

Once the export process has finished go to the directory you specified above, and you should see the OVA file.  Copy this file to your USB drive and on to the other PCs.

Using VirtualBox management interface;
* Click file
* Select Import Appliance
* Locate the OVA file you have copied to the new PC
* Click Next

### Alternate method
If you know where VirtualBox stores the VM files (this would be a folder containing the configuration file and the virtual disk file) then you can simply copy that folder to a USB pen drive and then onto the students systems.

However, the student will have to make some changes through the VirtualBox interface to enable the disk to be used, so less convenient than the exporting.
