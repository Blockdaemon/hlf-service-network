# hlf-service-network
Skeleton for building a simple Hyperledger Fabric service network

# Prerequisites
* Docker
* docker-compose
* GNU make
* curl
* Python3
* Python3 jinja2

## MacOS
* [Install docker](https://store.docker.com/editions/community/docker-ce-desktop-mac)
* Install other stuff:
```
brew install python3
pip3 install jinja2
```

## Ubuntu/Debian
* [Install docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository)
* Install other stuff:
```
apt-get install make curl
apt-get install python3-jinja2
```

# QUICKSTART
```
make
make run
```

# To clean up
```
make clean
```

# Overriding default config.env

You can put overrides in local.env

# References
See also [How to build your first Hyperledger fabric network](https://chainhero.io/2018/04/tutorial-hyperledger-fabric-how-to-build-your-first-network/)
