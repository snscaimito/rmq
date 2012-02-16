Ruby Wrapper for MQ Series client API
=====================================
rmq wraps the C API for IBM MQ Series message broker.

* Don't forget to set the MQSERVER environment variable

Running Specs
=============
Specs can be run with 'rake spec'. Make sure the prerequisites are met.

Prerequisites
-------------

* IBM MQ Broker installed
* Local queue manager with name BKR_QMGR up and running
* Can connect to local broker SYSTEM.DEF.SVRCONN/TCP/127.0.0.1(1414)
